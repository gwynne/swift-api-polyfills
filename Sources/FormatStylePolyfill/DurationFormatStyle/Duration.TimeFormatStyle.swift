import struct Foundation.Locale

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
public struct _polyfill_DurationTimeFormatStyle: Sendable {
    /// Creates a time format style using the provided pattern and optional locale.
    /// 
    /// - Parameters:
    ///   - pattern: A `Pattern` that specifies the units to include in the displayed string and the behavior of
    ///     the units.
    ///   - locale: The `Locale` used to create the string representation of the duration. This parameter defaults
    ///     to `autoupdatingCurrent`.
    public init(pattern: Self.Pattern, locale: Foundation.Locale = .autoupdatingCurrent) {
        self.attributed = .init(locale: locale, pattern: pattern)
    }

    /// A property that formats the duration as an attributed string.
    ///
    /// Apply the `attributed` property to a configured `Duration.TimeFormatStyle` to produce an
    /// `Duration.TimeFormatStyle.Attributed` style. You can then format a duration with this style to create
    /// a formatted `AttributedString`. The formatted attributed string contains instances of
    /// `AttributeScopes.FoundationAttributes.DateFieldAttribute` for runs with formatted durations.
    ///
    /// The following example formats a duration as an attributed string:
    ///
    /// ```swift
    /// let duration = Duration.seconds(70 * 60 + 32) +
    ///     Duration.milliseconds(400)
    /// let style = Duration.TimeFormatStyle(pattern: .hourMinuteSecond).attributed
    /// let attributedDuration = duration.formatted(style)
    /// ```
    ///
    /// The resulting `attributedDuration`, representing the string `1:10:32` contains the following runs:
    ///
    /// Run|Attributes
    /// :-|:-
    /// `1`|`Foundation.DurationFormatAttribute = hours`
    /// `:`|None
    /// `10`|`Foundation.DurationFormatAttribute = minutes`
    /// `:`|None
    /// `32`|`Foundation.DurationFormatAttribute = seconds`
    public var attributed: Self.Attributed

    /// The locale to use when formatting the duration.
    public var locale: Foundation.Locale {
        get { self.attributed.locale }
        set { self.attributed.locale = newValue }
    }

    /// The pattern to display a Duration with.
    public var pattern: Self.Pattern {
        get { self.attributed.pattern }
        set { self.attributed.pattern = newValue }
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DurationTimeFormatStyle {
    /// Creates a time format style using the provided pattern, from a type method.
    ///
    /// Use this convenience factory function in situations that expect a `Duration.TimeFormatStyle`, such as
    /// `formatted(_:)`, as an alternative to using the full initializer.
    ///
    /// - Parameter pattern: A `Pattern` that specifies the units to include in the displayed string and the behavior
    ///   of the units.
    /// - Returns: A format style to format a duration.
    public static func time(pattern: Self.Pattern) -> Self {
        .init(pattern: pattern)
    }
}

extension _polyfill_DurationTimeFormatStyle: _polyfill_FormatStyle {
    /// Creates a locale-aware string representation from a duration value.
    ///
    /// - Parameter value: The value to format.
    /// - Returns: A string representation of the duration.
    public func format(_ value: Swift.Duration) -> String {
        String(self.attributed.format(value).characters[...])
    }

    /// Modifies the format style to use the specified locale.
    ///
    /// - Parameter locale: The locale to use when formatting a duration.
    /// - Returns: A format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var res = self
        res.locale = locale
        return res
    }
}
