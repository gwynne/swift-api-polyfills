import Numerics

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.BinaryInteger {
    /// Format `self` using `IntegerFormatStyle`
    public func _polyfill_formatted() -> String {
        _polyfill_IntegerFormatStyle().format(self)
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, Self == S.FormatInput {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput: BinaryInteger {
        format.format(S.FormatInput(self))
    }

}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.BinaryFloatingPoint {
    /// Format `self` with `FloatingPointFormatStyle`.
    public func _polyfill_formatted() -> String {
        _polyfill_FloatingPointFormatStyle().format(self)
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, Self == S.FormatInput {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(self))
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension BinaryInteger {
    /// Formats `self` in "Numeric string" format (https://speleotrove.com/decimal/daconvs.html)
    /// which is the required input form for certain ICU functions (e.g. `unum_formatDecimal`).
    ///
    /// This produces output that (at time of writing) looks identical to the `description` for
    /// many `BinaryInteger` types, such as the built-in integer types.  However, the format of
    /// `description` is not specifically defined by `BinaryInteger` (or anywhere else, really),
    /// and as such cannot be relied upon.  Thus this purpose-built method, instead.
    ///
    internal var numericStringRepresentation: String {
        withUnsafeTemporaryAllocation(of: UInt.self, capacity: self.words.count) {
            let initializedEndIndex = $0.initialize(fromContentsOf: self.words)
            let initialized = UnsafeMutableBufferPointer(rebasing: $0[..<initializedEndIndex])
            defer { initialized.deinitialize() }
            
            return numericStringRepresentationForWords(initialized, isSigned: Self.isSigned)
        }
    }
}

/// Formats `words` in "Numeric string" format (https://speleotrove.com/decimal/daconvs.html)
/// which is the required input form for certain ICU functions (e.g. `unum_formatDecimal`).
///
/// - Parameters:
///   - words: The binary integer's mutable words.
///   - isSigned: The binary integer's signedness.
///
/// This method consumes the `words` such that the buffer is filled with zeros when it returns.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
private func numericStringRepresentationForWords(_ words: UnsafeMutableBufferPointer<UInt>, isSigned: Bool) -> String {
    var magnitude = words
    let isLessThanZero = isSigned && Int(bitPattern: magnitude.last ?? .zero) < .zero
    if  isLessThanZero { formTwosComplementForBinaryInteger(words: magnitude) }
    
    let capacity = maxDecimalDigitCountForUnsignedInteger(bitWidth: magnitude.count * UInt.bitWidth) + (isLessThanZero ? 1 : 0)
    return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) {
        let ascii = UnsafeMutableBufferPointer(start: $0.baseAddress, count: capacity)
        ascii.initialize(repeating: UInt8(ascii: "0"))
        defer { ascii.deinitialize() }
        let radix: (exponent: Int, power: UInt) = maxDecimalExponentAndPowerForUnsignedIntegerWord()
        var writeIndex = ascii.endIndex
        
        dividing: while true {
            var chunk = formQuotientWithRemainderForUnsignedInteger(words: magnitude, dividingBy: radix.power)
            magnitude = .init(rebasing: magnitude[..<magnitude[...].reversed().drop(while:{ $0 == .zero }).startIndex.base])
            repeat {
                let digit: UInt
                (chunk, digit) = chunk.quotientAndRemainder(dividingBy: 10)
                ascii.formIndex(before: &writeIndex)
                ascii[writeIndex] = UInt8(ascii: "0") &+ UInt8(truncatingIfNeeded: digit)
            } while chunk != .zero
            if magnitude.isEmpty { break }
            writeIndex = ascii.index(writeIndex, offsetBy: -radix.exponent)
        }
        if isLessThanZero {
            ascii.formIndex(before: &writeIndex)
            ascii[writeIndex] = UInt8(ascii: "-")
        }
        let result = UnsafeBufferPointer(rebasing: ascii[writeIndex...])
        return String(unsafeUninitializedCapacity: result.count) {
            _ = $0.initialize(fromContentsOf: result)
            return result.count
        }
    }
}

/// Returns an upper bound for the [number of decimal digits][algorithm] needed
/// to represent an unsigned integer with the given `bitWidth`.
///
/// [algorithm]: https://www.exploringbinary.com/number-of-decimal-digits-in-a-binary-integer
///
/// - Parameter bitWidth: An unsigned binary integer's bit width. It must be non-negative.
/// - Returns: Some integer greater than or equal to `1`.
private func maxDecimalDigitCountForUnsignedInteger(bitWidth: Int) -> Int {
    .init(Double(exactly: bitWidth)! * Double.log10(2.0).nextUp) + 1
}

/// Returns the largest `exponent` and `power` in `pow(10, exponent) <= UInt.max + 1`.
///
/// The `exponent` is also the maximum number of decimal digits needed to represent a binary integer
/// in the range of `0 ..< power`. Another method is used to estimate the total number of digits, however.
/// This is so that binary integers can be rabased and encoded in the same loop.
///
/// ```
/// 32-bit: (exponent:  9, power:           1000000000)
/// 64-bit: (exponent: 19, power: 10000000000000000000)
/// ```
///
/// - Note: The optimizer should inline this as a constant.
///
/// - Note: Dividing an integer by `power` yields the first `exponent` number of decimal digits in the
///   remainder. The quotient is the integer with its first `exponent` number of decimal digits removed.
private func maxDecimalExponentAndPowerForUnsignedIntegerWord() -> (exponent: Int, power: UInt) {
    var exponent: Int = 1, power: UInt = 10
    
    while true {
        let next = power.multipliedReportingOverflow(by: 10)
        if next.overflow { break }
        exponent += 1
        power = next.partialValue
    }
    return (exponent: exponent, power: power)
}

/// Forms the `two's complement` of a binary integer.
///
/// - Parameter words: A binary integer's mutable words.
private func formTwosComplementForBinaryInteger(words: UnsafeMutableBufferPointer<UInt>) {
    var carry = true
    
    for index in words.indices {
        (words[index], carry) = (~words[index]).addingReportingOverflow(carry ? 1 : 0)
    }
}

/// Forms the `quotient` of dividing the `dividend` by the `divisor`, then returns the `remainder`.
///
/// - Parameters:
///   - dividend: An unsigned binary integer's words. It becomes the `quotient` once this function returns.
///   - divisor:  An unsigned binary integer's only word.
/// - Returns: The `remainder`, which is a value in the range of `0 ..< divisor`.
private func formQuotientWithRemainderForUnsignedInteger(words dividend: UnsafeMutableBufferPointer<UInt>, dividingBy divisor: UInt) -> UInt {
    var remainder = UInt.zero
    
    for index in dividend.indices.reversed() {
        (dividend[index], remainder) = divisor.dividingFullWidth((high: remainder, low: dividend[index]))
    }
    return remainder
}
