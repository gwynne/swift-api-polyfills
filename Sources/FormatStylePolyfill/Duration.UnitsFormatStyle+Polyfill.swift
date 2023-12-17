import Foundation
import CLegacyLibICU
import Collections

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension UATimeUnitStyle: Codable, Hashable {}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration {
    /// A `FormatStyle` that displays a duration as a list of duration units, such as "2 hours, 43 minutes, 26 seconds" in English.
    public struct _polyfill_UnitsFormatStyle: _polyfill_FormatStyle, Sendable {
        /// The locale to use when formatting the duration.
        public var locale: Locale

        /// The units that may be included in the output string.
        public var allowedUnits: Set<Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Unit>

        /// The width of the unit and the spacing between the value and the unit.
        public var unitWidth: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_UnitWidth

        /// The maximum number of time units to include in the output string.
        public var maximumUnitCount: Int?

        /// The strategy for how zero-value units are handled.
        public var zeroValueUnitsDisplay: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_ZeroValueUnitsDisplayStrategy

        /// The strategy for displaying a duration if it cannot be represented exactly with the allowed units.
        public var fractionalPartDisplay: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_FractionalPartDisplayStrategy

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
            allowedUnits: Set<Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Unit>,
            width: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_UnitWidth,
            maximumUnitCount: Int? = nil,
            zeroValueUnits: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_ZeroValueUnitsDisplayStrategy = .hide,
            valueLength: Int? = nil,
            fractionalPart: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_FractionalPartDisplayStrategy = .hide
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
            allowedUnits: Set<Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Unit>,
            width: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_UnitWidth,
            maximumUnitCount: Int? = nil,
            zeroValueUnits: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_ZeroValueUnitsDisplayStrategy = .hide,
            valueLengthLimits: some RangeExpression<Int>,
            fractionalPart: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_FractionalPartDisplayStrategy = .hide
        ) {
            self.allowedUnits = allowedUnits
            self.unitWidth = width
            self.maximumUnitCount = maximumUnitCount
            self.zeroValueUnitsDisplay = zeroValueUnits
            self.fractionalPartDisplay = fractionalPart
            self.valueLengthLimits = valueLengthLimits.relative(to: Int.min ..< Int.max).clamped(to: 0 ..< .max)
            self.locale = .autoupdatingCurrent
        }

        /// A modifier to set the locale of the format style.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A copy of this format with the new locale set.
        public func locale(_ locale: Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }

        /// Creates a locale-aware string representation from a duration value.
        /// 
        /// - Parameter duration: The value to format.
        /// - Returns: A string representation of the duration.
        public func format(_ duration: Duration) -> String {
            let formattedFields = self._formatFields(duration)
            var result = self._getFullListPattern(length: formattedFields.count)
            for formattedField in formattedFields.reversed() {
                result.replaceSubrange(result.range(of: "{0}", options: [.backwards])!, with: formattedField)
            }
            return result
        }
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_UnitsFormatStyle {
    /// Returns a `Duration.UnitsFormatStyle.Attributed` style to format a duration as an attributed string
    /// using the configuration of this format style. Units in the string are annotated with the
    /// `durationField` and `measurement` attribute keys and the `DurationFieldAttribute` and
    /// `MeasurementAttribute` attribute values.
    ///
    /// For example, formatting a duration of 2 hours, 43 minutes, 26.25 second in `en_US` locale yields the
    /// following, conceptually:
    ///
    /// ```
    /// 2 { durationField: .hours, component: .value }
    /// hours { durationField: .hours, component: .unit }
    /// , { nil }
    /// 43 { durationField: .minutes, component: .value }
    /// minutes { durationField: .minutes, component: .unit }
    /// , { nil }
    /// 26.25 { durationField: .seconds, component: .value }
    /// seconds { durationField: .seconds, component: .unit }
    /// ```
    public var attributed: Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Attributed {
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
    /// ```
    /// 2 { durationField: .hours, component: .value }
    /// hours { durationField: .hours, component: .unit }
    /// , { nil }
    /// 43 { durationField: .minutes, component: .value }
    /// minutes { durationField: .minutes, component: .unit }
    /// , { nil }
    /// 26.25 { durationField: .seconds, component: .value }
    /// seconds { durationField: .seconds, component: .unit }
    /// ```
    public struct _polyfill_Attributed: _polyfill_FormatStyle, Sendable {
        var innerStyle: Swift.Duration._polyfill_UnitsFormatStyle

        /// Formats a duration as an attributed string with `DurationFieldAttribute`.
        public func format(_ duration: Swift.Duration) -> Foundation.AttributedString {
            let formattedFields = self._formatFields(duration)
            var result = Foundation.AttributedString(self.innerStyle._getFullListPattern(length: formattedFields.count))
            for formattedField in formattedFields.reversed() {
                result.replaceSubrange(result.range(of: "{0}", options: [.backwards])!, with: formattedField)
            }
            return result
        }

        /// A modifier to set the locale of the format style.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A copy of this format with the new locale set.
        public func locale(_ locale: Locale) -> Self { .init(innerStyle: innerStyle.locale(locale)) }

        func _formatFields(_ duration: Swift.Duration) -> [Foundation.AttributedString] {
            self.innerStyle._getSkeletons(duration).map { skeleton, unit, value in
                let numberFormatter = ICUMeasurementNumberFormatter.create(for: skeleton, locale: self.innerStyle.locale)!

                guard let (str, attributes) = numberFormatter.attributedFormatPositions(.floatingPoint(value)) else {
                    return .init(self.innerStyle.format(duration), attributes: .init().durationField(unit))
                }

                var attrStr = Foundation.AttributedString(str)
                attrStr.durationField = unit

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

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Unit {
    private var subtype: String { switch self {
        case .weeks:        "week"
        case .days:         "day"
        case .hours:        "hour"
        case .minutes:      "minute"
        case .seconds:      "second"
        case .milliseconds: "millisecond"
        case .microseconds: "microsecond"
        case .nanoseconds:  "nanosecond"
        #if canImport(Darwin)
        @unknown default: fatalError()
        #endif
    } }
    
    var icuSkeleton: String { "measure-unit/duration-\(self.subtype)" }
    
    var isSubsecond: Bool { self.rawValue < Self.seconds.rawValue }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_UnitsFormatStyle {
    /// Units that a duration can be displayed as with `UnitsFormatStyle`.
    public typealias _polyfill_Unit = Foundation.AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field

    /// Specifies the width of the unit and the spacing of the value and the unit.
    public struct _polyfill_UnitWidth: Codable, Hashable, Sendable {
        var width: ICUMeasurementNumberFormatter.UnitWidth
        var patternStyle: UATimeUnitStyle

        /// Shows the full unit name, such as "3 hours" for a 3-hour duration in the `en_US` locale.
        public static var wide: Self                 { .init(width: .wide, patternStyle: UATIMEUNITSTYLE_FULL) }

        /// Shows the abbreviated unit name, such as "3 hr" for a 3-hour duration in the `en_US` locale.
        public static var abbreviated: Self          { .init(width: .abbreviated, patternStyle: UATIMEUNITSTYLE_ABBREVIATED) }

        /// Shows the abbreviated unit name with a condensed space between the value and unit, such as
        /// "3hr" for a 3-hour duration in the `en_US` locale.
        public static var condensedAbbreviated: Self { .init(width: .abbreviated, patternStyle: UATIMEUNITSTYLE_SHORTER) }

        /// Shows the shortest unit name, such as "3h" for a 3-hour duration in the `en_US` locale.
        public static var narrow: Self               { .init(width: .narrow, patternStyle: UATIMEUNITSTYLE_NARROW) }
    }

    /// Specifies how zero value units are handled.
    public struct _polyfill_ZeroValueUnitsDisplayStrategy: Codable, Hashable, Sendable {
        var length: Int

        /// Excludes zero-value units from the formatted string.
        public static var hide: Self                 { .init(length: 0) }

        /// Displays zero-value units with zero padding to the specified length.
        public static func show(length: Int) -> Self { .init(length: length)}
    }

    /// Specifies how a duration is displayed if it cannot be represented exactly with the allowed units.
    ///
    /// For example, you can change this option to show a duration of 1 hour and 15 minutes as "1.25 hr", "1 hr", or "1.5 hr" with different lengths and rounding rules when hour is the only allowed unit.
    public struct _polyfill_FractionalPartDisplayStrategy: Codable, Hashable, Sendable {
        public var minimumLength: Int
        public var maximumLength: Int
        public var roundingRule: FloatingPointRoundingRule
        public var roundingIncrement: Double?

        init(
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

        /// Displays the remaining part as the fractional part of the smallest unit.
        ///
        /// - Parameters:
        ///   - lengthLimits: The range of the length of the fractional part.
        ///   - roundingRule: Rounding rule for the remaining value.
        ///   - roundingIncrement: Rounding increment for the remaining value.
        public init(
            lengthLimits: some RangeExpression<Int>,
            roundingRule: FloatingPointRoundingRule = .toNearestOrEven,
            roundingIncrement: Double? = nil
        ) {
            let bounds = lengthLimits.relative(to: Int.min ..< Int.max).clamped(to: 0 ..< .max)
            self.init(mininumLength: bounds.lowerBound, maximumLength: bounds.upperBound, roundingRule: roundingRule, roundingIncrement: roundingIncrement)
        }

        /// Displays the remaining part as the fractional part of the smallest unit.
        ///
        /// - Parameters:
        ///   - length: The length of the fractional part.
        ///   - rule: Rounding rule for the remaining value.
        ///   - increment: Rounding increment for the remaining value.
        public static func show(
            length: Int,
            rounded rule: FloatingPointRoundingRule = .toNearestOrEven,
            increment: Double? = nil
        ) -> Self {
            .init(mininumLength: length, maximumLength: length, roundingRule: rule, roundingIncrement: increment)
        }

        /// Excludes the remaining part.
        public static var hide: Self {
            .init(mininumLength: 0, maximumLength: 0, roundingRule: .toNearestOrEven, roundingIncrement: nil)
        }

        /// Excludes the remaining part with the specified rounding rule.
        ///
        /// - Parameter rounded: Rounding rule for the remaining value.
        public static func hide(rounded: FloatingPointRoundingRule = .toNearestOrEven) -> Self {
            .init(mininumLength: 0, maximumLength: 0, roundingRule: rounded, roundingIncrement: nil)
        }
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration._polyfill_UnitsFormatStyle {
    // The number format does not contain rounding settings because it's handled on the value itself
    private func _createNumberFormatStyle(useFractionalLimitsIfAvailable: Bool) -> _polyfill_FloatingPointFormatStyle<Double> {
        var collection = _polyfill_NumberFormatStyleConfiguration.Collection()

        let fractionalLimits = useFractionalLimitsIfAvailable ? self.fractionalPartDisplay.minimumLength...self.fractionalPartDisplay.maximumLength : 0...0
        let zeroValueLimits = self.zeroValueUnitsDisplay.length...
        if let valueLengthLimits = self.valueLengthLimits, self.zeroValueUnitsDisplay.length > 0 {
            let tightestLimits = zeroValueLimits.relative(to: valueLengthLimits)
            collection.precision = .integerAndFractionLength(integerLimits: tightestLimits, fractionLimits: fractionalLimits)
        } else if let valueLengthLimits = valueLengthLimits {
            collection.precision = .integerAndFractionLength(integerLimits: valueLengthLimits, fractionLimits: fractionalLimits)
        } else if zeroValueUnitsDisplay.length > 0 {
            collection.precision = .integerAndFractionLength(integerLimits: zeroValueLimits, fractionLimits: fractionalLimits)
        } else {
            collection.precision = .fractionLength(fractionalLimits)
        }

        var format = _polyfill_FloatingPointFormatStyle<Double>(locale: locale)
        format.collection = collection
        return format
    }

    private func _formatFields(_ duration: Swift.Duration) -> [String] {
        self._getSkeletons(duration).map { skeleton, unit, value in
            ICUMeasurementNumberFormatter.create(for: skeleton, locale: locale)!.format(value) ?? "\(value) \(unit.icuSkeleton)"
        }
    }

    private func _getSkeletons(_ duration: Duration) -> [(skeleton: String, measurementUnit: _polyfill_Unit, measurementValue: Double)] {
        let values = Self.unitsToUse(
            duration: duration,
            allowedUnits: self.allowedUnits,
            maximumUnitCount: self.maximumUnitCount ?? .max,
            roundSmallerParts: self.fractionalPartDisplay.roundingRule,
            trailingFractionalPartLength: self.fractionalPartDisplay.maximumLength,
            roundingIncrement: self.fractionalPartDisplay.roundingIncrement,
            dropZeroUnits: self.zeroValueUnitsDisplay.length <= 0
        )
        let numberFormatStyleWithFraction = self._createNumberFormatStyle(useFractionalLimitsIfAvailable: true)
        let numberFormatStyleNoFraction = self._createNumberFormatStyle(useFractionalLimitsIfAvailable: false)

        if values.isEmpty, let smallest = self.allowedUnits.sorted(by: { $0.rawValue < $1.rawValue }).last {
            let skeleton = ICUMeasurementNumberFormatter.skeleton(smallest.icuSkeleton, width: self.unitWidth.width, usage: nil, numberFormatStyle: numberFormatStyleWithFraction)
            return [(skeleton, measurementUnit: smallest, measurementValue: 0)]
        }

        var result = [(skeleton: String, measurementUnit: _polyfill_Unit, measurementValue: Double)]()
        let isNegative = values.contains(where: { $1 < 0 }), mostSignificantUnit = values.max(by: { $0.0.rawValue < $1.0.rawValue })?.0

        for (index, (unit, value)) in values.enumerated() {
            var numberFormatStyle = (index == values.count - 1) ? numberFormatStyleWithFraction : numberFormatStyleNoFraction, value = value

            if isNegative && unit == mostSignificantUnit {
                numberFormatStyle = numberFormatStyle.sign(strategy: .always(includingZero: true))
                if value == .zero { value = -0.1 }
            } else { numberFormatStyle = numberFormatStyle.sign(strategy: .never) }

            let skeleton = ICUMeasurementNumberFormatter.skeleton(unit.icuSkeleton, width: self.unitWidth.width, usage: nil, numberFormatStyle: numberFormatStyle)
            result.append((skeleton: skeleton, measurementUnit: unit, measurementValue: value))
        }

        return result
    }

    private func _getListPattern(_ type: UATimeUnitListPattern) -> String {
        _withResizingUCharBuffer(initialSize: 128) {
            uatmufmt_getListPattern(self.locale.identifier, self.unitWidth.patternStyle, type, $0, $1, &$2)
        } ?? "{0}, {1}"
    }

    private func _getFullListPattern(length: Int) -> String {
        let placeholder = "{0}", lastPlaceholder = "{1}"

        switch length {
        case 1: return placeholder
        case 2: return self._getListPattern(UATIMEUNITLISTPAT_TWO_ONLY).replacing(lastPlaceholder, with: placeholder)
        case let length:
            var pattern = self._getListPattern(UATIMEUNITLISTPAT_START_PIECE)
            let middle = self._getListPattern(UATIMEUNITLISTPAT_MIDDLE_PIECE)
            for _ in 2 ..< length { pattern.replace(lastPlaceholder, with: middle) }
            return pattern
                .replacing(lastPlaceholder, with: self._getListPattern(UATIMEUNITLISTPAT_END_PIECE))
                .replacing(lastPlaceholder, with: placeholder)
        }
    }

    static func unitsToUse(
        duration: Swift.Duration,
        allowedUnits: Set<_polyfill_Unit>,
        maximumUnitCount: Int,
        roundSmallerParts: FloatingPointRoundingRule,
        trailingFractionalPartLength: Int,
        roundingIncrement: Double?,
        dropZeroUnits: Bool
    ) -> OrderedDictionary<_polyfill_Unit, Double> {
        let values = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed.valuesForUnits(
            of: duration,
            allowedUnits.sorted { $0.rawValue < $1.rawValue },
            trailingFractionalLength: trailingFractionalPartLength,
            smallestUnitRounding: roundSmallerParts,
            roundingIncrement: roundingIncrement
        ).filter { dropZeroUnits ? $1 != 0 : true }

        if values.count <= maximumUnitCount { return values }
        guard let idx = values.elements.firstIndex(where: { $1 != 0 }) else { return values }

        return Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed.valuesForUnits(
            of: duration,
            values.elements[idx ..< Swift.min(allowedUnits.count, idx + maximumUnitCount)].map(\.key),
            trailingFractionalLength: trailingFractionalPartLength,
            smallestUnitRounding: roundSmallerParts,
            roundingIncrement: roundingIncrement
        )
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// A ``FormatStyle`` that displays a duration as a list of duration units, such as "2 hours, 43 minutes, 26 seconds" in English.
    public typealias UnitsFormatStyle = Swift.Duration._polyfill_UnitsFormatStyle
}

#endif
