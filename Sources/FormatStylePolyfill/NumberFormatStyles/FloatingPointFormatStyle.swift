import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Locale

/// A structure that converts between floating-point values and their textual representations.
///
/// Instances of `FloatingPointFormatStyle` create localized, human-readable text from `BinaryFloatingPoint`
/// numbers and parse string representations of numbers into instances of `BinaryFloatingPoint` types. All of
/// the Swift standard library’s floating-point types, such as `Double`, `Float`, and `Float80`, conform to
/// `BinaryFloatingPoint`, and therefore work with this format style.
///
/// `FloatingPointFormatStyle` includes two nested types, `FloatingPointFormatStyle.Percent` and
/// `FloatingPointFormatStyle.Currency`, for working with percentages and currencies, respectively. Each format
/// style includes a configuration that determines how it represents numeric values, for things like grouping,
/// displaying signs, and variant presentations like scientific notation. `FloatingPointFormatStyle` and
/// `FloatingPointFormatStyle.Percent` include a `NumberFormatStyleConfiguration`, and
/// `FloatingPointFormatStyle.Currency` includes a `CurrencyFormatStyleConfiguration`. You can customize numeric
/// formatting for a style by adjusting its backing configuration. The system automatically caches unique
/// configurations of a format style to enhance performance.
///
/// > Note: Foundation provides another format style type, `IntegerFormatStyle`, for working with numbers that
/// > conform to `BinaryInteger`. For Foundation’s `Decimal` type, use `Decimal.FormatStyle`.
///
/// ## Formatting floating-point values
///
/// Use the `formatted()` method to create a string representation of a floating-point value using the default
/// `FloatingPointFormatStyle` configuration.
///
/// ```swift
/// let formattedDefault = 12345.67.formatted()
/// // formattedDefault is "12,345.67" in the en_US locale.
/// // Other locales may use different separator and grouping behavior.
///```
///
/// You can specify a format style by providing an argument to the `formatted(_:)` method. The following example
/// shows the number `0.1` represented in each of the available styles, in the `en_US` locale:
///
/// ```swift
/// let number = 0.1
///
/// let formattedNumber = number.formatted(.number)
/// // formattedNumber is "0.1".
///
/// let formattedPercent = number.formatted(.percent)
/// // formattedPercent is "10%".
///
/// let formattedCurrency = number.formatted(.currency(code: "USD"))
/// // formattedCurrency is "$0.10".
/// ```
///
/// Each style provides methods for updating its numeric configuration, including the number of significant
/// digits, grouping length, and more. You can specify a numeric configuration by calling as many of these
/// methods as you need in any order you choose. The following example shows the same number with default
/// and custom configurations:
///
/// ```swift
/// let exampleNumber = 123456.78
///
/// let defaultFormatting = exampleNumber.formatted(.number)
/// // defaultFormatting is "123 456,78" for the "fr_FR" locale.
/// // defaultFormatting is "123,456.78" for the "en_US" locale.
///
/// let customFormatting = exampleNumber.formatted(
///     .number
///         .grouping(.never)
///         .sign(strategy: .always()))
/// // customFormatting is "+123456.78"
/// ```
///
/// ## Creating a floating-point format style instance
///
/// The previous examples use static factory methods like `number` to create format styles within the call
/// to the `formatted(_:)` method. You can also create a `FloatingPointFormatStyle` instance and use it to
/// repeatedly format different values, with the `format(_:)` method:
///
/// ```swift
/// let percentFormatStyle = FloatingPointFormatStyle<Double>.Percent()
///
/// percentFormatStyle.format(0.5) // "50%"
/// percentFormatStyle.format(0.855) // "85.5%"
/// percentFormatStyle.format(1.0) // "100%"
/// ```
///
/// ## Parsing floating-point values
///
///You can use `FloatingPointFormatStyle` to parse strings into floating-point values. You can define the format
///style within the type’s initializer or pass in a format style created outside the function, as shown here:
///
/// ```swift
/// let price = try? Double("$3,500.63",
///                         format: .currency(code: "USD")) // 3500.63
///
/// let priceFormatStyle = FloatingPointFormatStyle<Double>.Currency(code: "USD")
/// let salePrice = try? Double("$731.67",
///                             format: priceFormatStyle) // 731.67
/// ```
///
/// ## Matching regular expressions
///
/// Along with parsing numeric values in strings, you can use the Swift regular expression domain-specific
/// language to match and capture numeric substrings. The following example defines a percentage format style
/// to match a percentage value using `en_US` numeric conventions. The rest of the regular expression ignores
/// any characters prior to a `": "` sequence that precedes the percentage substring.
///
/// ```swift
/// import RegexBuilder
/// let source = "Percentage complete: 55.1%"
/// let matcher = Regex {
///     OneOrMore(.any)
///     ": "
///     Capture {
///         One(.localizedDoublePercentage(locale: Locale(identifier: "en_US")))
///     }
/// }
/// let match = source.firstMatch(of: matcher)
/// let localizedPercentage = match?.1
/// print("\(localizedPercentage!)") // 0.551
/// ```
public struct _polyfill_FloatingPointFormatStyle<Value: BinaryFloatingPoint>: Codable, Hashable, Sendable, _polyfill_FormatStyle {
    /// The locale of the format style.
    ///
    /// Use the `locale(_:)` modifier to create a copy of this format style with a different locale.
    public var locale: Foundation.Locale

