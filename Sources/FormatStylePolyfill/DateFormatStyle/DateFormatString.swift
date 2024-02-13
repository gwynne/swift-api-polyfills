/// A type which allows constructing a date format pattern using string interpolation and date symbol types.
public struct _polyfill_DateFormatString: Hashable, Sendable, ExpressibleByStringInterpolation {
    package var rawFormat: String = ""

    // See `ExpressibleByStringInterpolation.init(stringInterpolation:)`.
    public init(stringInterpolation: StringInterpolation) {
        self.rawFormat = stringInterpolation.format
    }

    // See `ExpressibleByStringLiteral.init(stringLiteral:)`.
    public init(stringLiteral value: String) {
        self.rawFormat = value.asDateFormatLiteral()
    }

    /// An implementation of `StringInterpolationProtocol` providing the interpolations available
    /// for `Date.FormatString`.
    public struct StringInterpolation: StringInterpolationProtocol, Sendable {
        fileprivate var format: String = ""
        
        // See `StringInterpolationProtocol.init(literalCapacity:interpolationCount:)`.
        public init(literalCapacity: Int, interpolationCount: Int) {}

        // See `StringInterpolationProtocol.appendLiteral(_:)`.
        public mutating func appendLiteral(_ literal: String) {
            self.format += literal.asDateFormatLiteral()
        }
                
        public mutating func appendInterpolation(era: _polyfill_DateFormatStyle.Symbol.Era) {
            self.format.append(era.option.rawValue)
        }
        
        public mutating func appendInterpolation(year: _polyfill_DateFormatStyle.Symbol.Year) {
            self.format.append(year.option.rawValue)
        }
        
        public mutating func appendInterpolation(yearForWeekOfYear: _polyfill_DateFormatStyle.Symbol.YearForWeekOfYear) {
            self.format.append(yearForWeekOfYear.option.rawValue)
        }
        
        public mutating func appendInterpolation(cyclicYear: _polyfill_DateFormatStyle.Symbol.CyclicYear) {
            self.format.append(cyclicYear.option.rawValue)
        }
        
        public mutating func appendInterpolation(quarter: _polyfill_DateFormatStyle.Symbol.Quarter) {
            self.format.append(quarter.option.rawValue)
        }
        
        public mutating func appendInterpolation(standaloneQuarter: _polyfill_DateFormatStyle.Symbol.StandaloneQuarter) {
            self.format.append(standaloneQuarter.option.rawValue)
        }
        
        public mutating func appendInterpolation(month: _polyfill_DateFormatStyle.Symbol.Month) {
            self.format.append(month.option.rawValue)
        }
        
        public mutating func appendInterpolation(standaloneMonth: _polyfill_DateFormatStyle.Symbol.StandaloneMonth) {
            self.format.append(standaloneMonth.option.rawValue)
        }
        
        public mutating func appendInterpolation(week: _polyfill_DateFormatStyle.Symbol.Week) {
            self.format.append(week.option.rawValue)
        }
        
        public mutating func appendInterpolation(day: _polyfill_DateFormatStyle.Symbol.Day) {
            self.format.append(day.option.rawValue)
        }
        
        public mutating func appendInterpolation(dayOfYear: _polyfill_DateFormatStyle.Symbol.DayOfYear) {
            self.format.append(dayOfYear.option.rawValue)
        }
        
        public mutating func appendInterpolation(weekday: _polyfill_DateFormatStyle.Symbol.Weekday) {
            self.format.append(weekday.option.rawValue)
        }
        
        public mutating func appendInterpolation(standaloneWeekday: _polyfill_DateFormatStyle.Symbol.StandaloneWeekday) {
            self.format.append(standaloneWeekday.option.rawValue)
        }
        
        public mutating func appendInterpolation(dayPeriod: _polyfill_DateFormatStyle.Symbol.DayPeriod) {
            self.format.append(dayPeriod.option.rawValue)
        }
        
        public mutating func appendInterpolation(hour: _polyfill_DateFormatStyle.Symbol.VerbatimHour) {
            self.format.append(hour.option.rawValue)
        }
        
        public mutating func appendInterpolation(minute: _polyfill_DateFormatStyle.Symbol.Minute) {
            self.format.append(minute.option.rawValue)
        }
        
        public mutating func appendInterpolation(second: _polyfill_DateFormatStyle.Symbol.Second) {
            self.format.append(second.option.rawValue)
        }
        
        public mutating func appendInterpolation(secondFraction: _polyfill_DateFormatStyle.Symbol.SecondFraction) {
            self.format.append(secondFraction.option.rawValue)
        }
        
        public mutating func appendInterpolation(timeZone: _polyfill_DateFormatStyle.Symbol.TimeZone) {
            self.format.append(timeZone.option.rawValue)
        }
    }
}

