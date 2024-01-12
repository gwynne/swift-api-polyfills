import Numerics
import struct Foundation.Locale
import struct Foundation.Decimal
import struct Foundation.AttributedString
import struct Foundation.CocoaError
import let Foundation.NSDebugDescriptionErrorKey

/// A structure that converts between integer values and their textual representations.
///
/// Instances of `IntegerFormatStyle` create localized, human-readable text from `BinaryInteger`
/// numbers and parse string representations of numbers into instances of `BinaryInteger` types.
/// All of the Swift standard library’s integer types, such as `Int` and `UInt32`, conform to
/// `BinaryInteger`, and therefore work with this format style.
///
/// `IntegerFormatStyle` includes two nested types, `IntegerFormatStyle.Percent` and
/// `IntegerFormatStyle.Currency`, for working with percentages and currencies. Each format style
/// includes a configuration that determines how it represents numeric values, for things like
/// grouping, displaying signs, and variant presentations like scientific notation.
/// `IntegerFormatStyle` and `IntegerFormatStyle.Percent` include a `NumberFormatStyleConfiguration`,
/// and `IntegerFormatStyle.Currency` includes a `CurrencyFormatStyleConfiguration`. You can customize
/// numeric formatting for a style by adjusting its backing configuration. The system automatically
/// caches unique configurations of a format style to enhance performance.
///
/// > Note: Foundation provides another format style type, `FloatingPointFormatStyle`, for working
/// > with numbers that conform to `BinaryFloatingPoint`. For Foundation’s `Decimal` type, use
/// > `Decimal.FormatStyle`.
///
/// ## Formattting integers
///
/// Use the `formatted()` method to create a string representation of an integer using the
/// default `IntegerFormatStyle` configuration.
///
/// ```swift
/// let formattedDefault = 123456.formatted()
/// // formattedDefault is "123,456" in en_US locale.
/// // Other locales may use different separator and grouping behavior.
/// ```
///
/// You can specify a format style by providing an argument to the `formatted(_:)` method. The
/// following example shows the number `12345` represented in each of the available styles, in
/// the `en_US` locale:
///
/// ```swift
/// let number = 123456
///
/// let formattedNumber = number.formatted(.number)
/// // formattedNumber is "123,456".
///
/// let formattedPercent = number.formatted(.percent)
/// // formattedPercent is "123,456%".
///
/// let formattedCurrency = number.formatted(.currency(code: "USD"))
/// // formattedCurrency is "$123,456.00".
/// ```
///
/// Each style provides methods for updating its numeric configuration, including the number of
/// significant digits, grouping length, and more. You can specify a numeric configuration by calling
/// as many of these methods as you need in any order you choose. The following example shows the same
/// number with default and custom configurations:
///
/// ```swift
/// let exampleNumber = 123456
///
/// let defaultFormatting = exampleNumber.formatted(.number)
/// // defaultFormatting is "125 000" for the "fr_FR" locale
/// // defaultFormatting is "125000" for the "jp_JP" locale
/// // defaultFormatting is "125,000" for the "en_US" locale
///
/// let customFormatting = exampleNumber.formatted(
///     .number
///     .grouping(.never)
///     .sign(strategy: .always()))
/// // customFormatting is "+123456"
/// ```
///
/// ## Creating an integer format style instance
///
/// The previous examples use static factory methods like `number` to create format styles within the
/// call to the `formatted(_:)` method. You can also create an `IntegerFormatStyle` instance and use
/// it to repeatedly format different values with the `format(_:)` method:
///
/// ```swift
/// let percentFormatStyle = IntegerFormatStyle<Int>.Percent()
///
/// percentFormatStyle.format(50) // "50%"
/// percentFormatStyle.format(85) // "85%"
/// percentFormatStyle.format(100) // "100%"
/// ```
///
/// ## Parsing integers
///
/// You can use `IntegerFormatStyle` to parse strings into integer values. You can define the format style
/// within the type’s initializer or pass in a format style you create prior to calling the method, as
/// shown here:
///
/// ```swift
/// let price = try? Int("$123,456",
///                      format: .currency(code: "USD")) // 123456
///
/// let priceFormatStyle = IntegerFormatStyle<Int>.Currency(code: "USD")
/// let salePrice = try? Int("$120,000",
///                           format: priceFormatStyle) // 120000
/// ```
///
/// ## Matching regular expressions
///
/// Along with parsing numeric values in strings, you can use the Swift regular expression domain-specific
/// language to match and capture numeric substrings. The following example defines a currency format style
/// to match and capture a currency value using US dollars and `en_US` numeric conventions. The rest of the
/// regular expression ignores any characters prior to a `": "` sequence that precedes the currency substring.
///
/// ```swift
/// import RegexBuilder
///
/// let source = "Payment due: $123,456"
/// let matcher = Regex {
///     OneOrMore(.any)
///     ": "
///     Capture {
///         One(.localizedIntegerCurrency(code: Locale.Currency("USD"),
///                                       locale: Locale(identifier: "en_US")))
///     }
/// }
/// let match = source.firstMatch(of: matcher)
/// let localizedInteger = match?.1 // 123456
/// ```
public struct _polyfill_IntegerFormatStyle<Value: BinaryInteger>: Codable, Hashable, Sendable {
    /// The type the format style uses for configuration settings.
    ///
    /// `IntegerFormatStyle` uses `NumberFormatStyleConfiguration` for its configuration type.
    public typealias Configuration = _polyfill_NumberFormatStyleConfiguration

