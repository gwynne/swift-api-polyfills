import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Locale
import CLegacyLibICU
import Collections
import PolyfillCommon

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
public struct _polyfill_DurationUnitsFormatStyle: _polyfill_FormatStyle, Sendable {
    /// The locale to use when formatting the duration.
    public var locale: Foundation.Locale

    /// The units that may be included in the output string.
    public var allowedUnits: Set<Self.Unit>

    /// The width of the unit and the spacing between the value and the unit.
    public var unitWidth: Self.UnitWidth

    /// The maximum number of time units to include in the output string.
    public var maximumUnitCount: Int?

    /// The strategy for how zero-value units are handled.
    public var zeroValueUnitsDisplay: Self.ZeroValueUnitsDisplayStrategy

    /// The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
    public var fractionalPartDisplay: Self.FractionalPartDisplayStrategy

    /// The padding or truncating behavior of the unit value.
    ///
    /// For example, set this to `2...` to force 2-digit padding on all units.
    public var valueLengthLimits: Range<Int>?

    /// Creates an instance using the provided specifications.
    ///
    /// - Parameters:
    ///   - allowedUnits: The units that may be included in the output string.
    ///   - width: The width of the unit and the spacing between the value and the unit.
    ///   - maximumUnitCount: The maximum number of time units to include in the output string.
    ///   - zeroValueUnits: The strategy for how zero-value units are handled.
    ///   - valueLength: The padding or truncating behavior of the unit value. Negative values are ignored.
    ///   - fractionalPart: The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
    public init(
        allowedUnits: Set<Self.Unit>,
        width: Self.UnitWidth,
        maximumUnitCount: Int? = nil,
        zeroValueUnits: Self.ZeroValueUnitsDisplayStrategy = .hide,
        valueLength: Int? = nil,
        fractionalPart: Self.FractionalPartDisplayStrategy = .hide
    ) {
        self.allowedUnits = allowedUnits
        self.unitWidth = width
        self.maximumUnitCount = maximumUnitCount
        self.zeroValueUnitsDisplay = zeroValueUnits
        self.fractionalPartDisplay = fractionalPart
        if let valueLength, valueLength > 0 {
            let upperBound = min(Int.max - 1, valueLength)
            self.valueLengthLimits = upperBound ..< upperBound + 1
        } else {
            self.valueLengthLimits = nil
        }
        self.locale = .autoupdatingCurrent
    }

    /// Creates an instance using the provided specifications.
    ///
    /// - Parameters:
    ///   - allowedUnits: The units that may be included in the output string.
    ///   - width: The width of the unit and the spacing between the value and the unit.
    ///   - maximumUnitCount: The maximum number of time units to include in the output string.
    ///   - zeroValueUnits: The strategy for how zero-value units are handled.
    ///   - valueLengthLimits: The padding or truncating behavior of the unit value. Values with negative bounds are ignored.
    ///   - fractionalPart: The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
    public init(
        allowedUnits: Set<Self.Unit>,
        width: Self.UnitWidth,
        maximumUnitCount: Int? = nil,
        zeroValueUnits: Self.ZeroValueUnitsDisplayStrategy = .hide,
        valueLengthLimits: some RangeExpression<Int>,
        fractionalPart: Self.FractionalPartDisplayStrategy = .hide
    ) {
        self.allowedUnits = allowedUnits
        self.unitWidth = width
        self.maximumUnitCount = maximumUnitCount
        self.zeroValueUnitsDisplay = zeroValueUnits
        self.fractionalPartDisplay = fractionalPart
        let (lower, upper) = valueLengthLimits.clampedLowerAndUpperBounds(0 ..< Int.max)
        if lower == nil && upper == nil { self.valueLengthLimits = nil }
        else { self.valueLengthLimits = (lower ?? 0) ..< (upper ?? Int.max) }
        self.locale = .autoupdatingCurrent
    }

