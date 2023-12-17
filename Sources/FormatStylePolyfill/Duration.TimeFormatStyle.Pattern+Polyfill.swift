import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle {
    /// The units to display a Duration with and configurations for the units.
    public struct _polyfill_Pattern: Swift.Hashable, Swift.Codable, Sendable {
        internal var fields: Fields
        internal var paddingForLargestField: Int?
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
    internal enum Fields: Swift.Hashable, Swift.Codable {
        case hourMinute(roundSeconds: Swift.FloatingPointRoundingRule)
        case hourMinuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: Swift.FloatingPointRoundingRule)
        case minuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: Swift.FloatingPointRoundingRule)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
    /// Displays a duration in hours and minutes.
    public static var hourMinute: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(fields: .hourMinute(roundSeconds: .toNearestOrEven))
    }

    /// Displays a duration in terms of hours and minutes with the specified configurations.
    /// - Parameters:
    ///   - padHourToLength: Padding for the hour field. For example, one hour is formatted as "01:00" in en_US locale when this value is set to 2.
    ///   - roundSeconds: Rounding rule for the remaining second values.
    /// - Returns: A pattern to format a duration with.
    public static func hourMinute(
        padHourToLength: Int,
        roundSeconds: Swift.FloatingPointRoundingRule = .toNearestOrEven
    ) -> Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(fields: .hourMinute(roundSeconds: roundSeconds), paddingForLargestField: padHourToLength)
    }

    /// Displays a duration in hours, minutes, and seconds.
    public static var hourMinuteSecond: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(fields: .hourMinuteSecond(fractionalSecondsLength: 0, roundFractionalSeconds: .toNearestOrEven))
    }

    /// Displays a duration in terms of hours, minutes, and seconds with the specified configurations.
    /// - Parameters:
    ///   - padHourToLength: Padding for the hour field. For example, one hour is formatted as "01:00:00" in en_US locale when this value is set to 2.
    ///   - fractionalSecondsLength: The length of the fractional seconds. For example, one hour is formatted as "1:00:00.00" in en_US locale when this value is set to 2.
    ///   - roundFractionalSeconds: Rounding rule for the fractional second values.
    /// - Returns: A pattern to format a duration with.
    public static func hourMinuteSecond(
        padHourToLength: Int,
        fractionalSecondsLength: Int = 0,
        roundFractionalSeconds: Swift.FloatingPointRoundingRule = .toNearestOrEven
    ) -> Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(
            fields: .hourMinuteSecond(fractionalSecondsLength: fractionalSecondsLength, roundFractionalSeconds: roundFractionalSeconds),
            paddingForLargestField: padHourToLength
        )
    }

    /// Displays a duration in minutes and seconds. For example, one hour is formatted as "60:00" in en_US locale.
    public static var minuteSecond: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(fields: .minuteSecond(fractionalSecondsLength: 0, roundFractionalSeconds: .toNearestOrEven))
    }

    /// Displays a duration in minutes and seconds with the specified configurations.
    /// - Parameters:
    ///   - padMinuteToLength: Padding for the minute field. For example, five minutes is formatted as "05:00" in en_US locale when this value is set to 2.
    ///   - fractionalSecondsLength: The length of the fractional seconds. For example, one hour is formatted as "1:00:00.00" in en_US locale when this value is set to 2.
    ///   - roundFractionalSeconds: Rounding rule for the fractional second values.
    /// - Returns: A pattern to format a duration with.
    public static func minuteSecond(
        padMinuteToLength: Int,
        fractionalSecondsLength: Int = 0,
        roundFractionalSeconds: Swift.FloatingPointRoundingRule = .toNearestOrEven
    ) -> Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
        .init(
            fields: .minuteSecond(fractionalSecondsLength: fractionalSecondsLength, roundFractionalSeconds: roundFractionalSeconds),
            paddingForLargestField: padMinuteToLength
        )
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration.TimeFormatStyle {
    /// The units to display a Duration with and configurations for the units.
    public typealias Pattern = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern
}

#endif
