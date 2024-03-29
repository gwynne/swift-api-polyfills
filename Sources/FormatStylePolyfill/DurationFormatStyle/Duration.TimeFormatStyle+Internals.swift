import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Locale
import CLegacyLibICU
import Collections

extension _polyfill_DurationTimeFormatStyle.Pattern {
    private var toUPattern: UATimeUnitTimePattern {
        switch self.fields {
        case .hourMinute:       UATIMEUNITTIMEPAT_HM
        case .hourMinuteSecond: UATIMEUNITTIMEPAT_HMS
        case .minuteSecond:     UATIMEUNITTIMEPAT_MS
        }
    }
    
    fileprivate func toPatternString(in locale: Foundation.Locale) -> String {
        withUnsafeTemporaryAllocation(of: UChar.self, capacity: 128) { buf in
            var status = U_ZERO_ERROR
            let count = uatmufmt_getTimePattern(
                locale.identifier,
                self.toUPattern,
                buf.baseAddress!,
                Int32(buf.count),
                &status
            )
            
            guard status.rawValue <= U_ZERO_ERROR.rawValue else {
                return switch self.fields {
                case .hourMinute: "h':'mm"
                case .hourMinuteSecond: "h':'mm':'ss"
                case .minuteSecond: "m':'ss"
                }
            }
            return String(utf16CodeUnits: buf.baseAddress!, count: Int(count))
        }
    }
}

private func abs(_ x: Swift.Duration) -> Swift.Duration {
    x < .zero ? .zero - x : x
}

extension Swift.Duration {
    private static var one: Self {
        .init(secondsComponent: 0, attosecondsComponent: 1)
    }
    
    fileprivate static func % (lhs: Self, rhs: Int64) -> Self {
        lhs - ((lhs / rhs) * rhs)
    }
    
    fileprivate func rounded(increment: Self, rule: FloatingPointRoundingRule = .toNearestOrEven) -> Self {
        self.rounded(rule, toMultipleOf: increment)
    }
    
    private func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrEven, toMultipleOf inc: Self) -> Self {
        let inc = abs(inc)
        let (truncated, truncCount) = self.roundedTowardZero(toMultipleOf: inc)
        let truncEven = (truncCount % 2) == .zero
        let diffToTrunc = abs(abs(truncated) - abs(self))
        let ceiled = truncated + ((self < .zero) ? .zero - inc : inc)
        let diffToCeiled = abs(abs(ceiled) - abs(self))
        
        guard diffToTrunc != .zero else {
            return self
        }
        
        return switch rule {
        case .up:                      Swift.max(truncated, ceiled)
        case .down:                    Swift.min(truncated, ceiled)
        case .towardZero:              truncated
        case .awayFromZero:            ceiled
        case .toNearestOrAwayFromZero: (diffToTrunc < diffToCeiled) ? truncated : ceiled
        case .toNearestOrEven:         (diffToTrunc < diffToCeiled || diffToTrunc == diffToCeiled && truncEven) ? truncated : ceiled
        @unknown default:              fatalError()
        }
    }

    private func roundedTowardZero(toMultipleOf divisor: Self) -> (duration: Self, count: Self) {
        let absSelf = abs(self), absDiv = abs(divisor), (ds, dattos) = absDiv.components
        let absCount: Self, absValue: Self

        if ds == 0 {
            absCount = absSelf / dattos
            absValue = absCount * dattos
        } else if dattos == 0 {
            absCount = .init(secondsComponent: 0, attosecondsComponent: absSelf.components.seconds / ds)
            absValue = .init(secondsComponent: ds * (absSelf.components.seconds / ds), attosecondsComponent: 0)
        } else if absSelf < absDiv {
            return (.zero, .zero)
        } else {
            let count = UInt64(absSelf / absDiv), remainderCount = Int64((absSelf - (absDiv * count)) / absDiv)

            (absCount, absValue) = (.one * count + .one * remainderCount, absDiv * count + absDiv * remainderCount)
        }
        return (self < .zero) != (divisor < .zero) ? (.zero - absValue, .zero - absCount) : (absValue, absCount)
    }
}

extension _polyfill_DurationTimeFormatStyle.Attributed {
    private static func secondCoefficientOrFracOffset(for unit: _polyfill_DurationUnitsFormatStyle.Unit) -> Double {
        (self.secondCoefficient(for: unit) as Int64?).map(Double.init) ?? pow(0.1, Double(self.fractionalSecOffset(from: unit)!))
    }
    