    /// The locale of the format style.
    ///
    /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
    public var locale: Locale
    
    var collection: Configuration.Collection = Configuration.Collection()
    
    /// Creates an integer format style that uses the given locale.
    ///
    /// Create an `IntegerFormatStyle` when you intend to apply a given style to multiple integers. The
    /// following example creates a style that uses the `en_US` locale, which uses three-based grouping
    /// and comma separators. It then applies this style to all the integers in an array.
    ///
    /// ```swift
    /// let enUSstyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let formattedNums = nums.map { enUSstyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// ```
    ///
    /// To format a single integer, you can use the `BinaryInteger` instance method `formatted(_:)`, passing
    /// in an instance of `IntegerFormatStyle`.
    ///
    /// - Parameter locale: The locale to use when formatting or parsing integers.
    ///   Defaults to `autoupdatingCurrent`.
    public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

    /// An attributed format style based on the integer format style.
    ///
    /// Use this modifier to create an `IntegerFormatStyle.Attributed` instance, which formats values
    /// as `AttributedString` instances. These attributed strings contain attributes from the
    /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes
    /// to determine which runs of the attributed string represent different parts of the formatted value.
    ///
    /// The following example finds runs of the attributed string that represent different parts of a
    /// formatted currency, and adds additional attributes like `foregroundColor` and `inlinePresentationIntent`.
    ///
    /// ```swift
    /// func attributedPrice(price: Int) -> AttributedString {
    ///     var attributedPrice = price.formatted(
    ///         .currency(code: "USD")
    ///         .attributed)
    ///
    ///
    ///     for run in attributedPrice.runs {
    ///         if run.attributes.numberSymbol == .currency ||
    ///             run.attributes.numberSymbol == .decimalSeparator {
    ///             attributedPrice[run.range].foregroundColor = .red
    ///         }
    ///         if run.attributes.numberPart == .integer ||
    ///             run.attributes.numberPart == .fraction {
    ///             attributedPrice[run.range].inlinePresentationIntent = [.stronglyEmphasized]
    ///         }
    ///     }
    ///     return attributedPrice
    /// }
    /// ```
    ///
    /// User interface frameworks like SwiftUI can use these attributes when presenting the attributed
    /// string, as seen here:
    ///
    /// ![The currency value $1,234.00, with the dollar sign and decimal separator in red, and the
    /// digits in bold.][sampleimg]
    ///
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMjY1IiBoZWlnaHQ9Ijk0IiB2aWV3Qm94PSIwIDAgNzAgMjUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NjAwIDEycHggJ1NGIFBybyBEaXNwbGF5JyxzYW5zLXNlcmlmO2ZpbGw6cmVkIj48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMjUiIHN0eWxlPSJmaWxsOiNmNGY0ZjQ7c3Ryb2tlOiNkZGQiLz48dGV4dCB4PSI2IiB5PSIxNyI%2BJDwvdGV4dD48dGV4dCB4PSIxNCIgeT0iMTYuOCIgZmlsbD0iIzAwMCI%2BMSwyMzTigIgwMDwvdGV4dD48dGV4dCB4PSI0NCIgeT0iMTciPi48L3RleHQ%2BPC9zdmc%2B
    public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }

    /// Modifies the format style to use the specified grouping.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a
    /// second style that never uses grouping. It then applies each style to an array of integers. The
    /// formatting that the modified style applies eliminates the three-digit grouping usually performed
    /// for the `en_US` locale.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let neverStyle = defaultStyle.grouping(.never)
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// let neverNums = nums.map { neverStyle.format($0) } // ["100", "1000", "10000", "100000", "1000000"]
    /// ```
    ///
    /// - Parameter group: The grouping to apply to the format style.
    /// - Returns: An integer format style modified to use the specified grouping.
    public func grouping(_ group: Configuration.Grouping) -> Self {
        var new = self
        new.collection.group = group
        return new
    }

    /// Modifies the format style to use the specified precision.
    ///
    /// The `NumberFormatStyleConfiguration.Precision` type lets you specify a fixed number of digits
    /// to show for a number’s integer and fractional parts, although `IntegerFormatStyle` only uses
    /// the former. You can also set a fixed number of significant digits.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a second
    /// style that uses a maximum of four significant digits. It then applies each style to an array of
    /// integers. The formatting that the modified style applies truncates precision to `0` after the fourth
    /// most significant digit.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let precisionStyle = defaultStyle.precision(.significantDigits(1...4))
    /// let nums = [123, 1234, 12345, 123456, 1234567]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["123", "1,234", "12,345", "123,456", "1,234,567"]
    /// let precisionNums = nums.map { precisionStyle.format($0) } // ["123", "1,234", "12,340", "123,500", "1,235,000"]
    /// ```
    ///
    /// - Parameter p: The precision to apply to the format style.
    /// - Returns: An integer format style modified to use the specified precision.
    public func precision(_ p: Configuration.Precision) -> Self {
        var new = self
        new.collection.precision = p
        return new
    }

    /// Modifies the format style to use the specified sign display strategy for displaying or
    /// omitting sign symbols.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a second
    /// style that displays a sign for all values except zero. It then applies each style to an array of
    /// integers. The formatting that the modified style applies adds the negative (`-`) or positive (`+`)
    /// sign to all the numbers.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let alwaysStyle = defaultStyle.sign(strategy: .always(includingZero: false))
    /// let nums = [-2, -1, 0, 1, 2]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["-2", "-1", "0", "1", "2"]
    /// let alwaysNums = nums.map { alwaysStyle.format($0) } // ["-2", "-1", "0", "+1", "+2"]
    /// ```
    ///
    /// - Parameter strategy: The sign display strategy to apply to the format style,
    ///   such as `automatic` or `never`.
    /// - Returns: An integer format style modified to use the specified sign display strategy.
    public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
        var new = self
        new.collection.signDisplayStrategy = strategy
        return new
    }
    
    /// Modifies the format style to use the specified decimal separator display strategy.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a second
    /// style that uses the `always` strategy. It then applies each style to an array of integers. The
    /// formatting that the modified style applies adds a trailing decimal separator in all cases.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let alwaysStyle = defaultStyle.decimalSeparator(strategy: .always)
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// let alwaysNums = nums.map { alwaysStyle.format($0) } // ["100.", "1,000.", "10,000.", "100,000.", "1,000,000."]
    /// ```
    ///
    /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
    /// - Returns: An integer format style modified to use the specified decimal separator display strategy.
    public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
        var new = self
        new.collection.decimalSeparatorStrategy = strategy
        return new
    }

    /// Modifies the format style to use the specified rounding rule and increment.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a
    /// modified style that rounds integers to the nearest multiple of `100`. It then formats the
    /// value `1999` using these format styles.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let roundedStyle = defaultStyle.rounded(rule: .toNearestOrEven,
    ///                                         increment: 100)
    /// let num = 1999
    /// let defaultNum = num.formatted(defaultStyle) // "1,999"
    /// let roundedNum = num.formatted(roundedStyle) // "2,000"
    /// ```
    ///
    /// - Parameters:
    ///   - rule: The rounding rule to apply to the format style.
    ///   - increment: A multiple by which the formatter rounds the fractional part. The formatter produces
    ///     a value that is an even multiple of this increment. If this parameter is `nil` (the default),
    ///     the formatter doesn’t apply an increment.
    /// - Returns: An integer format style modified to use the specified rounding rule and increment.
    public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
        var new = self
        new.collection.rounding = rule
        if let increment { new.collection.roundingIncrement = .integer(value: increment) }
        return new
    }

    /// Modifies the format style to use the specified scale.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a second style
    /// that scales by a multiplicand of `0.001`. It then applies each style to an array of integers. The
    /// formatting that the modified style applies expresses each value in terms of one-thousandths.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let scaledStyle = defaultStyle.scale(0.001)
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// let scaledNums = nums.map { scaledStyle.format($0) } // ["0.1", "1", "10", "100", "1,000"]
    /// ```
    ///
    /// - Parameter multiplicand: The multiplicand to apply to the format style.
    /// - Returns: An integer format style modified to use the specified scale.
    public func scale(_ multiplicand: Double) -> Self {
        var new = self
        new.collection.scale = multiplicand
        return new
    }

    /// Modifies the format style to use the specified notation.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and a second
    /// style that uses scientific notation style. It then applies each style to an array of integers.
    ///
    /// ```swift
    /// let defaultStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    /// let scientificStyle = defaultStyle.notation(.scientific)
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// let scientificNums = nums.map { scientificStyle.format($0) } // ["1E2", "1E3", "1E4", "1E5", "1E6"]
    /// ```
    ///
    /// - Parameter notation: The notation to apply to the format style.
    /// - Returns: An integer format style modified to use the specified notation.
    public func notation(_ notation: Configuration.Notation) -> Self {
        var new = self
        new.collection.notation = notation
        return new
    }
}