    /// A modifier to set the locale of the format style.
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: A copy of this format with the new locale set.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }

    /// Creates a locale-aware string representation from a duration value.
    ///
    /// - Parameter duration: The value to format.
    /// - Returns: A string representation of the duration.
    public func format(_ duration: Duration) -> String {
        let formattedFields = self.formatFields(duration)
        var result = self.getFullListPattern(length: formattedFields.count)
        for formattedField in formattedFields.reversed() {
            result.replaceSubrange(result.range(of: "{0}", options: [.backwards])!, with: formattedField)
        }
        return result
    }
}

extension _polyfill_DurationUnitsFormatStyle {
    /// Returns a `Duration.UnitsFormatStyle.Attributed` style to format a duration as an attributed string
    /// using the configuration of this format style. Units in the string are annotated with the
    /// `durationField` and `measurement` attribute keys and the `DurationFieldAttribute` and
    /// `MeasurementAttribute` attribute values.
    ///
    /// For example, formatting a duration of 2 hours, 43 minutes, 26.25 second in `en_US` locale yields the
    /// following, conceptually:
    ///
    /// ```swift
    /// 2 { durationField: .hours, component: .value }
    /// hours { durationField: .hours, component: .unit }
    /// , { nil }
    /// 43 { durationField: .minutes, component: .value }
    /// minutes { durationField: .minutes, component: .unit }
    /// , { nil }
    /// 26.25 { durationField: .seconds, component: .value }
    /// seconds { durationField: .seconds, component: .unit }
    /// ```
    public var attributed: Self.Attributed {
        .init(innerStyle: self)
    }

    /// A format style to format a duration as an attributed string. Units in the string are annotated with the
    /// `durationField` and `measurement` attribute keys and the `DurationFieldAttribute` and `MeasurementAttribute`
    /// attribute values.
    ///
    /// You can use `Duration.UnitsFormatStyle` to configure the style, and create an `Attributed` format with
    /// its `public var attributed: Attributed`
    ///
    /// For example, formatting a duration of 2 hours, 43 minutes, 26.25 second in `en_US` locale yields the
    /// following, conceptually:
    ///
    /// ```swift
    /// 2 { durationField: .hours, component: .value }
    /// hours { durationField: .hours, component: .unit }
    /// , { nil }
    /// 43 { durationField: .minutes, component: .value }
    /// minutes { durationField: .minutes, component: .unit }
    /// , { nil }
    /// 26.25 { durationField: .seconds, component: .value }
    /// seconds { durationField: .seconds, component: .unit }
    /// ```
    public struct Attributed: _polyfill_FormatStyle, Sendable {
        var innerStyle: _polyfill_DurationUnitsFormatStyle

        /// Formats a duration as an attributed string with `DurationFieldAttribute`.
        public func format(_ duration: Swift.Duration) -> Foundation.AttributedString {
            let formattedFields = self.formatFields(duration)
            var result = Foundation.AttributedString(self.innerStyle.getFullListPattern(length: formattedFields.count))
            for formattedField in formattedFields.reversed() {
                result.replaceSubrange(result.range(of: "{0}", options: [.backwards])!, with: formattedField)
            }
            return result
        }

        /// A modifier to set the locale of the format style.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A copy of this format with the new locale set.
        public func locale(_ locale: Foundation.Locale) -> Self { .init(innerStyle: innerStyle.locale(locale)) }

        private func formatFields(_ duration: Swift.Duration) -> [Foundation.AttributedString] {
            self.innerStyle.getSkeletons(duration).map { skeleton, unit, value in
                let numberFormatter = ICUMeasurementNumberFormatter.create(for: skeleton, locale: self.innerStyle.locale)!
                let durationField: Foundation.AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field =
                    switch unit.unit {
                    case .weeks:        .weeks
                    case .days:         .days
                    case .hours:        .hours
                    case .minutes:      .minutes
                    case .seconds:      .seconds
                    case .milliseconds: .milliseconds
                    case .microseconds: .microseconds
                    case .nanoseconds:  .nanoseconds
                    }

                guard let (str, attributes) = numberFormatter.attributedFormatPositions(.floatingPoint(value)) else {
                    return .init(self.innerStyle.format(duration), attributes: .init().durationField(durationField))
                }

                var attrStr = Foundation.AttributedString(str)
                attrStr.durationField = durationField

                for attr in attributes {
                    if let range = Range(String.Index(utf16Offset: attr.begin, in: str) ..< .init(utf16Offset: attr.end, in: str), in: attrStr) {
                        attrStr[range].measurement = (attr.field == UNUM_MEASURE_UNIT_FIELD) ? .unit : .value
                    }
                }
                return attrStr
            }
        }
    }
}

