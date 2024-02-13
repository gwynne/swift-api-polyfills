import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale
import CLegacyLibICU
import PolyfillCommon

extension Foundation.Calendar.Identifier {
    fileprivate var cldrIdentifier: String {
        switch self {
        case .gregorian: "gregorian"
        case .buddhist: "buddhist"
        case .chinese: "chinese"
        case .coptic: "coptic"
        case .ethiopicAmeteMihret: "ethiopic"
        case .ethiopicAmeteAlem: "ethioaa"
        case .hebrew: "hebrew"
        case .iso8601: "iso8601"
        case .indian: "indian"
        case .islamic: "islamic"
        case .islamicCivil: "islamic-civil"
        case .japanese: "japanese"
        case .persian: "persian"
        case .republicOfChina: "roc"
        case .islamicTabular: "islamic-tbla"
        case .islamicUmmAlQura: "islamic-umalqura"
        #if canImport(Darwin)
        @unknown default: fatalError()
        #endif
        }
    }
}

extension Foundation.Locale.Language.Components {
    fileprivate var identifier: String {
        """
        \(self.languageCode.map { $0.identifier.lowercased() } ?? "")\
        \(self.script.map { "-\($0.identifier.lowercased())" } ?? "")\
        \(self.region.map { "_\($0.identifier.lowercased())" } ?? "")
        """
    }
}

extension Foundation.Locale.Components {
    var icuIdentifier: String {
        withUnsafeTemporaryAllocation(of: CChar.self, capacity: Int(ULOC_FULLNAME_CAPACITY) + 1) { buffer in
            buffer.initialize(repeating: 0)
            _ = buffer.update(fromContentsOf: self.languageComponents.identifier.utf8.map(CChar.init(_:)))
            _ = [
                 "calendar": self.calendar?.cldrIdentifier,
                "collation": self.collation?.identifier.lowercased(),
                 "currency": self.currency?.identifier.lowercased(),
                  "numbers": self.numberingSystem?.identifier.lowercased(),
                       "fw": self.firstDayOfWeek?.rawValue,
                    "hours": self.hourCycle?.rawValue,
                  "measure": self.measurementSystem?.identifier.lowercased(),
                       "rg": self.region.flatMap {
                                 $0 != self.languageComponents.region ?
                                     Foundation.Locale.Subdivision.subdivision(for: $0).identifier.lowercased() :
                                     nil
                             },
                       "sd": self.subdivision?.identifier.lowercased(),
                 "timezone": self.timeZone?.identifier,
                       "va": self.variant?.identifier.lowercased(),
            ].compactMapValues { $0 }.reduce(0) { (f: Int32?, kv: (key: String, value: String)) in
                f.flatMap { _ in
                    try? ICU4Swift.withCheckedStatus {
                        uloc_setKeywordValue(kv.key, kv.value, buffer.baseAddress, ULOC_FULLNAME_CAPACITY, &$0)
                    }
                }
            }
            
            return String(cString: buffer.baseAddress!) // always correct regardless of ICU result
        }
    }
}

extension Foundation.Calendar.Identifier {
    fileprivate func applied(to localeIdentifier: String) -> String {
        var comps = Foundation.Locale.Components(identifier: localeIdentifier)
        comps.calendar = self
        return comps.icuIdentifier
    }
}

final class ICUDateFormatter {
    var udateFormat: UnsafeMutablePointer<UDateFormat?>
    var lenientParsing: Bool

    private init(
        localeIdentifier: String,
        timeZoneIdentifier: String,
        calendarIdentifier: Foundation.Calendar.Identifier,
        firstWeekday: Int,
        minimumDaysInFirstWeek: Int,
        capitalizationContext: _polyfill_FormatStyleCapitalizationContext,
        pattern: String,
        twoDigitStartDate: Date,
        lenientParsing: Bool
    ) {
        self.lenientParsing = lenientParsing

        let timeZoneUtf16 = Array(timeZoneIdentifier.utf16)
        let patternUtf16 = Array(pattern.utf16)
        let appliedLocaleIdentifier = calendarIdentifier.applied(to: localeIdentifier)

        self.udateFormat = try! ICU4Swift.withCheckedStatus { udat_open(
            UDAT_PATTERN, UDAT_PATTERN,
            appliedLocaleIdentifier,
            timeZoneUtf16, Int32(timeZoneUtf16.count),
            patternUtf16, Int32(patternUtf16.count), &$0
        ) }!

        try! ICU4Swift.withCheckedStatus {
            udat_setContext(self.udateFormat, capitalizationContext.icuContext, &$0)
        }

        if lenientParsing {
            udat_setLenient(self.udateFormat, 1)
        } else {
            try! ICU4Swift.withCheckedStatus {
                udat_setLenient(self.udateFormat, 0)
                udat_setBooleanAttribute(self.udateFormat, UDAT_PARSE_ALLOW_WHITESPACE, 0, &$0)
                udat_setBooleanAttribute(self.udateFormat, UDAT_PARSE_ALLOW_NUMERIC, 0, &$0)
                udat_setBooleanAttribute(self.udateFormat, UDAT_PARSE_PARTIAL_LITERAL_MATCH, 0, &$0)
                udat_setBooleanAttribute(self.udateFormat, UDAT_PARSE_MULTIPLE_PATTERNS_FOR_MATCH, 0, &$0)
            }
        }
        
        let ucal = try! ICU4Swift.withCheckedStatus {
            ucal_clone(udat_getCalendar(self.udateFormat), &$0)
        }
        defer { ucal_close(ucal) }
        
        try! ICU4Swift.withCheckedStatus {
            ucal_clear(ucal)
            ucal_setAttribute(ucal, UCAL_FIRST_DAY_OF_WEEK, Int32(firstWeekday))
            ucal_setAttribute(ucal, UCAL_MINIMAL_DAYS_IN_FIRST_WEEK, Int32(minimumDaysInFirstWeek))
            ucal_setMillis(ucal, twoDigitStartDate.timeIntervalSince1970 * 1000, &$0)
            ucal_setDateTime(ucal, ucal_get(ucal, UCAL_YEAR, &$0), 0, 1, 0, 0, 0, &$0)
            udat_set2DigitYearStart(self.udateFormat, ucal_getMillis(ucal, &$0), &$0)
        }
        udat_setCalendar(self.udateFormat, ucal)
    }