extension _polyfill_IntegerFormatStyle {
    /// A format style that converts between integer percentage values and their textual representations.
    public struct Percent: Codable, Hashable, Sendable {
        /// The type the format style uses for configuration settings.
        ///
        /// `IntegerFormatStyle.Percent` uses `NumberFormatStyleConfiguration` for its configuration type.
        public typealias Configuration = _polyfill_NumberFormatStyleConfiguration

        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale

        var collection: Configuration.Collection = Configuration.Collection(scale: 1)

        /// Creates an integer percent format style that uses the given locale.
        ///
        /// - Parameter locale: The locale to use when formatting or parsing integers.
        ///   Defaults to `autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) { self.locale = locale }

        /// An attributed format style based on the integer percent format style.
        ///
        /// Use this modifier to create an `IntegerFormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these
        /// attributes to determine which runs of the attributed string represent different parts of
        /// the formatted value.
        public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }
        
        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: An integer percent format style modified to use the specified grouping.
        public func grouping(_ group: Configuration.Grouping) -> Self {
            var new = self
            new.collection.group = group
            return new
        }
        
        /// Modifies the format style to use the specified precision.
        ///
        /// The `NumberFormatStyleConfiguration.Precision` type lets you specify a fixed number of digits
        /// to show for a number’s integer and fractional part, although `IntegerFormatStyle.Percent` only
        /// uses the former. You can also set a fixed number of significant digits.
        ///
        /// - Parameter p: The precision to apply to the format style.
        /// - Returns: An integer format style modified to use the specified precision.
        public func precision(_ p: Configuration.Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }
        
        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: An integer format style modified to use the specified sign display strategy.
        public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }
        
        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: An integer percent format style modified to use the specified decimal
        ///   separator display strategy.
        public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
            var new = self
            new.collection.decimalSeparatorStrategy = strategy
            return new
        }
        
        /// Modifies the format style to use the specified rounding rule and increment.
        ///
        /// - Parameters:
        ///   - rule: The rounding rule to apply to the format style.
        ///   - increment: A multiple by which the formatter rounds the fractional part. The formatter
        ///     produces a value that is an even multiple of this increment. If this parameter is `nil`
        ///     (the default), the formatter doesn’t apply an increment.
        /// - Returns: An integer percent format style modified to use the specified rounding rule and increment.
        public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
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
        /// - Returns: An integer format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }
        
        /// Modifies the format style to use the specified notation.
        ///
        /// - Parameter notation: The notation to apply to the format style.
        /// - Returns: An integer percent format style modified to use the specified notation.
        public func notation(_ notation: Configuration.Notation) -> Self {
            var new = self
            new.collection.notation = notation
            return new
        }
    }

    /// A format style that converts between integer currency values and their textual representations.
        public struct Currency: Codable, Hashable, Sendable {
        /// The type the format style uses for configuration settings.
        ///
        /// `IntegerFormatStyle.Currency` uses `CurrencyFormatStyleConfiguration` for its configuration type.
        public typealias Configuration = _polyfill_CurrencyFormatStyleConfiguration
        
        /// The locale of the format style.
        ///
        /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
        public var locale: Locale
        
        /// The currency code this format style uses.
        public let currencyCode: String

        var collection: Configuration.Collection
        
        /// Creates an integer currency format style that uses the given currency code and locale.
        ///
        /// - Parameters:
        ///   - code: The currency code to use, such as `EUR` or `JPY`.
        ///   - locale: The locale to use when formatting or parsing integers.
        ///     Defaults to `autoupdatingCurrent`.
        public init(code: String, locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
            self.currencyCode = code
            self.collection = Configuration.Collection(presentation: .standard)
        }
        
        /// An attributed format style based on the integer currency format style.
        ///
        /// Use this modifier to create an `IntegerFormatStyle.Attributed` instance, which formats values
        /// as `AttributedString` instances. These attributed strings contain attributes from the
        /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these
        /// attributes to determine which runs of the attributed string represent different parts
        /// of the formatted value.
        public var attributed: _polyfill_IntegerFormatStyle.Attributed { .init(style: self) }
        
        /// Modifies the format style to use the specified grouping.
        ///
        /// - Parameter group: The grouping to apply to the format style.
        /// - Returns: An integer currency format style modified to use the specified grouping.
        public func grouping(_ group: Configuration.Grouping) -> Self {
            var new = self
            new.collection.group = group
            return new
        }
        
        /// Modifies the format style to use the specified precision.
        ///
        /// The `NumberFormatStyleConfiguration.Precision` type lets you specify a fixed number of digits
        /// to show for a number’s integer and fractional part, although `IntegerFormatStyle.Currency` only
        /// uses the former. You can also set a fixed number of significant digits.
        ///
        /// - Parameter p: The precision to apply to the format style.
        /// - Returns: An integer currency format style modified to use the specified precision.
        public func precision(_ p: Configuration.Precision) -> Self {
            var new = self
            new.collection.precision = p
            return new
        }
        
        /// Modifies the format style to use the specified sign display strategy.
        ///
        /// - Parameter strategy: The sign display strategy to apply to the format style.
        /// - Returns: An integer format style modified to use the specified sign display strategy.
        public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
            var new = self
            new.collection.signDisplayStrategy = strategy
            return new
        }
        
        /// Modifies the format style to use the specified decimal separator display strategy.
        ///
        /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
        /// - Returns: An integer currency format style modified to use the specified decimal
        ///   separator display strategy.
        public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
            var new = self
            new.collection.decimalSeparatorStrategy = strategy
            return new
        }
        
        /// Modifies the format style to use the specified rounding rule and increment.
        ///
        /// - Parameters:
        ///   - rule: The rounding rule to apply to the format style.
        ///   - increment: A multiple by which the formatter rounds the fractional part. The formatter
        ///     produces a value that is an even multiple of this increment. If this parameter is `nil`
        ///     (the default), the formatter doesn’t apply an increment.
        /// - Returns: An integer currency format style modified to use the specified rounding rule and increment.
        public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Int? = nil) -> Self {
            var new = self
            new.collection.rounding = rule
            if let increment { new.collection.roundingIncrement = .integer(value: increment) }
            return new
        }
        
        /// Modifies the format style to use the specified scale.
        ///
        /// - Parameter multiplicand: The multiplicand to apply to the format style.
        /// - Returns: An integer format style modified to use the specified scale.
        public func scale(_ multiplicand: Double) -> Self {
            var new = self
            new.collection.scale = multiplicand
            return new
        }
        
        /// Modifies the format style to use the specified presentation.
        ///
        /// - Parameter p: A currency presentation value, such as `isoCode` or `fullName`.
        /// - Returns: An integer currency format style modified to use the specified presentation.
        public func presentation(_ p: Configuration.Presentation) -> Self {
            var new = self
            new.collection.presentation = p
            return new
        }
    }
}

