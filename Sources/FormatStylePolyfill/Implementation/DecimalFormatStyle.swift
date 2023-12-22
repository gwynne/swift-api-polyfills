import Foundation
import CLegacyLibICU

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension Foundation.Decimal {
    /// A structure that converts between decimal values and their textual representations.
    ///
    /// Instances of `Decimal.FormatStyle` create localized, human-readable text from `Decimal` numbers
    /// and parse string representations of numbers into instances of `Decimal`.
    ///
    /// `Decimal.FormatStyle` includes two nested types, `Decimal.FormatStyle.Percent` and
    /// `Decimal.FormatStyle.Currency`, for working with percentages and currencies, respectively. Each format
    /// style includes a configuration that determines how it represents numeric values, for things like
    /// grouping, displaying signs, and variant presentations like scientific notation. `Decimal.FormatStyle`
    /// and `Decimal.FormatStyle.Percent` include a `NumberFormatStyleConfiguration`, and
    /// `Decimal.FormatStyle.Currency` includes a `CurrencyFormatStyleConfiguration`. You can customize numeric
    /// formatting for a style by adjusting its backing configuration. The system automatically caches unique
    /// configurations of a format style to enhance performance.
    ///
    /// > Note: Foundation provides other format style types for working with the numeric types that the
    /// > Swift standard library defines. `IntegerFormatStyle` works with types that conform to
    /// > `BinaryInteger`, and `FloatingPointFormatStyle` works with types that conform to `BinaryFloatingPoint`.
    ///
    /// ## Formatting decimal values
    /// Use the `formatted()` method to create a string representation of a decimal value using the
    /// default `Decimal.FormatStyle` configuration:
    ///
    /// ```swift
    /// let formattedDefault = Decimal(12345.67).formatted()
    /// // formattedDefault is "12,345.67" in en_US locale.
    /// // Other locales may use different separator and grouping behavior.
    /// ```
    ///
    /// You can specify a format style by providing an argument to the `formatted(_:)` method. The following
    /// example shows the decimal `0.1` represented in each of the available styles in the `en_US` locale:
    ///
    /// ```swift
    /// let number: Decimal = 0.1
    ///
    /// let formattedNumber = number.formatted(.number)
    /// // formattedNumber is "0.1"
    ///
    /// let formattedPercent = number.formatted(.percent)
    /// // formattedPercent is "10%"
    ///
    /// let formattedCurrency = number.formatted(.currency(code: "USD"))
    /// // formattedCurrency is "$0.10"
    /// ```
    ///
    /// Each style provides methods for updating its numeric configuration, including the number of
    /// significant digits grouping length, and more. You can specify a numeric configuration by calling as
    /// many of these methods as you need in any order you choose. The following example shows the same number
    /// with default and custom configurations:
    ///
    /// ```swift
    /// let exampleNumber: Decimal = 125000.12
    ///
    /// let defaultFormatting = exampleNumber.formatted(.number)
    /// // defaultFormatting is "125 000,12" for the "fr_FR" locale
    /// // defaultFormatting is "125,000.12" for the "en_US" locale
    ///
    /// let customFormatting = exampleNumber.formatted(
    ///     .number
    ///     .grouping(.never)
    ///     .sign(strategy: .always()))
    /// // customFormatting is "+125000.12"
    /// ```
    ///
    /// ## Creating a decimal format style instance
    ///
    /// The previous examples use static instances like `number` to create format styles within the call to
    /// the `formatted(_:)` method. You can also create a `Decimal.FormatStyle` instance and use it to
    /// repeatedly format different values by using the `format(_:)` method, as shown here:
    ///
    /// ```swift
    /// let percentFormatStyle = Decimal.FormatStyle.Percent()
    ///
    /// percentFormatStyle.format(0.5) // "50%"
    /// percentFormatStyle.format(0.855) // "85.5%"
    /// percentFormatStyle.format(1.0) // "100%"
    /// ```
    ///
    /// ## Parsing decimal values
    ///
    /// You can use `Decimal.FormatStyle` to parse strings into decimal values. You can define the format
    /// style within the type’s initializer or pass in a format style created outside the function.
    /// The following demonstrates both approaches:
    ///
    /// ```swift
    /// let price = try? Decimal("$3,500.63",
    ///                          format: .currency(code: "USD")) // 3500.63
    ///
    /// let priceFormatStyle = Decimal.FormatStyle.Currency(code: "USD")
    /// let salePrice = try? Decimal("$731.67",
    ///                              format: priceFormatStyle) // 731.67
    /// ```
    ///
    /// ## Matching regular expressions
    ///
    /// Along with parsing numeric values in strings, you can use the Swift regular expression
    /// domain-specific language to match and capture numeric substrings. The following example defines a
    /// currency format style to match and capture a currency value using US dollars and `en_US` numeric
    /// conventions. The rest of the regular expression ignores any characters prior to a ": "
    /// sequence that precedes the currency substring.
    ///
    /// ```swift
    /// import RegexBuilder
    /// let source = "Payment due: $49,525.99"
    /// let matcher = Regex {
    ///     OneOrMore(.any)
    ///     ": "
    ///     Capture {
    ///         One(.localizedCurrency(code:Locale.Currency("USD"),
    ///                                locale:Locale(identifier: "en_US")))
    ///     }
    /// }
    /// let match = source.firstMatch(of: matcher)
    /// let localizedDecimal = match?.1 // 49525.99
    /// ```
    public struct _polyfill_FormatStyle: Sendable {
        /// The type the format style uses for configuration settings.
        public typealias _polyfill_Configuration = _polyfill_NumberFormatStyleConfiguration

        var collection: _polyfill_Configuration.Collection = .init()

        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale

        /// Creates a decimal format style that uses the given locale.
        ///
        /// Create a `Decimal.FormatStyle` instance when you intend to apply a given style to multiple
        /// decimal values. The following example creates a style that uses the `en_US` locale, which
        /// uses three-based grouping and comma separators. It then applies this style to all the` Decimal`
        /// values in an array.
        ///
        /// ```swift
        /// let enUSstyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
        /// let decimals: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedDecimals = decimals.map { enUSstyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
        /// ```
        ///
        /// To format a single integer, you can use the `Decimal` instance method `formatted(_:)`,
        /// passing in an instance of `Decimal.FormatStyle`.
        ///
        /// - Parameter locale: The locale to use when formatting or parsing decimal values.
        ///   Defaults to `autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

        /// An attributed format style based on the floating-point percent format style.
        ///
        /// Use this modifier to create an `FloatingPointFormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
        /// determine which runs of the attributed string represent different parts of the formatted value.
        public var attributed: _polyfill_Attributed { .init(style: self) }

        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: A decimal format style modified to use the specified grouping.
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
        /// - Returns: A decimal format style modified to use the specified precision.
        public func precision(_ p: _polyfill_Configuration._polyfill_Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: A decimal format style modified to use the specified sign display strategy.
        public func sign(strategy: _polyfill_Configuration._polyfill_SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified decimal
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
        /// - Returns: A decimal format style modified to use the specified rounding rule and increment.
        public func rounded(rule: _polyfill_Configuration._polyfill_RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment = increment {
                new.collection.roundingIncrement = .integer(value: increment)
            }
            return new
        }

        /// Modifies the format style to use the specified scale.
        ///
        /// - Parameter multiplicand: The multiplicand to apply to the format style.
        /// - Returns: A decimal format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }

        /// Modifies the format style to use the specified notation.
        ///
        /// - Parameter notation: The notation to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified notation.
        public func notation(_ notation: _polyfill_Configuration._polyfill_Notation) -> Self {
            var new = self
            new.collection.notation = notation
            return new
        }

        /// Formats a decimal value using this style.
        ///
        /// Use this method when you want to create a single style instance and then use it to format
        /// multiple decimal values. The following example creates a style that uses the `en_US` locale
        /// and then adds the `scientific` modifier. It then applies this style to all of the decimal
        /// values in an array.
        ///
        /// ```swift
        /// let scientificStyle = Decimal.FormatStyle(
        ///     locale: Locale(identifier: "en_US"))
        ///     .notation(.scientific)
        /// let nums: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedNums = nums.map { scientificStyle.format($0) } // ["1.001E2", "1.0002E3", "1.00003E4", "1.000004E5", "1E6"]
        /// ```
        ///
        /// To format a single floating-point value, use the `Decimal` instance method `formatted(_:)`, passing
        /// in an instance of `Decimal.FormatStyle`, or `formatted()` to use a default style.
        ///
        /// - Parameter value: The decimal value to format.
        /// - Returns: A string representation of `value` formatted according to the style’s configuration.
        public func format(_ value: Decimal) -> String {
            if let f = ICUNumberFormatter.create(for: self), let res = f.format(value) { return res }
            return value.description
        }

        /// Modifies the format style to use the specified locale.
        ///
        /// Use this format style to change the locale used by an existing format style. To instead determine
        /// the locale used by this format style, use the `locale` property.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A decimal format style with the provided locale.
        public func locale(_ locale: Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension Decimal._polyfill_FormatStyle {
    /// A format style that converts between decimal percentage values and their textual representations.
    public struct _polyfill_Percent: Sendable {
        /// The type the format style uses for configuration settings.
        public typealias _polyfill_Configuration = _polyfill_NumberFormatStyleConfiguration

        var collection: _polyfill_Configuration.Collection = .init(scale: 100)

        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale

        /// Creates a decimal percent format style that uses the given locale.
        ///
        /// Create a `Decimal.FormatStyle` instance when you intend to apply a given style to multiple
        /// decimal values. The following example creates a style that uses the `en_US` locale, which
        /// uses three-based grouping and comma separators. It then applies this style to all the` Decimal`
        /// values in an array.
        ///
        /// ```swift
        /// let enUSstyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
        /// let decimals: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedDecimals = decimals.map { enUSstyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
        /// ```
        ///
        /// To format a single integer, you can use the `Decimal` instance method `formatted(_:)`,
        /// passing in an instance of `Decimal.FormatStyle`.
        ///
        /// - Parameter locale: The locale to use when formatting or parsing decimal values.
        ///   Defaults to `autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }
        
        /// An attributed format style based on the decimal percent format style.
        ///
        /// Use this modifier to create a `Decimal.FormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
        /// determine which runs of the attributed string represent different parts of the formatted value.
        public var attributed: _polyfill_Attributed { .init(style: self) }

        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified grouping.
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
        /// - Returns: A decimal percent format style modified to use the specified precision.
        public func precision(_ p: _polyfill_Configuration._polyfill_Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }

        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified sign display strategy.
        public func sign(strategy: _polyfill_Configuration._polyfill_SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified decimal
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
        /// - Returns: A decimal percent format style modified to use the specified rounding rule and increment.
        public func rounded(rule: _polyfill_Configuration._polyfill_RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment { new.collection.roundingIncrement = .integer(value: increment) }
            return new
        }

        /// Modifies the format style to use the specified scale.
        ///
        /// - Parameter multiplicand: The multiplicand to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }

        /// Modifies the format style to use the specified notation.
        ///
        /// - Parameter notation: The notation to apply to the format style.
        /// - Returns: A decimal percent format style modified to use the specified notation.
        public func notation(_ notation: _polyfill_Configuration._polyfill_Notation) -> Self {
            var new = self
            new.collection.notation = notation
            return new
        }

        /// Formats a decimal value using this style.
        ///
        /// Use this method when you want to create a single style instance and then use it to format
        /// multiple decimal values. The following example creates a style that uses the `en_US` locale
        /// and then adds the `scientific` modifier. It then applies this style to all of the decimal
        /// values in an array.
        ///
        /// ```swift
        /// let scientificStyle = Decimal.FormatStyle(
        ///     locale: Locale(identifier: "en_US"))
        ///     .notation(.scientific)
        /// let nums: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedNums = nums.map { scientificStyle.format($0) } // ["1.001E2", "1.0002E3", "1.00003E4", "1.000004E5", "1E6"]
        /// ```
        ///
        /// To format a single floating-point value, use the `Decimal` instance method `formatted(_:)`, passing
        /// in an instance of `Decimal.FormatStyle.Percent`.
        ///
        /// - Parameter value: The decimal value to format.
        /// - Returns: A string representation of `value` formatted according to the style’s configuration.
        public func format(_ value: Decimal) -> String {
            if let f = ICUPercentNumberFormatter.create(for: self), let res = f.format(value) { return res }
            return value.description
        }

        /// Modifies the format style to use the specified locale.
        ///
        /// Use this format style to change the locale used by an existing format style. To instead determine
        /// the locale used by this format style, use the `locale` property.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A decimal percent format style with the provided locale.
        public func locale(_ locale: Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension Decimal._polyfill_FormatStyle {
    /// A format style that converts between decimal currency values and their textual representations.
    public struct _polyfill_Currency: Sendable {
        /// The type the format style uses for configuration settings.
        public typealias _polyfill_Configuration = _polyfill_CurrencyFormatStyleConfiguration

        var collection: _polyfill_Configuration.Collection

        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale

        public var currencyCode: String


        /// Creates a decimal percent format style that uses the given locale.
        ///
        /// Create a `Decimal.FormatStyle` instance when you intend to apply a given style to multiple
        /// decimal values. The following example creates a style that uses the `en_US` locale, which
        /// uses three-based grouping and comma separators. It then applies this style to all the` Decimal`
        /// values in an array.
        ///
        /// ```swift
        /// let enUSstyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
        /// let decimals: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedDecimals = decimals.map { enUSstyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
        /// ```
        ///
        /// To format a single integer, you can use the `Decimal` instance method `formatted(_:)`,
        /// passing in an instance of `Decimal.FormatStyle`.
        ///
        /// - Parameter locale: The locale to use when formatting or parsing decimal values.
        ///   Defaults to `autoupdatingCurrent`.

        ///   Defaults to `autoupdatingCurrent`.
        public init(code: String, locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
            self.currencyCode = code
            self.collection = .init(presentation: .standard)
        }

        /// An attributed format style based on the decimal currency format style.
        ///
        /// Use this modifier to create a `Decimal.FormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these
        /// attributes to determine which runs of the attributed string represent different parts
        /// of the formatted value.
        public var attributed: _polyfill_Attributed { .init(style: self) }

        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: A decimal currency format style modified to use the specified grouping.
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
        /// - Returns: A decimal currency format style modified to use the specified precision.
        public func precision(_ p: _polyfill_Configuration._polyfill_Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }
        
        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: A decimal currency format style modified to use the specified sign display strategy.
        public func sign(strategy: _polyfill_Configuration._polyfill_SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }

        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: A decimal currency format style modified to use the specified decimal
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
        /// - Returns: A decimal currency format style modified to use the specified rounding rule and increment.
        public func rounded(rule: _polyfill_Configuration._polyfill_RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment { new.collection.roundingIncrement = .integer(value: increment) }
            return new
        }
        
        /// Modifies the format style to use the specified scale.
        ///
        /// - Parameter multiplicand: The multiplicand to apply to the format style.
        /// - Returns: A decimal currency format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }
        
        /// Modifies the format style to use the specified presentation.
        ///
        /// - Parameter p: A currency presentation value, such as `isoCode` or `fullName`.
        /// - Returns: A decimal currency format style modified to use the specified presentation.
        public func presentation(_ p: _polyfill_Configuration._polyfill_Presentation) -> Self {
            var new = self
            new.collection.presentation = p
            return new
        }

        /// Formats a decimal value using this style.
        ///
        /// Use this method when you want to create a single style instance and then use it to format
        /// multiple decimal values. The following example creates a style that uses the `en_US` locale
        /// and then adds the `scientific` modifier. It then applies this style to all of the decimal
        /// values in an array.
        ///
        /// ```swift
        /// let scientificStyle = Decimal.FormatStyle(
        ///     locale: Locale(identifier: "en_US"))
        ///     .notation(.scientific)
        /// let nums: [Decimal] = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
        /// let formattedNums = nums.map { scientificStyle.format($0) } // ["1.001E2", "1.0002E3", "1.00003E4", "1.000004E5", "1E6"]
        /// ```
        ///
        /// To format a single floating-point value, use the `Decimal` instance method `formatted(_:)`, passing
        /// in an instance of `Decimal.FormatStyle.Currency`.
        ///
        /// - Parameter value: The decimal value to format.
        /// - Returns: A string representation of `value` formatted according to the style’s configuration.
        public func format(_ value: Decimal) -> String {
            if let f = ICUCurrencyNumberFormatter.create(for: self), let res = f.format(value) { return res }
            return value.description
        }
        
        /// Modifies the format style to use the specified locale.
        ///
        /// Use this format style to change the locale used by an existing format style. To instead determine
        /// the locale used by this format style, use the `locale` property.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A decimal currency format style with the provided locale.
        public func locale(_ locale: Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
extension Decimal._polyfill_FormatStyle {
    /// A format style that converts integers into attributed strings.
    public struct _polyfill_Attributed: Sendable {
        enum Style: Hashable, Codable, Sendable {
            case decimal(Decimal._polyfill_FormatStyle)
            case currency(Decimal._polyfill_FormatStyle._polyfill_Currency)
            case percent(Decimal._polyfill_FormatStyle._polyfill_Percent)
        }

        var style: Style

        init(style: Decimal._polyfill_FormatStyle) { self.style = .decimal(style) }
        init(style: Decimal._polyfill_FormatStyle._polyfill_Currency) { self.style = .currency(style) }
        init(style: Decimal._polyfill_FormatStyle._polyfill_Percent) { self.style = .percent(style) }

        /// Formats a decimal value, using this style.
        ///
        /// - Parameter value: The decimal value to format.
        /// - Returns: An attributed string representation of value, formatted according to the style’s
        ///   configuration. The returned string contains attributes from the
        ///   `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope to indicate
        ///   runs formatted by this format style.
        public func format(_ value: Decimal) -> Foundation.AttributedString {
            switch style {
            case .decimal(let style):  ICUNumberFormatter.create(for: style)?.attributedFormat(.decimal(value)) ?? .init(value.description)
            case .currency(let style): ICUCurrencyNumberFormatter.create(for: style)?.attributedFormat(.decimal(value)) ?? .init(value.description)
            case .percent(let style):  ICUPercentNumberFormatter.create(for: style)?.attributedFormat(.decimal(value)) ?? .init(value.description)
            }
        }

        /// Modifies the format style to use the specified locale.
        ///
        /// Use this format style to change the locale used by an existing format style. To instead determine
        /// the locale used by this format style, use the `locale` property.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A format style that uses the specified locale.
        public func locale(_ locale: Locale) -> Self {
            var new = self
            switch style {
            case .decimal(var s):
                s.locale = locale
                new.style = .decimal(s)
            case .currency(var s):
                s.locale = locale
                new.style = .currency(s)
            case .percent(var s):
                s.locale = locale
                new.style = .percent(s)
            }
            return new
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Decimal._polyfill_FormatStyle: _polyfill_FormatStyle {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Decimal._polyfill_FormatStyle._polyfill_Percent: _polyfill_FormatStyle {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Decimal._polyfill_FormatStyle._polyfill_Currency: _polyfill_FormatStyle {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Decimal._polyfill_FormatStyle._polyfill_Attributed: _polyfill_FormatStyle {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == Decimal._polyfill_FormatStyle {
    /// A format style instance for use with decimal values.
    ///
    /// Use this type property when you need a `Decimal.FormatStyle` for use when formatting a
    /// `Decimal`. The following example creates a `Decimal.FormatStyle` for `num`, and then modifies
    /// the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Decimal = 76.41
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.641E1"
    /// ```
    public static var number: Self { .init() }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == Decimal._polyfill_FormatStyle._polyfill_Percent {
    /// An integer percent format style instance for use with decimal values.
    public static var percent: Self { .init() }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle where Self == Decimal._polyfill_FormatStyle._polyfill_Currency {
    /// Creates a decimal currency format style that uses the given currency code.
    ///
    /// - Parameter code: The currency code to use, such as `EUR` or `JPY`. See ISO-4217 for a list of valid codes.
    /// - Returns: A decimal currency format style that uses the given currency code.
    public static func currency(code: String) -> Self { .init(code: code, locale: .autoupdatingCurrent) }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Decimal {
    /// Formats the decimal using a default localized format style.
    ///
    /// - Returns: A string representation of the decimal, formatted according to the default format style.
    public func formatted() -> String { _polyfill_FormatStyle().format(self) }
    
    /// Formats the decimal using the provided format style.
    ///
    /// Use this method when you want to format a single decimal value with a specific format style
    /// or multiple format styles. The following example shows the results of formatting a given
    /// decimal value with format styles for the `en_US` and `fr_FR` locales:
    ///
    /// ```swift
    /// let decimal: Decimal = 123456.789
    /// let usStyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
    /// let frStyle = Decimal.FormatStyle(locale: Locale(identifier: "fr_FR"))
    /// let formattedUS = decimal.formatted(usStyle) // 123,456.789
    /// let formattedFR = decimal.formatted(frStyle) // 123 456,789
    /// ```
    ///
    /// - Parameter format: The format style to apply when formatting the decimal.
    /// - Returns: A localized, formatted string representation of the decimal.
    public func formatted<S: FormatStylePolyfill._polyfill_FormatStyle>(_ format: S) -> S.FormatOutput where Self == S.FormatInput { format.format(self) }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Decimal._polyfill_FormatStyle : CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This strategy returns the `Decimal` type when performing regex capture.
    public typealias RegexOutput = Decimal

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
    ) throws -> (upperBound: String.Index, output: Decimal)? {
        //Decimal.ParseStrategy(formatStyle: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Decimal._polyfill_FormatStyle._polyfill_Percent : CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This strategy returns the `Decimal` type when performing regex capture.
    public typealias RegexOutput = Decimal

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
    ) throws -> (upperBound: String.Index, output: Decimal)? {
        //Decimal.ParseStrategy(formatStyle: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Decimal._polyfill_FormatStyle._polyfill_Currency : CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This strategy returns the `Decimal` type when performing regex capture.
    public typealias RegexOutput = Decimal

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
    ) throws -> (upperBound: String.Index, output: Decimal)? {
        //Decimal.ParseStrategy(formatStyle: self, lenient: false).parse(input, startingAt: index, in: bounds)
        fatalError()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == Decimal._polyfill_FormatStyle {
    /// Creates a localized decimal format style that uses the given locale.
    ///
    /// - Parameter locale: The locale to use when formatting or parsing decimal values.
    /// - Returns: A localized decimal format style that uses the given locale.
    public static func localizedDecimal(locale: Locale) -> Self {
        .init(locale: locale)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension RegexComponent where Self == Decimal._polyfill_FormatStyle._polyfill_Currency {
    /// Creates a regex component to match a localized currency string and capture it as a `Decimal`.
    /// For example, `localizedIntegerCurrency(code: "USD", locale: Locale(identifier: "en_US"))`
    /// matches "$52,249.98" and captures it as 52249.98.
    /// 
    /// - Parameters:
    ///   - code: The currency code of the currency symbol or name in the string.
    ///   - locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized currency number.
    public static func localizedCurrency(code: Locale.Currency, locale: Locale) -> Self {
        .init(code: code.identifier, locale: locale)
    }
}
