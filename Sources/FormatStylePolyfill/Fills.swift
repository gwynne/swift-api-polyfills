#if !canImport(Darwin)

import struct Foundation.Date
import struct Foundation.Decimal
import struct Foundation.URL

/// A type that converts a given data type into a representation in another type, such as a string.
///
/// Types conforming to the `FormatStyle` protocol take their input type and produce formatted instances of
/// their output type. The formatting process accounts for locale-specific conventions, like grouping and
/// separators for numbers, and presentation of units for measurements. The format styles Foundation provides
/// produce their output as `String` or `AttributedString` instances. You can also create custom styles that
/// format their output as any type, like XML or JSON `Data` or an image.
///
/// There are two basic approaches to using a `FormatStyle`:
///
/// * Create an instance of a type that conforms to `FormatStyle` and apply it to one or more instances of the
///   input type, by calling the style’s `format(_:)` method. Use this when you want to customize a style once
///   and apply it repeatedly to many instances.
/// * Pass an instance of a type that conforms to `FormatStyle` to the data type’s `formatted(_:)` method, which
///   takes the style as a parameter. Use this for one-off formatting scenarios, or when you want to apply different
///   format styles to the same data value. For the simplest cases, most types that support formatting also have a
///   no-argument `formatted()` method that applies a locale-appropriate default format style.
///
/// Foundation provides format styles for integers (`IntegerFormatStyle`), floating-point numbers
/// (`FloatingPointFormatStyle`), decimals (`Decimal.FormatStyle`), measurements (`Measurement.FormatStyle`),
/// arrays (`ListFormatStyle`), and more. The “Conforming types” section below shows all the format styles available
/// from Foundation and any system frameworks that implement the `FormatStyle` protocol. The numeric format styles
/// also provide supporting format styles to format currency and percent values, like `IntegerFormatStyle.Currency`
/// and `Decimal.FormatStyle.Percent`.
///
/// ## Modifying a format style
///
/// Format styles include modifier methods that return a new format style with an adjusted behavior. The following
/// example creates an `IntegerFormatStyle`, then applies modifiers to round values down to the nearest 1,000 and
/// applies formatting appropriate to the `fr_FR` locale:
///
/// ```swift
/// let style = IntegerFormatStyle<Int>()
///     .rounded(rule: .down, increment: 1000)
///     .locale(Locale(identifier: "fr_FR"))
/// let rounded = 123456789.formatted(style) // "123 456 000"
/// ```
///
/// Foundation caches identical instances of a customized format style, so you don’t need to pass format style
/// instances around unrelated parts of your app’s source code.
///
/// ## Accessing static instances
///
/// Types that conform to `FormatStyle` typically extend the base protocol with type properties or type methods to
/// provide convenience instances. These are available for use in a data type’s `formatted(_:)` method when the
/// format style’s input type matches the data type. For example, the various numeric format styles define `number`
/// properties with generic constraints to match the different numeric types (`Double`, `Int`, `Float16`, and so on).
///
/// To see how this works, consider this example of a default formatter for an `Int` value. Because `123456789` is
/// a `BinaryInteger`, its `formatted(_:)` method accepts an `IntegerFormatStyle` parameter. The following example
/// shows the style’s default behavior in the `en_US` locale.
///
/// ```swift
/// let formatted = 123456789.formatted(IntegerFormatStyle()) // "123,456,789"
/// ```
///
/// `IntegerFormatStyle` extends `FormatStyle` with multiple type properties called `number`, each of which is an
/// `IntegerFormatStyle` instance; these properties differ by which `BinaryInteger`-conforming type they take as
/// input. Since one of these statically-defined properties (`number`) takes `Int` as its input, you can use this
/// type property instead of instantiating a new format style instance. Using dot notation to access this property
/// on the inferred `FormatStyle` makes the call point much easier to read, as seen here:
///
/// ```swift
/// let formatted = 123456789.formatted( .number) // "123,456,789"
/// ```
///
/// Furthermore, since you can customize these statically-accessed format style instances, you can rewrite the example
/// from the previous section without instantiating a new `IntegerFormatStyle`, like this:
///
/// ```swift
/// let rounded = 123456789.formatted( .number
///     .rounded(rule: .down, increment: 1000)
///     .locale(Locale(identifier: "fr_FR"))) // "123 456 000"
/// ```
///
/// ## Parsing with a format style
///
/// To perform the opposite conversion — from formatted output type to input data type — some format styles provide
/// a corresponding `ParseStrategy` type. These format styles typically expose an instance of this type as a
/// variable, called `parseStrategy`.
///
/// You can use a `ParseStrategy` one of two ways:
///
/// * Initialize the data type by calling an initializer of that type that takes a formatted instance and a parse
///   strategy as parameters. For example, you can create a `Decimal` from a formatted string with the initializer
///   `init(_:format:lenient:)`.
/// * Create a parse strategy and call its `parse(_:)` method on one or more formatted instances.
public typealias FormatStyle = _polyfill_FormatStyle

/// A type that parses an input representation, such as a formatted string, into a provided data type.
///
/// A `ParseStrategy` allows you to convert a formatted representation into a data type, using one
/// of two approaches:
///
/// * Initialize the data type by calling an initializer of that type that takes a formatted instance
///   and a parse strategy as parameters. For example, you can create a `Decimal` from a formatted string
///   with the initializer `init(_:format:lenient:)`.
/// * Create a parse strategy and call its `parse(_:)` method on one or more formatted instances.
///
/// `ParseStrategy` is closely related to `FormatStyle`, which provides the opposite conversion: from data
/// type to formatted representation. To use a parse strategy, you create a `FormatStyle` to define the
/// representation you expect, then access the style’s `parseStrategy` property to get a strategy instance.
///
/// The following example creates a `Decimal.FormatStyle.Currency` format style that uses US dollars and
/// US English number-formatting conventions. It then creates a `Decimal` instance by providing a formatted
/// string to parse and the format style’s `parseStrategy`.
///
/// ```swift
/// let style = Decimal.FormatStyle.Currency(code: "USD",
///                                          locale: Locale(identifier: "en_US"))
/// let parsed = try? Decimal("$12,345.67",
///                            strategy: style.parseStrategy) // 12345.67
/// ```
public typealias ParseStrategy = _polyfill_ParseStrategy

/// A type that can convert a given input data type into a representation in an output type.
public typealias ParseableFormatStyle = _polyfill_ParseableFormatStyle

/// Configuration settings for formatting numbers of different types.
///
/// This type is effectively a namespace to collect types that configure parts of a formatted number,
/// such as grouping, precision, and separator and sign characters.
public typealias NumberFormatStyleConfiguration = _polyfill_NumberFormatStyleConfiguration

/// A structure that converts between floating-point values and their textual representations.
///
/// Instances of ``FloatingPointFormatStyle`` create localized, human-readable text from `BinaryFloatingPoint`
/// numbers and parse string representations of numbers into instances of `BinaryFloatingPoint` types. All of
/// the Swift standard library’s floating-point types, such as `Double`, `Float`, and `Float80`, conform to
/// `BinaryFloatingPoint`, and therefore work with this format style.
///
/// ``FloatingPointFormatStyle`` includes two nested types, ``FloatingPointFormatStyle/Percent`` and
/// ``FloatingPointFormatStyle/Currency``, for working with percentages and currencies, respectively. Each format
/// style includes a configuration that determines how it represents numeric values, for things like grouping,
/// displaying signs, and variant presentations like scientific notation. ``FloatingPointFormatStyle`` and
/// ``FloatingPointFormatStyle/Percent`` include a ``NumberFormatStyleConfiguration``, and
/// ``FloatingPointFormatStyle/Currency`` includes a ``CurrencyFormatStyleConfiguration``. You can customize numeric
/// formatting for a style by adjusting its backing configuration. The system automatically caches unique
/// configurations of a format style to enhance performance.
///
/// > Note: Foundation provides another format style type, ``IntegerFormatStyle``, for working with numbers that
/// > conform to `BinaryInteger`. For Foundation’s `Decimal` type, use `Decimal.FormatStyle`.
///
/// ## Formatting floating-point values
///
/// Use the `formatted()` method to create a string representation of a floating-point value using the default
/// ``FloatingPointFormatStyle`` configuration.
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
/// to the `formatted(_:)` method. You can also create a ``FloatingPointFormatStyle`` instance and use it to
/// repeatedly format different values, with the ``FloatingPointFormatStyle/format(_:)`` method:
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
///You can use ``FloatingPointFormatStyle`` to parse strings into floating-point values. You can define the format
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
public typealias FloatingPointFormatStyle<Value> = _polyfill_FloatingPointFormatStyle<Value>

/// A parse strategy for creating floating-point values from formatted strings.
///
/// Create an explicit ``FloatingPointParseStrategy`` to parse multiple strings according to the same parse
/// strategy. In the following example, `usCurrencyStrategy` is a ``FloatingPointParseStrategy`` that uses US
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
/// according to the provided ``FormatStyle``. The following example parses a string that represents a currency value
/// in US dollars.
///
/// ```swift
/// let formattedUSDollars = "$1,234.56"
/// let parsedUSDollars = try? Double(formattedUSDollars, format: .currency(code: "USD")
///     .locale(Locale(identifier: "en_US"))) // 1234.56
/// ```
public typealias FloatingPointParseStrategy = _polyfill_FloatingPointParseStrategy

extension RegexComponent where Self == FloatingPointFormatStyle<Double> {
    /// Creates a regex component to match a localized number string and capture it as a `Double`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized double string.
    public static func localizedDouble(locale: Foundation.Locale) -> Self {
        ._polyfill_localizedDouble(locale: locale)
    }
}

