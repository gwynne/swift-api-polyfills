#if !canImport(Darwin)

import struct Foundation.Date
import struct Foundation.Decimal

/// A type that can convert a given data type into a representation.
public typealias FormatStyle = _polyfill_FormatStyle

/// A type that can parse a representation of a given data type.
public typealias ParseStrategy = _polyfill_ParseStrategy

/// A type that can convert a given data type into a representation.
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

extension Swift.Duration {
    /// A ``FormatStyle`` that displays a duration as a list of duration units, such as
    /// "2 hours, 43 minutes, 26 seconds" in English.
    public typealias UnitsFormatStyle = _polyfill_DurationUnitsFormatStyle
}

extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
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

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where S: FormatStyle, S.FormatInput: BinaryInteger {
        self._polyfill_formatted(format)
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
        self._polyfill_formatted(FormatStyle)
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
        self.init(value, _polyfill_strategy: strategy)
    }

    @_disfavoredOverload
    public init<T: ParseStrategy>(_ value: some StringProtocol, strategy: T) throws where T.ParseOutput == Self, T.ParseInput == String {
        self.init(value, _polyfill_strategy: strategy)
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

#endif
