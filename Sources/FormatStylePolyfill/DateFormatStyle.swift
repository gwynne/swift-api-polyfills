import struct Foundation.AttributeContainer
import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Calendar
import struct Foundation.CocoaError
import struct Foundation.Date
import struct Foundation.DateComponents
import struct Foundation.Locale
import let Foundation.NSDebugDescriptionErrorKey
import struct Foundation.TimeZone
import typealias Foundation.TimeInterval
import CLegacyLibICU
import PolyfillCommon

extension Foundation.Date {
    public struct _polyfill_FormatString: Hashable, Sendable {
        var rawFormat: String = ""
    }
}

extension String {
    fileprivate func asDateFormatLiteral() -> String {
        guard !self.isEmpty else { return self }
        guard self.contains(where: { $0 != "'" }) else { return "'".repeated(2 * count) }
        return "'\(self.replacing("'", with: "''"))'"
    }
}

extension Foundation.Date._polyfill_FormatString: ExpressibleByStringInterpolation {
    public init(stringInterpolation: StringInterpolation) {
        self.rawFormat = stringInterpolation.format
    }

    public init(stringLiteral value: String) {
        self.rawFormat = value.asDateFormatLiteral()
    }

    public struct StringInterpolation: StringInterpolationProtocol, Sendable {
        fileprivate var format: String = ""
        
        public init(literalCapacity: Int, interpolationCount: Int) {}

        mutating public func appendLiteral(_ literal: String) { self.format += literal.asDateFormatLiteral() }

        mutating public func appendInterpolation(              era: Foundation.Date._polyfill_FormatStyle.Symbol.Era              ) { self.format.append(era.option.rawValue              ) }
        mutating public func appendInterpolation(             year: Foundation.Date._polyfill_FormatStyle.Symbol.Year             ) { self.format.append(year.option.rawValue             ) }
        mutating public func appendInterpolation(yearForWeekOfYear: Foundation.Date._polyfill_FormatStyle.Symbol.YearForWeekOfYear) { self.format.append(yearForWeekOfYear.option.rawValue) }
        mutating public func appendInterpolation(       cyclicYear: Foundation.Date._polyfill_FormatStyle.Symbol.CyclicYear       ) { self.format.append(cyclicYear.option.rawValue       ) }
        mutating public func appendInterpolation(          quarter: Foundation.Date._polyfill_FormatStyle.Symbol.Quarter          ) { self.format.append(quarter.option.rawValue          ) }
        mutating public func appendInterpolation(standaloneQuarter: Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneQuarter) { self.format.append(standaloneQuarter.option.rawValue) }
        mutating public func appendInterpolation(            month: Foundation.Date._polyfill_FormatStyle.Symbol.Month            ) { self.format.append(month.option.rawValue            ) }
        mutating public func appendInterpolation(  standaloneMonth: Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneMonth  ) { self.format.append(standaloneMonth.option.rawValue  ) }
        mutating public func appendInterpolation(             week: Foundation.Date._polyfill_FormatStyle.Symbol.Week             ) { self.format.append(week.option.rawValue             ) }
        mutating public func appendInterpolation(              day: Foundation.Date._polyfill_FormatStyle.Symbol.Day              ) { self.format.append(day.option.rawValue              ) }
        mutating public func appendInterpolation(        dayOfYear: Foundation.Date._polyfill_FormatStyle.Symbol.DayOfYear        ) { self.format.append(dayOfYear.option.rawValue        ) }
        mutating public func appendInterpolation(          weekday: Foundation.Date._polyfill_FormatStyle.Symbol.Weekday          ) { self.format.append(weekday.option.rawValue          ) }
        mutating public func appendInterpolation(standaloneWeekday: Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneWeekday) { self.format.append(standaloneWeekday.option.rawValue) }
        mutating public func appendInterpolation(        dayPeriod: Foundation.Date._polyfill_FormatStyle.Symbol.DayPeriod        ) { self.format.append(dayPeriod.option.rawValue        ) }
        mutating public func appendInterpolation(             hour: Foundation.Date._polyfill_FormatStyle.Symbol.VerbatimHour     ) { self.format.append(hour.option.rawValue             ) }
        mutating public func appendInterpolation(           minute: Foundation.Date._polyfill_FormatStyle.Symbol.Minute           ) { self.format.append(minute.option.rawValue           ) }
        mutating public func appendInterpolation(           second: Foundation.Date._polyfill_FormatStyle.Symbol.Second           ) { self.format.append(second.option.rawValue           ) }
        mutating public func appendInterpolation(   secondFraction: Foundation.Date._polyfill_FormatStyle.Symbol.SecondFraction   ) { self.format.append(secondFraction.option.rawValue   ) }
        mutating public func appendInterpolation(         timeZone: Foundation.Date._polyfill_FormatStyle.Symbol.TimeZone         ) { self.format.append(timeZone.option.rawValue         ) }
    }
}

extension Foundation.Date {
    /// Converts `self` to its textual representation.
    ///
    /// - Parameter format: The format for formatting `self`.
    /// - Returns: A representation of `self` using the given `format`. The type of the representation is specified by `FormatStyle.FormatOutput`.
    public func _polyfill_formatted<F: FormatStylePolyfill._polyfill_FormatStyle>(_ format: F) -> F.FormatOutput where F.FormatInput == Date {
        format.format(self)
    }

    /// Converts `self` to its textual representation that contains both the date and time parts. The exact format depends on the user's preferences.
    ///
    /// - Parameters:
    ///   - date: The style for describing the date part.
    ///   - time: The style for describing the time part.
    /// - Returns: A `String` describing `self`.
    public func _polyfill_formatted(date: _polyfill_FormatStyle.DateStyle, time: _polyfill_FormatStyle.TimeStyle) -> String {
        _polyfill_FormatStyle(date: date, time: time).format(self)
    }

    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(Foundation.Date._polyfill_FormatStyle(date: .numeric, time: .shortened))
    }

    /// Creates a new `Date` by parsing the given representation.
    ///
    /// - Parameters:
    ///   - value: A representation of a date. The type of the representation is specified by `ParseStrategy.ParseInput`.
    ///   - strategy: The parse strategy to parse `value` whose `ParseOutput` is `Date`.
    public init<T: FormatStylePolyfill._polyfill_ParseStrategy>(_ value: T.ParseInput, _polyfill_strategy: T) throws where T.ParseOutput == Self {
        self = try strategy.parse(value)
    }

    /// Creates a new `Date` by parsing the given string representation.
    @_disfavoredOverload
    public init<T: FormatStylePolyfill._polyfill_ParseStrategy>(_ value: some StringProtocol, _polyfill_strategy: T) throws where T.ParseOutput == Self, T.ParseInput == String {
        self = try strategy.parse(String(value))
    }
}

extension Foundation.Date._polyfill_FormatStyle {
    struct DateFieldCollection: Codable, Hashable {
        var era: Symbol.SymbolType.EraOption?
        var year: Symbol.SymbolType.YearOption?
        var quarter: Symbol.SymbolType.QuarterOption?
        var month: Symbol.SymbolType.MonthOption?
        var week: Symbol.SymbolType.WeekOption?
        var day: Symbol.SymbolType.DayOption?
        var dayOfYear: Symbol.SymbolType.DayOfYearOption?
        var weekday: Symbol.SymbolType.WeekdayOption?
        var dayPeriod: Symbol.SymbolType.DayPeriodOption?
        var hour: Symbol.SymbolType.HourOption?
        var minute: Symbol.SymbolType.MinuteOption?
        var second: Symbol.SymbolType.SecondOption?
        var secondFraction: Symbol.SymbolType.SecondFractionOption?
        var timeZoneSymbol: Symbol.SymbolType.TimeZoneSymbolOption?