    /// Creates a floating-point format style that uses the given locale.
    ///
    /// Create a `FloatingPointFormatStyle` when you intend to apply a given style to multiple
    /// floating-point values. The following example creates a style that uses the `en_US` locale,
    /// which uses three-based grouping and comma separators. It then applies this style to all the
    /// `Double` values in an array.
    ///
    /// ```swift
    /// let enUSstyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let nums = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
    /// let formattedNums = nums.map { enUSstyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
    /// ```
    ///
    /// To format a single integer, you can use the `BinaryFloatingPoint` instance method `formatted(_:)`,
    /// passing in an instance of `FloatingPointFormatStyle`.
    ///
    /// - Parameter locale: The locale to use when formatting or parsing floating-point values.
    ///   Defaults to `autoupdatingCurrent`.
    public init(locale: Foundation.Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    /// An attributed format style based on the floating-point format style.
    ///
    /// Use this modifier to create a `FloatingPointFormatStyle.Attributed` instance, which formats values
    /// as `AttributedString` instances. These attributed strings contain attributes from the
    /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
    /// determine which runs of the attributed string represent different parts of the formatted value.
    ///
    /// The following example finds runs of the attributed string that represent different parts of a
    /// formatted currency, and adds additional attributes like foregroundColor and inlinePresentationIntent.
    ///
    /// ```swift
    /// func attributedPrice(price: Double) -> AttributedString {
    ///     var attributedPrice = price.formatted(
    ///         .currency(code: "USD")
    ///         .attributed)
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
    /// User interface frameworks like SwiftUI can use these attributes when presenting the attributed string,
    /// as seen here:
    ///
    /// ![The currency value $1,234.56, with the dollar sign and decimal separator in red, and the
    /// digits in bold.][sampleimg]
    ///
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMjY1IiBoZWlnaHQ9Ijk0IiB2aWV3Qm94PSIwIDAgNzAgMjUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NjAwIDEycHggJ1NGIFBybyBEaXNwbGF5JyxzYW5zLXNlcmlmO2ZpbGw6cmVkIj48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMjUiIHN0eWxlPSJmaWxsOiNmNGY0ZjQ7c3Ryb2tlOiNkZGQiLz48dGV4dCB4PSI2IiB5PSIxNyI%2BJDwvdGV4dD48dGV4dCB4PSIxNCIgeT0iMTYuOCIgZmlsbD0iIzAwMCI%2BMSwyMzTigIg1NjwvdGV4dD48dGV4dCB4PSI0NCIgeT0iMTciPi48L3RleHQ%2BPC9zdmc%2B
    public var attributed: Self.Attributed {
        .init(style: self)
    }

    /// The type the format style uses for configuration settings.
    ///
    /// `FloatingPointFormatStyle` uses `NumberFormatStyleConfiguration` for its configuration type.
    public typealias Configuration = _polyfill_NumberFormatStyleConfiguration
    
    var collection: Configuration.Collection = .init()

    /// Modifies the format style to use the specified grouping.
    ///
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and a
    /// second style that never uses grouping. It then applies each style to an array of floating-point
    /// values. The formatting that the the modified style applies eliminates the three-digit grouping
    /// usually performed for the `en_US` locale.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let neverStyle = defaultStyle.grouping(.never)
    /// let nums = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
    /// let neverNums = nums.map { neverStyle.format($0) } // ["100.1", "1000.2", "10000.3", "100000.4", "1000000.5"]
    /// ```
    ///
    /// - Parameter group: The grouping to apply to the format style.
    /// - Returns: A floating-point format style modified to use the specified grouping.
    public func grouping(_ group: Configuration.Grouping) -> Self {
        var new = self
        new.collection.group = group
        return new
    }

    /// Modifies the format style to use the specified precision.
    ///
    /// The `NumberFormatStyleConfiguration.Precision` type lets you specify a fixed number of digits
    /// to show for a number’s integer and fractional parts. You can also set a fixed number of
    /// significant digits. The following example creates a default `FloatingPointFormatStyle` for the
    /// `en_US` locale, and a second style that uses a maximum of four significant digits. It then
    /// applies each style to an array of floating-point values. The formatting that the modified style
    /// applies truncates precision to `0` after the fourth most-significant digit.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let precisionStyle = defaultStyle.precision(.significantDigits(1...4))
    /// let nums = [123.1, 1234.1, 12345.1, 123456.1, 1234567.1]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["123.1", "1,234.1", "12,345.1", "123,456.1", "1,234,567.1"]
    /// let precisionNums = nums.map { precisionStyle.format($0) } // ["123.1", "1,234", "12,350", "123,500", "1,235,000"]
    /// ```
    ///
    /// - Parameter p: The precision to apply to the format style.
    /// - Returns: A floating-point format style modified to use the specified precision.
    public func precision(_ p: Configuration.Precision) -> Self {
        var new = self
        new.collection.precision = p
        return new
    }

    /// Modifies the format style to use the specified sign display strategy for displaying or omitting sign symbols.
    ///
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and a second
    /// style that displays a sign for all values except zero. It then applies each style to an array of
    /// floating-point values. The formatting that the modified style applies adds the negative (-) or
    /// positive (+) sign to all the numbers.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let alwaysStyle = defaultStyle.sign(strategy: .always(includingZero: false))
    /// let nums = [-2.1, -1.2, 0, 1.4, 2.5]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["-2.1", "-1.2", "0", "1.4", "2.5"]
    /// let alwaysNums = nums.map { alwaysStyle.format($0) } // ["-2.1", "-1.2", "0", "+1.4", "+2.5"]
    /// ```
    ///
    /// - Parameter strategy: The sign display strategy to apply to the format style, such as `automatic` or `never`.
    /// - Returns: A floating-point format style modified to use the specified sign display strategy.
    public func sign(strategy: Configuration.SignDisplayStrategy) -> Self {
        var new = self
        new.collection.signDisplayStrategy = strategy
        return new
    }

    /// Modifies the format style to use the specified decimal separator display strategy.
    ///
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and
    /// a second style that uses the always strategy. It then applies each style to an array of floating-point
    /// values that don’t have a fractional part. The formatting that the modified style applies adds a
    /// trailing decimal separator in all cases.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let alwaysStyle = defaultStyle.decimalSeparator(strategy: .always)
    /// let nums = [100.0, 1000.0, 10000.0, 100000.0, 1000000.0]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100", "1,000", "10,000", "100,000", "1,000,000"]
    /// let alwaysNums = nums.map { alwaysStyle.format($0) } // ["100.", "1,000.", "10,000.", "100,000.", "1,000,000."]
    /// ```
    ///
    /// - Parameter strategy: The decimal separator display strategy to apply to the format style.
    /// - Returns: A floating-point format style modified to use the specified decimal separator display strategy.
    public func decimalSeparator(strategy: Configuration.DecimalSeparatorDisplayStrategy) -> Self {
        var new = self
        new.collection.decimalSeparatorStrategy = strategy
        return new
    }

    /// Modifies the format style to use the specified rounding rule and increment.
    ///
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and modifies
    /// its rounding behavior. It uses the `FloatingPointRoundingRule`.up rounding rule, and an increment of
    /// `0.25`. It then applies this style to an array of floating-point values, rounding them to the next
    /// greater increment of `0.25`.
    ///
    /// ```swift
    /// let roundedStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    ///     .rounded(rule: .up, increment: 0.25)
    /// let nums = [1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6]
    /// let roundedNums = nums.map { roundedStyle.format($0) } // ["1.00", "1.25", "1.25", "1.50", "1.50", "1.50", "1.75"]
    /// ```
    ///
    /// - Parameters:
    ///   - rule: The rounding rule to apply to the format style.
    ///   - increment: A multiple by which the formatter rounds the fractional part. The formatter produces
    ///     a value that is an even multiple of this increment. If this parameter is `nil` (the default),
    ///     the formatter doesn’t apply an increment.
    /// - Returns: A floating-point format style modified to use the specified rounding rule and increment.
    public func rounded(rule: Configuration.RoundingRule = .toNearestOrEven, increment: Double? = nil) -> Self {
        var new = self
        new.collection.rounding = rule
        if let increment { new.collection.roundingIncrement = .floatingPoint(value: increment) }
        return new
    }

    /// Modifies the format style to use the specified scale.
    ///
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and a second
    /// style that scales by a multiplicand of `0.001`. It then applies each style to an array of floating-point
    /// values. The formatting that the modified style applies expresses each value in terms of one-thousandths.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let scaledStyle = defaultStyle.scale(0.001)
    /// let nums = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
    /// let scaledNums = nums.map { scaledStyle.format($0) } // ["0.1001", "1.0002", "10.0003", "100.0004", "1,000.0005"]
    /// ```
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
    /// The following example creates a default `FloatingPointFormatStyle` for the `en_US` locale, and a
    /// second style that uses `scientific` notation style. It then applies each style to an array of
    /// floating-point values.
    ///
    /// ```swift
    /// let defaultStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    /// let scientificStyle = defaultStyle.notation(.scientific)
    /// let nums = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
    /// let defaultNums = nums.map { defaultStyle.format($0) } // ["100.1", "1,000.2", "10,000.3", "100,000.4", "1,000,000.5"]
    /// let scientificNums = nums.map { scientificStyle.format($0) } // ["1.001E2", "1.0002E3", "1.00003E4", "1.000004E5", "1E6"]
    /// ```
    ///
    /// - Parameter notation: The notation to apply to the format style.
    /// - Returns: A floating-point format style modified to use the specified notation.
    public func notation(_ notation: Configuration.Notation) -> Self {
        var new = self
        new.collection.notation = notation
        return new
    }

    /// Formats a floating-point value, using this style.
    ///
    /// Use this method when you want to create a single style instance and use it to format multiple
    /// floating-point values. The following example creates a style that uses the `en_US` locale, then
    /// adds the `scientific` modifier. It applies this style to all the floating-point values in an array.
    ///
    /// ```swift
    /// let scientificStyle = FloatingPointFormatStyle<Double>(
    ///     locale: Locale(identifier: "en_US"))
    ///     .notation(.scientific)
    /// let nums = [100.1, 1000.2, 10000.3, 100000.4, 1000000.5]
    /// let formattedNums = nums.map { scientificStyle.format($0) } // ["1.001E2", "1.0002E3", "1.00003E4", "1.000004E5", "1E6"]
    /// ```
    ///
    /// To format a single floating-point value, use the `BinaryFloatingPoint` instance method
    /// `formatted(_:)`, passing in an instance of `FloatingPointFormatStyle`, or `formatted()`
    /// to use a default style.
    ///
    /// - Parameter value: The floating-point value to format.
    /// - Returns: A string representation of `value`, formatted according to the style’s configuration.
    public func format(_ value: Value) -> String {
        if let nf = ICUNumberFormatter.create(for: self), let str = nf.format(Double(value)) {
            return str
        }
        return String(Double(value))
    }

    /// Modifies the format style to use the specified locale.
    ///
    /// Use this modifier to change the locale that an existing format style uses. To instead determine the
    /// locale this format style uses, use the locale property. The following example creates a default
    /// `FloatingPointFormatStyle` for the `en_US` locale, and applies the `notation(_:)` modifier to use
    /// compact name notation. Next, the sample creates a second style based on this first style, but using
    /// the German (DE) locale. It then applies each style to an array of floating-point values.
    ///
    /// ```swift
    /// let compactStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    ///     .notation(.compactName)
    /// let germanStyle = compactStyle.locale(Locale(identifier: "DE"))
    /// let nums: [Double] = [100, 1000, 10000, 100000, 1000000]
    /// let enUSCompactNums = nums.map { compactStyle.format($0) } // ["100", "1K", "10K", "100K", "1M"]
    /// let deCompactNums = nums.map { germanStyle.format($0) } // ["100", "1000", "10.000", "100.000", "1 Mio."]
    /// ```
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: A floating-point format style modified to use the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_FloatingPointFormatStyle<Double> {
    /// A floating-point format style instance for use with the Swift standard double-precision floating-point type.
    ///
    /// Use this type property when you need a `FloatingPointFormatStyle` that matches the type of a given
    /// floating-point value. The following example creates a type-appropriate `FloatingPointFormatStyle` for
    /// num, then modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Double = 76.41
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.641E1"
    /// ```
    public static var number: Self {
        .init()
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_FloatingPointFormatStyle<Float> {
    /// A floating-point format style instance for use with the Swift standard single-precision floating-point type.
    ///
    /// Use this type property when you need a `FloatingPointFormatStyle` that matches the type of a given
    /// floating-point value. The following example creates a type-appropriate `FloatingPointFormatStyle` for
    /// num, then modifies the style to produce its output as scientific notation.
    ///
    /// ```swift
    /// let num: Float = 76.41
    /// let formatted = num.formatted(.number
    ///         .notation(.scientific)) // "7.641E1"
    /// ```
    public static var number: Self {
        .init()
    }
}


extension _polyfill_FloatingPointFormatStyle {
    /// A format style that converts integers into attributed strings.
    ///
    /// Use the `attributed` modifier on a `FloatingPointFormatStyle` to create a format style of this type.
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
    /// User interface frameworks like `SwiftUI` can use these attributes when presenting the attributed
    /// string, as seen here:
    ///
    /// ![The currency value $1,234.56, with the dollar sign and decimal separator in red, and the
    /// digits in bold.][sampleimg]
    ///
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMjY1IiBoZWlnaHQ9Ijk0IiB2aWV3Qm94PSIwIDAgNzAgMjUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NjAwIDEycHggJ1NGIFBybyBEaXNwbGF5JyxzYW5zLXNlcmlmO2ZpbGw6cmVkIj48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMjUiIHN0eWxlPSJmaWxsOiNmNGY0ZjQ7c3Ryb2tlOiNkZGQiLz48dGV4dCB4PSI2IiB5PSIxNyI%2BJDwvdGV4dD48dGV4dCB4PSIxNCIgeT0iMTYuOCIgZmlsbD0iIzAwMCI%2BMSwyMzTigIg1NjwvdGV4dD48dGV4dCB4PSI0NCIgeT0iMTciPi48L3RleHQ%2BPC9zdmc%2B
    public struct Attributed: Codable, Hashable, _polyfill_FormatStyle, Sendable {
        enum Style: Codable, Hashable, Sendable {
            case floatingPoint(_polyfill_FloatingPointFormatStyle)
            case currency(_polyfill_FloatingPointFormatStyle.Currency)
            case percent(_polyfill_FloatingPointFormatStyle.Percent)

            var formatter: ICUNumberFormatterBase? {
                switch self {
                case .floatingPoint(let style): ICUNumberFormatter.create(for: style)
                case .currency(let style): ICUCurrencyNumberFormatter.create(for: style)
                case .percent(let style): ICUPercentNumberFormatter.create(for: style)
                }
            }
        }

        var style: Style

        init(style: _polyfill_FloatingPointFormatStyle) {
            self.style = .floatingPoint(style)
        }
        
        init(style: _polyfill_FloatingPointFormatStyle.Percent) {
            self.style = .percent(style)
        }
        
        init(style: _polyfill_FloatingPointFormatStyle.Currency) {
            self.style = .currency(style)
        }
        
        /// Formats a floating-point value, using this style.
        /// 
        /// - Parameter value: The floating-point value to format.
        /// - Returns: An attributed string representation of value, formatted according to the style’s
        ///   configuration. The returned string contains attributes from the
        ///   `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope to indicate runs
        ///   formatted by this format style.
        public func format(_ value: Value) -> Foundation.AttributedString {
            switch self.style {
            case .floatingPoint(let formatStyle):
                if let formatter = ICUNumberFormatter.create(for: formatStyle) {
                    return formatter.attributedFormat(.floatingPoint(Double(value)))
                }
            case .currency(let formatStyle):
                if let formatter = ICUCurrencyNumberFormatter.create(for: formatStyle) {
                    return formatter.attributedFormat(.floatingPoint(Double(value)))
                }
            case .percent(let formatStyle):
                if let formatter = ICUPercentNumberFormatter.create(for: formatStyle) {
                    return formatter.attributedFormat(.floatingPoint(Double(value)))
                }
            }
            return Foundation.AttributedString(Double(value).description)
        }
        
        /// Modifies the format style to use the specified locale.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A format style that uses the specified locale.
        public func locale(_ locale: Foundation.Locale) -> Self {
            var new = self
            switch style {
            case .floatingPoint(var style):
                style.locale = locale
                new.style = .floatingPoint(style)
            case .currency(var style):
                style.locale = locale
                new.style = .currency(style)
            case .percent(var style):
                style.locale = locale
                new.style = .percent(style)
            }
            return new
        }
    }
}

/// A parse strategy for creating floating-point values from formatted strings.
///
/// Create an explicit `FloatingPointParseStrategy` to parse multiple strings according to the same parse
/// strategy. In the following example, `usCurrencyStrategy` is a `FloatingPointParseStrategy` that uses US
/// dollars and the `en_US` locale’s conventions for number formatting. The example then uses this strategy
/// to parse an array of strings, some of which represent valid US currency values.
///
/// ```swift
/// let usCurrencyStrategy: FloatingPointParseStrategy =
/// FloatingPointFormatStyle<Double>.Currency(code: "USD",
///                                           locale: Locale(identifier: "en_US"))
///     .parseStrategy
/// let currencyValues = ["$100.11", "$1,000.22", "$10,000.33", "€100.44"]
/// let parsedValues = currencyValues.map { try? usCurrencyStrategy.parse($0) } // [Optional(100.11), Optional(1000.22), Optional(10000.33), nil]
/// ```
///
/// You don’t need to instantiate a parse strategy variable to parse a single string. Instead, use the
/// `BinaryFloatingPoint` initializers that take a source `String` and a `format` parameter to parse the string
/// according to the provided `FormatStyle`. The following example parses a string that represents a currency value
/// in US dollars.
///
/// ```swift
/// let formattedUSDollars = "$1,234.56"
/// let parsedUSDollars = try? Double(formattedUSDollars, format: .currency(code: "USD")
///     .locale(Locale(identifier: "en_US"))) // 1234.56
/// ```
public struct _polyfill_FloatingPointParseStrategy<Format>: Codable, Hashable
    where Format: _polyfill_FormatStyle, Format.FormatInput: BinaryFloatingPoint
{
    /// The format style this strategy uses when parsing strings.
    public var formatStyle: Format

    /// A Boolean value that indicates whether parsing allows any discrepencies in the expected format.
    public var lenient: Bool

    var numberFormatType: ICULegacyNumberFormatter.NumberFormatType
    var locale: Foundation.Locale
}

extension _polyfill_FloatingPointParseStrategy: Sendable where Format: Sendable {}

extension _polyfill_FloatingPointParseStrategy: _polyfill_ParseStrategy {
    /// Parses a floating-point string in accordance with this strategy and returns the parsed value.
    ///
    /// Use this method to repeatedly parse floating-point strings with the same `FloatingPointParseStrategy`.
    /// To parse a single floating-point string, use the initializers inherited from `BinaryFloatingPoint` that
    /// take a `String` and a `FormatStyle` as parameters.
    ///
    /// This method throws an error if the parse strategy can’t parse the provided string.
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: The parsed floating-point value.
    public func parse(_ value: String) throws -> Format.FormatInput {
        let parser = ICULegacyNumberFormatter.formatter(for: self.numberFormatType, locale: self.locale, lenient: self.lenient)

        if let v = parser.parseAsDouble(value.trimmed) {
            return Format.FormatInput(v)
        } else {
            throw parseError(value, examples: "\(self.formatStyle.format(3.14))")
        }
    }

    func parse(_ value: String, startingAt index: String.Index, in range: Range<String.Index>) -> (String.Index, Format.FormatInput)? {
        guard index < range.upperBound else {
            return nil
        }

        let parser = ICULegacyNumberFormatter.formatter(
            for: self.numberFormatType,
            locale: self.locale,
            lenient: self.lenient
        )
        let substr = value[index ..< range.upperBound]
        var upperBound = 0 as Int32
        
        if let value = parser.parseAsDouble(substr, upperBound: &upperBound) {
            return (String.Index(utf16Offset: Int(upperBound), in: substr), Format.FormatInput(value))
        } else {
            return nil
        }
    }
}

extension _polyfill_FloatingPointParseStrategy {
    /// Creates a parse strategy instance using the specified floating-point format style.
    ///
    /// - Parameters:
    ///   - format: A configured `FloatingPointFormatStyle` that describes the string format to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some discrepencies
    ///     when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_FloatingPointFormatStyle<Value> {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .number(format.collection)
    }
    
    /// Creates a parse strategy instance using the specified floating-point currency format style.
    ///
    /// - Parameters:
    ///   - format: A configured `FloatingPointFormatStyle.Currency` that describes the currency string format
    ///     to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some discrepencies
    ///     when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_FloatingPointFormatStyle<Value>.Currency {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .currency(format.collection)
    }
    
    /// Creates a parse strategy instance using the specified floating-point percentage format style.
    ///
    /// - Parameters:
    ///   - format: A configured `FloatingPointFormatStyle.Percent` that describes the percent string format
    ///     to parse.
    ///   - lenient: A Boolean value that indicates whether the parse strategy should permit some discrepencies
    ///     when parsing. Defaults to `true`.
    public init<Value>(format: Format, lenient: Bool = true) where Format == _polyfill_FloatingPointFormatStyle<Value>.Percent {
        self.formatStyle = format
        self.lenient = lenient
        self.locale = format.locale
        self.numberFormatType = .percent(format.collection)
    }
}

extension _polyfill_FloatingPointFormatStyle: _polyfill_ParseableFormatStyle {
    /// The parse strategy that this format style uses.
    public var parseStrategy: _polyfill_FloatingPointParseStrategy<Self> {
        .init(format: self, lenient: true)
    }
}

extension _polyfill_FloatingPointFormatStyle: CustomConsumingRegexComponent {
    // See `RegexComponent.RegexOutput`.
    public typealias RegexOutput = Value
    
    // See `CustomConsumingRegexComponents.consuming(_:startingAt:in:)`.
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Value)? {
        _polyfill_FloatingPointParseStrategy(format: self, lenient: false).parse(input, startingAt: index, in: bounds)
    }
}

extension RegexComponent where Self == _polyfill_FloatingPointFormatStyle<Double> {
    /// Creates a regex component to match a localized number string and capture it as a `Double`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized double string.
    public static func _polyfill_localizedDouble(locale: Foundation.Locale) -> Self {
        .init(locale: locale)
    }
}