    deinit {
        udat_close(udateFormat)
    }

    func format(_ date: Date) -> String? {
        ICU4Swift.withResizingUCharBuffer { udat_formatForFields(self.udateFormat, date.timeIntervalSince1970 * 1000, $0, Int32($1), nil, &$2) }
    }

    func parse(_ string: String) -> Date? {
        (try? self.parseImpl(string, fromIndex: string.startIndex))?.date
    }

    func parse(_ string: some StringProtocol, in range: Range<String.Index>) -> (String.Index, Date)? {
        let substr = string[range]
        
        guard !substr.isEmpty else {
            return nil
        }
        if !self.lenientParsing, let start = substr.first, start.isWhitespace {
            return nil
        }
        
        let substrStr = String(substr)
        
        guard let (date, upperBoundInSubstr) = try? self.parseImpl(substrStr, fromIndex: substrStr.startIndex) else {
            return nil
        }
        return (String.Index(utf16Offset: upperBoundInSubstr, in: substr), date)
    }

    private func parseImpl(_ string: some StringProtocol, fromIndex: String.Index) throws -> (date: Date, upperBound: Int)? {
        let ucal = udat_getCalendar(self.udateFormat)
        let newCal = try ICU4Swift.withCheckedStatus { ucal_clone(ucal, &$0) }
        defer { ucal_close(newCal) }
        
        let ucharText = Array(string.utf16), utf16Index = fromIndex.utf16Offset(in: string)
        var pos = Int32(utf16Index)

        try ICU4Swift.withCheckedStatus { udat_parseCalendar(self.udateFormat, newCal, ucharText, Int32(ucharText.count), &pos, &$0) }
        guard pos != utf16Index else {
            return nil
        }
        
        return (
            Foundation.Date(timeIntervalSince1970: (try ICU4Swift.withCheckedStatus { ucal_getMillis(newCal, &$0) }) / 1000),
            Int(pos)
        )
    }

    struct AttributePosition {
        let field: UDateFormatField
        let begin: Int
        let end: Int
    }

    func attributedFormat(_ date: Date) -> (String, [AttributePosition])? {
        guard let positer = try? ICU4Swift.FieldPositer(), let result = ICU4Swift.withResizingUCharBuffer({
            udat_formatForFields(self.udateFormat, date.timeIntervalSince1970 * 1000, $0, Int32($1), positer.positer, &$2)
        }) else {
            return nil
        }
        return (result, positer.fields.map { .init(field: .init(numericCast($0.field)), begin: $0.begin, end: $0.end) })
    }

    struct DateFormatInfo: Hashable {
        let localeIdentifier: String
        let timeZoneIdentifier: String
        let calendarIdentifier: Foundation.Calendar.Identifier
        let firstWeekday: Int
        let minimumDaysInFirstWeek: Int
        let capitalizationContext: _polyfill_FormatStyleCapitalizationContext
        let pattern: String
        let parseLenient: Bool
        let parseTwoDigitStartDate: Date

        fileprivate func createICUDateFormatter() -> ICUDateFormatter {
            ICUDateFormatter(
                localeIdentifier: self.localeIdentifier,
                timeZoneIdentifier: self.timeZoneIdentifier,
                calendarIdentifier: self.calendarIdentifier,
                firstWeekday: self.firstWeekday,
                minimumDaysInFirstWeek: self.minimumDaysInFirstWeek,
                capitalizationContext: self.capitalizationContext,
                pattern: self.pattern,
                twoDigitStartDate: self.parseTwoDigitStartDate,
                lenientParsing: self.parseLenient
            )
        }

