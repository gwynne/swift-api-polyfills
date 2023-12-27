import Numerics
import struct Foundation.Locale
import struct Foundation.Decimal
import struct Foundation.AttributedString

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct _polyfill_IntegerFormatStyle<Value: BinaryInteger>: Codable, Hashable, Sendable {
    public typealias Configuration = _polyfill_NumberFormatStyleConfiguration

    public var locale: Locale
    
    var collection: Configuration.Collection = Configuration.Collection()

    public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

    public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }

    public func grouping(_ group: Configuration.Grouping) -> Self {
        var new = self
        new.collection.group = group
        return new
    }

    public func precision(_ p: Configuration.Precision) -> Self {
        var new = self
        new.collection.precision = p
        return new
    }

    public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
        var new = self
        new.collection.signDisplayStrategy = strategy
        return new
    }

    public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
        var new = self
        new.collection.decimalSeparatorStrategy = strategy
        return new
    }

    public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
        var new = self
        new.collection.rounding = rule
        if let increment { new.collection.roundingIncrement = .integer(value: increment) }
        return new
    }

    public func scale(_ multiplicand: Double) -> Self {
        var new = self
        new.collection.scale = multiplicand
        return new
    }

    public func notation(_ notation: Configuration.Notation) -> Self {
        var new = self
        new.collection.notation = notation
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_IntegerFormatStyle {
    public struct Percent: Codable, Hashable, Sendable {
        public typealias Configuration = _polyfill_NumberFormatStyleConfiguration

        public var locale: Locale

        var collection: Configuration.Collection = Configuration.Collection(scale: 1)

        public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

        public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }

        public func grouping(_ group: Configuration.Grouping) -> Self {
            var new = self
            new.collection.group = group
            return new
        }

        public func precision(_ p: Configuration.Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
            var new = self
            new.collection.decimalSeparatorStrategy = strategy
            return new
        }

        public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment = increment {
                new.collection.roundingIncrement = .integer(value: increment)
            }
            return new
        }

        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }

        public func notation(_ notation: Configuration.Notation) -> Self {
            var new = self
            new.collection.notation = notation
            return new
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public struct Currency: Codable, Hashable, Sendable {
        public typealias Configuration = _polyfill_CurrencyFormatStyleConfiguration

        public var locale: Locale
        public let currencyCode: String

        var collection: Configuration.Collection
        
        public init(code: String, locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
            self.currencyCode = code
            self.collection = Configuration.Collection(presentation: .standard)
        }

        public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }

        public func grouping(_ group: Configuration.Grouping) -> Self {
            var new = self
            new.collection.group = group
            return new
        }

        public func precision(_ p: Configuration.Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
            var new = self
            new.collection.decimalSeparatorStrategy = strategy
            return new
        }

        public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment { new.collection.roundingIncrement = .integer(value: increment) }
            return new
        }

        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }

        public func presentation(_ p: Configuration.Presentation) -> Self {
            var new = self
            new.collection.presentation = p
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_IntegerFormatStyle: _polyfill_FormatStyle {
    /// Returns a localized string for the given value. Supports up to 64-bit signed integer precision.
    /// Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized string for the given value.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func format(_ value: Value) -> String {
        if let nf = ICUNumberFormatter.create(for: self) {
            let str: String?
            
            if let i = Int64(exactly: value) { str = nf.format(i) }
            else if let decimal = Decimal(exactly: value) { str = nf.format(decimal) }
            else { str = nf.format(value.numericStringRepresentation) }

            if let str { return str }
        }
        return String(value)
    }

    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_IntegerFormatStyle.Percent: _polyfill_FormatStyle {
    /// Returns a localized string for the given value in percentage. Supports up to 64-bit signed
    /// integer precision. Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized string for the given value in percentage.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func format(_ value: Value) -> String {
        if let nf = ICUPercentNumberFormatter.create(for: self) {
            let str: String?

            if let i = Int64(exactly: value) { str = nf.format(i) }
            else if let decimal = Decimal(exactly: value) { str = nf.format(decimal) }
            else { str = nf.format(value.numericStringRepresentation) }
            
            if let str { return str }
        }
        return String(value)
    }

    public func locale(_ locale: Locale) -> _polyfill_IntegerFormatStyle.Percent {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_IntegerFormatStyle.Currency: _polyfill_FormatStyle {
    /// Returns a localized currency string for the given value. Supports up to 64-bit signed
    /// integer precision. Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized currency string for the given value.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func format(_ value: Value) -> String {
        if let nf = ICUCurrencyNumberFormatter.create(for: self) {
            let str: String?

            if let i = Int64(exactly: value) { str = nf.format(i) }
            else if let decimal = Decimal(exactly: value) { str = nf.format(decimal) }
            else { str = nf.format(value.numericStringRepresentation) }

            if let str { return str }
        }
        return String(value)
    }

    public func locale(_ locale: Locale) -> _polyfill_IntegerFormatStyle.Currency {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int>    { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int16>  { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int32>  { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int64>  { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int8>   { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt>   { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt16> { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt32> { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt64> { public static var number: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt8>  { public static var number: Self { .init() } }

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int>.Percent    { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int16>.Percent  { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int32>.Percent  { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int64>.Percent  { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int8>.Percent   { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt>.Percent   { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt16>.Percent { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt32>.Percent { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt64>.Percent { public static var percent: Self { .init() } }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt8>.Percent  { public static var percent: Self { .init() } }

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle {
    public static func currency<V: BinaryInteger>(code: String) -> Self where Self == _polyfill_IntegerFormatStyle<V>.Currency {
        .init(code: code)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_IntegerFormatStyle {
    public struct Attributed: Codable, Hashable, _polyfill_FormatStyle, Sendable {
        enum Style: Codable, Hashable {
            case integer(_polyfill_IntegerFormatStyle)
            case percent(_polyfill_IntegerFormatStyle.Percent)
            case currency(_polyfill_IntegerFormatStyle.Currency)
        }

        var style: Style

        init(style: _polyfill_IntegerFormatStyle) { self.style = .integer(style) }
        init(style: _polyfill_IntegerFormatStyle.Percent) { self.style = .percent(style) }
        init(style: _polyfill_IntegerFormatStyle.Currency) { self.style = .currency(style) }

        /// Returns an attributed string with `NumberFormatAttributes.SymbolAttribute` and
        /// `NumberFormatAttributes.NumberPartAttribute`. Values not representable by `Int64` are clamped.
        ///
        /// - Parameter value: The value to be formatted.
        /// - Returns: A localized attributed string for the given value.
        public func format(_ value: Value) -> Foundation.AttributedString {
            let nValue: ICUNumberFormatterBase.Value =
                Int64(exactly: value).map              { .integer($0) } ??
                Foundation.Decimal(exactly: value).map { .decimal($0) } ??
                .integer(Int64(clamping: value))

            return switch style {
            case .integer(let style):  ICUNumberFormatter.create(for: style)?.attributedFormat(nValue)         ?? .init(.init(value))
            case .currency(let style): ICUCurrencyNumberFormatter.create(for: style)?.attributedFormat(nValue) ?? .init(.init(value))
            case .percent(let style):  ICUPercentNumberFormatter.create(for: style)?.attributedFormat(nValue)  ?? .init(.init(value))
            }
        }

        public func locale(_ locale: Locale) -> Self {
            switch style {
            case .integer(let style): .init(style: style.locale(locale))
            case .currency(let style): .init(style: style.locale(locale))
            case .percent(let style): .init(style: style.locale(locale))
            }
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.BinaryInteger {
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
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
package func numericStringRepresentationForWords(_ magnitude: inout Array<UInt>, isSigned: Bool) -> String {
    let isLessThanZero = isSigned && Int(bitPattern: magnitude.last!) < .zero

    if isLessThanZero {
        var carry = true
        for i in magnitude.indices { (magnitude[i], carry) = (~magnitude[i]).addingReportingOverflow(carry ? 1 : 0) }
    }
    return withUnsafeTemporaryAllocation(
        of: UInt8.self,
        capacity: Int(Double(exactly: magnitude.count * UInt.bitWidth)! * Double.log10(2.0).nextUp) + (isLessThanZero ? 2 : 1)
    ) { ascii in
        ascii.initialize(repeating: UInt8(ascii: "0")); defer { ascii.deinitialize() }
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

/// Forms the `quotient` of dividing the `dividend` by the maximum decimal power, then returns the `remainder`.
///
/// - Parameters:
///   - dividend: An unsigned binary integer's words. It becomes the `quotient` once this function returns.
/// - Returns: The `remainder`, which is a value in the range of `0 ..< divisor`.
private func formQuotientWithRemainder(words dividend: inout Array<UInt>) -> UInt {
    var remainder = UInt.zero
    for i in dividend.indices.reversed() { (dividend[i], remainder) = (10_000_000_000_000_000_000 as UInt).dividingFullWidth((high: remainder, low: dividend[i])) }
    return remainder
}