    private static func nanosecondCoefficient(for unit: _polyfill_DurationUnitsFormatStyle.Unit) -> Int64? {
        switch unit {
        case .milliseconds: 1_000_000
        case .microseconds: 1_000
        case .nanoseconds:  1
        default:            nil
        }
    }

    private static func secondCoefficient(for unit: _polyfill_DurationUnitsFormatStyle.Unit) -> Int64? {
        switch unit {
        case .weeks:        604800
        case .days:         86400
        case .hours:        3600
        case .minutes:      60
        case .seconds:      1
        default:            nil
        }
    }

    private static func fractionalSecOffset(from unit: _polyfill_DurationUnitsFormatStyle.Unit) -> Int? {
        switch unit {
        case .milliseconds: 3
        case .microseconds: 6
        case .nanoseconds:  9
        default:            0
        }
    }

    private static func interval(fractionalLen: Int) -> Swift.Duration {
        switch fractionalLen {
        case ...0: .seconds(1)
        case ...3: .milliseconds(Int(pow(10, Double(2 - (fractionalLen + 2) % 3))))
        case ...6: .microseconds(Int(pow(10, Double(2 - (fractionalLen + 2) % 3))))
        case ...9: .nanoseconds( Int(pow(10, Double(2 - (fractionalLen + 2) % 3))))
        default:   .seconds(pow(0.1, Double(fractionalLen)))
        }
    }

    private static func interval(
        for unit: _polyfill_DurationUnitsFormatStyle.Unit,
        fractionalDigits: Int,
        roundingIncrement: Double?
    ) -> Swift.Duration {
        let fincrement: Swift.Duration, rincrement: Swift.Duration
        
        if !unit.unit.isSubsecond {
            fincrement = self.interval(fractionalLen: fractionalDigits) * self.secondCoefficient(for: unit)!
        } else {
            let offset = self.fractionalSecOffset(from: unit)!
            fincrement = self.interval(fractionalLen: offset + Swift.min(fractionalDigits, Int.max - offset))
        }
        if let roundingIncrement {
            if !unit.unit.isSubsecond {
                rincrement = .seconds(self.secondCoefficient(for: unit)!) * roundingIncrement
            } else {
                rincrement = .nanoseconds(self.nanosecondCoefficient(for: unit)!) * roundingIncrement
            }
            return Swift.max(fincrement, rincrement)
        } else {
            return fincrement
        }
    }

    private static func factor(
        _ value: Swift.Duration,
        intoUnits units: some Sequence<_polyfill_DurationUnitsFormatStyle.Unit>
    ) -> (values: [Double], remainder: Swift.Duration) {
        var value = value, values = [Double]()
        
        for unit in units {
            if !unit.unit.isSubsecond {
                let (quotient, remainder) = value.components.seconds.quotientAndRemainder(
                    dividingBy: self.secondCoefficient(for: unit)!
                )
            
                values.append(Double(quotient))
                value = .init(secondsComponent: remainder, attosecondsComponent: value.components.attoseconds)
            } else {
                let (quotient, remainder) = value.components.attoseconds.quotientAndRemainder(
                    dividingBy: self.nanosecondCoefficient(for: unit)! * Int64(1e9)
                )
                var unitValue = Double(quotient)
            
                unitValue = unitValue.addingProduct(
                    Double(value.components.seconds),
                    pow(10, Double(self.fractionalSecOffset(from: unit)!))
                )
                values.append(unitValue)
                value = .init(secondsComponent: 0, attosecondsComponent: remainder)
            }
        }
        return (values, value)
    }

    static func valuesForUnits(
        of value: Swift.Duration,
        _ units: some BidirectionalCollection<_polyfill_DurationUnitsFormatStyle.Unit>,
        trailingFractionalLength: Int,
        smallestUnitRounding: FloatingPointRoundingRule,
        roundingIncrement: Double?
    ) -> OrderedDictionary<_polyfill_DurationUnitsFormatStyle.Unit, Double> {
        guard let smallestUnit = units.last else {
            return [:]
        }
        
        let increment = Self.interval(
            for: smallestUnit,
            fractionalDigits: trailingFractionalLength,
            roundingIncrement: roundingIncrement
        )
        let rounded = (increment != .zero) ? value.rounded(increment: increment, rule: smallestUnitRounding) : value
        var (values, remainder) = self.factor(rounded, intoUnits: units)
        
        values[values.count - 1] += Double(remainder.components.seconds).addingProduct(
            1e-18,
            Double(remainder.components.attoseconds)
        ) / Self.secondCoefficientOrFracOffset(for: smallestUnit)

        return .init(uniqueKeys: units, values: values)
    }

    private struct PatternComponent {
        let symbols: [Character]
        let isField: Bool
    }