        func preferredHour(withLocale locale: Foundation.Locale?) -> Symbol.SymbolType.HourOption? {
            guard let hour, let locale else { return nil }
            guard locale.hourCycle == .zeroToEleven || locale.hourCycle == .oneToTwelve else {
                return hour
            }
            return if locale.language.languageCode == .chinese && locale.region == .taiwan {
                switch hour {
                case .defaultDigitsWithAbbreviatedAMPM: .conversationalDefaultDigitsWithAbbreviatedAMPM
                case .twoDigitsWithAbbreviatedAMPM: .conversationalTwoDigitsWithAbbreviatedAMPM
                case .defaultDigitsWithWideAMPM: .conversationalDefaultDigitsWithWideAMPM
                case .twoDigitsWithWideAMPM: .conversationalTwoDigitsWithWideAMPM
                case .defaultDigitsWithNarrowAMPM: .conversationalDefaultDigitsWithNarrowAMPM
                case .twoDigitsWithNarrowAMPM: .conversationalTwoDigitsWithNarrowAMPM
                default: hour
                }
            } else {
                hour
            }
        }

        func formatterTemplate(overridingDayPeriodWithLocale locale: Locale?) -> String {
            var ret = ""
            ret.append(self.era?.rawValue ?? "")
            ret.append(self.year?.rawValue ?? "")
            ret.append(self.quarter?.rawValue ?? "")
            ret.append(self.month?.rawValue ?? "")
            ret.append(self.week?.rawValue ?? "")
            ret.append(self.day?.rawValue ?? "")
            ret.append(self.dayOfYear?.rawValue ?? "")
            ret.append(self.weekday?.rawValue ?? "")
            ret.append(self.dayPeriod?.rawValue ?? "")
            ret.append(self.preferredHour(withLocale: locale)?.rawValue ?? "")
            ret.append(self.minute?.rawValue ?? "")
            ret.append(self.second?.rawValue ?? "")
            ret.append(self.secondFraction?.rawValue ?? "")
            ret.append(self.timeZoneSymbol?.rawValue ?? "")
            return ret
        }

        var dateFields: Self {
            DateFieldCollection(era: era, year: year, quarter: quarter, month: month, week: week, day: day, dayOfYear: dayOfYear, weekday: weekday, dayPeriod: dayPeriod)
        }

        mutating func add(_ rhs: Self) {
            self.era = rhs.era ?? self.era
            self.year = rhs.year ?? self.year
            self.quarter = rhs.quarter ?? self.quarter
            self.month = rhs.month ?? self.month
            self.week = rhs.week ?? self.week
            self.day = rhs.day ?? self.day
            self.dayOfYear = rhs.dayOfYear ?? self.dayOfYear
            self.weekday = rhs.weekday ?? self.weekday
            self.dayPeriod = rhs.dayPeriod ?? self.dayPeriod
            self.hour = rhs.hour ?? self.hour
            self.minute = rhs.minute ?? self.minute
            self.second = rhs.second ?? self.second
            self.secondFraction = rhs.secondFraction ?? self.secondFraction
            self.timeZoneSymbol = rhs.timeZoneSymbol ?? self.timeZoneSymbol
        }

        var empty: Bool {
            self.era == nil &&
            self.year == nil &&
            self.quarter == nil &&
            self.month == nil &&
            self.week == nil &&
            self.day == nil &&
            self.dayOfYear == nil &&
            self.weekday == nil &&
            self.dayPeriod == nil &&
            self.hour == nil &&
            self.minute == nil &&
            self.second == nil &&
            self.secondFraction == nil &&
            self.timeZoneSymbol == nil
        }

        func collection(date len: DateStyle) -> DateFieldCollection {
            var new = self
            if len == .omitted { return new }
            new.day = .defaultDigits
            new.year = .defaultDigits
            if len == .numeric { new.month = .defaultDigits }
            else if len == .abbreviated { new.month = .abbreviated }
            else if len == .long { new.month = .wide }
            else if len == .complete {
                new.month = .wide
                new.weekday = .wide
            }
            return new
        }

        func collection(time len: TimeStyle) -> DateFieldCollection {
            var new = self
            if len == .omitted { return new }
            new.hour = .defaultDigitsWithAbbreviatedAMPM
            new.minute = .twoDigits
            if len == .standard { new.second = .twoDigits }
            else if len == .complete {
                new.second = .twoDigits
                new.timeZoneSymbol = .shortSpecificName
            }
            return new
        }
    }
}

extension Foundation.Date {
    /// Strategies for formatting a `Date`.
    public struct _polyfill_FormatStyle: Sendable {
        var _symbols = DateFieldCollection()
        var symbols: DateFieldCollection {
            self._symbols.empty ? DateFieldCollection().collection(date: .numeric).collection(time: .shortened) : self._symbols
        }

        var _dateStyle: DateStyle? // For accessing locale pref's custom date format

        /// The locale to use when formatting date and time values.
        public var locale: Foundation.Locale

        /// The time zone with which to specify date and time values.
        public var timeZone: Foundation.TimeZone

        /// The calendar to use for date values.
        public var calendar: Foundation.Calendar

        /// The capitalization formatting context used when formatting date and time values.
        public var capitalizationContext: _polyfill_FormatStyleCapitalizationContext

        /// Returns
        public var attributed: _polyfill_AttributedStyle { .init(style: .formatStyle(self)) }

        var parseLenient: Bool = true

        /// Creates a new `FormatStyle` with the given configurations.
        ///
        /// - Parameters:
        ///   - date:  The date style for formatting the date.
        ///   - time:  The time style for formatting the date.
        ///   - locale: The locale to use when formatting date and time values.
        ///   - calendar: The calendar to use for date values.
        ///   - timeZone: The time zone with which to specify date and time values.
        ///   - capitalizationContext: The capitalization formatting context used when formatting date and time values.
        /// - Note: Always specify the date style, time style, or the date components to be included in the formatted string with the symbol modifiers. Otherwise, an empty string will be returned when you use the instance to format a `Date`.
        public init(
            date: DateStyle? = nil,
            time: TimeStyle? = nil,
            locale: Foundation.Locale = .autoupdatingCurrent,
            calendar: Foundation.Calendar = .autoupdatingCurrent,
            timeZone: Foundation.TimeZone = .autoupdatingCurrent,
            capitalizationContext: _polyfill_FormatStyleCapitalizationContext = .unknown) {
            if let dateStyle = date {
                self._dateStyle = dateStyle
                self._symbols = self._symbols.collection(date: dateStyle)
            }
            if let timeStyle = time {
                self._symbols = self._symbols.collection(time: timeStyle)
            }
            self.locale = locale
            self.calendar = calendar
            self.timeZone = timeZone
            self.capitalizationContext = capitalizationContext
        }