extension RegexComponent where Self == FloatingPointFormatStyle<Double>.Percent {
    /// Creates a regex component to match a localized string representing a percentage and capture it as a `Double`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized percentage string.
    public static func localizedDoublePercentage(locale: Foundation.Locale) -> Self {
        ._polyfill_localizedDoublePercentage(locale: locale)
    }
}

extension Swift.Duration {
    /// A `FormatStyle` that displays a duration as a list of duration units, such as
    /// "2 hours, 43 minutes, 26 seconds" in English.
    ///

    /// A format style that shows durations with localized labeled components
    ///
    /// This style produces formatted strings that break out a duration’s individual components, like “2 min, 3 sec”.
    ///
    /// Create a `UnitsFormatStyle` by providing a set of allowed `Duration.UnitsFormatStyle.Unit` instances — such
    /// as hours, minutes, or seconds — for formatted strings to include. You also specify a width for displaying
    /// these units, which controls whether they appear as full words (“minutes”) or abbreviations (“min”). The
    /// initializers also take optional parameters to control things like the handling of zero units and fractional
    /// parts. Then create a formatted string by calling `formatted(_:)` on a duration, passing the style, or
    /// `format(_:)` on the style, passing a duration. You can also use the style’s `attributed` property to create
    /// a style that produces `AttributedString` instances, which contains attributes that indicate the unit value
    /// of formatted runs of the string.
    ///
    /// In situations that expect a `Duration.UnitsFormatStyle`, such as `formatted(_:)`, you can use the convenience
    /// function `.units(allowed:width:maximumUnitCount:zeroValueUnits:valueLength:fractionalPart:)` to create a
    /// `Duration.UnitsFormatStyle`, rather than using the full initializer.
    ///
    /// If you want to reuse a style to format many durations, call `format(_:)` on the style, passing in a new
    /// duration each time.
    ///
    /// The following example creates `duration` to represent 1 hour, 10 minutes, 32 seconds, and 400 milliseconds. It
    /// then creates a `Duration.UnitsFormatStyle` to show the hours, minutes, seconds, and milliseconds parts, with a
    /// wide width that presents the full name of each unit.
    ///
    /// ```swift
    /// let duration = Duration.seconds(70 * 60 + 32) + Duration.milliseconds(400)
    /// let format = duration1.formatted(
    ///      .units(allowed: [.hours, .minutes, .seconds, .milliseconds],
    ///             width: .wide))
    /// // format == "1 hour, 10 minutes, 32 seconds, 400 milliseconds"
    /// ```
    ///
    /// The formatted string omits any units that aren’t needed to accurately represent the value. In the above example,
    /// a duration of exactly one minute would format as `1 minute`, omitting the hours, seconds, and milliseconds parts.
    /// To override this behavior and show the omitted units, use the initializer’s `zeroValueUnits` parameter.
    public typealias UnitsFormatStyle = _polyfill_DurationUnitsFormatStyle
}

extension Swift.Duration {
    /// A format style that shows durations in a compact, localized format with separators.
    ///
    /// This style produces formatted strings that uses separators between components, like `“2:03”`
    ///
    /// Create a `TimeFormatStyle` by providing a `Duration.TimeFormatStyle.Pattern` and an optional locale. The
    /// pattern specifies which units (hours, minutes, and seconds) to include in the formatted string, with optional
    /// configuration of the units. Then create a formatted string by calling `formatted(_:)` on a duration, passing
    /// the style, or `format(_:`) on the style, passing a duration. You can also use the style’s `attributed` property
    /// to create a style that produces `AttributedString` instances, which contains attributes that indicate the unit
    /// value of formatted runs of the string.
    ///
    /// In situations that expect a `Duration.TimeFormatStyle`, such as `formatted(_:)`, you can use the convenience
    /// function `time(pattern:)` to create a `Duration.TimeFormatStyle`, rather than using the full initializer.
    ///
    /// If you want to reuse a style to format many durations, call `format(_:)` on the style, passing in a new
    /// duration each time.
    ///
    /// The following example creates duration to represent 1 hour, 10 minutes, 32 seconds, and 400 milliseconds. It
    /// then creates a `Duration.TimeFormatStyle` to show hours, minutes, and seconds, padding the hours part to two
    /// digits and limiting the fractional seconds to two digits. When used with the `formatted(_:)` method, the
    /// resulting string is `01:10:32.40`.
    ///
    /// ```swift
    /// let duration = Duration.seconds(70 * 60 + 32) + Duration.milliseconds(400)
    /// let format = duration.formatted(
    ///     .time(pattern: .hourMinuteSecond(padHourToLength: 2,
    ///                                      fractionalSecondsLength: 2)))
    /// // format == "01:10:32.40"
    /// ```
    public typealias TimeFormatStyle = _polyfill_DurationTimeFormatStyle
}

extension Swift.Duration {
    /// Formats the duration, using the provided format style.
    ///
    /// - Returns: A localized, formatted string that describes the duration. For example, a duration of 1 hour,
    ///   30 minutes, and 56 seconds in the `en_US` locale with a ``Duration/TimeFormatStyle`` returns `1:30:56`.
    ///   In the Finnish locale, this returns `1.30.56`.
    ///
    /// Use this formatting method to apply a custom style when formatting a duration.
    ///
    /// There are two format styles that apply to durations:
    ///
    /// - ``Duration/TimeFormatStyle`` shows durations in a compact, numeric, localized form, like “2:03”.
    /// - ``Duration/UnitsFormatStyle`` shows durations with localized labeled components, like “2 min, 3 sec”.
    ///
    /// The following example uses a custom ``Duration/TimeFormatStyle`` that shows hours, minutes, and seconds,
    /// and pads the hour part to a minimum of two characters. When it formats a two-second duration, this produces
    /// the string `00:00:02`.
    ///
    /// ```swift
    /// let duration = Duration.seconds(2)
    /// let style = Duration.TimeFormatStyle(pattern: .hourMinuteSecond(padHourToLength: 2))
    /// let formatted = duration.formatted(style) // "00:00:02".
    /// ```
    ///
    /// Instead of explicitly initializing styles, you can use ``time(pattern:)`` or
    /// ``units(allowed:width:maximumUnitCount:zeroValueUnits:valueLength:fractionalPart:)`` in any call that expects
    /// a ``FormatStyle`` whose input type is `Duration`. This allows you to rewrite the above example as follows:
    ///
    /// ```swift
    /// let duration = Duration.seconds(2)
    /// let formatted = duration.formatted(
    ///     .time(pattern: .hourMinuteSecond(padHourToLength: 2))) // "00:00:02".
    ///  ```
    public func formatted<S>(_ v: S) -> S.FormatOutput where S: FormatStyle, S.FormatInput == Swift.Duration {
        self._polyfill_formatted(v)
    }
    
    /// Formats `self` using the hour-minute-second time pattern
    ///
    /// - Returns: A formatted string to describe the duration, such as "1:30:56" for a duration of 1 hour, 30 minutes, and 56 seconds
    public func formatted() -> String {
        self._polyfill_formatted()
    }
}

public typealias DescriptiveNumberFormatConfiguration = _polyfill_DescriptiveNumberFormatConfiguration

/// The capitalization formatting context used when formatting dates and times.
public typealias FormatStyleCapitalizationContext = _polyfill_FormatStyleCapitalizationContext

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
    /// and `Decimal.FormatStyle.Percent` include a ``NumberFormatStyleConfiguration``, and
    /// `Decimal.FormatStyle.Currency` includes a ``CurrencyFormatStyleConfiguration``. You can customize numeric
    /// formatting for a style by adjusting its backing configuration. The system automatically caches unique
    /// configurations of a format style to enhance performance.
    ///
    /// > Note: Foundation provides other format style types for working with the numeric types that the
    /// > Swift standard library defines. ``IntegerFormatStyle`` works with types that conform to
    /// > `BinaryInteger`, and ``FloatingPointFormatStyle`` works with types that conform to `BinaryFloatingPoint`.
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
    public typealias FormatStyle = _polyfill_DecimalFormatStyle
    
    /// A parse strategy for creating decimal values from formatted strings.
    ///
    /// Create an explicit `Decimal.ParseStrategy` to parse mulitple strings according to the same parse strategy.
    /// In the following example, `usCurrencyStrategy` is a `Decimal.ParseStrategy` that uses US dollars and the
    /// `en_US` locale’s conventions for number formatting. The example then uses this strategy to parse an array
    /// of strings, some of which represent valid US currency values.
    ///
    /// ```swift
    /// let usCurrencyStrategy: Decimal.ParseStrategy =
    /// Decimal.FormatStyle.Currency(code: "USD",
    ///                             locale: Locale(identifier: "en_US"))
    /// .parseStrategy
    /// let currencyValues = ["$100.11", "$1,000.22", "$10,000.33", "€100.44"]
    /// let parsedValues = currencyValues.map { try? usCurrencyStrategy.parse($0) } // [Optional(100.11), Optional(1000.22), Optional(10000.33), nil]
    /// ```
    ///
    /// You don’t need to instantiate a parse strategy variable to parse a single string. Instead, use the
    /// `init(_:format:lenient:)` initializer, which takes a source `String` and a `format` parameter to parse the
    /// string according to the provided `FormatStyle`. The following example parses a string that represents a
    /// currency value in US dollars.
    ///
    /// ```swift
    /// let formattedUSDollars = "$1,234.56"
    /// let parsedUSDollars = try? Decimal(formattedUSDollars, format: .currency(code: "USD")
    ///     .locale(Locale(identifier: "en_US"))) // 1234.56
    /// ```
    ///
    /// `Decimal` also has an `init(_:strategy:)` initializer, if it’s more convenient to pass a
    /// `Decimal.ParseStrategy` instance rather than implicitly derive a strategy from a `Decimal.FormatStyle`.
    public typealias ParseStrategy = _polyfill_DecimalParseStrategy
}

