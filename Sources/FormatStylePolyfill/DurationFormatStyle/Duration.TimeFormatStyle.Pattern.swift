extension _polyfill_DurationTimeFormatStyle {
    /// The units — including hours, minutes, or seconds — and the configuration of those units, used to
    /// format a duration.
    ///
    /// Use a pattern when initializing a `Duration.TimeFormatStyle`, or creating a time format style from the
    /// convenience method `time(pattern:)`.
    ///
    /// Use the type properties `hourMinute`, `hourMinuteSecond`, or `minuteSecond` to create patterns with
    /// default behavior. To customize how a pattern handles zero-padding and fractional parts, use one of the
    /// type methods that take these customizations as parameters.
    public struct Pattern: Hashable, Codable, Sendable {
        var fields: Fields
        var paddingForLargestField: Int?
    }
}

extension _polyfill_DurationTimeFormatStyle.Pattern {
    enum Fields: Hashable, Codable {
        case hourMinute(roundSeconds: FloatingPointRoundingRule)
        case hourMinuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: FloatingPointRoundingRule)
        case minuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: FloatingPointRoundingRule)
    }

    /// A pattern to format a duration with hours and minutes only, with default padding and rounding behavior.
    public static var hourMinute: Self {
        .init(fields: .hourMinute(roundSeconds: .toNearestOrEven))
    }

    /// Returns a pattern to format a duration with hours and minutes only, with the given unit configurations.
    ///
    /// - Parameters:
    ///   - padHourToLength: Padding for the hour field. For example, setting this value to `2` formats one hour
    ///     as `01:00` in the `en_US` locale.
    ///   - roundSeconds: The rule to use for rounding the minutes value, given the remaining seconds value. Use
    ///     one of the cases from the `FloatingPointRoundingRule` enumeration.
    /// - Returns: A `Duration.TimeFormatStyle.Pattern` that formats a duration with hours and minutes only, using
    ///   the given unit configurations.
    public static func hourMinute(
        padHourToLength: Int,
        roundSeconds: FloatingPointRoundingRule = .toNearestOrEven
    ) -> Self {
        .init(fields: .hourMinute(roundSeconds: roundSeconds), paddingForLargestField: padHourToLength)
    }

    /// A pattern to format a duration with hours, minutes, and seconds, with default padding and rounding behavior.
    public static var hourMinuteSecond: Self {
        .init(fields: .hourMinuteSecond(fractionalSecondsLength: 0, roundFractionalSeconds: .toNearestOrEven))
    }

    /// Returns a pattern to format a duration with hours, minutes, and seconds, with the given unit configurations.
    ///
    /// - Parameters:
    ///   - padHourToLength: Padding for the hour field. For example, setting this value to `2` formats one hour
    ///     as `01:00` in the `en_US` locale.
    ///   - fractionalSecondsLength: The length of the fractional seconds. For example, setting this value to `2`
    ///     formats one hour as `1:00:00.00` in the `en_US` locale.
    ///   - roundFractionalSeconds: The rule to use for rounding the seconds value, given the remaining fractional
    ///     seconds value. Use one of the cases from the `FloatingPointRoundingRule` enumeration.
    /// - Returns: A `Duration.TimeFormatStyle.Pattern` that formats a duration with hours, minutes, and seconds,
    ///   using the given unit configurations.
    public static func hourMinuteSecond(
        padHourToLength: Int,
        fractionalSecondsLength: Int = 0,
        roundFractionalSeconds: Swift.FloatingPointRoundingRule = .toNearestOrEven
    ) -> Self {
        .init(
            fields: .hourMinuteSecond(
                fractionalSecondsLength: fractionalSecondsLength,
                roundFractionalSeconds: roundFractionalSeconds
            ),
            paddingForLargestField: padHourToLength
        )
    }

    /// A pattern to format a duration with minutes and seconds only, with default padding and rounding behavior.
    public static var minuteSecond: Self {
        .init(fields: .minuteSecond(fractionalSecondsLength: 0, roundFractionalSeconds: .toNearestOrEven))
    }

    /// Returns a pattern to format a duration with minutes and seconds only, with the given unit configurations.
    ///
    /// - Parameters:
    ///   - padMinuteToLength: Padding for the minute field. For example, setting this value to `2` formats five
    ///     minutes as `05:00` in the `en_US` locale.
    ///   - fractionalSecondsLength: The length of the fractional seconds. For example, setting this value to `2`
    ///     formats five minutes as `5:00.00` in the `en_US` locale.
    ///   - roundFractionalSeconds: The rule to use for rounding the seconds value, given the remaining fractional
    ///     seconds value. Use one of the cases from the `FloatingPointRoundingRule` enumeration.
    /// - Returns: A `Duration.TimeFormatStyle.Pattern` that formats a duration with minutes and seconds, using
    ///   the given unit configurations.
    public static func minuteSecond(
        padMinuteToLength: Int,
        fractionalSecondsLength: Int = 0,
        roundFractionalSeconds: Swift.FloatingPointRoundingRule = .toNearestOrEven
    ) -> Self {
        .init(
            fields: .minuteSecond(
                fractionalSecondsLength: fractionalSecondsLength,
                roundFractionalSeconds: roundFractionalSeconds
            ),
            paddingForLargestField: padMinuteToLength
        )
    }
}
