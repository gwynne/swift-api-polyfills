import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration {
    /// Formats the duration, using the provided format style.
    ///
    /// - Returns: A localized, formatted string that describes the duration. For example, a duration of 1 hour,
    ///   30 minutes, and 56 seconds in the `en_US` locale with a `Duration.TimeFormatStyle` returns `1:30:56`.
    ///   In the Finnish locale, this returns `1.30.56`.
    ///
    /// Use this formatting method to apply a custom style when formatting a duration.
    ///
    /// There are two format styles that apply to durations:
    ///
    /// - `Duration.TimeFormatStyle` shows durations in a compact, numeric, localized form, like “2:03”.
    /// - `Duration.UnitsFormatStyle` shows durations with localized labeled components, like “2 min, 3 sec”.
    ///
    /// The following example uses a custom `Duration.TimeFormatStyle` that shows hours, minutes, and seconds,
    /// and pads the hour part to a minimum of two characters. When it formats a two-second duration, this produces
    /// the string `00:00:02`.
    ///
    /// ```swift
    /// let duration = Duration.seconds(2)
    /// let style = Duration.TimeFormatStyle(pattern: .hourMinuteSecond(padHourToLength: 2))
    /// let formatted = duration.formatted(style) // "00:00:02".
    /// ```
    ///
    /// Instead of explicitly initializing styles, you can use `time(pattern:)` or
    /// `units(allowed:width:maximumUnitCount:zeroValueUnits:valueLength:fractionalPart:)` in any call that expects
    /// a `FormatStyle` whose input type is `Duration`. This allows you to rewrite the above example as follows:
    ///
    /// ```swift
    /// let duration = Duration.seconds(2)
    /// let formatted = duration.formatted(
    ///     .time(pattern: .hourMinuteSecond(padHourToLength: 2))) // "00:00:02".
    ///  ```
    public func _polyfill_formatted<S>(_ v: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput == Swift.Duration {
        v.format(self)
    }
    
    /// Formats `self` using the hour-minute-second time pattern
    ///
    /// - Returns: A formatted string to describe the duration, such as "1:30:56" for a duration of 1 hour,
    ///   30 minutes, and 56 seconds
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(.time(pattern: .hourMinuteSecond))
    }
}