        private init(
            symbols: DateFieldCollection,
            dateStyle: DateStyle?,
            locale: Foundation.Locale,
            timeZone: Foundation.TimeZone,
            calendar: Foundation.Calendar,
            capitalizationContext: _polyfill_FormatStyleCapitalizationContext
        ) {
            self._symbols = symbols
            self._dateStyle = dateStyle
            self.locale = locale
            self.timeZone = timeZone
            self.calendar = calendar
            self.capitalizationContext = capitalizationContext
        }
    }

    public struct _polyfill_AttributedStyle: Sendable {
        enum InnerStyle: Codable, Hashable {
            case formatStyle(Foundation.Date._polyfill_FormatStyle)
            case verbatimFormatStyle(_polyfill_VerbatimFormatStyle)
        }
        var innerStyle: InnerStyle

        init(style: InnerStyle) {
            self.innerStyle = style
        }

        /// Returns an attributed string with `AttributeScopes.FoundationAttributes.DateFieldAttribute`
        public func format(_ value: Foundation.Date) -> Foundation.AttributedString {
            let fm: ICUDateFormatter = switch innerStyle {
            case .formatStyle(let formatStyle): ICUDateFormatter.cachedFormatter(for: formatStyle)
            case .verbatimFormatStyle(let verbatimFormatStyle): ICUDateFormatter.cachedFormatter(for: verbatimFormatStyle)
            }

            return if let (str, attributes) = fm.attributedFormat(value) { Self._attributedStringFromPositions(attributes, string: str) }
            else { AttributedString(value.description) }
        }

        static func _attributedStringFromPositions(_ positions: [ICUDateFormatter.AttributePosition], string: String) -> Foundation.AttributedString {
            typealias DateFieldAttribute = Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field

            var attrstr = Foundation.AttributedString(string)
            for attr in positions {
                let strRange = String.Index(utf16Offset: attr.begin, in: string) ..< String.Index(utf16Offset: attr.end, in: string)
                let range = Range<Foundation.AttributedString.Index>(strRange, in: attrstr)!
                let field = attr.field
                var container = Foundation.AttributeContainer()
                if let dateField = DateFieldAttribute(udateFormatField: field) { container.dateField = dateField }
                attrstr[range].mergeAttributes(container)
            }
            return attrstr
        }

        public func locale(_ locale: Foundation.Locale) -> Self {
            let newInnerStyle: InnerStyle = switch self.innerStyle {
            case .formatStyle(let style): .formatStyle(style.locale(locale))
            case .verbatimFormatStyle(let style): .verbatimFormatStyle(style.locale(locale))
            }

            var new = self
            new.innerStyle = newInnerStyle
            return new
        }
    }
}

extension Foundation.Date._polyfill_AttributedStyle: _polyfill_FormatStyle {}

extension Foundation.Date._polyfill_FormatStyle {
    public func       era(_ format: Symbol.Era       = .abbreviated  ) -> Self           { var n = self; n._symbols.era            = format.option; return n }
    public func      year(_ format: Symbol.Year      = .defaultDigits) -> Self           { var n = self; n._symbols.year           = format.option; return n }
    public func   quarter(_ format: Symbol.Quarter   = .abbreviated  ) -> Self           { var n = self; n._symbols.quarter        = format.option; return n }
    public func     month(_ format: Symbol.Month     = .abbreviated  ) -> Self           { var n = self; n._symbols.month          = format.option; return n }
    public func      week(_ format: Symbol.Week      = .defaultDigits) -> Self           { var n = self; n._symbols.week           = format.option; return n }
    public func       day(_ format: Symbol.Day       = .defaultDigits) -> Self           { var n = self; n._symbols.day            = format.option; return n }
    public func dayOfYear(_ format: Symbol.DayOfYear = .defaultDigits) -> Self           { var n = self; n._symbols.dayOfYear      = format.option; return n }
    public func   weekday(_ format: Symbol.Weekday   = .abbreviated  ) -> Self           { var n = self; n._symbols.weekday        = format.option; return n }
    public func hour(_ format: Symbol.Hour = .defaultDigits(amPM: .abbreviated)) -> Self { var n = self; n._symbols.hour           = format.option; return n }
    public func    minute(_ format: Symbol.Minute    = .defaultDigits) -> Self           { var n = self; n._symbols.minute         = format.option; return n }
    public func    second(_ format: Symbol.Second    = .defaultDigits) -> Self           { var n = self; n._symbols.second         = format.option; return n }
    public func secondFraction(_ format: Symbol.SecondFraction       ) -> Self           { var n = self; n._symbols.secondFraction = format.option; return n }
    public func  timeZone(_ format: Symbol.TimeZone  = .specificName(.short)) -> Self    { var n = self; n._symbols.timeZoneSymbol = format.option; return n }
}

extension Foundation.Date._polyfill_FormatStyle: _polyfill_FormatStyle {
    public func format(_ value: Date) -> String {
        ICUDateFormatter.cachedFormatter(for: self).format(value) ?? value.description
    }

    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}


extension Foundation.Date._polyfill_FormatStyle: _polyfill_ParseStrategy {
    public func parse(_ value: String) throws -> Date {
        guard let date = ICUDateFormatter.cachedFormatter(for: self).parse(value) else {
            throw parseError(value, example: ICUDateFormatter.cachedFormatter(for: self).format(.now))
        }
        return date
    }
}

extension Foundation.Date._polyfill_FormatStyle: Codable, Hashable {
    enum CodingKeys: CodingKey {
        case symbols, locale, timeZone, calendar, capitalizationContext, dateStyle
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.symbols, forKey: .symbols)
        try container.encode(self.locale, forKey: .locale)
        try container.encode(self.timeZone, forKey: .timeZone)
        try container.encode(self.calendar, forKey: .calendar)
        try container.encode(self.capitalizationContext, forKey: .capitalizationContext)
        try container.encodeIfPresent(self._dateStyle, forKey: .dateStyle)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let symbols = try container.decode(DateFieldCollection.self, forKey: .symbols)
        let locale = try container.decode(Locale.self, forKey: .locale)
        let timeZone = try container.decode(TimeZone.self, forKey: .timeZone)
        let calendar = try container.decode(Calendar.self, forKey: .calendar)
        let context = try container.decode(_polyfill_FormatStyleCapitalizationContext.self, forKey: .capitalizationContext)
        let dateStyle = try container.decodeIfPresent(DateStyle.self, forKey: .dateStyle)
        self.init(symbols: symbols, dateStyle: dateStyle, locale: locale, timeZone: timeZone, calendar: calendar, capitalizationContext: context)
    }
}

extension Foundation.Date._polyfill_FormatStyle {
    /// Predefined date styles varied in lengths or the components included. The exact format depends on the locale.
    public struct DateStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// Excludes the date part.
        public static let omitted: Self = .init(rawValue: 0)

        /// Shows date components in their numeric form. For example, "10/21/2015".
        public static let numeric: Self = .init(rawValue: 1)

        /// Shows date components in their abbreviated form if possible. For example, "Oct 21, 2015".
        public static let abbreviated: Self = .init(rawValue: 2)

        /// Shows date components in their long form if possible. For example, "October 21, 2015".
        public static let long: Self = .init(rawValue: 3)