extension _polyfill_IntegerFormatStyle: _polyfill_FormatStyle {
    /// The type of data to format.
    ///
    /// This type is the generic constraint `Value`, which is a type that conforms to `BinaryInteger`.
    public typealias FormatInput = Value
    
    /// The type of the formatted data.
    ///
    /// This format style produces `String` instances.
    public typealias FormatOutput = String
    
    /// Returns a localized string for the given value. Supports up to 64-bit signed integer precision.
    /// Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized string for the given value.
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
    
    /// Modifies the format style to use the specified locale.
    ///
    /// Use this modifier to change the locale used by an existing format style. To instead
    /// determine the locale this format style uses, use the `locale` property.
    ///
    /// The following example creates a default `IntegerFormatStyle` for the `en_US` locale, and
    /// applies the `notation(_:)` modifier to use compact name notation. Next, the sample creates
    /// a second style based on this first style, but using the German (`DE`) locale. It then applies
    /// each style to an array of integers.
    ///
    /// ```swift
    /// let compactStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
    ///     .notation(.compactName)
    /// let germanStyle = compactStyle.locale(Locale(identifier:"DE"))
    /// let nums = [100, 1000, 10000, 100000, 1000000]
    /// let enUSCompactNums = nums.map { compactStyle.format($0) } // ["100", "1K", "10K", "100K", "1M"]
    /// let deCompactNums = nums.map { germanStyle.format($0) } // ["100", "1000", "10.000", "100.000", "1 Mio."]
    /// ```
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: An integer format style modified to use the provided locale.
    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_IntegerFormatStyle.Percent: _polyfill_FormatStyle {
    /// Returns a localized string for the given value in percentage. Supports up to 64-bit signed
    /// integer precision. Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized string for the given value in percentage.
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

    /// Modifies the format style to use the specified locale.
    ///
    /// Use this format style to change the locale used by an existing format style. To instead
    /// determine the locale used by this format style, use the `locale` property.
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: An integer percent format style with the provided locale.
    public func locale(_ locale: Locale) -> _polyfill_IntegerFormatStyle.Percent {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_IntegerFormatStyle.Currency: _polyfill_FormatStyle {
    /// Returns a localized currency string for the given value. Supports up to 64-bit signed
    /// integer precision. Values not representable by `Int64` are clamped.
    ///
    /// - Parameter value: The value to be formatted.
    /// - Returns: A localized currency string for the given value.
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
    
    /// Modifies the format style to use the specified locale.
    ///
    /// Use this format style to change the locale used by an existing format style. To instead
    /// determine the locale used by this format style, use the `locale` property.
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: An integer currency format style with the provided locale.
    public func locale(_ locale: Locale) -> _polyfill_IntegerFormatStyle.Currency {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_IntegerFormatStyle: _polyfill_ParseableFormatStyle {
    /// The type of parse strategy this format style uses.
    public typealias Strategy = _polyfill_IntegerParseStrategy<_polyfill_IntegerFormatStyle<Value>>
    
    /// The parse strategy that this format style uses.
    public var parseStrategy: _polyfill_IntegerParseStrategy<Self> {
        .init(format: self, lenient: true)
    }
}

extension _polyfill_IntegerFormatStyle.Currency: _polyfill_ParseableFormatStyle {
    /// The parse strategy that this format style uses.
    public var parseStrategy: _polyfill_IntegerParseStrategy<Self> {
        .init(format: self, lenient: true)
    }
}
extension _polyfill_IntegerFormatStyle.Percent: _polyfill_ParseableFormatStyle {
    /// The parse strategy that this format style uses.
    public var parseStrategy: _polyfill_IntegerParseStrategy<Self> {
        .init(format: self, lenient: true)
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int> {
    /// An integer format style instance for use with Swift’s standard integer type.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Int = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int16> {
    /// An integer format style instance for use with 16-bit signed integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Int16 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int32> {
    /// An integer format style instance for use with 32-bit signed integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Int32 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int64> {
    /// An integer format style instance for use with 64-bit signed integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Int64 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int8> {
    /// An integer format style instance for use with 8-bit signed integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Int8 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt> {
    /// An integer format style instance for use with unsigned integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: UInt = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt16> {
    /// An integer format style instance for use with unsigned 16-bit integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: UInt16 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt32> {
    /// An integer format style instance for use with unsigned 32-bit integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: UInt32 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt64> {
    /// An integer format style instance for use with unsigned 64-bit integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: UInt64 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt8> {
    /// An integer format style instance for use with unsigned 8-bit integers.
    ///
    /// Use this type property when you need an `IntegerFormatStyle` that matches the type of a given
    /// integer. The following example creates a type-appropriate `IntegerFormatStyle` for `num`, then
    /// modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: UInt8 = 76
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.6E1"
    /// ```
    public static var number: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int>.Percent {
    /// A style for formatting signed integer types in Swift as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int16>.Percent {
    /// A style for formatting 16-bit signed integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int32>.Percent {
    /// A style for formatting 32-bit signed integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int64>.Percent {
    /// A style for formatting 64-bit signed integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<Int8>.Percent {
    /// A style for formatting 8-bit signed integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt>.Percent {
    /// A style for formatting unsigned integer types in Swift as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt16>.Percent {
    /// A style for formatting 16-bit unsigned integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt32>.Percent {
    /// A style for formatting 32-bit unsigned integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt64>.Percent {
    /// A style for formatting 64-bit unsigned integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle where Self == _polyfill_IntegerFormatStyle<UInt8>.Percent {
    /// A style for formatting 8-bit unsigned integers as a percent representation.
    ///
    /// Use the this type property when the call point allows the use of `IntegerFormatStyle`. You
    /// typically do this when calling the `formatted` methods of types that conform to `BinaryInteger`.
    public static var percent: Self { .init() }
}

extension _polyfill_FormatStyle {
    /// Returns a format style to use integer currency notation.
    ///
    /// Use the dot-notation form of this method when the call point allows the use of
    /// `IntegerFormatStyle`. You typically do this when calling the `formatted` methods
    /// of types that conform to `BinaryInteger`.
    ///
    /// The following example creates an array of integers, then uses `formatted(_:)` and
    /// the currency style provided by this method to format the integers as US dollars:
    ///
    /// ```swift
    /// let nums: [Int] = [100, 1000, 10000, 100000, 1000000]
    /// let currencyNums = nums.map { $0.formatted(
    ///     .currency(code:"USD")) } // ["$100.00", "$1,000.00", "$10,000.00", "$100,000.00", "$1,000,000.00"]
    /// ```
    ///
    /// - Parameter code: The currency code to use, such as `EUR` or `JPY`. See ISO-4217 for a list of valid codes.
    /// - Returns: An integer format style that uses the specified currency code.
    public static func currency<V: BinaryInteger>(code: String) -> Self where Self == _polyfill_IntegerFormatStyle<V>.Currency {
        .init(code: code)
    }
}

extension _polyfill_IntegerFormatStyle {
    /// A format style that converts integers into attributed strings.
    /// 
    /// Use the `attributed` modifier on an `IntegerFormatStyle` to create a format style of this type.
    /// 
    /// The attributed strings that this format style creates contain attributes from the
    /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes
    /// to determine which runs of the attributed string represent different parts of the formatted value.
    /// 
    /// The following example finds runs of the attributed string that represent different parts of a
    /// formatted currency, and adds additional attributes like `foregroundColor` and `inlinePresentationIntent`.
    /// 
    /// ```swift
    /// func attributedPrice(price: Decimal) -> AttributedString {
    ///     var attributedPrice = price.formatted(
    ///         .currency(code: "USD")
    ///         .attributed)
    /// 
    ///     for run in attributedPrice.runs {
    ///         if run.attributes.numberSymbol == .currency ||
    ///             run.attributes.numberSymbol == .decimalSeparator  {
    ///             attributedPrice[run.range].foregroundColor = .red
    ///         }
    ///         if run.attributes.numberPart == .integer ||
    ///             run.attributes.numberPart == .fraction {
    ///             attributedPrice[run.range].inlinePresentationIntent = [.stronglyEmphasized]
    ///         }
    ///     }
    ///     return attributedPrice
    /// }
    /// ```
    /// 
    /// User interface frameworks like SwiftUI can use these attributes when presenting the attributed string,
    /// as seen here:
    /// 
    /// ![The currency value $1,234.56, with the dollar sign and decimal separator in red, and the
    /// digits in bold.][sampleimg]
    /// 
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMjY1IiBoZWlnaHQ9Ijk0IiB2aWV3Qm94PSIwIDAgNzAgMjUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NjAwIDEycHggJ1NGIFBybyBEaXNwbGF5JyxzYW5zLXNlcmlmO2ZpbGw6cmVkIj48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMjUiIHN0eWxlPSJmaWxsOiNmNGY0ZjQ7c3Ryb2tlOiNkZGQiLz48dGV4dCB4PSI2IiB5PSIxNyI%2BJDwvdGV4dD48dGV4dCB4PSIxNCIgeT0iMTYuOCIgZmlsbD0iIzAwMCI%2BMSwyMzTigIg1NjwvdGV4dD48dGV4dCB4PSI0NCIgeT0iMTciPi48L3RleHQ%2BPC9zdmc%2B
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

        /// Modifies the format style to use the specified locale.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A format style that uses the specified locale.
        public func locale(_ locale: Locale) -> Self {
            switch style {
            case .integer(let style): .init(style: style.locale(locale))
            case .currency(let style): .init(style: style.locale(locale))
            case .percent(let style): .init(style: style.locale(locale))
            }
        }
    }
}

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

/// A parse strategy for creating integer values from formatted strings.
///
/// Create an explicit `IntegerParseStrategy` to parse multiple strings according to
/// the same parse strategy. In the following example, `usCurrencyStrategy` is an
/// `IntegerParseStrategy` that uses US dollars and the `en_US` locale’s conventions for
/// number formatting. The example then uses this strategy to parse an array of strings,
/// some of which represent valid US currency values.
///
/// ```swift
/// let usCurrencyStrategy: IntegerParseStrategy =
///     IntegerFormatStyle<Int>.Currency(code: "USD",
///                                      locale: Locale(identifier: "en_US"))
///     .parseStrategy
/// let currencyValues = ["$100", "$1,000", "$10,000", "€100"]
/// let parsedValues = currencyValues.map { try? usCurrencyStrategy.parse($0) } // [Optional(100), Optional(1000), Optional(10000), nil]
/// ```
///
/// You don’t need to instantiate a parse strategy variable to parse a single string. Instead,
/// use the `BinaryInteger` initializers that take a source `String` and a `format` parameter to
/// parse the string according to the provided `FormatStyle`. The following example parses a
/// string that represents a currency value in US dollars.
///
/// ```swift
/// let formattedUSDollars = "$1,234"
/// let parsedUSDollars = try? Int(formattedUSDollars, format: .currency(code: "USD")
///     .locale(Locale(identifier: "en_US"))) // 1234
/// ```
public struct _polyfill_IntegerParseStrategy<Format>: Codable, Hashable
    where Format: _polyfill_FormatStyle, Format.FormatInput: BinaryInteger
{
    /// The format style this strategy uses when parsing strings.
    public var formatStyle: Format
    
    /// A Boolean value that indicates whether parsing allows any discrepencies in the expected format.
    public var lenient: Bool
    
    var numberFormatType: ICULegacyNumberFormatter.NumberFormatType
    var locale: Locale
}

extension _polyfill_IntegerParseStrategy: Sendable where Format: Sendable {}

extension _polyfill_IntegerParseStrategy: _polyfill_ParseStrategy {
    /// Parses an integer string in accordance with this strategy and returns the parsed value.
    ///
    /// Use this method to repeatedly parse integer strings with the same `IntegerParseStrategy`. To
    /// parse a single integer string, use the initializers inherited from `BinaryInteger` that take a
    /// `String` and a `FormatStyle` as parameters.
    ///
    /// This method throws an error if the parse strategy can’t parse the provided string.
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: The parsed integer value.
    public func parse(_ value: String) throws -> Format.FormatInput {
        let parser = ICULegacyNumberFormatter.formatter(for: self.numberFormatType, locale: self.locale, lenient: self.lenient)
        let trimmedString = value.trimmed

        if let v = parser.parseAsInt(trimmedString) {
            return Format.FormatInput(v)
        } else if let v = parser.parseAsDouble(trimmedString) {
            return Format.FormatInput(clamping: Int64(v))
        } else {
            throw CocoaError(.formatting, userInfo: [
                NSDebugDescriptionErrorKey: "Cannot parse \(value). String should adhere to the specified format, such as \(self.formatStyle.format(123))"
            ])
        }
    }

    func parse(_ value: String, startingAt index: String.Index, in range: Range<String.Index>) -> (String.Index, Format.FormatInput)? {
        guard index < range.upperBound else { return nil }

        let parser = ICULegacyNumberFormatter.formatter(for: self.numberFormatType, locale: self.locale, lenient: self.lenient)
        let substr = value[index ..< range.upperBound]
        var upperBound = 0 as Int32

        if let value = parser.parseAsInt(substr, upperBound: &upperBound) {
            return (String.Index(utf16Offset: Int(upperBound), in: substr), Format.FormatInput(value))
        } else if let value = parser.parseAsDouble(substr, upperBound: &upperBound) {
            return (String.Index(utf16Offset: Int(upperBound), in: substr), Format.FormatInput(clamping: Int64(value)))
        }
        return nil
    }
}

extension _polyfill_IntegerParseStrategy {
    /// Creates a parse strategy instance using the specified integer format style.
    ///
    /// - Parameters:
    ///   - format: A configured `IntegerFormatStyle` that describes the string format to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some
    ///     discrepencies when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_IntegerFormatStyle<Value> {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .number(format.collection)
    }

    /// Creates a parse strategy instance using the specified integer percentage format style.
    ///
    /// - Parameters:
    ///   - format: A configured `IntegerFormatStyle.Percent` that describes the percent string format to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some
    ///     discrepencies when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_IntegerFormatStyle<Value>.Percent {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .percent(format.collection)
    }

    /// Creates a parse strategy instance using the specified integer currency format style.
    ///
    /// - Parameters:
    ///   - format: A configured `IntegerFormatStyle.Currency` that describes the currency string format to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some
    ///     discrepencies when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_IntegerFormatStyle<Value>.Currency {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .currency(format.collection)
    }
}

extension _polyfill_IntegerFormatStyle: CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This type is the generic constraint `Value`, which is a type that conforms to `BinaryInteger.
    public typealias RegexOutput = Value

    /// Process the input string within the specified bounds, beginning at the given index, and return the
    /// end position (upper bound) of the match and the produced output.
    ///
    /// Don’t call this method directly. Regular expression matching and capture calls it
    /// automatically when matching substrings.
    ///
    /// - Parameters:
    ///   - input: An input string to match against.
    ///   - index: The index within input at which to begin searching.
    ///   - bounds: The bounds within input in which to search.
    /// - Returns: The upper bound where the match terminates and a matched instance, or `nil` if there isn’t a match.
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        _polyfill_IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
    }
}

extension _polyfill_IntegerFormatStyle.Percent: CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This type is the generic constraint `Value`, which is a type that conforms to `BinaryInteger.
    public typealias RegexOutput = Value

    /// Process the input string within the specified bounds, beginning at the given index, and return the
    /// end position (upper bound) of the match and the produced output.
    ///
    /// Don’t call this method directly. Regular expression matching and capture calls it
    /// automatically when matching substrings.
    ///
    /// - Parameters:
    ///   - input: An input string to match against.
    ///   - index: The index within input at which to begin searching.
    ///   - bounds: The bounds within input in which to search.
    /// - Returns: The upper bound where the match terminates and a matched instance, or `nil` if there isn’t a match.
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        _polyfill_IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
    }
}

extension _polyfill_IntegerFormatStyle.Currency: CustomConsumingRegexComponent {
    /// The output type when you use this format style to match substrings.
    ///
    /// This type is the generic constraint `Value`, which is a type that conforms to `BinaryInteger.
    public typealias RegexOutput = Value

    /// Process the input string within the specified bounds, beginning at the given index, and return the
    /// end position (upper bound) of the match and the produced output.
    ///
    /// Don’t call this method directly. Regular expression matching and capture calls it
    /// automatically when matching substrings.
    ///
    /// - Parameters:
    ///   - input: An input string to match against.
    ///   - index: The index within input at which to begin searching.
    ///   - bounds: The bounds within input in which to search.
    /// - Returns: The upper bound where the match terminates and a matched instance, or `nil` if there isn’t a match.
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Value)? {
        _polyfill_IntegerParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
    }
}

extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int> {
    /// Creates a regex component that matches a localized numeric string, capturing it
    /// as an integer value.
    ///
    /// This method matches decimal substrings in accordance with the provided locale. For
    /// example, the value `1234567890` formats as `1,234,567,890` in the `en_US` locale, as
    /// `1 234 567 890` in the `FR` locale, and as `1234567890` in the `JP` locale. Because of
    /// this, the regex needs to know what locale convention to match against.
    ///
    /// The following example creates a `Regex` that matches a date and time followed by whitespace
    /// and an integer formatted in the `en_US` locale. It then matches this regex against a source
    /// string containing a date with this format, some whitespace, and an integer value.
    ///
    /// ```swift
    /// let enUSLocale = Locale(languageCode: .english, languageRegion: .unitedStates)
    /// let source = "7/31/2022, 5:15:12 AM  49,525"
    /// let matcher = Regex {
    ///     One(.dateTime(date: .numeric,
    ///                   time: .standard,
    ///                   locale: enUSLocale,
    ///                   timeZone: TimeZone(identifier: "PST")!))
    ///     OneOrMore(.horizontalWhitespace)
    ///     Capture {
    ///         One(.localizedInteger(locale: enUSLocale))
    ///     }
    /// }
    /// guard let match = source.firstMatch(of: matcher) else { return }
    /// let matchedInteger = match?.1 // matchedInteger == 49525
    /// ```
    ///
    /// - Parameter locale: The locale that specifies formatting conventions to use when
    ///   matching numeric strings.
    /// - Returns: A `RegexComponent` that matches localized substrings as `Int` instances.
    public static func localizedInteger(locale: Locale) -> Self {
        .init(locale: locale)
    }
}

extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int>.Percent {
    /// Creates a regex component that matches a localized percentage string, capturing it
    /// as an integer value.
    ///
    /// This method matches percentage substrings in accordance with the provided locale. For example,
    /// in the `en_US` locale, `75` formats as `75%`, and `1234` formats as `1,234%`. Other locales
    /// use different separators, or omit them entirely. Because of this, the regex needs to know
    /// what locale convention to match against.
    ///
    /// The following example creates a `Regex` that matches a date and time followed by whitespace and
    /// a percentage string formatted in the `en_US` locale. It then matches this regex against a source
    /// string containing a date with this format, some whitespace, and a percentage string.
    ///
    /// ```swift
    /// let enUSLocale = Locale(languageCode: .english, languageRegion: .unitedStates)
    /// let source = "7/31/2022, 5:15:12 AM  75%"
    /// let matcher = Regex {
    ///     One(.dateTime(date: .numeric,
    ///                   time: .standard,
    ///                   locale: enUSLocale,
    ///                   timeZone: TimeZone(identifier: "PST")!))
    ///     OneOrMore(.horizontalWhitespace)
    ///     Capture {
    ///         One(.localizedIntegerPercentage(locale: enUSLocale))
    ///     }
    /// }
    /// guard let match = source.firstMatch(of: matcher) else { return }
    /// let percentage = match?.1 // percentage == 75
    /// ```
    ///
    /// - Parameter locale: The locale that specifies formatting conventions to use when matching
    ///   percentage strings.
    /// - Returns: A `RegexComponent` that matches percentage substrings as `Int` instances.
    public static func localizedIntegerPercentage(locale: Locale) -> Self {
        .init(locale: locale)
    }
}

extension RegexComponent where Self == _polyfill_IntegerFormatStyle<Int>.Currency {
    /// Creates a regex component that matches a localized currency string, capturing it
    /// as an integer value.
    ///
    /// This method matches currency substrings in accordance with the provided currency code and locale.
    /// For example, the currency code `USD` matches U.S. dollars, which use the symbol `$`, and `JPY`
    /// matches Japanese yen, which use the symbol `¥`. The locale determines formatting conventions for
    /// number separators in the currency value. The regex uses both of these to match currency substrings.
    ///
    /// The method truncates fractional parts in currency strings. To match currency strings with
    /// fractional parts, use `localizedCurrency(code:locale:)` instead.
    ///
    /// The following example creates a `Regex` that matches a date and time followed by whitespace and
    /// a currency value that uses U.S. dollars and the `en_US` locale. It then matches this regex against
    /// a source string containing a date with this format, some whitespace, and a currency value in dollars.
    ///
    /// ```swift
    /// let enUSLocale = Locale(languageCode: .english, languageRegion: .unitedStates)
    /// let source = "7/31/2022, 5:15:12 AM    $39,739"
    /// let matcher = Regex {
    ///     One(.dateTime(date: .numeric,
    ///                   time: .standard,
    ///                   locale: enUSLocale,
    ///                   timeZone: TimeZone(identifier: "PST")!))
    ///     OneOrMore(.horizontalWhitespace)
    ///     Capture {
    ///         One(.localizedIntegerCurrency(code: Locale.Currency("USD"),
    ///                                       locale: enUSLocale))
    ///     }
    /// }
    ///
    /// guard let match = source.firstMatch(of: matcher) else { return }
    /// let currency = match?.1 // currency == 39739
    /// ```
    ///
    /// - Parameters:
    ///   - code: The currency code that indicates the currency symbol or name to match against.
    ///   - locale: The locale that specifies formatting conventions to use when matching currency strings.
    /// - Returns: A `RegexComponent` that matches localized currency substrings as `Int` instances.
    public static func localizedIntegerCurrency(code: Locale.Currency, locale: Locale) -> Self {
        .init(code: code.identifier, locale: locale)
    }
}