extension RegexComponent where Self == Foundation.Decimal.FormatStyle {
    /// Creates a regex component to match a localized number string and capture it as a `Decimal`.
    ///
    /// - Parameter locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized number string.
    public static func localizedDecimal(locale: Foundation.Locale) -> Self {
        ._polyfill_localizedDecimal(locale: locale)
    }
}

extension RegexComponent where Self == Foundation.Decimal.FormatStyle.Currency {
    /// Creates a regex component to match a localized currency string and capture it as a `Decimal`. For
    /// example, `localizedIntegerCurrency(code: "USD", locale: Locale(identifier: "en_US"))` matches
    /// `"$52,249.98"` and captures it as `52249.98`.
    /// 
    /// - Parameters:
    ///   - code: The currency code of the currency symbol or name in the string.
    ///   - locale: The locale with which the string is formatted.
    /// - Returns: A `RegexComponent` to match a localized currency number.
    public static func localizedCurrency(code: Foundation.Locale.Currency, locale: Foundation.Locale) -> Self {
        ._polyfill_localizedCurrency(code: code, locale: locale)
    }
}

/// Configuration settings for formatting currency values.
public typealias CurrencyFormatStyleConfiguration = _polyfill_CurrencyFormatStyleConfiguration

/// A format style that provides string representations of byte counts.
///
/// The following example creates an Int representing 1,024 bytes, and then formats it as an expression of
/// memory storage, with the default byte count format style.
///
/// ```swift
/// let count: Int64 = 1024
/// let formatted = count.formatted(.byteCount(style: .memory)) // "1 kB"
/// ```
///
/// You can also customize a byte count format style, and use this to format one or more `Int64` instances. The
/// following example creates a format style to only use kilobyte units, and to spell out the exact byte count
/// of the measurement.
///
/// ```swift
/// let style = ByteCountFormatStyle(style: .memory,
///                                  allowedUnits: [.kb],
///                                  spellsOutZero: true,
///                                  includesActualByteCount: false,
///                                  locale: Locale(identifier: "en_US"))
/// let counts: [Int64] = [0, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
/// let formatted = counts.map ( {style.format($0) } ) // ["Zero kB", "1 kB", "2 kB", "4 kB", "8 kB", "16 kB", "32 kB", "64 kB"]
/// ```
public typealias ByteCountFormatStyle = _polyfill_ByteCountFormatStyle

/// A structure that converts between integer values and their textual representations.
///
/// Instances of ``IntegerFormatStyle`` create localized, human-readable text from `BinaryInteger`
/// numbers and parse string representations of numbers into instances of `BinaryInteger` types.
/// All of the Swift standard library’s integer types, such as `Int` and `UInt32`, conform to
/// `BinaryInteger`, and therefore work with this format style.
///
/// ``IntegerFormatStyle`` includes two nested types, ``IntegerFormatStyle/Percent`` and
/// ``IntegerFormatStyle/Currency``, for working with percentages and currencies. Each format style
/// includes a configuration that determines how it represents numeric values, for things like
/// grouping, displaying signs, and variant presentations like scientific notation.
/// ``IntegerFormatStyle`` and ``IntegerFormatStyle/Percent`` include a ``NumberFormatStyleConfiguration``,
/// and ``IntegerFormatStyle/Currency`` includes a ``CurrencyFormatStyleConfiguration``. You can customize
/// numeric formatting for a style by adjusting its backing configuration. The system automatically
/// caches unique configurations of a format style to enhance performance.
///
/// > Note: Foundation provides another format style type, ``FloatingPointFormatStyle``, for working
/// > with numbers that conform to `BinaryFloatingPoint`. For Foundation’s `Decimal` type, use
/// > ``Decimal.FormatStyle``.
///
/// ## Formattting integers
///
/// Use the `formatted()` method to create a string representation of an integer using the
/// default ``IntegerFormatStyle`` configuration.
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
/// call to the `formatted(_:)` method. You can also create an ``IntegerFormatStyle`` instance and use
/// it to repeatedly format different values with the ``IntegerFormatStyle/format(_:)`` method:
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
/// You can use ``IntegerFormatStyle`` to parse strings into integer values. You can define the format style
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
public typealias IntegerFormatStyle = _polyfill_IntegerFormatStyle

/// A parse strategy for creating integer values from formatted strings.
///
/// Create an explicit ``IntegerParseStrategy`` to parse multiple strings according to
/// the same parse strategy. In the following example, `usCurrencyStrategy` is an
/// ``IntegerParseStrategy`` that uses US dollars and the `en_US` locale’s conventions for
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
/// parse the string according to the provided ``FormatStyle``. The following example parses a
/// string that represents a currency value in US dollars.
///
/// ```swift
/// let formattedUSDollars = "$1,234"
/// let parsedUSDollars = try? Int(formattedUSDollars, format: .currency(code: "USD")
///     .locale(Locale(identifier: "en_US"))) // 1234
/// ```
public typealias IntegerParseStrategy = _polyfill_IntegerParseStrategy

extension RegexComponent where Self == IntegerFormatStyle<Int> {
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
    public static func localizedInteger(locale: Foundation.Locale) -> Self {
        ._polyfill_localizedInteger(locale: locale)
    }
}

extension RegexComponent where Self == IntegerFormatStyle<Int>.Percent {
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
    public static func localizedIntegerPercentage(locale: Foundation.Locale) -> Self {
        ._polyfill_localizedIntegerPercentage(locale: locale)
    }
}

extension RegexComponent where Self == IntegerFormatStyle<Int>.Currency {
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
    public static func localizedIntegerCurrency(code: Foundation.Locale.Currency, locale: Foundation.Locale) -> Self {
        ._polyfill_localizedIntegerCurrency(code: code, locale: locale)
    }
}

/// A type that formats lists of items with a separator and conjunction appropriate for a given locale.
///
/// A list format style creates human readable text from a `Sequence` of values. Customize the formatting behavior
/// of the list using the ``ListFormatStyle/width``, ``ListFormatStyle/listType``, and ``ListFormatStyle/locale``
/// properties. The system automatically caches unique configurations of ``ListFormatStyle`` to enhance performance.
///
/// Use either `formatted()` or `formatted(_:)`, both instance methods of `Sequence`, to create a string
/// representation of the items.
///
/// The `formatted()` method applies the default list format style to a sequence of strings. For example:
///
/// ```swift
/// ["Kristin", "Paul", "Ana", "Bill"].formatted()
/// // Kristin, Paul, Ana, and Bill
/// ```
///
/// You can customize a list’s type and width properties.
///
/// - The ``ListFormatStyle/listType`` property specifies the semantics of the list.
/// - The ``ListFormatStyle/width`` property determines the size of the returned string.
///
/// The `formatted(_:)` method to applies a custom list format style. You can use the static factory method
/// `list(type:width:)` to create a custom list format style as a parameter to the method.
///
/// This example formats a sequence with a ``ListFormatStyle/ListType/and`` list type and
/// ``ListFormatStyle/Width/short`` width:
///
/// ```swift
/// ["Kristin", "Paul", "Ana", "Bill"].formatted(.list(type: .and, width: .short))
/// // Kristin, Paul, Ana, & Bill
/// ```
///
/// You can provide a member format style to transform each list element to a string in applications where the
/// elements aren’t already strings. For example, the following code sample uses an ``IntegerFormatStyle`` to
/// convert a range of integer values into a list:
///
/// ```swift
/// (5201719 ... 5201722).formatted(.list(memberStyle: IntegerFormatStyle(), type: .or, width: .standard))
/// // For locale: en_US: 5,201,719, 5,201,720, 5,201,721, or 5,201,722
/// // For locale: fr_CA: 5 201 719, 5 201 720, 5 201 721, ou 5 201 722
/// ```
///
/// > Note: The generated string is locale-dependent and incorporates linguistic and cultural conventions of the user.
///
/// You can create and reuse a list format style instance to format similar sequences. For example:
///
/// ```swift
/// let percentStyle = ListFormatStyle<FloatingPointFormatStyle.Percent, StrideThrough<Double>>(memberStyle: .percent)
/// stride(from: 7.5, through: 9.0, by: 0.5).formatted(percentStyle)
/// // 7.5%, 8%, 8.5%, and 9%
/// stride(from: 89.0, through: 95.0, by: 2.0).formatted(percentStyle)
/// // 89%, 91%, 93%, and 95%
/// ```
public typealias ListFormatStyle = _polyfill_ListFormatStyle

public typealias StringStyle = _polyfill_StringStyle

extension Swift.Sequence {
    public func formatted<S: FormatStyle>(_ style: S) -> S.FormatOutput where S.FormatInput == Self {
        self._polyfill_formatted(style)
    }
}

extension Swift.Sequence<String> {
    public func formatted() -> String {
        self._polyfill_formatted()
    }
}

/// A format style that provides string representations of byte counts.
///
/// The following example creates an Int representing 1,024 bytes, and then formats it as an expression of
/// memory storage, with the default byte count format style.
///
/// ```swift
/// let count: Int64 = 1024
/// let formatted = count.formatted(.byteCount(style: .memory)) // "1 kB"
/// ```
///
/// You can also customize a byte count format style, and use this to format one or more `Int64` instances. The
/// following example creates a format style to only use kilobyte units, and to spell out the exact byte count
/// of the measurement.
///
/// ```swift
/// let style = ByteCountFormatStyle(style: .memory,
///                                  allowedUnits: [.kb],
///                                  spellsOutZero: true,
///                                  includesActualByteCount: false,
///                                  locale: Locale(identifier: "en_US"))
/// let counts: [Int64] = [0, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
/// let formatted = counts.map ( {style.format($0) } ) // ["Zero kB", "1 kB", "2 kB", "4 kB", "8 kB", "16 kB", "32 kB", "64 kB"]
/// ```
public typealias ByteCountFormatStyle = _polyfill_ByteCountFormatStyle

