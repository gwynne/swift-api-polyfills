import Numerics
import CLegacyLibICU
import enum Foundation.AttributeScopes
import struct Foundation.CocoaError
import struct Foundation.Decimal
import let Foundation.NSDebugDescriptionErrorKey

func parseError(_ value: String, examples: String?...) -> Foundation.CocoaError {
    var dict: [String: Any] = [:]
    var desc = "Cannot parse \(value)."
    
    if !examples.compactMap({ $0 }).isEmpty {
        desc += " String should adhere to the preferred format of the locale, such as "
        desc += examples.compactMap { $0 }._polyfill_formatted(.list(type: .or, width: .standard))
        desc += "."
    }
    dict[NSDebugDescriptionErrorKey] = desc
    return .init(.formatting, userInfo: dict)
}

extension Swift.RangeExpression {
    func clampedLowerAndUpperBounds(_ boundary: Range<Int>) -> (lower: Int?, upper: Int?) {
        var lower: Int?, upper: Int?
        
        switch self {
        /// `lower ..< upper`
        case let self as Range<Int>:
            let clamped = self.clamped(to: boundary)

            (lower, upper) = (clamped.lowerBound, clamped.upperBound)
        /// `lower ... upper`
        case let self as ClosedRange<Int>:
            let clamped = self.clamped(to: ClosedRange(boundary))

            (lower, upper) = (clamped.lowerBound, clamped.upperBound)
        /// `lower...`
        case let self as PartialRangeFrom<Int>:
            (lower, upper) = (Swift.max(self.lowerBound, boundary.lowerBound), nil)
        /// `...upper`
        case let self as PartialRangeThrough<Int>:
            (lower, upper) = (nil, Swift.min(self.upperBound, boundary.upperBound))
        /// `..<upper`
        case let self as PartialRangeUpTo<Int>:
            let (val, overflow) = self.upperBound.subtractingReportingOverflow(1)

            (lower, upper) = (nil, Swift.min(overflow ? self.upperBound : val, boundary.upperBound))
        default:
            (lower, upper) = (nil, nil)
        }
        return (
            lower: lower.map { Swift.min($0, boundary.upperBound) },
            upper: upper.map { Swift.max($0, boundary.lowerBound) }
        )
    }
}

extension String {
    func asDateFormatLiteral() -> String {
        self.contains { $0 != "'" } ?
            "'\(self.replacing("'", with: "''"))'" :
            "'".repeated(2 * self.count)
    }
}

extension Foundation.Decimal {
    private subscript(index: UInt32) -> UInt16 {
        switch index {
        case 0: self._mantissa.0
        case 1: self._mantissa.1
        case 2: self._mantissa.2
        case 3: self._mantissa.3
        case 4: self._mantissa.4
        case 5: self._mantissa.5
        case 6: self._mantissa.6
        case 7: self._mantissa.7
        default: fatalError("Invalid index \(index) for _mantissa")
        }
    }

    var doubleValue: Double {
        if self._length == 0 {
            return self._isNegative == 1 ? Double.nan : 0
        }
        
        var d = 0.0
        
        for idx in (0 ..< Swift.min(self._length, 8)).reversed() {
            d = Double(self[idx]).addingProduct(d, 65536)
        }
        
        if self._exponent < 0 {
            d /= pow(10.0, Double(-self._exponent))
        } else {
            d *= pow(10.0, Double(self._exponent))
        }
        
        return self._isNegative != 0 ? -d : d
    }
}

extension BinaryInteger {
    /// Formats `self` in "Numeric string" format (https://speleotrove.com/decimal/daconvs.html)
    /// which is the required input form for certain ICU functions (e.g. `unum_formatDecimal`).
    ///
    /// This produces output that (at time of writing) looks identical to the `description` for
    /// many `BinaryInteger` types, such as the built-in integer types.  However, the format of
    /// `description` is not specifically defined by `BinaryInteger` (or anywhere else, really),
    /// and as such cannot be relied upon.  Thus this purpose-built method, instead.
    ///
    package var numericStringRepresentation: String {
        var words = Array(self.words)
        return numericStringRepresentationForWords(&words, isSigned: Self.isSigned)
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
package func numericStringRepresentationForWords(_ magnitude: inout Array<UInt>, isSigned: Bool) -> String {
    /// Forms the `quotient` of dividing the `dividend` by the maximum decimal power, then returns the `remainder`.
    ///
    /// - Parameters:
    ///   - dividend: An unsigned binary integer's words. It becomes the `quotient` once this function returns.
    /// - Returns: The `remainder`, which is a value in the range of `0 ..< divisor`.
    func formQuotientWithRemainder(words dividend: inout Array<UInt>) -> UInt {
        var remainder = UInt.zero
        for i in dividend.indices.reversed() {
            (dividend[i], remainder) = (10_000_000_000_000_000_000 as UInt).dividingFullWidth((high: remainder, low: dividend[i]))
        }
        return remainder
    }
    
    let isLessThanZero = isSigned && Int(bitPattern: magnitude.last!) < .zero

    if isLessThanZero {
        var carry = true
        
        for i in magnitude.indices {
            (magnitude[i], carry) = (~magnitude[i]).addingReportingOverflow(carry ? 1 : 0)
        }
    }
    return withUnsafeTemporaryAllocation(
        of: UInt8.self,
        capacity: Int(Double(exactly: magnitude.count * UInt.bitWidth)! * Double.log10(2.0).nextUp) + (isLessThanZero ? 2 : 1)
    ) { ascii in
        ascii.initialize(repeating: UInt8(ascii: "0"))
        
        var writeIndex = ascii.endIndex, chunkIndex = writeIndex
        
        while true {
            var chunk = formQuotientWithRemainder(words: &magnitude)
            magnitude = .init(magnitude[..<magnitude[...].reversed().drop { $0 == .zero }.startIndex.base])
            repeat {
                let digit: UInt
                (chunk, digit) = chunk.quotientAndRemainder(dividingBy: 10)
                ascii.formIndex(before: &writeIndex)
                ascii[writeIndex] = UInt8(ascii: "0") &+ UInt8(truncatingIfNeeded: digit)
            } while chunk != .zero
            if magnitude.isEmpty { break }
            chunkIndex = ascii.index(chunkIndex, offsetBy: -19)
            writeIndex = chunkIndex
        }
        if isLessThanZero {
            ascii.formIndex(before: &writeIndex)
            ascii[writeIndex] = UInt8(ascii: "-")
        }
        return .init(decoding: ascii[writeIndex...], as: Unicode.ASCII.self)
    }
}