extension _polyfill_DurationUnitsFormatStyle.Unit.RawUnit {
    private var subtype: String { switch self {
        case .weeks:        "week"
        case .days:         "day"
        case .hours:        "hour"
        case .minutes:      "minute"
        case .seconds:      "second"
        case .milliseconds: "millisecond"
        case .microseconds: "microsecond"
        case .nanoseconds:  "nanosecond"
    } }
    
    var icuSkeleton: String { "measure-unit/duration-\(self.subtype)" }
    
    var isSubsecond: Bool { self.rawValue > Self.seconds.rawValue }
}

extension _polyfill_DurationUnitsFormatStyle {
    /// A unit to use in formatting a duration.
    ///
    /// Supported units range from hours to nanoseconds. Use these with the `allowed` parameter of the
    /// `Duration.UnitsFormatStyle` initializers to specify which units to use in a formatted string.
    public struct Unit: Codable, Hashable, Sendable {
        enum RawUnit: Int, Codable, Hashable, Comparable {
            case weeks
            case days
            case hours
            case minutes
            case seconds
            case milliseconds
            case microseconds
            case nanoseconds

            static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue > rhs.rawValue }
        }
        
        var unit: RawUnit
     
        /// The unit for weeks. One week is always 604800 seconds.
        public static var weeks: Unit { .init(unit: .weeks) }

        /// The unit for days. One day is always 86400 seconds.
        public static var days: Unit { .init(unit: .days) }

        /// The hours unit, used for formatting a duration.
        public static var hours: Unit { .init(unit: .hours) }

        /// The minutes unit, used for formatting a duration.
        public static var minutes: Unit { .init(unit: .minutes) }

        /// The seconds unit, used for formatting a duration.
        public static var seconds: Unit { .init(unit: .seconds) }

        /// The milliseconds unit, used for formatting a duration.
        public static var milliseconds: Unit { .init(unit: .milliseconds) }

        /// The microseconds unit, used for formatting a duration.
        public static var microseconds: Unit { .init(unit: .microseconds) }

