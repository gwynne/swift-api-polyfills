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

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension _polyfill_IntegerFormatStyle: CustomConsumingRegexComponent {
    public typealias RegexOutput = Value
    
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        //IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension _polyfill_IntegerFormatStyle.Percent: CustomConsumingRegexComponent {
    public typealias RegexOutput = Value

    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        //IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension _polyfill_IntegerFormatStyle.Currency: CustomConsumingRegexComponent {
    public typealias RegexOutput = Value
    
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        //IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int> {
    /// Creates a regex component to match a localized integer string and capture it as a `Int`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized integer string.
    public static func localizedInteger(locale: Locale) -> Self { .init(locale: locale) }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int>.Percent {
    /// Creates a regex component to match a localized string representing a percentage and capture it as a `Int`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized string representing a percentage.
    public static func localizedIntegerPercentage(locale: Locale) -> Self { .init(locale: locale) }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int>.Currency {
    /// Creates a regex component to match a localized currency string and capture it as a `Int`.
    /// For example, `localizedIntegerCurrency(code: "USD", locale: Locale(identifier: "en_US"))`
    /// matches "$52,249" and captures it as 52249.
    ///
    /// - Parameters:
    ///   - code: The currency code of the currency symbol or name in the string.
    ///   - locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized currency string.
    public static func localizedIntegerCurrency(code: Locale.Currency, locale: Locale) -> Self { .init(code: code.identifier, locale: locale) }
}
