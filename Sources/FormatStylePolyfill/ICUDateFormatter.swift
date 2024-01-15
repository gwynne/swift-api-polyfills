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
    fileprivate var icuIdentifier: String {
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
                "rg": self.region.flatMap { $0 != self.languageComponents.region ? Foundation.Locale.Subdivision.subdivision(for: $0).identifier.lowercased() : nil },
                "sd": self.subdivision?.identifier.lowercased(),
                "timezone": self.timeZone?.identifier,
                "va": self.variant?.identifier.lowercased(),
            ].compactMapValues { $0 }.reduce(0) { (f: Int32?, kv: (key: String, value: String)) in f.flatMap { _ in
                try? ICU4Swift.withCheckedStatus { uloc_setKeywordValue(kv.key, kv.value, buffer.baseAddress, ULOC_FULLNAME_CAPACITY, &$0) }
            } }
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
        self.udateFormat = try! ICU4Swift.withCheckedStatus { udat_open(
            UDAT_PATTERN, UDAT_PATTERN,
            calendarIdentifier.applied(to: localeIdentifier),
            Array(timeZoneIdentifier.utf16), Int32(timeZoneIdentifier.utf16.count),
            Array(pattern.utf16), Int32(pattern.utf16.count), &$0
        ) }!

        try! ICU4Swift.withCheckedStatus { udat_setContext(self.udateFormat, capitalizationContext.icuContext, &$0) }

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
        let ucal = try! ICU4Swift.withCheckedStatus { ucal_clone(udat_getCalendar(self.udateFormat), &$0) }
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
        (try? self._parse(string, fromIndex: string.startIndex))?.date
    }

    func _parse(_ string: some StringProtocol, fromIndex: String.Index) throws -> (date: Date, upperBound: Int)? {
        let ucal = udat_getCalendar(self.udateFormat)
        let newCal = try ICU4Swift.withCheckedStatus { ucal_clone(ucal, &$0) }
        defer { ucal_close(newCal) }
        let ucharText = Array(string.utf16), utf16Index = fromIndex.utf16Offset(in: string)
        var pos = Int32(utf16Index)

        try ICU4Swift.withCheckedStatus { udat_parseCalendar(self.udateFormat, newCal, ucharText, Int32(ucharText.count), &pos, &$0) }
        return pos != utf16Index ? (Date(timeIntervalSince1970: (try ICU4Swift.withCheckedStatus { ucal_getMillis(newCal, &$0) }) / 1000), Int(pos)) : nil
    }

    func parse(_ string: some StringProtocol, in range: Range<String.Index>) -> (String.Index, Date)? {
        let substr = string[range]
        guard !substr.isEmpty else { return nil }
        if !self.lenientParsing, let start = substr.first, start.isWhitespace { return nil }
        let substrStr = String(substr)
        guard let (date, upperBoundInSubstr) = try? self._parse(substrStr, fromIndex: substrStr.startIndex) else { return nil }
        return (String.Index(utf16Offset: upperBoundInSubstr, in: substr), date)
    }

    func search(_ string: String, in range: Range<String.Index>) -> (Range<String.Index>, Date)? {
        var idx = range.lowerBound
        let end = range.upperBound
        while idx < end {
            if let (newUpper, match) = self.parse(string, in: idx ..< end) { return (idx ..< newUpper, match) }
            string.formIndex(after: &idx)
        }
        return nil
    }

    struct AttributePosition {
        let field: UDateFormatField
        let begin: Int, end: Int
    }

    func attributedFormat(_ date: Date) -> (String, [AttributePosition])? {
        guard let positer = try? ICUFieldPositer(), let result = ICU4Swift.withResizingUCharBuffer({
            udat_formatForFields(self.udateFormat, date.timeIntervalSince1970 * 1000, $0, Int32($1), positer.positer, &$2)
        }) else {
            return nil
        }
        return (result, positer.fields.map { .init(field: .init(numericCast($0.field)), begin: $0.begin, end: $0.end) })
    }

    func symbols(for key: UDateFormatSymbolType) -> [String] {
        (0 ..< udat_countSymbols(self.udateFormat, key)).compactMap { i in
            ICU4Swift.withResizingUCharBuffer { udat_getSymbols(self.udateFormat, key, i, $0, $1, &$2) }
        }
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

        func createICUDateFormatter() -> ICUDateFormatter {
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

    static func cachedFormatter(for dateFormatInfo: DateFormatInfo) -> ICUDateFormatter {
        dateFormatInfo.createICUDateFormatter()
    }

    static func cachedFormatter(for format: _polyfill_DateFormatStyle) -> ICUDateFormatter {
        self.cachedFormatter(for: .init(
            localeIdentifier: format.locale.identifier,
            timeZoneIdentifier: format.timeZone.identifier,
            calendarIdentifier: format.calendar.identifier,
            firstWeekday: format.calendar.firstWeekday,
            minimumDaysInFirstWeek: format.calendar.minimumDaysInFirstWeek,
            capitalizationContext: format.capitalizationContext,
            pattern: ICUPatternGenerator.localizedPattern(symbols: format.symbols, locale: format.locale, calendar: format.calendar),
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

    static func cachedFormatter(for calendar: Foundation.Calendar) -> ICUDateFormatter {
        self.cachedFormatter(for: .init(
            localeIdentifier: calendar.locale?.identifier,
            timeZoneIdentifier: calendar.timeZone.identifier,
            calendarIdentifier: calendar.identifier,
            firstWeekday: calendar.firstWeekday,
            minimumDaysInFirstWeek: calendar.minimumDaysInFirstWeek,
            capitalizationContext: .unknown,
            pattern: ""
        ))
    }
}

extension UDateFormatHourCycle: Hashable {}

final class ICUPatternGenerator {
    private let upatternGenerator: UnsafeMutablePointer<UDateTimePatternGenerator?>

    private init(localeIdentifier: String, calendarIdentifier: Foundation.Calendar.Identifier) {
        self.upatternGenerator = try! ICU4Swift.withCheckedStatus { udatpg_open(calendarIdentifier.applied(to: localeIdentifier), &$0) }
    }

    deinit {
        udatpg_close(self.upatternGenerator)
    }

    private func patternForSkeleton(_ skeleton: String) -> String {
        let clonedPatternGenerator = try! ICU4Swift.withCheckedStatus { udatpg_clone(self.upatternGenerator, &$0) }
        defer { udatpg_close(clonedPatternGenerator) }

        let skeletonUChar = Array(skeleton.utf16)
        return ICU4Swift.withResizingUCharBuffer {
            udatpg_getBestPatternWithOptions(clonedPatternGenerator, skeletonUChar, Int32(skeletonUChar.count), UDATPG_MATCH_ALL_FIELDS_LENGTH, $0, $1, &$2)
        } ?? skeleton
    }

    var defaultHourCycle: Foundation.Locale.HourCycle {
        ([
            UDAT_HOUR_CYCLE_11: .zeroToEleven,
            UDAT_HOUR_CYCLE_12: .oneToTwelve,
            UDAT_HOUR_CYCLE_23: .zeroToTwentyThree,
            UDAT_HOUR_CYCLE_24: .oneToTwentyFour,
        ] as [UDateFormatHourCycle?: Foundation.Locale.HourCycle])[
            try? ICU4Swift.withCheckedStatus { udatpg_getDefaultHourCycle(self.upatternGenerator, &$0) }
        ] ?? .zeroToTwentyThree
    }

    struct PatternGeneratorInfo: Hashable {
        let localeIdentifier: String
        let calendarIdentifier: Foundation.Calendar.Identifier
    }

    static func localizedPattern(
        symbols: _polyfill_DateFormatStyle.DateFieldCollection,
        locale: Foundation.Locale,
        calendar: Foundation.Calendar
    ) -> String {
        self.cachedPatternGenerator(localeIdentifier: locale.identifier, calendarIdentifier: calendar.identifier)
            .patternForSkeleton(symbols.formatterTemplate(overridingDayPeriodWithLocale: locale))
    }

    static func cachedPatternGenerator(localeIdentifier: String, calendarIdentifier: Foundation.Calendar.Identifier) -> ICUPatternGenerator {
        .init(localeIdentifier: localeIdentifier, calendarIdentifier: calendarIdentifier)
    }
}

final class ICUDateIntervalFormatter {
    struct Signature: Hashable {
        let localeComponents: Foundation.Locale.Components
        let calendarIdentifier: Foundation.Calendar.Identifier
        let timeZoneIdentifier: String
        let dateTemplate: String
    }
    
    let uformatter: OpaquePointer

    private init(signature: Signature) {
        var comps = signature.localeComponents
        comps.calendar = signature.calendarIdentifier

        self.uformatter = try! Array(signature.timeZoneIdentifier.utf16).withUnsafeBufferPointer { tz in
            try Array(signature.dateTemplate.utf16).withUnsafeBufferPointer { template in
                try ICU4Swift.withCheckedStatus {
                    udtitvfmt_open(comps.icuIdentifier, template.baseAddress, Int32(template.count), tz.baseAddress, Int32(tz.count), &$0)
                }
            }
        }
        try! ICU4Swift.withCheckedStatus {
            udtitvfmt_setAttribute(self.uformatter, UDTITVFMT_MINIMIZE_TYPE, UDTITVFMT_MINIMIZE_NONE, &$0)
        }
    }

    deinit {
        udtitvfmt_close(self.uformatter)
    }

    func string(from: Range<Foundation.Date>) -> String {
        ICU4Swift.withResizingUCharBuffer {
            udtitvfmt_format(uformatter, from.lowerBound.timeIntervalSince1970 * 100, from.upperBound.timeIntervalSince1970 * 1000, $0, $1, nil, &$2)
        } ?? ""
    }

    static func formatter(for style: _polyfill_DateIntervalFormatStyle) -> ICUDateIntervalFormatter {
        var template = style.symbols.formatterTemplate(overridingDayPeriodWithLocale: style.locale)

        if template.isEmpty {
            template = _polyfill_DateFormatStyle.DateFieldCollection()
                .collection(date: .numeric)
                .collection(time: .shortened)
                .formatterTemplate(overridingDayPeriodWithLocale: style.locale)
        }

        return .init(signature: .init(
            localeComponents: .init(locale: style.locale),
            calendarIdentifier: style.calendar.identifier,
            timeZoneIdentifier: style.timeZone.identifier,
            dateTemplate: template
        ))
    }
}

final class ICURelativeDateFormatter {
    struct Signature: Hashable {
        let localeIdentifier: String
        let numberFormatStyle: UNumberFormatStyle.RawValue?
        let relativeDateStyle: UDateRelativeDateTimeFormatterStyle.RawValue
        let context: UDisplayContext.RawValue
    }
    
    static let sortedAllowedComponents: [Foundation.Calendar.Component] = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
    static let componentsToURelativeDateUnit: [Foundation.Calendar.Component: URelativeDateTimeUnit] = [
               .year: UDAT_REL_UNIT_YEAR,
              .month: UDAT_REL_UNIT_MONTH,
        .weekOfMonth: UDAT_REL_UNIT_WEEK,
                .day: UDAT_REL_UNIT_DAY,
               .hour: UDAT_REL_UNIT_HOUR,
             .minute: UDAT_REL_UNIT_MINUTE,
             .second: UDAT_REL_UNIT_SECOND,
    ]

    let uformatter: OpaquePointer

    private init?(signature: Signature) {
        guard let result = try? ICU4Swift.withCheckedStatus(do: { ureldatefmt_open(
            signature.localeIdentifier,
            signature.numberFormatStyle.flatMap { s in try? ICU4Swift.withCheckedStatus { unum_open(.init(rawValue: s), nil, 0, signature.localeIdentifier, nil, &$0) } },
            .init(rawValue: signature.relativeDateStyle),
            .init(rawValue: signature.context),
            &$0
        ) }) else { return nil }
        self.uformatter = result
    }

    deinit {
        ureldatefmt_close(self.uformatter)
    }

    func format(value: Int, component: Foundation.Calendar.Component, presentation: _polyfill_DateRelativeFormatStyle.Presentation) -> String? {
        Self.componentsToURelativeDateUnit[component].flatMap { urelUnit in
            ICU4Swift.withResizingUCharBuffer {
                switch presentation.option {
                case .named: ureldatefmt_format(self.uformatter, Double(value), urelUnit, $0, $1, &$2)
                case .numeric: ureldatefmt_formatNumeric(self.uformatter, Double(value), urelUnit, $0, $1, &$2)
                }
            }
        }
    }

    internal static func formatter(for style: _polyfill_DateRelativeFormatStyle) -> ICURelativeDateFormatter {
        .init(signature: .init(
            localeIdentifier: style.locale.identifier,
            numberFormatStyle: style.unitsStyle.icuNumberFormatStyle?.rawValue,
            relativeDateStyle: style.unitsStyle.icuRelativeDateStyle.rawValue,
            context: style.capitalizationContext.icuContext.rawValue
        ))!
    }
}
