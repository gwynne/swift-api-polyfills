#if !canImport(Darwin)

import struct Foundation.Decimal

/// A type that can convert a given data type into a representation.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias FormatStyle = _polyfill_FormatStyle

/// Configuration settings for formatting numbers of different types.
///
/// This type is effectively a namespace to collect types that configure parts of a formatted number,
/// such as grouping, precision, and separator and sign characters.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias NumberFormatStyleConfiguration = _polyfill_NumberFormatStyleConfiguration

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
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias FloatingPointFormatStyle<Value> = _polyfill_FloatingPointFormatStyle<Value>

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// A ``FormatStyle`` that displays a duration as a list of duration units, such as
    /// "2 hours, 43 minutes, 26 seconds" in English.
    public typealias UnitsFormatStyle = Swift.Duration._polyfill_UnitsFormatStyle
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public typealias TimeFormatStyle = Swift.Duration._polyfill_TimeFormatStyle
}


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
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
    /// - `Duration.UnitsFormatStyle` shows durations with localized labeled components, like “2 min, 3 sec”.
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
    /// `units(allowed:width:maximumUnitCount:zeroValueUnits:valueLength:fractionalPart:)` in any call that expects
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias DescriptiveNumberFormatConfiguration = _polyfill_DescriptiveNumberFormatConfiguration

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias FormatStyleCapitalizationContext = _polyfill_FormatStyleCapitalizationContext

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal {
    public typealias FormatStyle = Foundation.Decimal._polyfill_FormatStyle
}

/// Configuration settings for formatting currency values.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias CurrencyFormatStyleConfiguration = _polyfill_CurrencyFormatStyleConfiguration

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias ByteCountFormatStyle = _polyfill_ByteCountFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias IntegerFormatStyle = _polyfill_IntegerFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias ListFormatStyle = _polyfill_ListFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias StringStyle = _polyfill_StringStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.Sequence {
    public func _polyfill_formatted<S: FormatStyle>(_ style: S) -> S.FormatOutput where S.FormatInput == Self {
        self._polyfill_formatted(style)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.Sequence<String> {
    public func formatted() -> String {
        self._polyfill_formatted()
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias ByteCountFormatStyle = _polyfill_ByteCountFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.BinaryInteger {
    /// Format `self` using `IntegerFormatStyle`
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension BinaryFloatingPoint {
    /// Format `self` with `FloatingPointFormatStyle`.
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

#endif