        /// Shows the complete day. For example, "Wednesday, October 21, 2015".
        public static let complete: Self = .init(rawValue: 4)
    }

    /// Predefined time styles varied in lengths or the components included. The exact format depends on the locale.
    public struct TimeStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// Excludes the time part.
        public static let omitted: Self = .init(rawValue: 0)

        /// For example, `04:29 PM`, `16:29`.
        public static let shortened: Self = .init(rawValue: 1)

        /// For example, `4:29:24 PM`, `16:29:24`.
        public static let standard: Self = .init(rawValue: 2)

        /// For example, `4:29:24 PM PDT`, `16:29:24 GMT`.
        public static let complete: Self = .init(rawValue: 3)
    }
}

extension Foundation.Date._polyfill_FormatStyle: _polyfill_ParseableFormatStyle {
    public var parseStrategy: Foundation.Date._polyfill_FormatStyle { self }
}

extension _polyfill_FormatStyle where Self == Foundation.Date._polyfill_FormatStyle {
    public static var dateTime: Self { .init() }
}

extension _polyfill_ParseableFormatStyle where Self == Foundation.Date._polyfill_FormatStyle {
    public static var dateTime: Self { .init() }
}

extension _polyfill_ParseStrategy where Self == Foundation.Date._polyfill_FormatStyle {
    @_disfavoredOverload
    public static var dateTime: Self { .init() }
}

extension Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field {
    init?(udateFormatField: UDateFormatField) {
        switch udateFormatField {
        case UDAT_ERA_FIELD:                           self = .era
        case UDAT_YEAR_FIELD:                          self = .year
        case UDAT_MONTH_FIELD:                         self = .month
        case UDAT_DATE_FIELD:                          self = .day
        case UDAT_HOUR_OF_DAY1_FIELD:                  self = .hour // "k"
        case UDAT_HOUR_OF_DAY0_FIELD:                  self = .hour // "H"
        case UDAT_MINUTE_FIELD:                        self = .minute
        case UDAT_SECOND_FIELD:                        self = .second
        case UDAT_FRACTIONAL_SECOND_FIELD:             self = .secondFraction
        case UDAT_DAY_OF_WEEK_FIELD:                   self = .weekday // "E"
        case UDAT_DAY_OF_YEAR_FIELD:                   self = .dayOfYear // "D"
        case UDAT_DAY_OF_WEEK_IN_MONTH_FIELD:          self = .weekdayOrdinal // "F"
        case UDAT_WEEK_OF_YEAR_FIELD:                  self = .weekOfYear
        case UDAT_WEEK_OF_MONTH_FIELD:                 self = .weekOfMonth
        case UDAT_AM_PM_FIELD:                         self = .amPM
        case UDAT_HOUR1_FIELD:                         self = .hour
        case UDAT_HOUR0_FIELD:                         self = .hour
        case UDAT_TIMEZONE_FIELD:                      self = .timeZone
        case UDAT_YEAR_WOY_FIELD:                      self = .year
        case UDAT_DOW_LOCAL_FIELD:                     self = .weekday // "e"
        case UDAT_EXTENDED_YEAR_FIELD:                 self = .year
        case UDAT_JULIAN_DAY_FIELD:                    self = .day
        case UDAT_MILLISECONDS_IN_DAY_FIELD:           self = .second
        case UDAT_TIMEZONE_RFC_FIELD:                  self = .timeZone
        case UDAT_TIMEZONE_GENERIC_FIELD:              self = .timeZone
        case UDAT_STANDALONE_DAY_FIELD:                self = .weekday // "c": day of week number/name
        case UDAT_STANDALONE_MONTH_FIELD:              self = .month
        case UDAT_STANDALONE_QUARTER_FIELD:            self = .quarter
        case UDAT_QUARTER_FIELD:                       self = .quarter
        case UDAT_TIMEZONE_SPECIAL_FIELD:              self = .timeZone
        case UDAT_YEAR_NAME_FIELD:                     self = .year
        case UDAT_TIMEZONE_LOCALIZED_GMT_OFFSET_FIELD: self = .timeZone
        case UDAT_TIMEZONE_ISO_FIELD:                  self = .timeZone
        case UDAT_TIMEZONE_ISO_LOCAL_FIELD:            self = .timeZone
        case UDAT_AM_PM_MIDNIGHT_NOON_FIELD:           self = .amPM
        case UDAT_FLEXIBLE_DAY_PERIOD_FIELD:           self = .amPM
        default:                                       return nil
        }
    }
}

extension Foundation.Date._polyfill_FormatStyle: CustomConsumingRegexComponent {
    public typealias RegexOutput = Date
    
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Date)? {
        guard index < bounds.upperBound else { return nil }
        return ICUDateFormatter.cachedFormatter(for: self).parse(input, in: index ..< bounds.upperBound)
    }
}

extension Foundation.Date {
    /// Formats a `Date` using the given format.
    public struct _polyfill_VerbatimFormatStyle: Sendable {
        public var timeZone: Foundation.TimeZone
        public var calendar: Foundation.Calendar

        /// Use system locale if nil or unspecified.
        public var locale: Foundation.Locale?

        var formatPattern: String
        
        public init(format: _polyfill_FormatString, locale: Foundation.Locale? = nil, timeZone: Foundation.TimeZone, calendar: Foundation.Calendar) {
            self.formatPattern = format.rawFormat
            self.calendar = calendar
            self.locale = locale
            self.timeZone = timeZone
        }

        /// Returns the corresponding `AttributedStyle` which formats the date with  `AttributeScopes.FoundationAttributes.DateFormatFieldAttribute`
        public var attributed: _polyfill_AttributedStyle {
            .init(style: .verbatimFormatStyle(self))
        }

        public func format(_ value: Foundation.Date) -> String {
            ICUDateFormatter.cachedFormatter(for: self).format(value) ?? value.description
        }

        public func locale(_ locale: Foundation.Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }
    }
}

extension Foundation.Date._polyfill_VerbatimFormatStyle: _polyfill_FormatStyle {}

extension _polyfill_FormatStyle where Self == Foundation.Date._polyfill_VerbatimFormatStyle {
    public static func verbatim(_ format: Foundation.Date._polyfill_FormatString, locale: Foundation.Locale? = nil, timeZone: Foundation.TimeZone, calendar: Foundation.Calendar) -> Foundation.Date._polyfill_VerbatimFormatStyle { .init(format: format, locale: locale, timeZone: timeZone, calendar: calendar) }
}

extension Foundation.Date._polyfill_VerbatimFormatStyle: _polyfill_ParseableFormatStyle {
    public var parseStrategy: Foundation.Date._polyfill_ParseStrategy {
        .init(format: formatPattern, locale: locale, timeZone: timeZone, calendar: calendar, isLenient: false, twoDigitStartDate: Date(timeIntervalSince1970: 0))
    }
}

extension Foundation.Date._polyfill_VerbatimFormatStyle: CustomConsumingRegexComponent {
    public typealias RegexOutput = Date
    
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Date)? {
        try self.parseStrategy.consuming(input, startingAt: index, in: bounds)
    }
}

typealias CalendarComponentAndValue = (component: Calendar.Component, value: Int)

extension Foundation.Date {
    public struct _polyfill_RelativeFormatStyle: Codable, Hashable, Sendable {
        public struct UnitsStyle: Codable, Hashable, Sendable {
            enum Option: Int, Codable, Hashable {
                case wide, spellOut, abbreviated, narrow
            }
            var option: Option