    private static func componentsFromPatternString(_ pattern: String, patternSet: [Character]) -> [PatternComponent] {
        var inQuote: Bool = false
        var runSymbol: Character?
        var runIsField: Bool = true
        var result = [PatternComponent](), token = [Character]()
        
        for c in pattern {
            let isField = !inQuote && patternSet.contains(c)
            
            if !token.isEmpty, (isField && c != runSymbol) || (!isField && runIsField) {
                result.append(.init(symbols: token, isField: runIsField))
                token = []
            }
            switch (c, runSymbol) {
                case ("'", "'"): token.append("'")
                case ("'",   _): inQuote.toggle()
                case (let c, _): token.append(c)
            }
            (runIsField, runSymbol) = (isField, c)
        }
        if !token.isEmpty {
            result.append(PatternComponent(symbols: token, isField: runIsField))
        }
        return result
    }

    private static func formatWithPatternComponents(
        _ value: Swift.Duration,
        in locale: Foundation.Locale,
        pattern: _polyfill_DurationTimeFormatStyle.Pattern,
        _ components: [PatternComponent],
        hour: Double, minute: Double, second: Double
    ) -> Foundation.AttributedString {
        components.reduce(Foundation.AttributedString()) { result, component in
            guard component.isField, let symbol = component.symbols.first else {
                var r = result
                r.append(Foundation.AttributedString(String(component.symbols)))
                return r
            }

            var attr: Foundation.AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field?
            var substring = Foundation.AttributedString(String(component.symbols))
            var isMostSignificantField = true
            var value: Double?
            var fracLimits = 0 ... 0

            switch symbol {
            case "h": (value, attr) = (hour, .hours)
            case "m":
                (value, attr) = (minute, .minutes)
                switch pattern.fields {
                case .hourMinute, .hourMinuteSecond: isMostSignificantField = false
                case .minuteSecond: break
                }
            case "s":
                (value, attr, isMostSignificantField) = (second, .seconds, false)
                switch pattern.fields {
                case .hourMinute: break
                case .hourMinuteSecond(let fracLen, _), .minuteSecond(let fracLen, _): fracLimits = fracLen...fracLen
                }
            default: break
            }
            
            if let value, let attr {
                substring = .init(_polyfill_FloatingPointFormatStyle<Double>(locale: locale)
                    .precision(.integerAndFractionLength(
                        integerLimits: Swift.max(component.symbols.count, isMostSignificantField ? (pattern.paddingForLargestField ?? .min) : .min)...,
                        fractionLimits: fracLimits
                    ))
                    .sign(strategy: (hour < 0 || minute < 0 || second < 0) && isMostSignificantField ? .always() : .never)
                    .format((hour < 0 || minute < 0 || second < 0) && isMostSignificantField && value == 0 ? -0.1 : value),
                    attributes: .init().durationField(attr)
                )
            }
            var r = result
            r.append(substring)
            return r
        }
    }

    static func formatImpl(
        value: Swift.Duration,
        locale: Foundation.Locale,
        pattern: _polyfill_DurationTimeFormatStyle.Pattern
    ) -> Foundation.AttributedString {
        let patternString = pattern.toPatternString(in: locale).lowercased()
        let units: [_polyfill_DurationUnitsFormatStyle.Unit]
        let rounding: FloatingPointRoundingRule
        let lastUnitFractionalLen: Int

        switch pattern.fields {
        case .hourMinute(let roundSeconds):
            (units, rounding, lastUnitFractionalLen) = ([.hours, .minutes], roundSeconds, 0)
        case .hourMinuteSecond(let fractionalSecondsLength, let roundFractionalSeconds):
            (units, rounding, lastUnitFractionalLen) = ([.hours, .minutes, .seconds], roundFractionalSeconds, fractionalSecondsLength)
        case .minuteSecond(let fractionalSecondsLength, let roundFractionalSeconds):
            (units, rounding, lastUnitFractionalLen) = ([.minutes, .seconds], roundFractionalSeconds, fractionalSecondsLength)
        }
        let unitValues = self.valuesForUnits(
            of: value, units,
            trailingFractionalLength: lastUnitFractionalLen,
            smallestUnitRounding: rounding,
            roundingIncrement: nil
        )
        let patternComponents = Self.componentsFromPatternString(patternString, patternSet: ["h", "m", "s"])

        return self.formatWithPatternComponents(
            value,
            in: locale,
            pattern: pattern,
            patternComponents,
            hour: unitValues[.hours] ?? 0,
            minute: unitValues[.minutes] ?? 0,
            second: unitValues[.seconds] ?? 0
        )
    }
}
