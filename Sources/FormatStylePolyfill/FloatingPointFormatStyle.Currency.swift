import struct Foundation.Locale

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FloatingPointFormatStyle {
    /// A format style that converts between floating-point currency values and their textual representations.
    public struct Currency: Codable, Hashable, Sendable {
        var collection: _polyfill_FloatingPointFormatStyle.Currency.Configuration.Collection
        
        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale
        
        /// The currency code this format style uses.
        public let currencyCode: String

        /// The type the format style uses for configuration settings.
        public typealias Configuration = _polyfill_CurrencyFormatStyleConfiguration
        
        /// Creates a floating-point currency format style that uses the given currency code and locale.
        ///
        /// - Parameters:
        ///   - code: The currency code to use, such as `EUR` or `JPY`.
        ///   - locale: The locale to use when formatting or parsing floating-point values.
        ///     Defaults to `autoupdatingCurrent`.
        public init(code: String, locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
            self.currencyCode = code
            self.collection = .init(presentation: .standard)
        }

        /// An attributed format style based on the floating-point currency format style.
        ///
        /// Use this modifier to create a `FloatingPointFormatStyle.Attributed` instance, which formats `value`
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes
        /// to determine which runs of the attributed string represent different parts of the formatted value.
        public var attributed: _polyfill_FloatingPointFormatStyle.Attributed {
            .init(style: self)
        }

        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: A floating-point currency format style modified to use the specified grouping.
        public func grouping(_ group: Configuration.Grouping) -> Self {
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
        public func precision(_ p: Configuration.Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: A floating-point format style modified to use the specified sign display strategy.
        public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: A floating-point currency format style modified to use the specified decimal
        ///   separator display strategy.
        public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
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
        public func rounded(
            rule: Configuration.RoundingRule = .toNearestOrEven,
            increment: Double? = nil
        ) -> Self {
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

        /// Modifies the format style to use the specified presentation.
        ///
        /// - Parameters p: A currency presentation value, such as `isoCode` or `fullName`.
        /// - Returns: A floating-point currency format style modified to use the specified presentation.
        public func presentation(_ p: Configuration.Presentation) -> Self {
            var new = self
            new.collection.presentation = p
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FloatingPointFormatStyle.Currency: _polyfill_FormatStyle {
    /// Formats a floating-point value, using this style.
    ///
    /// Use this method when you want to create a single style instance, and then use it to format
    /// multiple floating-point values. To format a single value, use the `BinaryFloatingPoint` instance
    /// method `formatted(_:)`, passing in an instance of `FloatingPointFormatStyle.Currency`.
    ///
    /// - Parameter value: The floating-point value to format.
    /// - Returns: A string representation of `value`, formatted according to the style’s configuration.
    public func format(_ value: Value) -> String {
        if let nf = ICUCurrencyNumberFormatter.create(for: self), let str = nf.format(Double(value)) {
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
    /// - Returns: A floating-point currency format style with the provided locale.
    public func locale(_ locale: Locale) -> _polyfill_FloatingPointFormatStyle.Currency {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension _polyfill_FormatStyle {
    /// Returns a format style to use floating-point currency notation.
    ///
    /// Use the dot-notation form of this method when the call point allows the use of `FloatingPointFormatStyle`.
    /// You typically do this when calling the `formatted` methods of types that conform to `BinaryFloatingPoint`.
    ///
    /// The following example creates an array of doubles, then uses `formatted(_:)` and the currency style
    /// provided by this method to format the doubles as US dollars.
    ///
    /// ```swift
    /// let nums: [Double] = [100.01, 1000.02, 10000.03, 100000.04, 1000000.05]
    /// let currencyNums = nums.map { $0.formatted(
    ///     .currency(code: "USD"))
    /// } // ["$100.01", "$1,000.02", "$10,000.03", "$100,000.04", "$1,000,000.05"]
    /// ```
    ///
    /// - Parameter code: The currency code to use, such as `EUR` or `JPY`. See ISO-4217 for a list of valid codes.
    /// - Returns: An floating-point format style that uses the specified currency code.
    public static func currency<V>(code: String) -> Self where Self == _polyfill_FloatingPointFormatStyle<V>.Currency { .init(code: code) }
}