            var icuNumberFormatStyle: UNumberFormatStyle? {
                self.option == .spellOut ? UNUM_SPELLOUT : nil
            }

            var icuRelativeDateStyle: UDateRelativeDateTimeFormatterStyle {
                switch self.option {
                case .spellOut, .wide: UDAT_STYLE_LONG
                case .abbreviated: UDAT_STYLE_SHORT
                case .narrow: UDAT_STYLE_NARROW
                }
            }

            /// "2 months ago", "next Wednesday"
            public static var wide: Self { .init(option: .wide) }

            /// "two months ago", "next Wednesday"
            public static var spellOut: Self { .init(option: .spellOut) }

            /// "2 mo. ago", "next Wed."
            public static var abbreviated: Self { .init(option: .abbreviated) }

            /// "2 mo. ago", "next W"
            public static var narrow: Self { .init(option: .narrow) }
        }

        public struct Presentation: Codable, Hashable, Sendable {
            enum Option: Int, Codable, Hashable {
                case numeric, named
            }
            var option: Option

            /// "1 day ago", "2 days ago", "1 week ago", "in 1 week"
            public static var numeric: Self { .init(option: .numeric) }

            /// "yesterday", "2 days ago", "last week", "next week"; falls back to the numeric style if no name is available.
            public static var named: Self { .init(option: .named) }
        }

        public var presentation: Presentation
        public var unitsStyle: UnitsStyle
        public var capitalizationContext: _polyfill_FormatStyleCapitalizationContext
        public var locale: Foundation.Locale
        public var calendar: Foundation.Calendar

        public init(
            presentation: Presentation = .numeric,
            unitsStyle: UnitsStyle = .wide,
            locale: Foundation.Locale = .autoupdatingCurrent,
            calendar: Foundation.Calendar = .autoupdatingCurrent,
            capitalizationContext: _polyfill_FormatStyleCapitalizationContext = .unknown
        ) {
            self.presentation = presentation
            self.unitsStyle = unitsStyle
            self.capitalizationContext = capitalizationContext
            self.locale = locale
            self.calendar = calendar
        }

        public func format(_ destDate: Foundation.Date) -> String { self._format(destDate, refDate: Date.now) }

        public func locale(_ locale: Foundation.Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }

        enum ComponentAdjustmentStrategy: Codable, Hashable {
            case alignedWithComponentBoundary, rounded
        }

        var componentAdjustmentStrategy: ComponentAdjustmentStrategy?

        private func _format(_ destDate: Foundation.Date, refDate: Foundation.Date) -> String {
            let strategy: ComponentAdjustmentStrategy = switch self.presentation.option {
            case .numeric: .rounded
            case .named: .alignedWithComponentBoundary
            }

            let (component, value) = self.largestNonZeroComponent(destDate, reference: refDate, adjustComponent: strategy)
            return ICURelativeDateFormatter.formatter(for: self).format(value: value, component: component, presentation: self.presentation)!
        }


        private static func alignedComponentValue(
            component: Foundation.Calendar.Component,
            for destDate: Foundation.Date,
            reference refDate: Foundation.Date,
            calendar: Foundation.Calendar
        ) -> CalendarComponentAndValue? {
            var refDateStart = refDate, interval: TimeInterval = 0
            guard calendar.dateInterval(of: component, start: &refDateStart, interval: &interval, for: refDate) else { return nil }

            return calendar
                .dateComponents(
                    Set(ICURelativeDateFormatter.sortedAllowedComponents),
                    from: refDateStart.addingTimeInterval(refDate < destDate ? 0 : interval - 1),
                    to: destDate
                )
                .nonZeroComponentsAndValue.first
        }

        private static func roundedLargestComponentValue(
            components: Foundation.DateComponents,
            for destDate: Foundation.Date,
            calendar: Foundation.Calendar
        ) -> CalendarComponentAndValue? {
            let compsAndValues = components.nonZeroComponentsAndValue

            if var largest = compsAndValues.first {
                if compsAndValues.count >= 2, let range = calendar.range(of: compsAndValues[1].component, in: largest.component, for: destDate),
                   Swift.abs(compsAndValues[1].value) * 2 >= range.count {
                    largest.value += compsAndValues[1].value > 0 ? 1 : -1
                }
                return largest
            }
            return nil
        }

        private func largestNonZeroComponent(
            _ destDate: Foundation.Date,
            reference refDate: Foundation.Date,
            adjustComponent: ComponentAdjustmentStrategy
        ) -> CalendarComponentAndValue {
            var searchComponents = ICURelativeDateFormatter.sortedAllowedComponents
            searchComponents.append(.nanosecond)
            let components = self.calendar.dateComponents(Set(searchComponents), from: refDate, to: destDate)

            let dateComponents = if let nanosecond = components.value(for: .nanosecond),
                                    abs(nanosecond) > Int(0.5 * 1.0e+9),
                                    let adjustedDestDate = calendar.date(byAdding: .second, value: nanosecond > 0 ? 1 : -1, to: destDate) {
                self.calendar.dateComponents(Set(ICURelativeDateFormatter.sortedAllowedComponents), from: refDate, to: adjustedDestDate)
            } else {
                components
            }

            let compAndValue: CalendarComponentAndValue
            if let largest = dateComponents.nonZeroComponentsAndValue.first {
                if largest.component == .hour || largest.component == .minute || largest.component == .second {
                    compAndValue = Self.roundedLargestComponentValue(components: dateComponents, for: destDate, calendar: self.calendar) ?? largest
                } else {
                    compAndValue = Self.alignedComponentValue(component: largest.component, for: destDate, reference: refDate, calendar: self.calendar) ?? largest
                }
            } else {
                let smallestUnit = ICURelativeDateFormatter.sortedAllowedComponents.last!
                compAndValue = (smallestUnit, dateComponents.value(for: smallestUnit)!)
            }

            return compAndValue
        }
    }
}

extension Foundation.Date._polyfill_RelativeFormatStyle: _polyfill_FormatStyle {}

extension Foundation.DateComponents {
    var nonZeroComponentsAndValue: [CalendarComponentAndValue] {
        ICURelativeDateFormatter.sortedAllowedComponents.filter { self.value(for: $0) != 0 }.map { ($0, self.value(for: $0)!) }
    }
}

public extension _polyfill_FormatStyle where Self == Foundation.Date._polyfill_RelativeFormatStyle {
    static func relative(
        presentation: Foundation.Date._polyfill_RelativeFormatStyle.Presentation,
        unitsStyle: Foundation.Date._polyfill_RelativeFormatStyle.UnitsStyle = .wide
    ) -> Self {
        .init(presentation: presentation, unitsStyle: unitsStyle)
    }
}

extension Foundation.Date {
    public struct _polyfill_IntervalFormatStyle: Codable, Hashable, Sendable {
        public typealias DateStyle = Foundation.Date._polyfill_FormatStyle.DateStyle
        public typealias TimeStyle = Foundation.Date._polyfill_FormatStyle.TimeStyle

        public var locale: Foundation.Locale
        public var timeZone: Foundation.TimeZone
        public var calendar: Foundation.Calendar

        var symbols = Foundation.Date._polyfill_FormatStyle.DateFieldCollection()