        /// The nanoseconds unit, used for formatting a duration.
        public static var nanoseconds: Unit { .init(unit: .nanoseconds) }
    }

    /// The width of a unit to use in formatting a duration.
    ///
    /// Use the provided unit widths with the `width` parameter of the `Duration.UnitsFormatStyle` initializers
    /// to customize the display of units in a formatted string.
    public struct UnitWidth: Codable, Hashable, Sendable {
        var width: ICUMeasurementNumberFormatter.UnitWidth
        var patternStyle: UATimeUnitStyle

        /// The full unit name.
        ///
        /// For example, `wide` produces the unit label “3 hours” for a 3-hour duration in the `en_US` locale.
        public static var wide: Self {
            .init(width: .wide, patternStyle: UATIMEUNITSTYLE_FULL)
        }

        /// An abbreviated unit name.
        ///
        /// For example, `abbreviated` produces the unit label “3 hr” for a 3-hour duration in the `en_US` locale.
        public static var abbreviated: Self {
            .init(width: .abbreviated, patternStyle: UATIMEUNITSTYLE_ABBREVIATED)
        }

        /// An abbreviated unit name, with condensed space between the value and name.
        ///
        /// For example, `condensedAbbreviated` produces the unit label “3hr” for a 3-hour duration in
        /// the `en_US` locale.
        public static var condensedAbbreviated: Self {
            .init(width: .abbreviated, patternStyle: UATIMEUNITSTYLE_SHORTER)
        }

        /// The shortest possible unit name.
        ///
        /// For example, `narrow` produces the unit label “3h” for a 3-hour duration in the `en_US` locale.
        public static var narrow: Self {
            .init(width: .narrow, patternStyle: UATIMEUNITSTYLE_NARROW)
        }
    }

    /// A strategy that determines how to format a unit whose value is zero.
    /// 
    /// When using a `Duration.UnitsFormatStyle`, specifying a `ZeroValueUnitsDisplayStrategy` enables you to
    /// decide whether show a unit whose value is zero.
    /// 
    /// The following example creates a duration of 25 seconds, then formats it with two different styles. The
    /// first style uses the `hide` display strategy, which omits the hours and minutes, since their value is `0`.
    /// The second uses `show(length:)` to create two-digit representations of the hour and minute fields.
    /// 
    /// ```swift
    /// let duration = Duration.seconds(25)
    /// let hide = duration.formatted(
    ///     .units(allowed: [.hours, .minutes, .seconds],
    ///            width: .abbreviated,
    ///            zeroValueUnits:.hide)) // 25 sec
    /// let showTwo = duration.formatted(
    ///     .units(allowed: [.hours, .minutes, .seconds],
    ///            width: .abbreviated,
    ///            zeroValueUnits:.show(length: 2))) // 00 hr, 00 min, 25 sec
    /// ```
    public struct ZeroValueUnitsDisplayStrategy: Codable, Hashable, Sendable {
        var length: Int

        /// A display strategy that hides leading fields whose value is zero.
        public static var hide: Self { .init(length: 0) }

        /// Returns display strategy that shows leading fields whose value is zero, with a given number of digits.
        /// 
        /// - Parameter length: The number of digits to show for zero-value units.
        public static func show(length: Int) -> Self { .init(length: length)}
    }
    
    /// A strategy that determines how to format the fractional part of a duration if the allowed units
    /// can’t represent it exactly.
    ///
    /// When using a `Duration.UnitsFormatStyle`, specifying a `FractionalPartDisplayStrategy` enables you to
    /// decide how to balance between accuracy and verbosity when you’re not using all of the available units
    /// (hours, minutes, and seconds). When a formatted duration has a fractional part, you can hide it entirely,
    /// round the unit up or down while hiding the fractional part, or show the unit with a fraction.
    ///
    /// The following example shows different display strategies used with a duration of 1 hour, 15 minutes and
    /// unit format styles that only show hours.
    ///
    /// ```swift
    /// let duration = Duration.seconds(75 * 60) // 1 minute, 15 seconds
    /// let hide = duration.formatted(
    ///     .units(allowed: [.hours],
    ///            width: .wide,
    ///            fractionalPart: .hide)) // 1 hour
    /// let hideRounded = duration.formatted(
    ///     .units(allowed: [.hours],
    ///            width: .wide,
    ///            fractionalPart: .hide(rounded:.up))) // 2 hours
    /// let show = duration.formatted(
    ///     .units(allowed: [.hours],
    ///            width: .wide,
    ///            fractionalPart: .show(length: 2))) // 1.25 hours
    /// ```
    public struct FractionalPartDisplayStrategy: Codable, Hashable, Sendable {
        /// The minimum length of the fractional part, if shown.
        public var minimumLength: Int
        
        /// The maximum length of the fractional part, if shown.
        public var maximumLength: Int
        
        /// The rule for rounding a unit up or down if it has a fractional part.
        public var roundingRule: FloatingPointRoundingRule
        
        /// A multiple by which a formatter rounds a fractional part of a duration.
        public var roundingIncrement: Double?

        private init(
            mininumLength: Int,
            maximumLength: Int,
            roundingRule: FloatingPointRoundingRule,
            roundingIncrement: Double?
        ) {
            self.minimumLength = mininumLength
            self.maximumLength = maximumLength
            self.roundingRule = roundingRule
            self.roundingIncrement = roundingIncrement
        }

        /// Creates a fractional part display strategy that uses the provided behaviors.
        ///
        /// - Parameters:
        ///   - lengthLimits: The maximum string length of the fractional part.
        ///   - roundingRule: A rule for rounding fractional values up or down. Defaults to
        ///     `FloatingPointRoundingRule.toNearestOrEven`.
        ///   - roundingIncrement: A multiple by which the formatter rounds the fractional part. The formatter
        ///     produces a value that is an even multiple of this increment. If this parameter is `nil`
        ///     (the default), the formatter doesn’t apply an increment. This value is only meaningful when the
        ///     combination of allowed units, rounding rule, and formatting strategy requires expressing a unit
        ///     with a fractional part. For example, a formatter that only allows minutes and uses a strategy
        ///     with a length of `2` and default rounding rule formats 40 seconds as `0.67 minutes`. With a
        ///     `roundingIncrement` of `0.05`, the formatter formats this value as `0.65 minutes` instead.
        public init(
            lengthLimits: some RangeExpression<Int>,
            roundingRule: FloatingPointRoundingRule = .toNearestOrEven,
            roundingIncrement: Double? = nil
        ) {
            let (lower, upper) = lengthLimits.clampedLowerAndUpperBounds(0 ..< Int.max)
            self.init(mininumLength: lower ?? 0, maximumLength: upper ?? Int.max, roundingRule: roundingRule, roundingIncrement: roundingIncrement)
        }

        /// Creates a display strategy that shows a fractional part.
        /// 
        /// - Parameters:
        ///   - length: The maximum string length of the fractional part.
        ///   - rule: A rule for rounding fractional values up or down. Defaults to
        ///     `FloatingPointRoundingRule.toNearestOrEven`.
        ///   - roundingIncrement: A multiple by which the formatter rounds the fractional part. The formatter
        ///     produces a value that is an even multiple of this increment. If this parameter is `nil`
        ///     (the default), the formatter doesn’t apply an increment. This value is only meaningful when the
        ///     combination of allowed units, rounding rule, and formatting strategy requires expressing a unit
        ///     with a fractional part. For example, a formatter that only allows minutes and uses a strategy
        ///     with a length of `2` and default rounding rule formats 40 seconds as `0.67 minutes`. With a
        ///     `roundingIncrement` of `0.05`, the formatter formats this value as `0.65 minutes` instead.
        public static func show(
            length: Int,
            rounded rule: FloatingPointRoundingRule = .toNearestOrEven,
            increment: Double? = nil
        ) -> Self {
            .init(mininumLength: length, maximumLength: length, roundingRule: rule, roundingIncrement: increment)
        }

        /// A display strategy that hides any fractional part by truncating it.
        public static var hide: Self {
            .init(mininumLength: 0, maximumLength: 0, roundingRule: .toNearestOrEven, roundingIncrement: nil)
        }

        /// Creates a display strategy that hides any fractional part by rounding the unit value.
        ///
        /// - Parameter rounded: Rounding rule for the remaining value.
        public static func hide(rounded: FloatingPointRoundingRule = .toNearestOrEven) -> Self {
            .init(mininumLength: 0, maximumLength: 0, roundingRule: rounded, roundingIncrement: nil)
        }
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DurationUnitsFormatStyle {
    /// A factory function to create a units format style to format a duration.
    /// - Parameters:
    ///   - units: The units that may be included in the output string.
    ///   - width: The width of the unit and the spacing between the value and the unit.
    ///   - maximumUnitCount: The maximum number of time units to include in the output string.
    ///   - zeroValueUnits: The strategy for how zero-value units are handled.
    ///   - valueLength: The padding or truncating behavior of the unit value.
    ///   - fractionalPart: The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
    /// - Returns: A format style to format a duration.
    public static func units(
        allowed units: Set<Self.Unit> = [.hours, .minutes, .seconds],
        width: Self.UnitWidth = .abbreviated,
        maximumUnitCount: Int? = nil,
        zeroValueUnits: Self.ZeroValueUnitsDisplayStrategy = .hide,
        valueLength: Int? = nil,
        fractionalPart: Self.FractionalPartDisplayStrategy = .hide
    ) -> Self {
        .init(
            allowedUnits: units,
            width: width,
            maximumUnitCount: maximumUnitCount,
            zeroValueUnits: zeroValueUnits,
            valueLength: valueLength,
            fractionalPart: fractionalPart
        )
    }

    /// A factory function to create a units format style to format a duration.
    /// - Parameters:
    ///   - allowedUnits: The units that may be included in the output string.
    ///   - width: The width of the unit and the spacing between the value and the unit.
    ///   - maximumUnitCount: The maximum number of time units to include in the output string.
    ///   - zeroValueUnits: The strategy for how zero-value units are handled.
    ///   - valueLengthLimits: The padding or truncating behavior of the unit value.
    ///   - fractionalPart: The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
    ///   - Returns: A format style to format a duration.
    public static func units(
        allowed units: Set<Self.Unit> = [.hours, .minutes, .seconds],
        width: Self.UnitWidth = .abbreviated,
        maximumUnitCount: Int? = nil,
        zeroValueUnits: Self.ZeroValueUnitsDisplayStrategy = .hide,
        valueLengthLimits: some RangeExpression<Int>,
        fractionalPart: Self.FractionalPartDisplayStrategy = .hide
    ) -> Self {
        .init(
            allowedUnits: units,
            width: width,
            maximumUnitCount: maximumUnitCount,
            zeroValueUnits: zeroValueUnits,
            valueLengthLimits: valueLengthLimits,
            fractionalPart: fractionalPart
        )
    }
}


extension _polyfill_DurationUnitsFormatStyle {
    private func createNumberFormatStyle(useFractionalLimitsIfAvailable: Bool) -> _polyfill_FloatingPointFormatStyle<Double> {
        var collection = _polyfill_NumberFormatStyleConfiguration.Collection()

        let fractionalLimits = useFractionalLimitsIfAvailable ? self.fractionalPartDisplay.minimumLength...self.fractionalPartDisplay.maximumLength : 0...0
        let zeroValueLimits = self.zeroValueUnitsDisplay.length...
        if let valueLengthLimits = self.valueLengthLimits, zeroValueLimits.lowerBound > 0 {
            let tightestLimits = zeroValueLimits.relative(to: valueLengthLimits)
            collection.precision = .integerAndFractionLength(integerLimits: tightestLimits, fractionLimits: fractionalLimits)
        } else if let valueLengthLimits = self.valueLengthLimits {
            collection.precision = .integerAndFractionLength(integerLimits: valueLengthLimits, fractionLimits: fractionalLimits)
        } else if zeroValueLimits.lowerBound > 0 {
            collection.precision = .integerAndFractionLength(integerLimits: zeroValueLimits, fractionLimits: fractionalLimits)
        } else {
            collection.precision = .fractionLength(fractionalLimits)
        }

        var format = _polyfill_FloatingPointFormatStyle<Double>(locale: locale)
        format.collection = collection
        return format
    }

    private func formatFields(_ duration: Swift.Duration) -> [String] {
        self.getSkeletons(duration).map { skeleton, unit, value in
            ICUMeasurementNumberFormatter.create(for: skeleton, locale: self.locale)!.format(value) ?? "\(value) \(unit.unit.icuSkeleton)"
        }
    }

    private func getSkeletons(_ duration: Duration) -> [(skeleton: String, measurementUnit: Unit, measurementValue: Double)] {
        let values = Self.unitsToUse(
            duration: duration,
            allowedUnits: self.allowedUnits,
            maximumUnitCount: self.maximumUnitCount ?? .max,
            roundSmallerParts: self.fractionalPartDisplay.roundingRule,
            trailingFractionalPartLength: self.fractionalPartDisplay.maximumLength,
            roundingIncrement: self.fractionalPartDisplay.roundingIncrement,
            dropZeroUnits: self.zeroValueUnitsDisplay.length <= 0
        )
        let numberFormatStyleWithFraction = self.createNumberFormatStyle(useFractionalLimitsIfAvailable: true)
        let numberFormatStyleNoFraction = self.createNumberFormatStyle(useFractionalLimitsIfAvailable: false)

        if values.isEmpty, let smallest = self.allowedUnits.sorted(by: { $0.unit > $1.unit }).last {
            let skeleton = ICUMeasurementNumberFormatter.skeleton(smallest.unit.icuSkeleton, width: self.unitWidth.width, usage: nil, numberFormatStyle: numberFormatStyleWithFraction)
            return [(skeleton, measurementUnit: smallest, measurementValue: 0)]
        }

        var result = [(skeleton: String, measurementUnit: Unit, measurementValue: Double)]()
        let isNegative = values.contains(where: { $1 < 0 }), mostSignificantUnit = values.max(by: { $0.0.unit < $1.0.unit })?.0

        for (index, (unit, value)) in values.enumerated() {
            var numberFormatStyle = (index == values.count - 1) ? numberFormatStyleWithFraction : numberFormatStyleNoFraction, value = value

            if isNegative, unit == mostSignificantUnit {
                numberFormatStyle = numberFormatStyle.sign(strategy: .always(includingZero: true))
                if value == .zero { value = -0.1 }
            } else { numberFormatStyle = numberFormatStyle.sign(strategy: .never) }

            let skeleton = ICUMeasurementNumberFormatter.skeleton(unit.unit.icuSkeleton, width: self.unitWidth.width, usage: nil, numberFormatStyle: numberFormatStyle)
            result.append((skeleton: skeleton, measurementUnit: unit, measurementValue: value))
        }

        return result
    }

    private func getListPattern(_ type: UATimeUnitListPattern) -> String {
        ICU4Swift.withResizingUCharBuffer(initialSize: 128) {
            uatmufmt_getListPattern(self.locale.identifier, self.unitWidth.patternStyle, type, $0, $1, &$2)
        } ?? "{0}, {1}"
    }

    private func getFullListPattern(length: Int) -> String {
        switch length {
        case 1: "{0}"
        case 2: self.getListPattern(UATIMEUNITLISTPAT_TWO_ONLY).replacing("{1}", with: "{0}")
        case let length:
            (2 ..< length - 1).reduce((
                self.getListPattern(UATIMEUNITLISTPAT_START_PIECE),
                self.getListPattern(UATIMEUNITLISTPAT_MIDDLE_PIECE)
            )) { r, _ in (r.0.replacing("{1}", with: r.1), r.1) }.0
                .replacing("{1}", with: self.getListPattern(UATIMEUNITLISTPAT_END_PIECE))
                .replacing("{1}", with: "{0}")
        }
    }

    static func unitsToUse(
        duration: Swift.Duration,
        allowedUnits: Set<Unit>,
        maximumUnitCount: Int,
        roundSmallerParts: FloatingPointRoundingRule,
        trailingFractionalPartLength: Int,
        roundingIncrement: Double?,
        dropZeroUnits: Bool
    ) -> OrderedDictionary<Unit, Double> {
        let values = _polyfill_DurationTimeFormatStyle.Attributed.valuesForUnits(
            of: duration,
            allowedUnits.sorted { $0.unit.rawValue < $1.unit.rawValue },
            trailingFractionalLength: trailingFractionalPartLength,
            smallestUnitRounding: roundSmallerParts,
            roundingIncrement: roundingIncrement
        ).filter { dropZeroUnits ? $1 != 0 : true }

        if values.count <= maximumUnitCount { return values }
        guard let idx = values.elements.firstIndex(where: { $1 != 0 }) else { return values }

        return _polyfill_DurationTimeFormatStyle.Attributed.valuesForUnits(
            of: duration,
            values.elements[idx ..< Swift.min(allowedUnits.count, idx + maximumUnitCount)].map(\.key),
            trailingFractionalLength: trailingFractionalPartLength,
            smallestUnitRounding: roundSmallerParts,
            roundingIncrement: roundingIncrement
        )
    }
}

extension UATimeUnitStyle: Codable, Hashable {}
