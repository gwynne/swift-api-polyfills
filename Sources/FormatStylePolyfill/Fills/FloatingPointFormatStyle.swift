#if !canImport(Darwin)

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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle {
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
    /// [sampleimg]: data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjY1IiBoZWlnaHQ9Ijk0IiB2aWV3Qm94PSIwIDAgNzAgMjUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NjAwIDEycHggJ1NGIFBybyBEaXNwbGF5JyxzYW5zLXNlcmlmO2ZpbGw6cmVkIj48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMjUiIHN0eWxlPSJmaWxsOiNmNGY0ZjQ7c3Ryb2tlOiNkZGQiLz48dGV4dCB4PSI2IiB5PSIxNyI%2BJDwvdGV4dD48dGV4dCB4PSIxNCIgeT0iMTYuOCIgZmlsbD0iIzAwMCI%2BMSwyMzTigIjigIk1NjwvdGV4dD48dGV4dCB4PSI0NSIgeT0iMTciPi48L3RleHQ%2BPC9zdmc%2B
    public typealias Attributed = _polyfill_FloatingPointFormatStyle._polyfill_Attributed

    public typealias Configuration = _polyfill_FloatingPointFormatStyle._polyfill_Configuration
}

#endif