extension Swift.BinaryInteger {
    /// Format `self` using ``IntegerFormatStyle``
    public func formatted() -> String {
        self._polyfill_formatted()
    }

    /// Format `self` with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where S: FormatStyle, Self == S.FormatInput {
        self._polyfill_formatted(format)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then
    /// formatted with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where S: FormatStyle, S.FormatInput: BinaryInteger {
        self._polyfill_formatted(format)
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput: Swift.BinaryInteger {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput == Self {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: IntegerFormatStyle<Self>, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: IntegerFormatStyle<Self>.Percent, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: IntegerFormatStyle<Self>.Currency, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }
}

extension Swift.BinaryFloatingPoint {
    /// Format `self` with ``FloatingPointFormatStyle``.
    public func formatted() -> String {
        self._polyfill_formatted()
    }

    /// Format `self` with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where S: FormatStyle, Self == S.FormatInput {
        self._polyfill_formatted(format)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        self._polyfill_formatted(format)
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput: Swift.BinaryFloatingPoint {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput == Self {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: FloatingPointFormatStyle<Self>, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: FloatingPointFormatStyle<Self>.Percent, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: FloatingPointFormatStyle<Self>.Currency, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }
}

extension Foundation.Decimal {
    /// Formats the decimal using a default localized format style.
    ///
    /// - Returns: A string representation of the decimal, formatted according to the default format style.
    public func formatted() -> String {
        self._polyfill_formatted()
    }
    
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
    public func formatted<S: FormatStyle>(_ format: S) -> S.FormatOutput where Self == S.FormatInput {
        self._polyfill_formatted(format)
    }
    
    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: ParseStrategy>(
        _ value: S.ParseInput,
        strategy: S
    ) throws where S.ParseOutput == Self {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: Self.FormatStyle, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: Self.FormatStyle.Percent, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }

    /// Initialize an instance by parsing `value` with a ``ParseStrategy`` created with the given `format`
    /// and the `lenient` argument.
    public init(_ value: String, format: Self.FormatStyle.Currency, lenient: Bool = true) throws {
        try self.init(value, _polyfill_format: format, lenient: lenient)
    }
}

extension Foundation.Date {
    public typealias FormatString = _polyfill_DateFormatString

    /// A structure that creates a locale-appropriate string representation of a date instance and
    /// converts strings of dates and times into date instances.
    ///
    /// A date format style shares the date and time formatting pattern preferred by the user’s locale
    /// for formatting and parsing.
    ///
    /// When you want to apply a specific formatting style to a single `Date` instance, use
    /// ``FormatStyle``. For other instances, use the following:
    ///
    /// - When working with date representations in ISO 8601 format, use ``ISO8601FormatStyle``.
    /// - To represent an interval between two date instances, use ``RelativeFormatStyle``.
    /// - To represent two dates as a pair, for example to get output that looks like
    ///   `10/21/1985 1:45 PM - 9/13/2015 6:33 PM`, use ``IntervalFormatStyle``.
    ///
    /// ## Formatting String Representations of Dates and Times
    ///
    /// ``FormatStyle`` provides a variety of localized presets and configuration options to create
    /// user-visible representations of dates and times from instances of `Date`.
    ///
    /// When displaying a date to a user, use the `formatted(date:time:)` instance method. Set the date
    /// and time styles of the date format style separately, according to your particular needs.
    ///
    /// For example, to create a string with a full date and no time representation, set the
    /// ``FormatStyle/DateStyle`` to ``FormatStyle/DateStyle/complete`` and the ``FormatStyle/TimeStyle``
    /// to ``FormatStyle/DateStyle/omitted``. Conversely, to create a string representing only the time
    /// for the current locale and time zone, set the date style to ``FormatStyle/DateStyle/omitted`` and
    /// the time style to ``FormatStyle/TimeStyle/complete``, as the following code illustrates:
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .complete, time: .omitted) // Sunday, January 17, 2021
    /// birthday.formatted(date: .omitted, time: .complete) // 4:03:12 p.m. CST
    /// ```
    ///
    /// The results shown are for locale set to `en_US` and time zone set to `CST`.
    ///
    /// You can create string representations of a `Date` instance with various levels of brevity
    /// using preset date and time styles. The following example shows date styles of
    /// ``FormatStyle/DateStyle/long``, ``FormatStyle/DateStyle/abbreviated``,
    /// and ``FormatStyle/DateStyle/numeric``, and time styles of ``FormatStyle/TimeStyle/shortened``,
    /// ``FormatStyle/TimeStyle/standard``, and ``FormatStyle/TimeStyle/complete``:
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .long, time: .shortened) // January 17, 2021, 4:03 PM
    /// birthday.formatted(date: .abbreviated, time: .standard) // Jan 17, 2021, 4:03:12 PM
    /// birthday.formatted(date: .numeric, time: .complete) // 1/17/2021, 4:03:12 PM CST
    ///
    /// birthday.formatted() // Jan 17, 2021, 4:03 PM
    /// ```
    ///
    /// The default date style is ``FormatStyle/DateStyle/abbreviated`` and the default time style
    /// is ``FormatStyle/TimeStyle/shortened``.
    ///
    /// For full customization of the string representation of a date, use the `formatted(_:)` instance
    /// method of `Date` and provide a ``FormatStyle`` instance.
    ///
    /// You can apply more customization of the date and time components and their representation in your
    /// app by appying a series of convenience modifiers to your format style. The following example applies
    /// a series of modifiers to the format style to precisely define the formatting of the year, month, day,
    /// hour, minute, and timezone components of the resulting string. The ordering of the date and time
    /// modifiers has no impact on the string produced.
    ///
    /// ```swift
    /// // Call the .formatted method on an instance of Date passing in an instance of Date.FormatStyle.
    ///
    /// let birthday = Date()
    ///
    /// birthday.formatted(
    ///     Date.FormatStyle()
    ///         .year(.defaultDigits)
    ///         .month(.abbreviated)
    ///         .day(.twoDigits)
    ///         .hour(.defaultDigits(amPM: .abbreviated))
    ///         .minute(.twoDigits)
    ///         .timeZone(.identifier(.long))
    ///         .era(.wide)
    ///         .dayOfYear(.defaultDigits)
    ///         .weekday(.abbreviated)
    ///         .week(.defaultDigits)
    /// )
    /// // Sun, Jan 17, 2021 Anno Domini (week: 4), 11:18 AM America/Chicago
    /// ```
    ///
    /// ``FormatStyle`` provides a convenient factory variable, ``FormatStyle/dateTime``, used to shorten
    /// the syntax when applying date and time modifiers to customize the format, as in the following example:
    ///
    /// ```swift
    /// let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
    /// for localeID in localeArray {
    ///     print(meetingDate.formatted(.dateTime
    ///              .day(.twoDigits)
    ///              .month(.wide)
    ///              .weekday(.short)
    ///              .hour(.conversationalTwoDigits(amPM: .wide))
    ///              .locale(Locale(identifier: localeID))))
    /// }
    ///
    /// // Th, November 12, 7 PM
    /// // to 12 november 19
    /// // Th 12 November, 19
    /// // พฤ. 12 พฤศจิกายน 19
    /// // je 12 novembre, 19 h
    /// ```
    ///
    /// ## Parsing Dates and Times
    ///
    /// To parse a `Date` instance from an input string, use a date parse strategy. For example:
    ///
    /// ```swift
    /// let inputString = "Archive for month 8, archived on day 23 - complete."
    /// let strategy = Date.ParseStrategy(format: "Archive for month \(month: .defaultDigits), archived on day \(day: .twoDigits) - complete.", locale: Locale(identifier: "en_US"), timeZone: TimeZone(abbreviation: "CDT")!)
    /// if let date = try? Date(inputString, strategy: strategy) {
    ///    print(date.formatted()) // "Aug 23, 2000 at 12:00 AM"
    /// }
    /// ```
    ///
    /// The time defaults to midnight local time unless explicitly defined.
    ///
    /// The parse instance method attempts to parse a provided string into an instance of date using the
    /// source date format style. The function throws an error if it can’t parse the input string into a
    /// date instance.
    ///
    /// You can use ``FormatStyle`` for round-trip formatting and parsing in a locale-aware manner. This
    /// date format style guides parsing the date instance from an input string, as the following
    /// code demonstrates:
    ///
    /// ```swift
    /// let birthdayFormatStyle = Date.FormatStyle()
    ///     .year(.defaultDigits)
    ///     .month(.abbreviated)
    ///     .day(.twoDigits)
    ///     .hour(.defaultDigits(amPM: .abbreviated))
    ///     .minute(.twoDigits)
    ///     .timeZone(.identifier(.long))
    ///     .era(.abbreviated)
    ///     .weekday(.abbreviated)
    ///
    /// let yourBirthdayString = "Mon, Feb 17, 1997 AD, 1:27 AM America/Chicago"
    ///
    /// // Create a date instance from a string representation of a date.
    /// let yourBirthday = try? birthdayFormatStyle.parse(yourBirthdayString)
    /// // Feb 17, 1997 at 1:27 AM
    /// ```
    ///
    /// The following round-trip date formatting example uses a date format style to create a locale-aware
    /// string representation of a date instance. Then, the date format style guides parsing the newly
    /// created string into a new date instance.
    ///
    /// ```swift
    /// let myFormat = Date.FormatStyle()
    ///     .year()
    ///     .day()
    ///     .month()
    ///     .locale(Locale(identifier: "en_US"))
    ///
    /// let dateString = Date().formatted(myFormat)
    /// // "Feb 17, 2021" for the "en_US" locale
    ///
    /// print(dateString) // Feb 17, 2021
    ///
    /// if let anniversary = try? Date(dateString, strategy: myFormat) {
    ///     print(anniversary.formatted(myFormat)) // Feb 17, 2021
    ///     print(anniversary.formatted()) // 2/17/2021, 12:00 AM
    /// } else {
    ///     print("Can't parse string into date with this format.")
    /// }
    /// ```
    ///
    /// After this code executes, `anniversary` contains a `Date` instance parsed from `dateString`.
    ///
    /// ## Applying Format Styles Repeatedly
    ///
    /// Once you create a date format style, you can use it to format dates multiple times.
    ///
    /// You can use a format style to parse a set of date instances from a set of string representations
    /// of dates. Then, use another format style, applied repeatedly, to produce more detailed string
    /// representations of those dates for a different locale. For example:
    ///
    /// ```swift
    /// func formatIntroDates() {
    ///    let inputFormat = Date.FormatStyle()
    ///       .locale(Locale(identifier: "en_GB"))
    ///       .year()
    ///       .month()
    ///       .day()
    ///     // Parse string inputs into date instances.
    ///     guard let productIntroDate = try? Date("9 Jan 2007", strategy: inputFormat) else { return }
    ///     guard let anotherIntroDate = try? Date("27 Jan 2010", strategy: inputFormat) else { return }
    ///     guard let conferenceDate = try? Date("7 Jun 2021", strategy: inputFormat) else { return }
    ///
    ///     let outputFormat = Date.FormatStyle() // Define format style for string output.
    ///         .locale(Locale(identifier: "en_US"))
    ///         .year()
    ///         .month(.wide)
    ///         .day(.twoDigits)
    ///         .weekday(.abbreviated)
    ///
    ///     // Apply the output format on the three dates below.
    ///     print(outputFormat.format(conferenceDate)) // Mon, June 07, 2021
    ///     print(outputFormat.format(anotherIntroDate)) // Wed, January 27, 2010
    ///     print(outputFormat.format(productIntroDate)) // Tue, January 09, 2007
    /// }
    /// ```
    public typealias FormatStyle = _polyfill_DateFormatStyle
    