        /// Creates a new `FormatStyle` with the given configurations.
        ///
        /// - Parameters:
        ///   - date: The style for formatting the date part of the given date pairs. Note that if
        ///     `.omitted` is specified, but the date interval spans more than one day, a locale-specific
        ///     fallback will be used.
        ///   - time: The style for formatting the time part of the given date pairs.
        ///   - locale: The locale to use when formatting date and time values.
        ///   - calendar: The calendar to use for date values.
        ///   - timeZone: The time zone with which to specify date and time values.
        ///
        /// > Important: Always specify the date length, time length, or the date components to be included
        /// > in the formatted string with the symbol modifiers. Otherwise, an empty string will be returned
        /// > when you use the instance to format an object.
        ///
        /// > Note: If specifying the date fields, and the `DateInterval` range is larger than the specified
        /// > units, a locale-specific fallback will be used.
        /// >   > Example: for the range 2010-03-04 07:56 - 2010-03-08 16:11 (4 days, 8 hours, 15 minutes),
        /// >   > specifying `.hour().minute()` will produce
        /// >   >   - for `en_US`, "3/4/2010 7:56 AM - 3/8/2010 4:11 PM"
        /// >   >   - for `en_GB`, "4/3/2010 7:56 - 8/3/2010 16:11"
        public init(
            date: DateStyle? = nil,
            time: TimeStyle? = nil,
            locale: Foundation.Locale = .autoupdatingCurrent,
            calendar: Foundation.Calendar = .autoupdatingCurrent,
            timeZone: Foundation.TimeZone = .autoupdatingCurrent
        ) {
            self.locale = locale
            self.calendar = calendar
            self.timeZone = timeZone
            if let date { self.symbols = self.symbols.collection(date: date) }
            if let time { self.symbols = self.symbols.collection(time: time) }
        }

        public func format(_ v: Range<Foundation.Date>) -> String {
            ICUDateIntervalFormatter.formatter(for: self).string(from: v)
        }

        public func locale(_ locale: Foundation.Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }
    }
}

extension Foundation.Date._polyfill_IntervalFormatStyle: _polyfill_FormatStyle {}

extension Foundation.Date._polyfill_IntervalFormatStyle {
    public typealias Symbol = Foundation.Date._polyfill_FormatStyle.Symbol
    public func year()                                                           -> Self { var n = self; n.symbols.year           = .defaultDigits; return n }
    public func month(_ format: Symbol.Month = .abbreviated)                     -> Self { var n = self; n.symbols.month          = format.option;  return n }
    public func day()                                                            -> Self { var n = self; n.symbols.day            = .defaultDigits; return n }
    public func weekday(_ format: Symbol.Weekday = .abbreviated)                 -> Self { var n = self; n.symbols.weekday        = format.option;  return n }
    public func hour(_ format: Symbol.Hour = .defaultDigits(amPM: .abbreviated)) -> Self { var n = self; n.symbols.hour           = format.option;  return n }
    public func minute()                                                         -> Self { var n = self; n.symbols.minute         = .defaultDigits; return n }
    public func second()                                                         -> Self { var n = self; n.symbols.second         = .defaultDigits; return n }
    public func timeZone(_ format: Symbol.TimeZone = .genericName(.short))       -> Self { var n = self; n.symbols.timeZoneSymbol = format.option;  return n }
}

extension _polyfill_FormatStyle where Self == Foundation.Date._polyfill_IntervalFormatStyle {
    public static var interval: Self { .init() }
}

extension Range where Bound == Foundation.Date {
    /// Formats the date range as an interval.
    public func _polyfill_formatted() -> String {
        Foundation.Date._polyfill_IntervalFormatStyle().format(self)
    }
    
    /// Formats the date range using the specified date and time format styles.
    public func _polyfill_formatted(
        date: Foundation.Date._polyfill_IntervalFormatStyle.DateStyle,
        time: Foundation.Date._polyfill_IntervalFormatStyle.TimeStyle
    ) -> String {
        Foundation.Date._polyfill_IntervalFormatStyle(date: date, time: time).format(self)
    }
    
    /// Formats the date range using the specified style.
    public func _polyfill_formatted<S>(_ style: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput == Range<Foundation.Date> {
        style.format(self)
    }
}

extension Foundation.Date {
    public func _polyfill_ISO8601Format(_ style: _polyfill_ISO8601FormatStyle = .init()) -> String {
        style.format(self)
    }
}

extension Foundation.Date {
    /// Options for generating and parsing string representations of dates following the ISO 8601 standard.
    public struct _polyfill_ISO8601FormatStyle: Sendable {
        public enum TimeZoneSeparator: String, Codable, Sendable { case colon = ":", omitted = "" }
        public enum DateSeparator: String, Codable, Sendable     { case dash = "-", omitted = "" }
        public enum TimeSeparator: String, Codable, Sendable     { case colon = ":", omitted = "" }
        public enum DateTimeSeparator: String, Codable, Sendable { case space = " ", standard = "'T'" }
        
        enum Field: Int, Codable, Hashable, Comparable {
            case year, month, weekOfYear, day, time, timeZone

            static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
        }
        
        public private(set) var timeSeparator: TimeSeparator
        public private(set) var includingFractionalSeconds: Bool
        public private(set) var timeZoneSeparator: TimeZoneSeparator
        public private(set) var dateSeparator: DateSeparator
        public private(set) var dateTimeSeparator: DateTimeSeparator

        private var _formatFields: Set<Field> = []
        var formatFields: Set<Field> { self._formatFields.isEmpty ? [ .year, .month, .day, .time, .timeZone] : self._formatFields }
        
        /// The time zone to use to create and parse date representations.
        public var timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!

        private var format: String {
            let fields = self.formatFields
            var result = ""
            for (idx, field) in fields.sorted().enumerated() {
                switch field {
                case .year: result += fields.contains(.weekOfYear) ? "YYYY" : "yyyy"
                case .month:
                    if idx > 0, self.dateSeparator == .dash { result += DateSeparator.dash.rawValue }
                    result += "MM"
                case .weekOfYear:
                    if idx > 0, self.dateSeparator == .dash { result += DateSeparator.dash.rawValue }
                    result += "'W'ww"
                case .day:
                    if idx > 0, self.dateSeparator == .dash { result += DateSeparator.dash.rawValue }
                    if fields.contains(.weekOfYear) { result += "ee" }
                    else if fields.contains(.month) { result += "dd" }
                    else { result += "DDD" }
                case .time:
                    if idx > 0 { result += self.dateTimeSeparator.rawValue }
                    switch self.timeSeparator {
                    case .colon: result += "HH:mm:ss"
                    case .omitted: result += "HHmmss"
                    }
                    if self.includingFractionalSeconds { result += ".SSS" }
                case .timeZone:
                    switch self.timeZoneSeparator {
                    case .colon: result += "XXXXX"
                    case .omitted: result += "XXXX"
                    }
                }
            }
            return result
        }

        private var formatter: ICUDateFormatter {
            .cachedFormatter(for: .init(
                localeIdentifier: "en_US_POSIX",
                timeZoneIdentifier: self.timeZone.identifier,
                calendarIdentifier: .gregorian,
                firstWeekday: 2,
                minimumDaysInFirstWeek: 4,
                capitalizationContext: .unknown,
                pattern: self.format,
                parseLenient: false
            ))
        }