        init(
            localeIdentifier: String?,
            timeZoneIdentifier: String,
            calendarIdentifier: Foundation.Calendar.Identifier,
            firstWeekday: Int,
            minimumDaysInFirstWeek: Int,
            capitalizationContext: _polyfill_FormatStyleCapitalizationContext,
            pattern: String,
            parseLenient: Bool = true,
            parseTwoDigitStartDate: Date = .init(timeIntervalSince1970: 0)
        ) {
            self.localeIdentifier = localeIdentifier ?? ""
            self.timeZoneIdentifier = timeZoneIdentifier
            self.calendarIdentifier = calendarIdentifier
            self.firstWeekday = firstWeekday
            self.minimumDaysInFirstWeek = minimumDaysInFirstWeek
            self.capitalizationContext = capitalizationContext
            self.pattern = pattern
            self.parseLenient = parseLenient
            self.parseTwoDigitStartDate = parseTwoDigitStartDate
        }
    }

    private static let formatterCache = FormatterCache<DateFormatInfo, ICUDateFormatter>()
    private static let patternCache = FormatterCache<PatternCacheKey, String>()

    struct PatternCacheKey: Hashable, Sendable {
        var localeIdentifier: String
        var calendarIdentifier: Foundation.Calendar.Identifier
        var symbols: _polyfill_DateFormatStyle.DateFieldCollection
    }

    static func cachedFormatter(for dateFormatInfo: DateFormatInfo) -> ICUDateFormatter {
        Self.formatterCache.formatter(for: dateFormatInfo, creator: dateFormatInfo.createICUDateFormatter)
    }

    static func cachedFormatter(for format: _polyfill_DateFormatStyle) -> ICUDateFormatter {
        let calendarIdentifier = format.calendar.identifier

        let key = PatternCacheKey(
            localeIdentifier: format.locale.identifier,
            calendarIdentifier: format.calendar.identifier,
            symbols: format.symbols
        )
        let pattern = self.patternCache.formatter(for: key) {
            ICUPatternGenerator.localizedPattern(symbols: format.symbols, locale: format.locale, calendar: format.calendar)
        }
        return self.cachedFormatter(for: .init(
            localeIdentifier: format.locale.identifier,
            timeZoneIdentifier: format.timeZone.identifier,
            calendarIdentifier: calendarIdentifier,
            firstWeekday: format.calendar.firstWeekday,
            minimumDaysInFirstWeek: format.calendar.minimumDaysInFirstWeek,
            capitalizationContext: format.capitalizationContext,
            pattern: pattern,
            parseLenient: format.parseLenient
        ))
    }

    static func cachedFormatter(for format: _polyfill_DateVerbatimFormatStyle) -> ICUDateFormatter {
        self.cachedFormatter(for: .init(
            localeIdentifier: format.locale?.identifier,
            timeZoneIdentifier: format.timeZone.identifier,
            calendarIdentifier: format.calendar.identifier,
            firstWeekday: format.calendar.firstWeekday,
            minimumDaysInFirstWeek: format.calendar.minimumDaysInFirstWeek,
            capitalizationContext: .unknown,
            pattern: format.formatPattern
        ))
    }
}

final class ICUPatternGenerator {
    static func localizedPattern(
        symbols: _polyfill_DateFormatStyle.DateFieldCollection,
        locale: Foundation.Locale,
        calendar: Foundation.Calendar
    ) -> String {
        self.cachedPatternGenerator(localeIdentifier: locale.identifier, calendarIdentifier: calendar.identifier)
            .patternForSkeleton(symbols.formatterTemplate(overridingDayPeriodWithLocale: locale))
    }

    private let upatternGenerator: UnsafeMutablePointer<UDateTimePatternGenerator?>

    private init(localeIdentifier: String, calendarIdentifier: Foundation.Calendar.Identifier) {
        self.upatternGenerator = try! ICU4Swift.withCheckedStatus {
            udatpg_open(calendarIdentifier.applied(to: localeIdentifier), &$0)
        }
    }

    deinit {
        udatpg_close(self.upatternGenerator)
    }

    private func patternForSkeleton(_ skeleton: String) -> String {
        let clonedPatternGenerator = try! ICU4Swift.withCheckedStatus {
            udatpg_clone(self.upatternGenerator, &$0)
        }
        defer { udatpg_close(clonedPatternGenerator) }

        let skeletonUChar = Array(skeleton.utf16)
        
        return ICU4Swift.withResizingUCharBuffer {
            udatpg_getBestPatternWithOptions(
                clonedPatternGenerator,
                skeletonUChar,
                Int32(skeletonUChar.count),
                UDATPG_MATCH_ALL_FIELDS_LENGTH,
                $0, $1, &$2
            )
        } ?? skeleton
    }

    private struct PatternGeneratorInfo: Hashable {
        let localeIdentifier: String
        let calendarIdentifier: Foundation.Calendar.Identifier
    }

    private static let cache = FormatterCache<PatternGeneratorInfo, ICUPatternGenerator>()

    private static func cachedPatternGenerator(
        localeIdentifier: String,
        calendarIdentifier: Foundation.Calendar.Identifier
    ) -> ICUPatternGenerator {
        self.cache.formatter(for: .init(localeIdentifier: localeIdentifier, calendarIdentifier: calendarIdentifier)) {
            .init(localeIdentifier: localeIdentifier, calendarIdentifier: calendarIdentifier)
        }
    }
}