    /// A structure that creates a locale-appropriate attributed string representation of a date instance.
    ///
    /// Use a ``FormatStyle`` instance to customize the lexical representation of a date as a string. Use
    /// the format style’s ``FormatStyle/attributed`` property to customize the visual representation of
    /// the date as a string. Attributed strings can represent the subcomponent characters, words, and
    /// phrases of a string with a custom combination of font size, weight, and color.
    ///
    /// For example, the function below uses a date format style to create a custom lexical representation
    /// of a date, then retrieves an attributed string representation of the same date and applies a visual
    /// emphasis to the year component of the date.
    ///
    /// ```swift
    /// // Applies visual emphasis to the year component of a formatted attributed date string.
    /// private func makeAttributedString() -> AttributedString {
    ///     let date = Date()
    ///     let formatStyle = Date.FormatStyle(date: .abbreviated, time: .standard)
    ///     var attributedString = formatStyle.attributed.format(date)
    ///     for run in attributedString.runs {
    ///         if let dateFieldAttribute = run.attributes.foundation.dateField,
    ///            dateFieldAttribute == .year {
    ///             // When you find a year, change its attributes.
    ///             attributedString[run.range].inlinePresentationIntent = [.emphasized, .stronglyEmphasized]
    ///         }
    ///     }
    ///     return attributedString
    /// }
    /// ```
    ///
    /// The expression `formatStyle.attributed.format(date)` above creates an attributed string representation
    /// of the date. This assigns instances of the `AttributeScopes.FoundationAttributes.DateFieldAttribute` to
    /// indicate ranges of the string that represent different date fields. The example then loops over the runs
    /// of the attributed string to find any run with the
    /// `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year` attribute. When it finds one, it
    /// adds the `inlinePresentationIntent` attributes `emphasized` and `stronglyEmphasized`.
    ///
    /// The runs of the resulting attributed string have the following attributes:
    ///
    /// | Run text | Attributes                                                             |
    /// |:---------|:-----------------------------------------------------------------------|
    /// | `Mar`    | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.month`  |
    /// | `15`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.day`    |
    /// | `2022`   | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year`   |
    /// |          | `emphasized`                                                           |
    /// |          | `stronglyEmphasized`                                                   |
    /// | `10`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.hour`   |
    /// | `06`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.minute` |
    /// | `46`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.second` |
    /// | `AM`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.amPM`   |
    ///
    /// If you create a SwiftUI `Text` view with this attributed string, SwiftUI renders the combination
    /// of `emphasized` and `stronglyEmphasized` attributes as bold, italicized text, as seen in the
    /// following screenshot.
    ///
    /// ![A macOS window with a text view showing the current date and time. The year is displayed
    /// in bold, italicized text.][sampleimg]
    ///
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMzk4IiBoZWlnaHQ9IjE1MiIgdmlld0JveD0iMCAwIDM5OCAxNTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NTAwIDI3LjVweCAnU0YgUHJvIFRleHQnLHNhbnMtc2VyaWY7bGV0dGVyLXNwYWNpbmc6MHB4Ij48ZGVmcz48bGluZWFyR3JhZGllbnQgaWQ9ImEiIHgyPSIwIiB5MT0iNTYiIHkyPSI1OCIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPjxzdG9wIHN0b3AtY29sb3I9IiNiZWJlYmUiLz48c3RvcCBzdG9wLWNvbG9yPSIjZTllOWU5IiBvZmZzZXQ9IjEiLz48L2xpbmVhckdyYWRpZW50PjwvZGVmcz48cGF0aCBkPSJtMCw1Ni41aDM5OHptMCwxaDM5OHoiIHN0cm9rZT0idXJsKCNhKSIvPjxnIHN0cm9rZS13aWR0aD0iMiI%2BPHBhdGggZD0ibTIsNTZoMzk0di00MWMwLTcuMi01LjgtMTMtMTMtMTNoLTM2OGMtNy4yLDAtMTMsNS44LTEzLDEzeiIgZmlsbD0iI2ZiZmJmYiIvPjxwYXRoIGQ9Im0yLDU4aDM5NHY4MWMwLDcuMi01LjgsMTMtMTMsMTNoLTM2OGMtNy4yLDAtMTMtNS44LTEzLTEzeiIgZmlsbD0iI2Y0ZjRmNCIvPjxjaXJjbGUgY3g9IjY4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiNmOGFmMjQ7c3Ryb2tlOiNkZmE2NGMiLz48Y2lyY2xlIGN4PSIyOCIgY3k9IjI4IiByPSIxMS41IiBzdHlsZT0iZmlsbDojZjY0NTQ2O3N0cm9rZTojZTE2MjY0Ii8%2BPGNpcmNsZSBjeD0iMTA4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiMyOWMyMzE7c3Ryb2tlOiMyN2FmMzAiLz48cmVjdCB4PSIxIiB5PSIxIiB3aWR0aD0iMzk2IiBoZWlnaHQ9IjE1MCIgcng9IjE0IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojY2JjYmNiIi8%2BPC9nPjx0ZXh0IHg9IjMxIiB5PSIxMTQiPk1hciAxNSw8dHNwYW4gc3R5bGU9ImZvbnQtd2VpZ2h0OjgwMDtmb250LXN0eWxlOml0YWxpYyI%2BIDIwMjI8L3RzcGFuPiwgMTA6MDY6NDYgQU08L3RleHQ%2BPHRleHQgeD0iMTM2IiB5PSIzNyIgZm9udC13ZWlnaHQ9IjcwMCI%2BRGF0ZUZvcm1hdFRvQXR04oCmPC90ZXh0Pjwvc3ZnPg%3D%3D
    public typealias AttributedStyle = _polyfill_DateAttributedStyle

    /// A style that formats a date with an explicitly-specified style.
    public typealias VerbatimFormatStyle = _polyfill_DateVerbatimFormatStyle