        @_disfavoredOverload
        public init(
            dateSeparator: DateSeparator = .dash,
            dateTimeSeparator: DateTimeSeparator = .standard,
            timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!
        ) {
            self.dateSeparator = dateSeparator
            self.dateTimeSeparator = dateTimeSeparator
            self.timeZone = timeZone
            self.timeSeparator = .colon
            self.timeZoneSeparator = .omitted
            self.includingFractionalSeconds = false
        }

        // The default is the format of RFC 3339 with no fractional seconds: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        public init(
            dateSeparator: DateSeparator = .dash,
            dateTimeSeparator: DateTimeSeparator = .standard,
            timeSeparator: TimeSeparator = .colon,
            timeZoneSeparator: TimeZoneSeparator = .omitted,
            includingFractionalSeconds: Bool = false,
            timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!
        ) {
            self.dateSeparator = dateSeparator
            self.dateTimeSeparator = dateTimeSeparator
            self.timeZone = timeZone
            self.timeSeparator = timeSeparator
            self.timeZoneSeparator = timeZoneSeparator
            self.includingFractionalSeconds = includingFractionalSeconds
        }
    }
}

extension Foundation.Date._polyfill_ISO8601FormatStyle {
    public func       year() -> Self { var new = self; new._formatFields.insert(.year);       return new }
    public func weekOfYear() -> Self { var new = self; new._formatFields.insert(.weekOfYear); return new }
    public func      month() -> Self { var new = self; new._formatFields.insert(.month);      return new }
    public func        day() -> Self { var new = self; new._formatFields.insert(.day);        return new }
    public func time(includingFractionalSeconds i: Bool) -> Self { var new = self; new._formatFields.insert(.time);     new.includingFractionalSeconds = i; return new }
    public func timeZone(separator s: TimeZoneSeparator) -> Self { var new = self; new._formatFields.insert(.timeZone); new.timeZoneSeparator = s;          return new }
    public func     dateSeparator(_ sep: DateSeparator    ) -> Self { var new = self; new.dateSeparator = sep;     return new }
    public func dateTimeSeparator(_ sep: DateTimeSeparator) -> Self { var new = self; new.dateTimeSeparator = sep; return new }
    public func     timeSeparator(_ sep: TimeSeparator    ) -> Self { var new = self; new.timeSeparator = sep;     return new }
    public func timeZoneSeparator(_ sep: TimeZoneSeparator) -> Self { var new = self; new.timeZoneSeparator = sep; return new }
}

extension Foundation.Date._polyfill_ISO8601FormatStyle: _polyfill_FormatStyle {
    public func format(_ value: Foundation.Date) -> String {
        self.formatter.format(value) ?? value.description
    }
}

extension Foundation.Date._polyfill_ISO8601FormatStyle: _polyfill_ParseStrategy {
    public func parse(_ value: String) throws -> Foundation.Date {
        guard let date = self.formatter.parse(value) else { throw parseError(value, example: self.formatter.format(.now))}
        return date
    }
}

extension Foundation.Date._polyfill_ISO8601FormatStyle: _polyfill_ParseableFormatStyle {
    public var parseStrategy: Self { self }
}

extension _polyfill_FormatStyle where Self == Foundation.Date._polyfill_ISO8601FormatStyle {
    public static var iso8601: Self { .init() }
}

extension _polyfill_ParseableFormatStyle where Self == Foundation.Date._polyfill_ISO8601FormatStyle {
    public static var iso8601: Self { .init() }
}

extension _polyfill_ParseStrategy where Self == Foundation.Date._polyfill_ISO8601FormatStyle {
    @_disfavoredOverload
    public static var iso8601: Self { .init() }
}

extension Foundation.Date._polyfill_ISO8601FormatStyle: CustomConsumingRegexComponent {
    public typealias RegexOutput = Foundation.Date
    
    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Foundation.Date)? {
        guard index < bounds.upperBound else { return nil }
        return self.formatter.parse(input, in: index..<bounds.upperBound)
    }
}

extension RegexComponent where Self == Foundation.Date._polyfill_ISO8601FormatStyle {
    /// Creates a regex component to match an ISO 8601 date and time, such as "2015-11-14'T'15:05:03'Z'",
    /// and capture the string as a `Date` using the time zone as specified in the string.
    @_disfavoredOverload
    public static var iso8601: Self { .init() }

    /// Creates a regex component to match an ISO 8601 date and time string, including time zone, and
    /// capture the string as a `Date` using the time zone as specified in the string.
    ///
    /// - Parameters:
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    ///   - timeZoneSeparator: The separator between time parts in the time zone.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string, including time zone.
    public static func iso8601WithTimeZone(
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon,
        timeZoneSeparator: Self.TimeZoneSeparator = .omitted
    ) -> Self {
        .init(
            dateSeparator: dateSeparator,
            dateTimeSeparator: dateTimeSeparator,
            timeSeparator: timeSeparator,
            timeZoneSeparator: timeZoneSeparator,
            includingFractionalSeconds: includingFractionalSeconds
        )
    }

    /// Creates a regex component to match an ISO 8601 date and time string without time zone, and
    /// capture the string as a `Date` using the specified `timeZone`. If the string contains time
    /// zone designators, matches up until the start of time zone designators.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string.
    public static func iso8601(
        timeZone: Foundation.TimeZone,
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon
    ) -> Self {
        .init(timeZone: timeZone)
            .year()
            .month()
            .day()
            .time(includingFractionalSeconds: includingFractionalSeconds)
            .timeSeparator(timeSeparator)
            .dateSeparator(dateSeparator)
            .dateTimeSeparator(dateTimeSeparator)
    }

    /// Creates a regex component to match an ISO 8601 date string, such as "2015-11-14", and
    /// capture the string as a `Date`. The captured `Date` would be at midnight in the specified `timeZone`.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - dateSeparator: The separator between date components.
    /// - Returns:  A `RegexComponent` to match an ISO 8601 date string, including time zone.
    public static func iso8601Date(timeZone: Foundation.TimeZone, dateSeparator: Self.DateSeparator = .dash) -> Self {
        .init(dateSeparator: dateSeparator, timeZone: timeZone).year().month().day()
    }
}

extension Foundation.Date {
    /// Options for parsing string representations of dates to create a `Date` instance.
    public struct _polyfill_ParseStrategy: Hashable, Sendable {
        /// Indicates whether to use heuristics when parsing the representation.
        public var isLenient: Bool

        /// The earliest date that can be denoted by a two-digit year specifier.
        public var twoDigitStartDate: Foundation.Date

        /// The locale to use when parsing date strings with the specified format.
        /// Use system locale if unspecified.
        public var locale: Foundation.Locale?

        /// The time zone to use for creating the date.
        public var timeZone: Foundation.TimeZone

        /// The calendar to use when parsing date strings and creating the date.
        public var calendar: Foundation.Calendar

        /// The string representation of the fixed format conforming to Unicode Technical Standard #35.
        public private(set) var format: String

