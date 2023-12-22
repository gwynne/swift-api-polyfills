import struct Foundation.Locale

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FloatingPointFormatStyle {
    /// A format style that converts between floating-point percentage values and their textual representations.
    public struct _polyfill_Percent: Codable, Hashable, Sendable {
        /// The type the format style uses for configuration settings.
        public typealias _polyfill_Configuration = _polyfill_NumberFormatStyleConfiguration

        /// Actual configuration storage.
        var collection: _polyfill_Configuration.Collection = .init(scale: 100)

        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale

        /// Creates a floating-point percent format style that uses the given locale.
        ///
        /// - Parameter locale: The locale to use when formatting or parsing floating-point values.
        ///   Defaults to `autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

        /// An attributed format style based on the floating-point percent format style.
        ///
        /// Use this modifier to create an `FloatingPointFormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
        /// determine which runs of the attributed string represent different parts of the formatted value.
        public var attributed: _polyfill_FloatingPointFormatStyle._polyfill_Attributed { .init(style: self) }

        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: A floating-point percent format style modified to use the specified grouping.
        public func grouping(_ group: _polyfill_Configuration._polyfill_Grouping) -> Self {
            var new = self
            new.collection.group = group
            return new
        }

        /// Modifies the format style to use the specified precision.
        ///
        /// The `NumberFormatStyleConfiguration.Precision` type lets you specify a fixed number of digits to
        /// show for a number’s integer and fractional part. You can also set a fixed number of
        /// significant digits.
        ///
        /// - Parameter p: The precision to apply to the format style.
        /// - Returns: A floating-point format style modified to use the specified precision.
        public func precision(_ p: _polyfill_Configuration._polyfill_Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: A floating-point format style modified to use the specified sign display strategy.
        public func sign(strategy: _polyfill_Configuration._polyfill_SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: A floating-point percent format style modified to use the specified decimal
        ///   separator display strategy.
        public func decimalSeparator(strategy: _polyfill_Configuration._polyfill_DecimalSeparatorDisplayStrategy) -> Self {
            var new = self
            new.collection.decimalSeparatorStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified rounding rule and increment.
        ///
        /// - Parameter rule: The rounding rule to apply to the format style.
        /// - Parameter increment: A multiple by which the formatter rounds the fractional part. The formatter
        ///   produces a value that’s an even multiple of this increment. If this parameter is `nil` (the
        ///   default), the formatter doesn’t apply an increment.
        /// - Returns: A floating-point currency format style modified to use the specified rounding
        ///   rule and increment.
        public func rounded(rule: _polyfill_Configuration._polyfill_RoundingRule = .toNearestOrEven, increment: Double? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment = increment {
                new.collection.roundingIncrement = .floatingPoint(value: increment)
            }
            return new
        }

        /// Modifies the format style to use the specified scale.
        ///
        /// - Parameter multiplicand: The multiplicand to apply to the format style.
        /// - Returns: A floating-point format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }

        /// Modifies the format style to use the specified notation.
        ///
        /// - Parameter notation: The notation to apply to the format style.
        /// - Returns: A floating-point percent format style modified to use the specified notation.
        public func notation(_ notation: _polyfill_Configuration._polyfill_Notation) -> Self {
            var new = self
            new.collection.notation = notation
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FloatingPointFormatStyle._polyfill_Percent: _polyfill_FormatStyle {
    /// Formats a floating-point value, using this style.
    ///
    /// Use this method when you want to create a single style instance, and then use it to format
    /// multiple floating-point values. To format a single value, use the `BinaryFloatingPoint` instance
    /// method `formatted(_:)`, passing in an instance of `FloatingPointFormatStyle.Percent`.
    ///
    /// - Parameter value: The floating-point value to format.
    /// - Returns: A string representation of `value`, formatted according to the style’s configuration.
    public func format(_ value: Value) -> String {
        if let nf = ICUPercentNumberFormatter.create(for: self), let str = nf.format(Double(value)) {
            return str
        }
        return String(Double(value))
    }

    /// Modifies the format style to use the specified locale.
    ///
    /// Use this format style to change the locale used by an existing format style. To instead determine
    /// the locale used by this format style, use the `locale` property.
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: A floating-point percent format style with the provided locale.
    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FormatStyle where Self == _polyfill_FloatingPointFormatStyle<Double>._polyfill_Percent {
    /// An integer percent format style instance for use with Swift’s double-precision floating-point type.
    public static var percent: Self { .init() }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FormatStyle where Self == _polyfill_FloatingPointFormatStyle<Float>._polyfill_Percent {
    /// An integer percent format style instance for use with Swift’s single-precision floating-point type.
    public static var percent: Self { .init() }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension _polyfill_FloatingPointFormatStyle._polyfill_Percent: CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This type is the generic constraint `Value`, which is a type that conforms to `BinaryFloatingPoint`.
    public typealias RegexOutput = Value

    /// Process the input string within the specified bounds, beginning at the given index, and
    /// return the end position (upper bound) of the match and the produced output.
    ///
    /// - Parameters:
    ///   - input: An input string to match against.
    ///   - index: The index within `input` at which to begin searching.
    ///   - bounds: The bounds within `input` in which to search.
    /// - Returns: The upper bound where the match terminates and a matched instance, or `nil`
    ///   if there isn’t a match.
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Value)? {
        //FloatingPointParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == _polyfill_FloatingPointFormatStyle<Double>._polyfill_Percent {
    /// Creates a regex component to match a localized string representing a percentage and capture it as a `Double`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized percentage string.
    public static func localizedDoublePercentage(locale: Locale) -> Self { .init(locale: locale) }
}