    /// A format style that forms locale-aware string representations of a relative date or time.
    ///
    /// Use the strings that the format style produces, such as “1 hour ago”, “in 2 weeks”, “yesterday”,
    /// and “tomorrow” as standalone strings. Embedding them in other strings may not be grammatically correct.
    ///
    /// Express relative date formats in either `numeric` or `named` styles. For example:
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
    ///     var formatStyle = Date.RelativeFormatStyle()
    ///
    ///     formatStyle.presentation = .numeric
    ///     past.formatted(formatStyle) // "1 week ago"
    ///
    ///     formatStyle.presentation = .named
    ///     past.formatted(formatStyle) // "last week"
    /// }
    /// ```
    ///
    /// Use the convenient static factory method `relative(presentation:unitsStyle:)` to shorten the
    /// syntax when applying presentation and units style modifiers to customize the format. For example:
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
    ///     past.formatted(.relative(presentation: .numeric)) // "in 1 week"
    ///     past.formatted(.relative(presentation: .named)) // "next week"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .wide)) // "next week"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .narrow)) // "next wk."
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)) // "next wk."
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .spellOut)) // "next week"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .wide)) // "in 1 week"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)) // "in 1 wk."
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)) // "in 1 wk."
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .spellOut)) // "in one week"
    /// }
    /// ```
    ///
    /// The `format(_:)` instance method generates a string from the provided relative date. Once
    /// you create a style, you can use it to format relative dates multiple times.
    ///
    /// The following example applies a format style repeatedly to produce string representations
    /// of relative dates:
    ///
    /// ```swift
    /// if let pastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()),
    ///   let pastDay = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
    ///
    ///     let formatStyle = Date.RelativeFormatStyle(
    ///         presentation: .named,
    ///         unitsStyle: .spellOut,
    ///         locale: Locale(identifier: "en_GB"),
    ///         calendar: Calendar.current,
    ///         capitalizationContext: .beginningOfSentence)
    ///
    ///     formatStyle.format(pastDay) // "Yesterday"
    ///     formatStyle.format(pastWeek) // "Last week"
    /// }
    /// ```
    public typealias RelativeFormatStyle = _polyfill_DateRelativeFormatStyle

    /// A format style that creates string representations of date intervals.
    ///
    /// Use a date interval format style to create user-readable strings in the form of
    /// `<start> - <end>` for your app’s interface, where `<start>` and `<end>` are date values
    /// that you supply. The format style uses locale and language information, along with custom
    /// formatting options, to define the content of the resulting string.
    ///
    /// ``IntervalFormatStyle`` provides a variety of localized presets and configuration options to
    /// create user-visible representations of date intervals. When displaying a date interval to a user,
    /// use the `formatted(date:time:)` instance method of `Range<Date>`. Set the date and time styles
    /// of the date interval format style separately, according to your particular needs.
    ///
    /// For example, to create a date interval string with a full date and no time representation, set
    /// the ``IntervalFormatStyle/DateStyle`` to `complete` and the ``IntervalFormatStyle/TimeStyle`` to
    /// `omitted`. The following example creates a formatted interval string with this style:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
    ///     let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
    ///     // today: June 5, 2023
    ///     // thirtyDaysBeforeToday: May 6, 2023
    ///
    ///     // Create a Range<Date>.
    ///     let last30days = thirtyDaysBeforeToday..<today
    ///
    ///     let formatted = last30days.formatted(date: .complete, time: .omitted)
    ///     // "Saturday, January 30 – Monday, March 1, 2021"
    /// }
    /// ```
    ///
    /// You can create string representations of date intervals with various levels of brevity using a
    /// variety of preset date and time styles. The following example shows date styles of `long`,
    /// `abbreviated`, and `numeric`, and time styles of `shortened`, `standard`, and `complete`:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
    ///    let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
    ///    // today: Mar 1, 2021 at 8:01 PM
    ///    // thirtyDaysBeforeToday: Jan 30, 2021 at 8:01 PM
    ///
    ///    // Create a Range<Date>.
    ///    let last30days = thirtyDaysBeforeToday..<today
    ///
    ///    print(last30days.formatted(date: .long, time: .shortened))
    ///    // January 30, 2021, 8:01 PM – March 1, 2021, 8:01 PM
    ///
    ///    print(last30days.formatted(date: .abbreviated, time: .standard))
    ///    // Jan 30, 2021, 8:01:49 PM – Mar 1, 2021, 8:01:49 PM
    ///
    ///    print(last30days.formatted(date: .numeric, time: .complete))
    ///    // 1/30/2021, 8:01:49 PM CST – 3/1/2021, 8:01:49 PM CST
    ///
    ///    print(last30days.formatted())
    ///    // 1/30/21, 8:01 PM – 3/1/21, 8:01 PM
    /// }
    /// ```
    ///
    /// The default date style is `abbreviated` and the default time style is `shortened`.
    ///
    /// For full customization of the string representation of a date interval, use the `formatted(_:)`
    /// instance method of `Range<Date>` and provide a ``IntervalFormatStyle`` instance.
    ///
    /// You can achieve any customization of date and time representation your app requires by appying a
    /// series of convenience modifiers to your format style. The following example applies a series of
    /// modifiers to the format style to precisely define the formatting of the year, month, day, hour,
    /// minute, and time zone components of the resulting string:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysAfterToday = Calendar.current.date(byAdding: .day, value: 7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekFromNow = today..<sevenDaysAfterToday
    ///
    ///     // Call the .formatted method on a Range<Date> and pass in an instance of Date.IntervalFormatStyle.
    ///     weekFromNow.formatted(
    ///         Date.IntervalFormatStyle()
    ///             .year()
    ///             .month(.abbreviated)
    ///             .day()
    ///             .hour(.defaultDigits(amPM: .narrow))
    ///             .weekday(.abbreviated)
    ///     ) //  Wed, Feb 10, 2021, 3 p – Wed, Feb 17, 2021, 3 p
    /// }
    /// ```
    ///
    /// ``IntervalFormatStyle`` provides a convenient factory variable, `interval`, to shorten the syntax
    /// when applying date and time modifiers to customize the format.
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
    ///     for localeID in localeArray {
    ///         // Call the .formatted method on a Range<Date> and pass in an instance of Date.IntervalFormatStyle.
    ///         print(weekBefore.formatted(.interval
    ///                  .day()
    ///                  .month(.wide)
    ///                  .weekday(.short)
    ///                  .hour(.conversationalTwoDigits(amPM: .wide))
    ///                  .locale(Locale(identifier: localeID))))
    ///     }
    /// }
    /// // We, February 3, 3 PM – We, February 10, 3 PM
    /// // on 3 februari 15 – on 10 februari 15
    /// // We 3 February, 15 – We 10 February, 15
    /// // พ. 3 กุมภาพันธ์ 15 – พ. 10 กุมภาพันธ์ 15
    /// // me 3 février, 15 h – me 10 février, 15 h
    /// ```
    public typealias IntervalFormatStyle = _polyfill_DateIntervalFormatStyle

    /// A type that converts between dates and their ISO-8601 string representations.
    ///
    /// The ``ISO8601FormatStyle`` type generates and parses string representations of dates following
    /// the ISO-8601 standard, like `2024-04-01T12:34:56.789Z`. Use this type to create ISO-8601
    /// representations of dates and create dates from text strings in ISO 8601 format. For other formatting
    /// conventions, like human-readable, localized date formats, use ``FormatStyle``.
    ///
    /// Instance modifier methods applied to an ISO-8601 format style customize the formatted output, as
    /// the following example illustrates.
    ///
    /// ```swift
    /// let now = Date()
    /// print(now.formatted(Date.ISO8601FormatStyle().dateSeparator(.dash)))
    /// // 2021-06-21T211015Z
    /// ```
    ///
    /// Use the static factory property `iso8601` to create an instance of ``ISO8601FormatStyle``. Then
    /// apply instance modifier methods to customize the format, as in the example below.
    ///
    /// ```swift
    /// let meetNow = Date()
    /// let formatted = meetNow.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .timeZone(separator: .omitted)
    ///     .time(includingFractionalSeconds: true)
    ///     .timeSeparator(.colon)
    /// ) // "2022-06-10T12:34:56.789Z"
    /// ```
    public typealias ISO8601FormatStyle = _polyfill_DateISO8601FormatStyle

    /// Options for parsing string representations of dates to create a `Date` instance.
    public typealias ParseStrategy = _polyfill_DateParseStrategy

    public init<T: ParseStrategy>(_ value: T.ParseInput, strategy: T) throws where T.ParseOutput == Self {
        try self.init(value, _polyfill_strategy: strategy)
    }

    @_disfavoredOverload
    public init<T: ParseStrategy>(_ value: some StringProtocol, strategy: T) throws where T.ParseOutput == Self, T.ParseInput == String {
        try self.init(value, _polyfill_strategy: strategy)
    }

    /// Generates a locale-aware string representation of a date using the specified date format style.
    ///
    /// - Parameter format: The date format style to apply to the date.
    /// - Returns: A string, formatted according to the specified style.
    ///
    /// For full customization of the string representation of a date, use the `formatted(_:)` instance method
    /// of `Date` and provide a ``FormatStyle`` object.
    ///
    /// You can achieve any customization of date and time representation your app requires by appying a series of
    /// convenience modifiers to your format style. This example applies a series of modifiers to the format style
    /// to precisely define the formatting of the year, month, day, hour, minute, and timezone components of the
    /// resulting string.
    ///
    /// ```swift
    /// // Call the .formatted method on an instance of Date passing in an instance of Date.FormatStyle.
    /// let birthday = Date()
    ///
    /// birthday.formatted(
    ///     Date.FormatStyle()
    ///         .year(.defaultDigits)
    ///         .month(.abbreviated)
    ///         .day(.twoDigits)
    ///         .hour(.defaultDigits(amPM: .abbreviated))
    ///         .minute(.twoDigits)
    ///         .timeZone(.identifier(.long))
    ///         .era(.wide)
    ///         .dayOfYear(.defaultDigits)
    ///         .weekday(.abbreviated)
    ///         .week(.defaultDigits)
    /// )
    /// // Sun, Jan 17, 2021 Anno Domini (week: 4), 11:18 AM America/Chicago
    /// ```
    ///
    /// For the default date formatting, use the `formatted()` method. For basic customization of the formatted
    /// date string, use the `formatted(date:time:)` and include a date and time style.
    ///
    /// For more information about formatting dates, see ``FormatStyle``.
    public func formatted<F: FormatStylePolyfill.FormatStyle>(_ format: F) -> F.FormatOutput where F.FormatInput == Foundation.Date {
        self._polyfill_formatted(format)
    }

    /// Generates a locale-aware string representation of a date using specified date and time format styles.
    ///
    /// - Parameters:
    ///   - date: The date format style to apply to the date.
    ///   - time: The time format style to apply to the date.
    /// - Returns: A string, formatted according to the specified date and time styles.
    ///
    /// When displaying a date to a user, use the convenient `formatted(date:time:)` instance method to customize
    /// the string representation of the date. Set the date and time styles of the date format style separately,
    /// according to your particular needs.
    ///
    /// For example, to create a string with a full date and no time representation, set the
    /// ``FormatStyle/DateStyle`` to `complete` and the ``FormatStyle/TimeStyle`` to `omitted`. Conversely, to
    /// create a string representing only the time, set the date style to `omitted` and the time style to `complete`.
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .complete, time: .omitted) // Sunday, January 17, 2021
    /// birthday.formatted(date: .omitted, time: .complete) // 4:03:12 PM CST
    /// ```
    ///
    /// You can create string representations of a `Date` instance with several levels of brevity using a variety
    /// of preset date and time styles. This example shows date styles of `long`, `abbreviated`, and `numeric`, and
    /// time styles of `shortened`, `standard`, and `complete`.
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .long, time: .shortened) // January 17, 2021, 4:03 PM
    /// birthday.formatted(date: .abbreviated, time: .standard) // Jan 17, 2021, 4:03:12 PM
    /// birthday.formatted(date: .numeric, time: .complete) // 1/17/2021, 4:03:12 PM CST
    ///
    /// birthday.formatted() // Jan 17, 2021, 4:03 PM
    /// ```
    ///
    /// The default date style is `abbreviated` and the default time style is `shortened`.
    ///
    /// For the default date formatting, use the `formatted()` method. To customize the formatted measurement
    /// string, use the `formatted(_:)` method and include a ``FormatStyle``.
    ///
    /// For more information about formatting dates, see the ``FormatStyle``.
    public func formatted(date: Foundation.Date.FormatStyle.DateStyle, time: Foundation.Date.FormatStyle.TimeStyle) -> String {
        self._polyfill_formatted(date: date, time: time)
    }

    /// Generates a locale-aware string representation of a date using the default date format style.
    ///
    /// - Returns: A string, formatted according to the default style.
    ///
    /// Use the `formatted()` method to apply the default format style to a date, as in the following example:
    ///
    /// ```swift
    /// let birthday = Date()
    /// print(birthday.formatted())
    /// // 6/4/2021, 2:24 PM
    /// ```
    ///
    /// The default date format style uses the `numeric` date style and the `shortened` time style.
    ///
    /// To customize the formatted measurement string, use either the `formatted(_:)` method and
    /// include a `Measurement.FormatStyle` or the `formatted(date:time:)` and include a date and time style.
    ///
    /// For more information about formatting dates, see ``FormatStyle``.
    public func formatted() -> String {
        self._polyfill_formatted()
    }

    /// Generates a locale-aware string representation of a date using the ISO 8601 date format.
    ///
    /// - Parameter style: A customized ``ISO8601FormatStyle`` to apply. By default, the method applies an
    ///   unmodified ISO 8601 format style.
    /// - Returns: A string, formatted according to the specified style.
    ///
    /// Calling this method is equivalent to passing a ``ISO8601FormatStyle`` to a date’s `formatted()` method.
    public func ISO8601Format(_ style: Foundation.Date.ISO8601FormatStyle = .init()) -> String {
        self._polyfill_ISO8601Format(style)
    }
}

