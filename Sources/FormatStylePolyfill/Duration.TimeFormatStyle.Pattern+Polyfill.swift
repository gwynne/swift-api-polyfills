import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle {
    /// The units to display a Duration with and configurations for the units.
    public struct _polyfill_Pattern: Swift.Hashable, Swift.Codable, Sendable {
        private var fields: Fields
        private var paddingForLargestField: Int?
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
    private enum Fields: Swift.Hashable, Swift.Codable {
        case hourMinute(roundSeconds: Swift.FloatingPointRoundingRule)
        case hourMinuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: Swift.FloatingPointRoundingRule)
        case minuteSecond(fractionalSecondsLength: Int, roundFractionalSeconds: Swift.FloatingPointRoundingRule)
        
        var hasHours: Bool {
            switch self {
            case .hourMinute, .hourMinuteSecond: true
            default: false
            }
        }
        
        var hasSeconds: Bool {
            switch self {
            case .hourMinuteSecond, .minuteSecond: true
            default: false
            }
        }
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

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    fileprivate func fractionalSeconds() -> Double {
        Double(self.components.seconds)
            .addingProduct(Double(self.components.attoseconds), 1e-18)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern {
    internal func format(_ value: Swift.Duration, in locale: Foundation.Locale) -> String {
        let maxFormatter = NumberFormatter(locale: locale, integerWidth: self.paddingForLargestField ?? 1)
        let hoursStr: String?
        let minutesStr: String?
        let secondsStr: String?
        
        switch self.fields {
        case .hourMinute(roundSeconds: let rounding):
            let minutesFmt = NumberFormatter(locale: locale, rounding: rounding)
            
            let allMinutes = Int((value.fractionalSeconds() / 60.0).rounded(rounding))
            let (hours, minutes) = allMinutes.quotientAndRemainder(dividingBy: 60)
            
            hoursStr = maxFormatter.string(from: hours) ?? "?"
            minutesStr = minutesFmt.string(from: minutes) ?? "??"
            secondsStr = nil
            
        case .hourMinuteSecond(fractionalSecondsLength: let fracLen, roundFractionalSeconds: let rounding):
            let minutesFmt = NumberFormatter(locale: locale)
            let secondsFmt = NumberFormatter(locale: locale, fractionWidth: fracLen, rounding: rounding)
            
            

            let (hours, most) = value.components.seconds.quotientAndRemainder(dividingBy: 3600)
            let (minutes, more) = most.quotientAndRemainder(dividingBy: 60)
            let seconds = Double(more) + 1.0e-18 * Double(value.components.attoseconds)
            
            var secondsStr = secondsFmt.string(from: seconds) ?? "??", minutesStr: String, hoursStr: String

            if secondsStr.starts(with: "60") {
                secondsStr = secondsFmt.string(from: seconds - 60) ?? "??"
                minutesStr = minutesFmt.string(from: minutes + 1) ?? "??"
            } else {
                minutesStr = minutesFmt.string(from: minutes) ?? "??"
            }
            
            if minutesStr.starts(with: "60") {
                minutesStr = minutesFmt.string(from: minutes - 60) ?? "??"
                hoursStr = hoursFmt.string(from: hours + 1) ?? "?"
            } else {
                hoursStr = hoursFmt.string(from: hours) ?? "?"
            }
            return "\(hoursStr):\(minutesStr):\(secondsStr)"
                   
        case .minuteSecond(fractionalSecondsLength: let fracLen, roundFractionalSeconds: let rounding):
            let secondsFmt = NumberFormatter(locale: locale, fractionWidth: fracLen, rounding: rounding)

            let (minutes, most) = value.components.seconds.quotientAndRemainder(dividingBy: 60)
            let seconds = Double(most) + 1.0e-18 * Double(value.components.attoseconds)

            var secondsStr = secondsFmt.string(from: seconds) ?? "??", minutesStr: String

            if secondsStr.starts(with: "60") {
                secondsStr = secondsFmt.string(from: seconds - 60) ?? "??"
                minutesStr = minutesFmt.string(from: minutes + 1) ?? "?"
            } else {
                minutesStr = minutesFmt.string(from: minutes) ?? "?"
            }
            return "\(minutesStr):\(secondsStr)"
        }
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration.TimeFormatStyle {
    /// The units to display a Duration with and configurations for the units.
    public typealias Pattern = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern
}

#endif