        /// Creates a new `ParseStrategy` with the given configurations.
        /// - Parameters:
        ///   - format: A fixed format representing the pattern of the date string.
        ///   - locale: The locale of the fixed format.
        ///   - timeZone: The time zone to use for creating the date.
        ///   - isLenient: Whether to use heuristics when parsing the representation.
        ///   - twoDigitStartDate: The earliest date that can be denoted by a two-digit year specifier.
        public init(
            format: _polyfill_FormatString,
            locale: Foundation.Locale? = nil,
            timeZone: Foundation.TimeZone,
            calendar: Foundation.Calendar = .init(identifier: .gregorian),
            isLenient: Bool = true,
            twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
        ) {
            self.init(format: format.rawFormat, locale: locale, timeZone: timeZone, calendar: calendar, isLenient: isLenient, twoDigitStartDate: twoDigitStartDate)
        }

        init(format: String, locale: Foundation.Locale?, timeZone: Foundation.TimeZone, calendar: Foundation.Calendar, isLenient: Bool, twoDigitStartDate: Foundation.Date) {
            self.locale = locale
            self.timeZone = timeZone
            self.format = format
            self.calendar = calendar
            self.isLenient = isLenient
            self.twoDigitStartDate = twoDigitStartDate
        }

        private var formatter: ICUDateFormatter {
            .cachedFormatter(for: .init(
                localeIdentifier: self.locale?.identifier,
                timeZoneIdentifier: self.timeZone.identifier,
                calendarIdentifier: self.calendar.identifier,
                firstWeekday: self.calendar.firstWeekday,
                minimumDaysInFirstWeek: self.calendar.minimumDaysInFirstWeek,
                capitalizationContext: .unknown,
                pattern: self.format,
                parseLenient: self.isLenient,
                parseTwoDigitStartDate: self.twoDigitStartDate
            ))
        }

        init(
            formatStyle: Foundation.Date._polyfill_FormatStyle,
            lenient: Bool,
            twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
        ) {
            self.init(
                format: ICUPatternGenerator.localizedPattern(symbols: formatStyle.symbols, locale: formatStyle.locale, calendar: formatStyle.calendar),
                locale: formatStyle.locale,
                timeZone: formatStyle.timeZone,
                calendar: formatStyle.calendar,
                isLenient: lenient,
                twoDigitStartDate: twoDigitStartDate
            )
        }
    }
}

extension Foundation.Date._polyfill_ParseStrategy: _polyfill_ParseStrategy {
    /// Returns a `Date` of a given string interpreted using the current settings.
    ///
    /// - Parameter value: A string representation of a date.
    /// - Throws: Throws `NSFormattingError` if the string cannot be parsed.
    /// - Returns: A `Date` represented by `value`.
    public func parse(_ value: String) throws -> Foundation.Date {
        guard let date = self.formatter.parse(value) else { throw parseError(value, example: self.formatter.format(.now)) }
        return date
    }
}

public extension _polyfill_ParseStrategy {
    static func fixed(
        format: Foundation.Date._polyfill_FormatString,
        timeZone: Foundation.TimeZone,
        locale: Foundation.Locale? = nil
    ) -> Self where Self == Foundation.Date._polyfill_ParseStrategy {
        .init(format: format, locale: locale, timeZone: timeZone)
    }
}

extension Foundation.Date._polyfill_ParseStrategy: CustomConsumingRegexComponent {
    public typealias RegexOutput = Foundation.Date
    
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Foundation.Date)? {
        guard index < bounds.upperBound else { return nil }
        return self.formatter.parse(input, in: index..<bounds.upperBound)
    }
}

extension RegexComponent where Self == Foundation.Date._polyfill_ParseStrategy {
    public typealias DateStyle = Foundation.Date._polyfill_FormatStyle.DateStyle
    public typealias TimeStyle = Foundation.Date._polyfill_FormatStyle.TimeStyle

    /// Creates a regex component to match a localized date string following the specified format
    /// and capture the string as a `Date`.
    ///
    /// - Parameters:
    ///   - format: The date format that describes the localized date string. For example,
    ///     `"\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)"` matches `"05_04_22"`
    ///     as May 4th, 2022 in the Gregorian calendar.
    ///   - locale: The locale of the date string to be matched.
    ///   - timeZone: The time zone to create the matched date with.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar
    ///     of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func date(
        format: Foundation.Date._polyfill_FormatString,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil,
        twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
    ) -> Self {
        .init(
            format: format.rawFormat,
            locale: locale,
            timeZone: timeZone,
            calendar: calendar ?? locale.calendar,
            isLenient: false,
            twoDigitStartDate: twoDigitStartDate
        )
    }

    /// Creates a regex component to match a localized date and time string and capture the string as
    /// a `Date`. The date string is expected to follow the format of what
    /// `Date.FormatStyle(date:time:locale:calendar:)` produces.
    ///
    /// - Parameters:
    ///   - date: The style that describes the date part of the string. For example, `.numeric` matches
    ///     `"10/21/2015"`, and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US`
    ///     locale.
    ///   - time: The style that describes the time part of the string.
    ///   - locale: The locale of the string to be matched.
    ///   - timeZone: The time zone to create the matched date with. Ignored if the string contains a time
    ///     zone and matches the specified style.
    ///   - calendar: The calendar with which to interpret the date string. If set to nil, the default
    ///     calendar of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    ///
    /// > Note: If the string contains a time zone and matches the specified style, then the `timeZone`
    /// > argument is ignored. For example, "Oct 21, 2015 4:29:24 PM PDT" matches
    /// > `.dateTime(date: .abbreviated, time: .complete, ...)` and is captured as
    /// > `October 13, 2022, 20:29:24 PDT` regardless of the `timeZone` value.
    public static func dateTime(
        date: Foundation.Date._polyfill_FormatStyle.DateStyle,
        time: Foundation.Date._polyfill_FormatStyle.TimeStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Foundation.Date._polyfill_ParseStrategy {
        .init(formatStyle: .init(date: date, time: time, locale: locale, calendar: calendar ?? locale.calendar, timeZone: timeZone), lenient: false)
    }

    /// Creates a regex component to match a localized date string and capture the string as a `Date`.
    /// The string is expected to follow the format of what `Date.FormatStyle(date:locale:calendar:)`
    /// produces. `Date` created by this regex component would be at `00:00:00` in the specified time zone.
    ///
    /// - Parameters:
    ///   - style: The style that describes the date string. For example, `.numeric` matches `"10/21/2015"`,
    ///     and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US` locale.
    ///     `.omitted` is invalid.
    ///   - locale: The locale of the string to be matched. Generally speaking, the language of the locale
    ///     is used to parse the date parts if the string contains localized numbers or words, and the region
    ///     of the locale specifies the order of the date parts. For example, `"3/5/2015"` represents
    ///     March 5th, 2015 in `en_US`, but represents May 3rd, 2015 in `en_GB`.
    ///   - timeZone: The time zone to create the matched date with. For example, parsing `"Oct 21, 2015"`
    ///     with the `PDT` time zone returns a date representing October 21, 2015 at 00:00:00 PDT.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar of
    ///     the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func date(
        _ style: Foundation.Date._polyfill_FormatStyle.DateStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Foundation.Date._polyfill_ParseStrategy {
        .init(formatStyle: .init(date: style, locale: locale, calendar: calendar ?? locale.calendar, timeZone: timeZone), lenient: false)
    }
}

func parseError(_ value: String, example: String?) -> Foundation.CocoaError {
    .init(.formatting, userInfo: [
        NSDebugDescriptionErrorKey: "Cannot parse \(value).\(example.map { " String should adhere to the preferred format of the locale, such as \($0)." } ?? "")"
    ])
}