extension RegexComponent where Self == Foundation.Date.ParseStrategy {
    public typealias DateStyle = _polyfill_DateParseStrategy._polyfill_DateStyle
    public typealias TimeStyle = _polyfill_DateParseStrategy._polyfill_TimeStyle

    /// Creates a regex component to match a localized date string following the specified format
    /// and capture the string as a `Date`.
    ///
    /// - Parameters:
    ///   - format: The date format that describes the localized date string. For example,
    ///     `"\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)"` matches `"05_04_22"`
    ///     as May 4th, 2022 in the Gregorian calendar.
    ///   - locale: The locale of the date string to be matched.
    ///   - timeZone: The time zone to create the matched date with.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar
    ///     of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func date(
        format: Foundation.Date.FormatString,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil,
        twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
    ) -> Self {
        ._polyfill_date(format: format, locale: locale, timeZone: timeZone, calendar: calendar, twoDigitStartDate: twoDigitStartDate)
    }

    /// Creates a regex component to match a localized date and time string and capture the string as
    /// a `Date`. The date string is expected to follow the format of what
    /// `Date.FormatStyle(date:time:locale:calendar:)` produces.
    ///
    /// - Parameters:
    ///   - date: The style that describes the date part of the string. For example, `.numeric` matches
    ///     `"10/21/2015"`, and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US`
    ///     locale.
    ///   - time: The style that describes the time part of the string.
    ///   - locale: The locale of the string to be matched.
    ///   - timeZone: The time zone to create the matched date with. Ignored if the string contains a time
    ///     zone and matches the specified style.
    ///   - calendar: The calendar with which to interpret the date string. If set to nil, the default
    ///     calendar of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    ///
    /// > Note: If the string contains a time zone and matches the specified style, then the `timeZone`
    /// > argument is ignored. For example, "Oct 21, 2015 4:29:24 PM PDT" matches
    /// > `.dateTime(date: .abbreviated, time: .complete, ...)` and is captured as
    /// > `October 13, 2022, 20:29:24 PDT` regardless of the `timeZone` value.
    public static func dateTime(
        date: Foundation.Date.FormatStyle.DateStyle,
        time: Foundation.Date.FormatStyle.TimeStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Self {
        ._polyfill_dateTime(date: date, time: time, locale: locale, timeZone: timeZone, calendar: calendar)
    }

    /// Creates a regex component to match a localized date string and capture the string as a `Date`.
    /// The string is expected to follow the format of what `Date.FormatStyle(date:locale:calendar:)`
    /// produces. `Date` created by this regex component would be at `00:00:00` in the specified time zone.
    ///
    /// - Parameters:
    ///   - style: The style that describes the date string. For example, `.numeric` matches `"10/21/2015"`,
    ///     and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US` locale.
    ///     `.omitted` is invalid.
    ///   - locale: The locale of the string to be matched. Generally speaking, the language of the locale
    ///     is used to parse the date parts if the string contains localized numbers or words, and the region
    ///     of the locale specifies the order of the date parts. For example, `"3/5/2015"` represents
    ///     March 5th, 2015 in `en_US`, but represents May 3rd, 2015 in `en_GB`.
    ///   - timeZone: The time zone to create the matched date with. For example, parsing `"Oct 21, 2015"`
    ///     with the `PDT` time zone returns a date representing October 21, 2015 at 00:00:00 PDT.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar of
    ///     the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func date(
        _ style: Foundation.Date.FormatStyle.DateStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Self {
        ._polyfill_date(style, locale: locale, timeZone: timeZone, calendar: calendar)
    }
}

extension RegexComponent where Self == Foundation.Date.ISO8601FormatStyle {
    /// Creates a regex component to match an ISO 8601 date and time, such as "2015-11-14'T'15:05:03'Z'",
    /// and capture the string as a `Date` using the time zone as specified in the string.
    @_disfavoredOverload
    public static var iso8601: Self { ._polyfill_iso8601 }

    /// Creates a regex component to match an ISO 8601 date and time string, including time zone, and
    /// capture the string as a `Date` using the time zone as specified in the string.
    ///
    /// - Parameters:
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    ///   - timeZoneSeparator: The separator between time parts in the time zone.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string, including time zone.
    public static func iso8601WithTimeZone(
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon,
        timeZoneSeparator: Self.TimeZoneSeparator = .omitted
    ) -> Self {
        ._polyfill_iso8601WithTimeZone(
            includingFractionalSeconds: includingFractionalSeconds,
            dateSeparator: dateSeparator,
            dateTimeSeparator: dateTimeSeparator,
            timeSeparator: timeSeparator,
            timeZoneSeparator: timeZoneSeparator
        )
    }

    /// Creates a regex component to match an ISO 8601 date and time string without time zone, and
    /// capture the string as a `Date` using the specified `timeZone`. If the string contains time
    /// zone designators, matches up until the start of time zone designators.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string.
    public static func iso8601(
        timeZone: Foundation.TimeZone,
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon
    ) -> Self {
        ._polyfill_iso8601(
            timeZone: timeZone,
            includingFractionalSeconds: includingFractionalSeconds,
            dateSeparator: dateSeparator,
            dateTimeSeparator: dateTimeSeparator,
            timeSeparator: timeSeparator
        )
    }

    /// Creates a regex component to match an ISO 8601 date string, such as "2015-11-14", and
    /// capture the string as a `Date`. The captured `Date` would be at midnight in the specified `timeZone`.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - dateSeparator: The separator between date components.
    /// - Returns:  A `RegexComponent` to match an ISO 8601 date string, including time zone.
    public static func iso8601Date(timeZone: Foundation.TimeZone, dateSeparator: Self.DateSeparator = .dash) -> Self {
        ._polyfill_iso8601Date(timeZone: timeZone, dateSeparator: dateSeparator)
    }
}

extension Range where Bound == Foundation.Date {
    /// Formats the date range as an interval.
    public func formatted() -> String {
        self._polyfill_formatted()
    }
    
    /// Formats the date range using the specified date and time format styles.
    public func formatted(
        date: Foundation.Date.IntervalFormatStyle.DateStyle,
        time: Foundation.Date.IntervalFormatStyle.TimeStyle
    ) -> String {
        self._polyfill_formatted(date: date, time: time)
    }
    
    /// Formats the date range using the specified style.
    public func formatted<S>(_ style: S) -> S.FormatOutput where S: FormatStyle, S.FormatInput == Range<Foundation.Date> {
        self._polyfill_formatted(style)
    }
}

extension Foundation.URL {
    /// A structure that converts between URL instances and their textual representations.
    ///
    /// Instances of `URL.FormatStyle` create localized, human-readable text from `URL` instances and parse string
    /// representations of URLs into instances of `URL`.
    ///
    /// ## Formatting URLs
    ///
    /// Use the `formatted()` method to create a string representation of a `URL` using the default
    /// `URL.FormatStyle` configuration. As seen in the following example, the default style creates a
    /// string with the scheme, host, and path, but not the port or query.
    ///
    /// ```swift
    /// let url = URL(string:"https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted() // "https://www.example.com/path/to/endpoint"
    /// ```
    ///
    /// You can specify a format style by providing an argument to the `format(_:)` method. The following example
    /// uses the previous URL, but preserves only the host and path.
    ///
    /// ```swift
    /// let url = URL(string:"https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let style = URL.FormatStyle(scheme: .never,
    ///                             user: .never,
    ///                             password: .never,
    ///                             host: .always,
    ///                             port: .never,
    ///                             path: .always,
    ///                             query: .never,
    ///                             fragment: .never)
    /// let formatted = style.format(url) // "www.example.com/path/to/endpoint"
    /// ```
    ///
    /// Instantiate a style when you want to format multiple `URL` instances with the same style. For one-time
    /// access to a default style, you can use the static accessor url at call points that expect the
    /// `URL.FormatStyle` type, such as the `format(_:)` method. This means you can write the example above
    /// as follows:
    ///
    /// ```swift
    /// let url = URL(string:"https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted(.url
    ///     .scheme(.never)
    ///     .host(.always)
    ///     .port(.never)
    ///     .path(.always)
    ///     .query(.never)) // "www.example.com/path/to/endpoint"
    /// ```
    ///
    /// This example works by taking the default style provided by `url`, then customizing it with calls to the
    /// style modifiers in `Customizing style behavior`.
    ///
    /// ## Parsing URLs
    ///
    /// You can use `URL.FormatStyle` to parse strings into `URL` values. To do this, create a `URL.ParseStrategy`
    /// from a format style, then call the strategy’s `parse(_:)` method.
    ///
    /// ```swift
    /// let style = URL.FormatStyle(scheme: .always,
    ///                             user: .never,
    ///                             password: .never,
    ///                             host: .always,
    ///                             port: .always,
    ///                             path: .always,
    ///                             query: .always,
    ///                             fragment: .never)
    /// let urlString = "https://www.example.com:8080/path/to/endpoint?key=value"
    /// let url = try? style.parseStrategy.parse(urlString)
    /// ```
    ///
    /// ## Matching regular expressions
    ///
    /// Along with parsing URL values in strings, you can use the regular expression domain-specific language
    /// provided by Swift to match and capture URL substrings. The following example scans source input that’s
    /// expected to contain a timestamp, some whitespace, and a URL.
    ///
    /// ```swift
    /// import RegexBuilder
    /// let source = "7/31/2022, 5:15:12 AM  https://www.example.com/productList?query=slushie"
    /// let matcher = Regex {
    ///     One(.dateTime(date: .numeric,
    ///                   time: .standard,
    ///                   locale: Locale(identifier: "en_US"),
    ///                   timeZone: TimeZone(identifier: "PST")!))
    ///     OneOrMore(.horizontalWhitespace)
    ///     Capture {
    ///         One(.url(scheme: .required,
    ///                  user: .optional,
    ///                  password: .optional,
    ///                  host: .required,
    ///                  port: .defaultValue(8088),
    ///                  path: .optional,
    ///                  query: .optional,
    ///                  fragment: .optional))
    ///     }
    /// }
    /// guard let match = source.firstMatch(of: matcher) else { return }
    /// let url = match.1 // url = https://www.example.com:8088/productList?query=slushie
    /// ```
    public typealias FormatStyle = _polyfill_URLFormatStyle

    /// Formats the URL, using the provided format style.
    ///
    /// - Parameter format: The format style to apply when formatting the URL.
    /// - Returns: A formatted string representation of the URL.
    ///
    /// Use this method when you want to format a single URL value with a specific format style, or call
    /// it repeatedly with different format styles. The following example uses the static accessor `url` to
    /// get a default style, then modifies its behavior to include or omit different URL components when
    /// `formatted(_:)` creates the string:
    ///
    /// ```swift
    /// let url = URL(string:"https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted(.url
    ///     .scheme(.never)
    ///     .host(.always)
    ///     .port(.never)
    ///     .path(.always)
    ///     .query(.never)) // "www.example.com/path/to/endpoint"
    /// ```
    public func formatted<F>(_ format: F) -> F.FormatOutput where F: FormatStyle, F.FormatInput == Self {
        self._polyfill_formatted(format)
    }

    /// Formats the URL using a default format style.
    ///
    /// Use this method to create a string representation of a URL using the default `URL.FormatStyle`
    /// configuration. As seen in the following example, the default style creates a string with the
    /// scheme, host, and path, but not the port or query.
    ///
    /// ```swift
    /// let url = URL(string:"https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted() // "https://www.example.com/path/to/endpoint"
    /// ```
    ///
    /// To customize formatting of the URL, use `formatted(_:)`, passing in a customized `FormatStyle`.
    ///
    /// - Returns: A string representation of the URL, formatted according to the default format style.
    public func formatted() -> String {
        self._polyfill_formatted()
    }

    /// A parse strategy for creating URLs from formatted strings.
    ///
    /// Create an explicit `URL.ParseStrategy` to parse multiple strings according to the same parse strategy. The
    /// following example creates a customized strategy, then applies it to multiple URL candidate strings.
    ///
    /// ```swift
    /// let strategy = URL.ParseStrategy(
    ///     scheme: .defaultValue("https"),
    ///     user: .optional,
    ///     password: .optional,
    ///     host: .required,
    ///     port: .optional,
    ///     path: .required,
    ///     query: .required,
    ///     fragment: .optional)
    /// let urlStrings = [
    ///     "example.com?key1=value1", // no scheme or path
    ///     "https://example.com?key2=value2", // no path
    ///     "https://example.com", // no query
    ///     "https://example.com/path?key4=value4", // complete
    ///     "//example.com/path?key5=value5" // complete except for default-able scheme
    /// ]
    /// let urls = urlStrings.map { try? strategy.parse($0) }
    /// // [nil, nil, nil, Optional(https://example.com/path?key4=value4), Optional(https://example.com/path?key5=value5)]
    /// ```
    ///
    /// You don’t need to instantiate a parse strategy instance to parse a single string. Instead, use the `URL`
    /// initializer `init(_:strategy:)`, passing in a string to parse and a customized strategy, typically created
    /// with one of the static accessors. The following example parses a URL string, with a custom strategy that
    /// provides a default value for the port component if the source string doesn’t specify one.
    ///
    /// ```swift
    /// let urlString = "https://internal.example.com/path/to/endpoint?key=value"
    /// let url = try? URL(urlString, strategy: .url
    ///     .port(.defaultValue(8080))) // https://internal.example.com:8080/path/to/endpoint?key=value
    /// ```
    public typealias ParseStrategy = _polyfill_URLParseStrategy

    /// Creates a URL instance by parsing the provided input in accordance with a parse strategy.
    ///
    /// - Parameters:
    ///   - value: The value to parse, as the input type accepted by strategy. For `URL.ParseStrategy`,
    ///     this is `String`.
    ///   - strategy: A parse strategy to apply when parsing `value`.
    ///
    /// The following example parses a URL string, with a custom strategy that provides a default value
    /// for the port component if the source string doesn’t specify one.
    ///
    /// ```swift
    /// let urlString = "https://internal.example.com/path/to/endpoint?key=value"
    /// let url = try? URL(urlString, strategy: .url
    ///     .port(.defaultValue(8080))) // https://internal.example.com:8080/path/to/endpoint?key=value
    /// ```
    public init<T>(
        _ value: T.ParseInput,
        strategy: T
    ) throws
        where T: ParseStrategy, T.ParseOutput == Self
    {
        self.init(value, _polyfill_strategy: strategy)
    }
}

extension RegexComponent where Self == Foundation.URL.ParseStrategy {
    /// Returns a custom strategy for parsing a URL.
    /// 
    /// - Parameters:
    ///   - scheme: A strategy for parsing the scheme component.
    ///   - user: A strategy for parsing the user component.
    ///   - password: A strategy for parsing the password component.
    ///   - host: A strategy for parsing the host component.
    ///   - port: A strategy for parsing the port component.
    ///   - path: A strategy for parsing the path component.
    ///   - query: A strategy for parsing the query component.
    ///   - fragment: A strategy for parsing the fragment component.
    /// - Returns: A strategy for parsing URL strings, with the specified behavior for each component.
    ///
    /// Use the dot-notation form of this method when the call point allows the use of `URL.ParseStrategy`.
    /// Typically, you use this with the `URL` initializer `init(_:strategy:)`.
    public static func url(
        scheme:   Self.ComponentParseStrategy<String> = .required,
        user:     Self.ComponentParseStrategy<String> = .optional,
        password: Self.ComponentParseStrategy<String> = .optional,
        host:     Self.ComponentParseStrategy<String> = .required,
        port:     Self.ComponentParseStrategy<Int>    = .optional,
        path:     Self.ComponentParseStrategy<String> = .optional,
        query:    Self.ComponentParseStrategy<String> = .optional,
        fragment: Self.ComponentParseStrategy<String> = .optional
    ) -> Self {
        self._polyfill_url(
            scheme: scheme,
            user: user,
            password: password,
            host: host,
            port: port,
            path: path,
            query: query,
            fragment: fragment
        )
    }
}
#endif
