import FormatStylePolyfill
import class XCTest.XCTestCase
import func XCTest.XCTAssert
import func XCTest.XCTAssertEqual
import func XCTest.XCTAssertGreaterThan
import func XCTest.XCTAssertNil
import func XCTest.XCTAssertNoThrow
import func XCTest.XCTAssertNotNil
import func XCTest.XCTAssertThrowsError
import func XCTest.XCTFail
import func XCTest.XCTSkipUnless
import func XCTest.XCTUnwrap
import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Calendar
import struct Foundation.Date
import class Foundation.DateFormatter
import struct Foundation.Decimal
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import struct Foundation.Locale
import typealias Foundation.TimeInterval
import struct Foundation.TimeZone
import RegexBuilder

extension Foundation.Calendar { fileprivate static var gregorian: Self { .init(identifier: .gregorian) } }
extension Foundation.Locale   {
    fileprivate static var enUS: Self { .init(identifier: "en_US") }
    fileprivate static var enGB: Self { .init(identifier: "en_GB") }
    fileprivate static var zhTW: Self { .init(identifier: "zh_TW") }
}
extension Foundation.TimeZone {
    fileprivate static var losAngeles: Self { .init(identifier: "America/Los_Angeles")! }
    fileprivate static var pst: Self { .init(secondsFromGMT: -3600*8)! }
}
extension Foundation.AttributedString { fileprivate static func + (lhs: Self, rhs: Self) -> Self { var res = lhs; res.append(rhs); return res } }
extension Foundation.Date { fileprivate static func + (lhs: Self, rhs: Foundation.TimeInterval) -> Self { .init(timeInterval: rhs, since: lhs) } }
extension Foundation.DateFormatter {
    fileprivate convenience init(locale: Foundation.Locale, timeZone: Foundation.TimeZone, dateFormat: String? = nil) {
        self.init()
        self.locale = locale
        self.timeZone = timeZone
        if let dateFormat { self.dateFormat = dateFormat }
    }
}

typealias Segment = (String, Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field?)

extension Sequence<Segment> {
    fileprivate var attributedString: Foundation.AttributedString {
        self.map { .init($0, attributes: $1.map { .init().dateField($0) } ?? .init()) }.reduce(.init(), +)
    }
}

private func XCTAssertEqualIgnoreSeparator(
    _ lhs: @autoclosure () throws -> String, _ rhs: @autoclosure () throws -> String,
    _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line
) {
    XCTAssertEqual(
        try lhs().replacingOccurrences(of: "\u{202f}", with: " "), try rhs().replacingOccurrences(of: "\u{202f}", with: " "),
        message(), file: file, line: line
    )
}

private func XCTAssertEqualIgnoreSeparator(
    _ lhs: @autoclosure () throws -> Foundation.AttributedString, _ rhs: @autoclosure () throws -> Foundation.AttributedString,
    _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line
) {
    func sanitize(_ string: Foundation.AttributedString) -> Foundation.AttributedString {
        var str = string
        while let idx = str.characters.firstIndex(of: "\u{202f}") {
            str.characters.replaceSubrange(idx ..< str.characters.index(after: idx), with: " ")
        }
        return str
    }
    XCTAssertEqual(try sanitize(lhs()), try sanitize(rhs()), message(), file: file, line: line)
}

final class DateFormatStyleTests: XCTestCase {
    let refDate = Foundation.Date(timeIntervalSinceReferenceDate: 0)
    let oldRefDate = Foundation.Date(timeIntervalSince1970: 0)
    let testDate = Foundation.Date(timeIntervalSinceReferenceDate: 639932672.0) // 2021-04-12 15:04:32

    func test_constructorSyntax() {
        let style = _polyfill_DateFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .losAngeles)
            .year(.defaultDigits).month(.abbreviated).day(.twoDigits).hour(.twoDigits(amPM: .omitted)).minute(.defaultDigits)
        
        XCTAssertEqual(self.refDate._polyfill_formatted(style), "Dec 31, 2000 at 04:00")
    }

    func test_era() {
        let style = _polyfill_DateFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .losAngeles)

        XCTAssertEqual(self.refDate._polyfill_formatted(style.era(.abbreviated)), "AD")
        XCTAssertEqual(self.refDate._polyfill_formatted(style.era(.narrow)), "A")
        XCTAssertEqual(self.refDate._polyfill_formatted(style.era(.wide)), "Anno Domini")
    }

    func test_dateFormatString() {
        func verify(_ format: _polyfill_DateFormatString, raw: String, formatted: String, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertEqual(format.rawFormat, raw, file: file, line: line)
            XCTAssertEqual(
                _polyfill_DateVerbatimFormatStyle(format: format, timeZone: .gmt, calendar: .gregorian).locale(.enUS).format(self.testDate), formatted,
                file: file, line: line
            )
        }

        verify("", raw: "", formatted: "\(self.testDate)")
        verify("some latin characters", raw: "'some latin characters'", formatted: "some latin characters")
        verify(" ", raw: "' '", formatted: " ")
        verify("😀😀", raw: "'😀😀'", formatted: "😀😀")
        verify("'", raw: "''", formatted: "'")
        verify(" ' ", raw: "' '' '", formatted: " ' ")
        verify("' ", raw: "''' '", formatted: "' ")
        verify(" '", raw: "' '''", formatted: " '")
        verify("''", raw: "''''", formatted: "''")
        verify("'some strings in single quotes'", raw: "'''some strings in single quotes'''", formatted: "'some strings in single quotes'")
        verify("\(day: .twoDigits)\(month: .twoDigits)", raw: "ddMM", formatted: "1204")
        verify("\(day: .twoDigits)/\(month: .twoDigits)", raw: "dd'/'MM", formatted: "12/04")
        verify("\(day: .twoDigits)-\(month: .twoDigits)", raw: "dd'-'MM", formatted: "12-04")
        verify("\(day: .twoDigits)'\(month: .twoDigits)", raw: "dd''MM", formatted: "12'04")
        verify(" \(day: .twoDigits) \(month: .twoDigits) ", raw: "' 'dd' 'MM' '", formatted: " 12 04 ")
        verify("\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased)) o'clock", raw: "h' o''clock'", formatted: "3 o'clock")
        verify("Day:\(day: .defaultDigits) Month:\(month: .abbreviated) Year:\(year: .padded(4))", raw: "'Day:'d' Month:'MMM' Year:'yyyy", formatted: "Day:12 Month:Apr Year:2021")
    }

    func test_parsingThrows() {
        let invalidFormats: [(_polyfill_DateFormatString, String)] = [("ddMMyy", "010599"), ("dd/MM/yy", "01/05/99"), ("d/MMM/yyyy", "1/Sep/1999")]

        for (format, dateString) in invalidFormats {
            XCTAssertThrowsError(try _polyfill_DateParseStrategy(format: format, locale: .enUS, timeZone: .gmt, isLenient: false).parse(dateString))
        }
    }

    func test_codable() throws {
        let style = _polyfill_DateFormatStyle(date: .long, time: .complete, capitalizationContext: .unknown)
            .era().year().quarter().month().week().day().dayOfYear().weekday().hour().minute().second().secondFraction(.milliseconds(2)).timeZone()
        let encodedStyle = try Foundation.JSONEncoder().encode(style)
        XCTAssertNotNil(encodedStyle)
        let decodedStyle = try Foundation.JSONDecoder().decode(_polyfill_DateFormatStyle.self, from: encodedStyle)
        XCTAssertNotNil(decodedStyle)
        XCTAssertEqual(self.refDate._polyfill_formatted(decodedStyle), self.refDate._polyfill_formatted(style))
    }

    func test_roundtrip() {
        let style = _polyfill_DateFormatStyle(date: .numeric, time: .shortened)
        let format = Foundation.Date.now._polyfill_formatted(style)

        XCTAssertEqual(try Foundation.Date(format, _polyfill_strategy: style.parseStrategy)._polyfill_formatted(style), format)
    }

    func testLeadingDotSyntax() {
        let date = Foundation.Date.now
        
        XCTAssertEqual(date._polyfill_formatted(date: .long, time: .complete),   date._polyfill_formatted(_polyfill_DateFormatStyle(date: .long, time: .complete)))
        XCTAssertEqual(date._polyfill_formatted(.dateTime.day().month().year()), date._polyfill_formatted(_polyfill_DateFormatStyle().day().month().year()))
    }

    func testDateFormatStyleIndividualFields() {
        let style = _polyfill_DateFormatStyle(date: nil, time: nil, locale: .enUS, calendar: .gregorian, timeZone: .gmt, capitalizationContext: .unknown)

        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.era(.abbreviated)), "AD")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.era(.wide)), "Anno Domini")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.era(.narrow)), "A")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.defaultDigits)), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.twoDigits)), "70")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.padded(0))), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.padded(1))), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.padded(2))), "70")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.padded(3))), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.padded(999))), "0000001970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.relatedGregorian(minimumLength: 0))), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.relatedGregorian(minimumLength: 999))), "0000001970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.extended(minimumLength: 0))), "1970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.year(.extended(minimumLength: 999))), "0000001970")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.quarter(.oneDigit)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.quarter(.twoDigits)), "01")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.quarter(.abbreviated)), "Q1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.quarter(.wide)), "1st quarter")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.quarter(.narrow)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.month(.defaultDigits)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.month(.twoDigits)), "01")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.month(.abbreviated)), "Jan")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.month(.wide)), "January")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.month(.narrow)), "J")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.week(.defaultDigits)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.week(.twoDigits)), "01")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.week(.weekOfMonth)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.day(.defaultDigits)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.day(.twoDigits)), "01")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.day(.ordinalOfDayInMonth)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.day(.julianModified(minimumLength: 0))), "2440588")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.day(.julianModified(minimumLength: 999))), "0002440588")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.dayOfYear(.defaultDigits)), "1")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.dayOfYear(.twoDigits)), "01")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.dayOfYear(.threeDigits)), "001")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.oneDigit)), "5")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.twoDigits)), "5") // This is an ICU bug
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.abbreviated)), "Thu")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.wide)), "Thursday")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.narrow)), "T")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.weekday(.short)), "Th")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.hour(.defaultDigits(amPM: .omitted))), "12")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.defaultDigits(amPM: .narrow))), "12 a")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.defaultDigits(amPM: .abbreviated))), "12 AM")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.defaultDigits(amPM: .wide))), "12 AM")
        XCTAssertEqual(self.oldRefDate._polyfill_formatted(style.hour(.twoDigits(amPM: .omitted))), "12")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.twoDigits(amPM: .narrow))), "12 a")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.twoDigits(amPM: .abbreviated))), "12 AM")
        XCTAssertEqualIgnoreSeparator(self.oldRefDate._polyfill_formatted(style.hour(.twoDigits(amPM: .wide))), "12 AM")
    }

    func testConversationalDayPeriodsOverride() throws {
        let middleOfNight = try Foundation.Date("2001-01-01T03:50:00Z", _polyfill_strategy: .iso8601)
        let earlyMorning  = try Foundation.Date("2001-01-01T06:50:00Z", _polyfill_strategy: .iso8601)
        let morning       = try Foundation.Date("2001-01-01T09:50:00Z", _polyfill_strategy: .iso8601)
        let noon          = try Foundation.Date("2001-01-01T12:50:00Z", _polyfill_strategy: .iso8601)
        let afternoon     = try Foundation.Date("2001-01-01T15:50:00Z", _polyfill_strategy: .iso8601)
        let evening       = try Foundation.Date("2001-01-01T21:50:00Z", _polyfill_strategy: .iso8601)

        var locale: Foundation.Locale
        var format: _polyfill_DateFormatStyle
        
        func verifyWithFormat(_ date: Foundation.Date, expected: String, file: StaticString = #filePath, line: UInt = #line) {
            let fmt = format.locale(locale)
            let formatted = fmt.format(date)
            XCTAssertEqualIgnoreSeparator(formatted, expected, file: file, line: line)
        }

        locale = .zhTW
        format = .init(timeZone: .gmt).hour()
        verifyWithFormat(middleOfNight, expected: "凌晨3時")
        verifyWithFormat(earlyMorning, expected: "清晨6時")
        verifyWithFormat(morning, expected: "上午9時")
        verifyWithFormat(noon, expected: "中午12時")
        verifyWithFormat(afternoon, expected: "下午3時")
        verifyWithFormat(evening, expected: "晚上9時")
        format = .init(timeZone: .gmt).hour(.defaultDigits(amPM: .abbreviated))
        verifyWithFormat(middleOfNight, expected: "凌晨3時")
        verifyWithFormat(earlyMorning, expected: "清晨6時")
        verifyWithFormat(morning, expected: "上午9時")
        verifyWithFormat(noon, expected: "中午12時")
        verifyWithFormat(afternoon, expected: "下午3時")
        verifyWithFormat(evening, expected: "晚上9時")
        format = .init(timeZone: .gmt).hour(.twoDigits(amPM: .abbreviated))
        verifyWithFormat(middleOfNight, expected: "凌晨03時")
        verifyWithFormat(earlyMorning, expected: "清晨06時")
        verifyWithFormat(morning, expected: "上午09時")
        verifyWithFormat(noon, expected: "中午12時")
        verifyWithFormat(afternoon, expected: "下午03時")
        verifyWithFormat(evening, expected: "晚上09時")
        format = .init(timeZone: .gmt).hour().minute()
        verifyWithFormat(middleOfNight, expected: "凌晨3:50")
        verifyWithFormat(earlyMorning, expected: "清晨6:50")
        verifyWithFormat(morning, expected: "上午9:50")
        verifyWithFormat(noon, expected: "中午12:50")
        verifyWithFormat(afternoon, expected: "下午3:50")
        verifyWithFormat(evening, expected: "晚上9:50")
        format = .init(timeZone: .gmt).hour(.defaultDigits(amPM: .wide)).minute()
        verifyWithFormat(middleOfNight, expected: "凌晨3:50")
        verifyWithFormat(earlyMorning, expected: "清晨6:50")
        verifyWithFormat(morning, expected: "上午9:50")
        verifyWithFormat(noon, expected: "中午12:50")
        verifyWithFormat(afternoon, expected: "下午3:50")
        verifyWithFormat(evening, expected: "晚上9:50")
        format = .init(timeZone: .gmt).hour(.twoDigits(amPM: .wide)).minute()
        verifyWithFormat(middleOfNight, expected: "凌晨03:50")
        verifyWithFormat(earlyMorning, expected: "清晨06:50")
        verifyWithFormat(morning, expected: "上午09:50")
        verifyWithFormat(noon, expected: "中午12:50")
        verifyWithFormat(afternoon, expected: "下午03:50")
        verifyWithFormat(evening, expected: "晚上09:50")
        format = .init(timeZone: .gmt).hour().minute().second()
        verifyWithFormat(middleOfNight, expected: "凌晨3:50:00")
        verifyWithFormat(earlyMorning, expected: "清晨6:50:00")
        verifyWithFormat(morning, expected: "上午9:50:00")
        verifyWithFormat(noon, expected: "中午12:50:00")
        verifyWithFormat(afternoon, expected: "下午3:50:00")
        verifyWithFormat(evening, expected: "晚上9:50:00")
        format = .init(timeZone: .gmt).hour(.defaultDigits(amPM: .wide)).minute().second()
        verifyWithFormat(middleOfNight, expected: "凌晨3:50:00")
        verifyWithFormat(earlyMorning, expected: "清晨6:50:00")
        verifyWithFormat(morning, expected: "上午9:50:00")
        verifyWithFormat(noon, expected: "中午12:50:00")
        verifyWithFormat(afternoon, expected: "下午3:50:00")
        verifyWithFormat(evening, expected: "晚上9:50:00")
        format = .init(timeZone: .gmt).hour(.twoDigits(amPM: .wide)).minute().second()
        verifyWithFormat(middleOfNight, expected: "凌晨03:50:00")
        verifyWithFormat(earlyMorning, expected: "清晨06:50:00")
        verifyWithFormat(morning, expected: "上午09:50:00")
        verifyWithFormat(noon, expected: "中午12:50:00")
        verifyWithFormat(afternoon, expected: "下午03:50:00")
        verifyWithFormat(evening, expected: "晚上09:50:00")
        format = .init(timeZone: .gmt).hour(.defaultDigits(amPM: .omitted))
        verifyWithFormat(middleOfNight, expected: "3時")
        verifyWithFormat(earlyMorning, expected: "6時")
        verifyWithFormat(morning, expected: "9時")
        verifyWithFormat(noon, expected: "12時")
        verifyWithFormat(afternoon, expected: "3時")
        verifyWithFormat(evening, expected: "9時")

        locale = .init(identifier: "zh_TW@hours=h24")
        format = .init(timeZone: .gmt).hour()
        verifyWithFormat(middleOfNight, expected: "3時")
        verifyWithFormat(earlyMorning, expected: "6時")
        verifyWithFormat(morning, expected: "9時")
        verifyWithFormat(noon, expected: "12時")
        verifyWithFormat(afternoon, expected: "15時")
        verifyWithFormat(evening, expected: "21時")

        var custom24HourLocale = Foundation.Locale.Components(identifier: "zh_TW")
        custom24HourLocale.hourCycle = .zeroToTwentyThree
        locale = .init(components: custom24HourLocale)
        format = .init(timeZone: .gmt).hour()
        verifyWithFormat(middleOfNight, expected: "3時")
        verifyWithFormat(earlyMorning, expected: "6時")
        verifyWithFormat(morning, expected: "9時")
        verifyWithFormat(noon, expected: "12時")
        verifyWithFormat(afternoon, expected: "15時")
        verifyWithFormat(evening, expected: "21時")

        locale = .init(identifier: "en_TW")
        format = .init(timeZone: .gmt).hour(.twoDigits(amPM: .wide)).minute().second()
        verifyWithFormat(middleOfNight, expected: "03:50:00 AM")
        verifyWithFormat(earlyMorning, expected: "06:50:00 AM")
        verifyWithFormat(morning, expected: "09:50:00 AM")
        verifyWithFormat(noon, expected: "12:50:00 PM")
        verifyWithFormat(afternoon, expected: "03:50:00 PM")
        verifyWithFormat(evening, expected: "09:50:00 PM")
    }
}

final class DateAttributedFormatStyleTests: XCTestCase {
    let testDate = Foundation.Date(timeIntervalSinceReferenceDate: 639932672.0) // 2021-04-12 15:04:32

    func testAttributedFormatStyle() throws {
        let baseStyle = _polyfill_DateFormatStyle(locale: .enUS, timeZone: .gmt)
        let expectations: [_polyfill_DateFormatStyle: [Segment]] = [
            baseStyle.month().day().hour().minute(): [("Apr", .month), (" ", nil), ("12", .day), (" at ", nil), ("3", .hour), (":", nil), ("04", .minute), (" ", nil), ("PM", .amPM)]
        ]
        for (style, expectation) in expectations {
            XCTAssertEqualIgnoreSeparator(style.attributed.format(self.testDate), expectation.attributedString)
        }
    }
    
    func testIndividualFields() throws {
        let baseStyle = _polyfill_DateFormatStyle(locale: .enUS, timeZone: .gmt)
        let expectations: [_polyfill_DateFormatStyle: [Segment]] = [
            baseStyle.era():      [("AD",  .era)],        baseStyle.year(.defaultDigits):  [("2021", .year)],
            baseStyle.quarter():  [("Q2",  .quarter)],    baseStyle.month(.defaultDigits): [("4",    .month)],
            baseStyle.week():     [("16",  .weekOfYear)], baseStyle.week(.weekOfMonth):    [("3",    .weekOfMonth)],
            baseStyle.day():      [("12",  .day)],        baseStyle.dayOfYear():           [("102",  .dayOfYear)],
            baseStyle.weekday():  [("Mon", .weekday)],    baseStyle.hour():                [("3",    .hour), (" ", nil), ("PM", .amPM)],
            baseStyle.minute():   [("4",   .minute)],     baseStyle.second():              [("32",   .second)],
            baseStyle.timeZone(): [("GMT", .timeZone)]
        ]

        for (style, expectation) in expectations {
            XCTAssertEqualIgnoreSeparator(style.attributed.format(self.testDate), expectation.attributedString)
        }
    }

    func testCodable() throws {
        let fields: [Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field] = [
            .era, .year, .relatedGregorianYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal,
            .day, .dayOfYear, .amPM, .hour, .minute, .second, .secondFraction, .timeZone
        ]
        
        for field in fields {
            let encoded = try? Foundation.JSONEncoder().encode(field)
            XCTAssertNotNil(encoded)
            let decoded = try? Foundation.JSONDecoder().decode(Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.self, from: encoded!)
            XCTAssertEqual(decoded, field)
        }
    }

    func testSettingLocale() throws {
                func test(_ attributedResult: Foundation.AttributedString, _ expected: [Segment], file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertEqual(attributedResult, expected.attributedString, file: file, line: line)
        }

        test(self.testDate._polyfill_formatted(.dateTime.weekday().locale(.enUS).attributed), [("Mon", .weekday)])
        test(self.testDate._polyfill_formatted(.dateTime.weekday().locale(.zhTW).attributed), [("週一", .weekday)])
        test(self.testDate._polyfill_formatted(.dateTime.weekday().attributed.locale(.enUS)), [("Mon", .weekday)])
        test(self.testDate._polyfill_formatted(.dateTime.weekday().attributed.locale(.zhTW)),  [("週一", .weekday)])
    }
}

final class DateVerbatimFormatStyleTests: XCTestCase {
    let testDate = Foundation.Date(timeIntervalSinceReferenceDate: 633106280.0) // 2021-01-23 14:51:20

    func testFormats() throws {
        func verify(_ f: _polyfill_DateFormatString, expected: String, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertEqual(self.testDate._polyfill_formatted(_polyfill_DateVerbatimFormatStyle.verbatim(f, timeZone: .gmt, calendar: .gregorian)), expected, file: file, line: line)
        }
        
        verify("\(month: .wide)", expected: "M01")
        verify("\(month: .narrow)", expected: "1")
        verify("\(weekday: .abbreviated)", expected: "Sat")
        verify("\(weekday: .wide)", expected: "Sat")
        verify("\(weekday: .narrow)", expected: "S")
        verify("\(standaloneMonth: .wide)", expected: "M01")
        verify("\(standaloneQuarter: .abbreviated)", expected: "Q1")
        verify("\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased)) heures et \(minute: .twoDigits) minutes", expected: "14 heures et 51 minutes")
        verify("\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased)) heures et \(minute: .twoDigits) minutes", expected: "2 heures et 51 minutes")
    }

    func testParseable() throws {
        func verify(_ f: _polyfill_DateFormatString, expect: String, date: Foundation.Date, file: StaticString = #filePath, line: UInt = #line) throws {
            let style = _polyfill_DateVerbatimFormatStyle.verbatim(f, timeZone: .gmt, calendar: .gregorian)
            
            XCTAssertEqual(self.testDate._polyfill_formatted(style), expect)
            XCTAssertEqual(try Foundation.Date(self.testDate._polyfill_formatted(style), _polyfill_strategy: style.parseStrategy), date)
        }

        XCTAssertNoThrow(try verify("\(year: .twoDigits)_\(month: .defaultDigits)_\(day: .defaultDigits)",
                   expect: "21_1_23", date: .init(timeIntervalSinceReferenceDate: 633052800.0)))
        XCTAssertNoThrow(try verify("\(year: .defaultDigits)_\(month: .defaultDigits)_\(day: .defaultDigits) at \(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased)) o'clock",
                   expect: "2021_1_23 at 2 o'clock", date: .init(timeIntervalSinceReferenceDate: 633060000.0)))
        XCTAssertNoThrow(try verify("\(year: .defaultDigits)_\(month: .defaultDigits)_\(day: .defaultDigits) at \(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased))",
                   expect: "2021_1_23 at 14", date: .init(timeIntervalSinceReferenceDate: 633103200.0)))
    }

    func testNonLenientParsingAbbreviatedNames() throws {
        let date = Foundation.Date(timeIntervalSinceReferenceDate: -978307200.0) // 1970-01-01 00:00:00
        
        func verify(_ f: _polyfill_DateFormatString, localeID: String, calendar: Calendar, expect: String, file: StaticString = #filePath, line: UInt = #line) throws {
            let style = _polyfill_DateVerbatimFormatStyle.verbatim(f, locale: .init(identifier: localeID), timeZone: .gmt, calendar: calendar)
            let s = date._polyfill_formatted(style)
            XCTAssertEqual(s, expect, file: file, line: line)

            var strategy = style.parseStrategy; strategy.isLenient = false
            XCTAssertEqual(try Foundation.Date(s, _polyfill_strategy: strategy), date, file: file, line: line)
        }

        XCTAssertNoThrow(try verify("\(era: .abbreviated) \(month: .twoDigits) \(day: .twoDigits) \(year: .defaultDigits)", localeID: "en_GB", calendar: .gregorian, expect: "AD 01 01 1970"))
        XCTAssertNoThrow(try verify("\(quarter: .abbreviated) \(month: .twoDigits) \(day: .twoDigits) \(year: .defaultDigits)", localeID: "en_GB", calendar: .gregorian, expect: "Q1 01 01 1970"))
        XCTAssertNoThrow(try verify("\(quarter: .abbreviated)", localeID: "en_GB", calendar: .gregorian, expect: "Q1"))
        XCTAssertNoThrow(try verify("\(month: .abbreviated) \(day: .twoDigits) \(year: .defaultDigits)", localeID: "en_GB", calendar: .gregorian, expect: "Jan 01 1970"))
        XCTAssertNoThrow(try verify("\(month: .abbreviated)", localeID: "en_GB", calendar: .gregorian, expect: "Jan"))
        XCTAssertNoThrow(try verify("\(weekday: .abbreviated) \(month: .twoDigits) \(day: .twoDigits) \(year: .defaultDigits)", localeID: "en_GB", calendar: .gregorian, expect: "Thu 01 01 1970"))
        XCTAssertNoThrow(try verify("\(weekday: .abbreviated)", localeID: "en_GB", calendar: .gregorian, expect: "Thu"))
        XCTAssertNoThrow(try verify("\(hour: .twoDigits(clock: .twelveHour, hourCycle: .zeroBased)) \(dayPeriod: .standard(.abbreviated))", localeID: "en_GB", calendar: .gregorian, expect: "00 am"))
    }

    func testAttributedString() throws {
        func verify(_ f: _polyfill_DateFormatString, expected: [Segment], file: StaticString = #filePath, line: UInt = #line) {
            let s = self.testDate._polyfill_formatted(_polyfill_DateVerbatimFormatStyle.verbatim(f, locale: .enUS, timeZone: .gmt, calendar: .gregorian).attributed)
            XCTAssertEqual(s, expected.attributedString, file: file, line: line)
        }

        verify("\(year: .twoDigits)_\(month: .defaultDigits)_\(day: .defaultDigits)", expected: [("21", .year), ("_", nil), ("1", .month), ("_", nil), ("23", .day)])
        verify("\(weekday: .wide) at \(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased))😜\(minute: .twoDigits)🏄🏽‍♂️\(second: .defaultDigits)", expected:
               [("Saturday", .weekday), (" at ", nil), ("14", .hour), ("😜", nil), ("51", .minute), ("🏄🏽‍♂️", nil), ("20", .second)])
    }

    func testAllIndividualFields() {
        func verify(_ f: _polyfill_DateFormatString, expect: String, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertEqual(self.testDate._polyfill_formatted(_polyfill_DateVerbatimFormatStyle.verbatim(f, locale: .enUS, timeZone: .gmt, calendar: .gregorian)), expect, file: file, line: line)
        }

        verify("\(era: .abbreviated)",                                                   expect: "AD")
        verify("\(era: .wide)",                                                          expect: "Anno Domini")
        verify("\(era: .narrow)",                                                        expect: "A")
        verify("\(year: .defaultDigits)",                                                expect: "2021")
        verify("\(year: .twoDigits)",                                                    expect: "21")
        verify("\(year: .padded(0))",                                                    expect: "2021")
        verify("\(year: .padded(1))",                                                    expect: "2021")
        verify("\(year: .padded(2))",                                                    expect: "21")
        verify("\(year: .padded(999))",                                                  expect: "0000002021") // We cap at 10 digits
        verify("\(year: .relatedGregorian(minimumLength: 0))",                           expect: "2021")
        verify("\(year: .relatedGregorian(minimumLength: 999))",                         expect: "0000002021")
        verify("\(year: .extended(minimumLength: 0))",                                   expect: "2021")
        verify("\(year: .extended(minimumLength: 999))",                                 expect: "0000002021")
        verify("\(quarter: .oneDigit)",                                                  expect: "1")
        verify("\(quarter: .twoDigits)",                                                 expect: "01")
        verify("\(quarter: .abbreviated)",                                               expect: "Q1")
        verify("\(quarter: .wide)",                                                      expect: "1st quarter")
        verify("\(quarter: .narrow)",                                                    expect: "1")
        verify("\(month: .defaultDigits)",                                               expect: "1")
        verify("\(month: .twoDigits)",                                                   expect: "01")
        verify("\(month: .abbreviated)",                                                 expect: "Jan")
        verify("\(month: .wide)",                                                        expect: "January")
        verify("\(month: .narrow)",                                                      expect: "J")
        verify("\(week: .defaultDigits)",                                                expect: "4")
        verify("\(week: .twoDigits)",                                                    expect: "04")
        verify("\(week: .weekOfMonth)",                                                  expect: "4")
        verify("\(day: .defaultDigits)",                                                 expect: "23")
        verify("\(day: .twoDigits)",                                                     expect: "23")
        verify("\(day: .ordinalOfDayInMonth)",                                           expect: "4")
        verify("\(day: .julianModified(minimumLength: 0))",                              expect: "2459238")
        verify("\(day: .julianModified(minimumLength: 999))",                            expect: "0002459238")
        verify("\(dayOfYear: .defaultDigits)",                                           expect: "23")
        verify("\(dayOfYear: .twoDigits)",                                               expect: "23")
        verify("\(dayOfYear: .threeDigits)",                                             expect: "023")
        verify("\(weekday: .oneDigit)",                                                  expect: "7")
        verify("\(weekday: .twoDigits)",                                                 expect: "07")
        verify("\(weekday: .abbreviated)",                                               expect: "Sat")
        verify("\(weekday: .wide)",                                                      expect: "Saturday")
        verify("\(weekday: .narrow)",                                                    expect: "S")
        verify("\(weekday: .short)",                                                     expect: "Sa")
        verify("\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased))",     expect: "2")
        verify("\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased))",      expect: "2")
        verify("\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased))", expect: "14")
        verify("\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .oneBased))",  expect: "14")
        verify("\(hour: .twoDigits(clock: .twelveHour, hourCycle: .zeroBased))",         expect: "02")
        verify("\(hour: .twoDigits(clock: .twelveHour, hourCycle: .oneBased))",          expect: "02")
        verify("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))",     expect: "14")
        verify("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased))",      expect: "14")
    }
}

final class MatchConsumerAndSearcherTests: XCTestCase {
    private func verifyString(
        _ string: String,
        matches format: _polyfill_DateFormatString,
        start: String.Index,
        in range: Range<String.Index>,
        expectBound: String.Index?,
        date: Foundation.Date?,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let style = _polyfill_DateVerbatimFormatStyle(format: format, locale: .enUS, timeZone: .gmt, calendar: .gregorian)
        let (matchedUpper, match) = try style.consuming(string, startingAt: start, in: range) ?? (nil, nil)
        
        XCTAssertEqual(matchedUpper, expectBound, file: file, line: line)
        XCTAssertEqual(match, date, file: file, line: line)
    }

    func testMatchFullRanges() throws {
        func verify(_ string: String, match format: _polyfill_DateFormatString, expect: Foundation.TimeInterval?, file: StaticString = #filePath, line: UInt = #line) throws {
            try self.verifyString(
                string, matches: format, start: string.startIndex, in: string.startIndex ..< string.endIndex, expectBound: expect.map { _ in string.endIndex },
                date: expect.map { .init(timeIntervalSinceReferenceDate: $0) },
                file: file, line: line
            )
        }

        XCTAssertNoThrow(try verify("2022-02-12",  match: "\(year: .defaultDigits)-\(month: .defaultDigits)-\(day: .defaultDigits)",                          expect: 666316800.0))
        XCTAssertNoThrow(try verify("2022-2-12",   match: "\(year: .defaultDigits)-\(month: .defaultDigits)-\(day: .defaultDigits)",                          expect: 666316800.0))
        XCTAssertNoThrow(try verify("2022-2-1",    match: "\(year: .defaultDigits)-\(month: .defaultDigits)-\(day: .defaultDigits)",                          expect: 665366400.0))
        XCTAssertNoThrow(try verify("2022-02-30",  match: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",                                  expect: nil))
        XCTAssertNoThrow(try verify("2020-02-29",  match: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",                                  expect: 604627200.0))
        XCTAssertNoThrow(try verify("2022👩‍🦳2👨‍🦲28", match: "\(year: .defaultDigits)👩‍🦳\(month: .defaultDigits)👨‍🦲\(day: .defaultDigits)",                       expect: 667699200.0))
        XCTAssertNoThrow(try verify("2022/2/2",    match: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                          expect: 665452800.0))
        XCTAssertNoThrow(try verify("22/2/2",      match: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                          expect: 665452800.0))
        XCTAssertNoThrow(try verify("22/2/23",     match: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                          expect: 667267200.0))
        XCTAssertNoThrow(try verify("22/2/00",     match: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                          expect: nil))
        XCTAssertNoThrow(try verify("22/0/2",      match: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                          expect: nil))
        XCTAssertNoThrow(try verify("2022-02-12",  match: "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)",                                      expect: 666316800.0))
        XCTAssertNoThrow(try verify("0225-02-12",  match: "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)",                                      expect: -56041545600.0))
        XCTAssertNoThrow(try verify("22/2/2",      match: "\(year: .twoDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                              expect: 665452800.0))
        XCTAssertNoThrow(try verify("22/2/22",     match: "\(year: .twoDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)",                              expect: 667180800.0))
        XCTAssertNoThrow(try verify("22222",       match: "\(year: .twoDigits)\(month: .defaultDigits)\(day: .twoDigits)",                                    expect: 667180800.0))
        XCTAssertNoThrow(try verify("2/28",        match: "\(month: .defaultDigits)/\(day: .defaultDigits)",                                                  expect: -973296000.0))
        XCTAssertNoThrow(try verify("23/39",       match: "\(month: .defaultDigits)/\(day: .defaultDigits)",                                                  expect: nil))
        XCTAssertNoThrow(try verify("Feb_28",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: -973296000.0))
        XCTAssertNoThrow(try verify("FEB_28",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: -973296000.0))
        XCTAssertNoThrow(try verify("fEb_28",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: -973296000.0))
        XCTAssertNoThrow(try verify("Feb_30",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: nil))
        XCTAssertNoThrow(try verify("Feb_29",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: nil))
        XCTAssertNoThrow(try verify("Nan_48",      match: "\(month: .abbreviated)_\(day: .defaultDigits)",                                                    expect: nil))
        XCTAssertNoThrow(try verify("10:48",       match: "\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased)):\(minute: .defaultDigits)",     expect:  -978268320.0))
        XCTAssertNoThrow(try verify("10:61",       match: "\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased)):\(minute: .defaultDigits)",     expect: nil))
        XCTAssertNoThrow(try verify("15:35",       match: "\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .defaultDigits)", expect: -978251100.0))
        XCTAssertNoThrow(try verify("15:35",       match: "\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .zeroBased)):\(minute: .defaultDigits)",     expect: nil))
    }

    func testMatchPartialRangesFromBeginning() throws {
        func verify(
            _ string: String, matches format: _polyfill_DateFormatString, expect: String, date: Foundation.TimeInterval,
            file: StaticString = #filePath, line: UInt = #line
        ) throws {
            try self.verifyString(
                string, matches: format, start: string.startIndex, in: string.startIndex ..< string.endIndex, expectBound: string.range(of: expect, options: [])!.upperBound,
                date: .init(timeIntervalSinceReferenceDate: date),
                file: file, line: line
            )
        }

        XCTAssertNoThrow(try verify("2022/2/28(some_other_texts)",   matches: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)", expect: "2022/2/28", date: 667699200.0))
        XCTAssertNoThrow(try verify("2022/2/28/2023/3/13/2024/4/14", matches: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)", expect: "2022/2/28", date: 667699200.0))
        XCTAssertNoThrow(try verify("2223",                          matches: "\(year: .defaultDigits)\(month: .defaultDigits)\(day: .defaultDigits)",   expect: "222",       date: -63079776000.0))
        XCTAssertNoThrow(try verify("2223",                          matches: "\(year: .twoDigits)\(month: .defaultDigits)\(day: .defaultDigits)",       expect: "2223",      date: 665539200.0))
        XCTAssertNoThrow(try verify("Feb_28Mar_30Apr_2",             matches: "\(month: .abbreviated)_\(day: .defaultDigits)",                           expect: "Feb_28",    date: -973296000.0))
        XCTAssertNoThrow(try verify("Feb_28_Mar_30_Apr_2",           matches: "\(month: .abbreviated)_\(day: .defaultDigits)",                           expect: "Feb_28",    date: -973296000.0))
    }

    func testDateFormatStyleMatchRoundtrip() throws {
        let date = Foundation.Date(timeIntervalSinceReferenceDate: 633106280.0) // 2021-01-23 14:51:20
        
        func verify(_ formatStyle: _polyfill_DateFormatStyle, file: StaticString = #filePath, line: UInt = #line) throws {
            var format = formatStyle; (format.calendar, format.timeZone) = (.gregorian, .gmt)
            let fdate = format.format(date),
                embeds = ["\(fdate)":  0, "\(fdate)trailing_text":   0, "\(fdate)   trailing text with space":          0, "\(fdate);\(fdate)": 0,
                          " \(fdate)": 1, "__\(fdate)trailing_text": 2, "🥹💩\(fdate)   🥹💩trailing text with space": 2                     ]

            for (embed, off) in embeds {
                let (upper, match) = try format.consuming(embed, startingAt: embed.index(embed.startIndex, offsetBy: off), in: embed.startIndex ..< embed.endIndex) ?? (nil, nil)
                
                XCTAssertEqual(upper, embed.range(of: fdate)?.upperBound, file: file, line: line)
                XCTAssertEqual(match, date, file: file, line: line)
            }
        }

        XCTAssertNoThrow(try verify(.init(date: .complete, time: .standard)))
        XCTAssertNoThrow(try verify(.init(date: .complete, time: .complete)))
        XCTAssertNoThrow(try verify(.init(date: .complete, time: .complete, locale: .zhTW)))
        XCTAssertNoThrow(try verify(.init(date: .omitted, time: .complete, locale: .enUS).year().month(.abbreviated).day(.twoDigits)))
        XCTAssertNoThrow(try verify(.init(date: .omitted, time: .complete).year().month(.wide).day(.twoDigits).locale(.zhTW)))
    }

    func testMatchPartialRangesFromMiddle() throws {
        func verify(_ s: String, matches f: _polyfill_DateFormatString, expect: String, date: Foundation.TimeInterval, file: StaticString = #filePath, line: UInt = #line) throws {
            let r = s.range(of: expect)!
            
            try self.verifyString(
                s, matches: f, start: r.lowerBound, in: s.startIndex ..< s.endIndex, expectBound: r.upperBound, date: .init(timeIntervalSinceReferenceDate: date),
                file: file, line: line
            )
        }

        XCTAssertNoThrow(try verify("(some_other_texts)2022/2/28(some_other_texts)",   matches: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)", expect: "2022/2/28", date: 667699200.0))
        XCTAssertNoThrow(try verify("(some_other_texts)2022/2/28/2023/3/13/2024/4/14", matches: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits)", expect: "2022/2/28", date: 667699200.0))
        XCTAssertNoThrow(try verify("(some_other_texts)2223",                          matches: "\(year: .defaultDigits)\(month: .defaultDigits)\(day: .defaultDigits)",   expect: "222",       date: -63079776000.0))
        XCTAssertNoThrow(try verify("(some_other_texts)2223",                          matches: "\(year: .twoDigits)\(month: .defaultDigits)\(day: .defaultDigits)",       expect: "2223",      date: 665539200.0))
        XCTAssertNoThrow(try verify("(some_other_texts)Feb_28Mar_30Apr_2",             matches: "\(month: .abbreviated)_\(day: .defaultDigits)",                           expect: "Feb_28",    date: -973296000.0))
        XCTAssertNoThrow(try verify("(some_other_texts)Feb_28_Mar_30_Apr_2",           matches: "\(month: .abbreviated)_\(day: .defaultDigits)",                           expect: "Feb_28",    date: -973296000.0))
    }
}

extension DateFormatStyleTests {
    func test_dateFormatPresets() {
        let dateFormatter = Foundation.DateFormatter(locale: .enUS, timeZone: .losAngeles)
        
        dateFormatter.setLocalizedDateFormatFromTemplate("yMd")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .numeric,     time: .omitted,   locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("yMMMd")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .abbreviated, time: .omitted,   locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("yMMMMd")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .long,        time: .omitted,   locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("yMMMMEEEEd")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .complete,    time: .omitted,   locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("jmm")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .omitted,     time: .shortened, locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("jmmss")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .omitted,     time: .standard,  locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("jmmssz")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .omitted,     time: .complete,  locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("yMdjmm")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .numeric,     time: .shortened, locale: .enUS, timeZone: .losAngeles)),
                       dateFormatter.string(from: self.refDate))
    }

    func test_customParsing() {
        let expectedFormats: [(_polyfill_DateFormatString, String, String, UInt)] = [
            ("\(day: .twoDigits)/\(month: .twoDigits)/\(year: .twoDigits)",                      "dd/MM/yy",                        "01/05/99",                  #line),
            ("\(day: .twoDigits)-\(month: .twoDigits)-\(year: .twoDigits)",                      "dd-MM-yy",                        "01-05-99",                  #line),
            ("\(day: .twoDigits)'\(month: .twoDigits)'\(year: .twoDigits)",                      "dd''MM''yy",                      "01'05'99",                  #line),
            ("\(day: .defaultDigits)/\(month: .abbreviated)/\(year: .padded(4))",                "d/MMM/yyyy",                      "1/Sep/1999",                #line),
            ("Day:\(day: .defaultDigits) Month:\(month: .abbreviated) Year:\(year: .padded(4))", "'Day:'d 'Month:'MMM 'Year:'yyyy", "Day:1 Month:Sep Year:1999", #line),
            //("😀:\(day: .defaultDigits) 😡:\(month: .abbreviated) 😍:\(year: .padded(4))",      "'😀:'d '😡:'MMM '😡:'yyyy",       "😀:1 😡:Sep 😍:1999",       #line),
            ("\(day: .twoDigits)-\(month: .twoDigits)-\(year: .twoDigits)",                      "dd-MM-yy",                        "01 - 05 - 99",              #line),
            ("\(day: .twoDigits)-\(month: .twoDigits)-\(year: .twoDigits)",                      "dd-MM-yy",                        "01-05-1999",                #line),
            ("\(day: .twoDigits)/\(month: .twoDigits)/\(year: .twoDigits)",                      "dd'/'MM'/'yy",                    "01-05-99",                  #line),
        ]
        let dateFormatter = Foundation.DateFormatter(locale: .enUS, timeZone: .gmt)

        for (format, dfFormat, dateString, line) in expectedFormats {
            let parseStrategy = _polyfill_DateParseStrategy(format: format, locale: .enUS, timeZone: .gmt)
            dateFormatter.dateFormat = dfFormat
            XCTAssertEqual(try Foundation.Date(dateString, _polyfill_strategy: parseStrategy), dateFormatter.date(from: dateString), line: line)
        }
    }

    func test_presetModifierCombination() {
        let dateFormatter = Foundation.DateFormatter(locale: .enUS, timeZone: .losAngeles)
        
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMMddjmm")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(time: .shortened, locale: .enUS, timeZone: .losAngeles)
                           .year(.padded(4)).month(.abbreviated).day(.twoDigits)),
                       dateFormatter.string(from: self.refDate))
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyyyyMMMMd")
        XCTAssertEqual(self.refDate._polyfill_formatted(_polyfill_DateFormatStyle(date: .numeric, locale: .enUS, timeZone: .losAngeles).year(.padded(6)).month(.wide)),
                       dateFormatter.string(from: self.refDate))
    }

    func test_hourSymbols() {
        func verify(_ style: _polyfill_DateFormatStyle, expectedFormat: String, locale: Foundation.Locale, file: StaticString = #filePath, line: UInt = #line) {
            var style = style
            style.timeZone = .init(secondsFromGMT: -3600)!
            let dateFormatter = Foundation.DateFormatter(locale: locale, timeZone: style.timeZone, dateFormat: expectedFormat)

            XCTAssertEqual(self.refDate._polyfill_formatted(style.locale(locale)), dateFormatter.string(from: self.refDate), file: file, line: line)
        }

        verify(.dateTime.hour(.defaultDigits(amPM: .abbreviated)),           expectedFormat: "h\u{202f}a", locale: .enUS)
        verify(.dateTime.hour(.defaultDigits(amPM: .omitted)),               expectedFormat: "hh",         locale: .enUS)
        verify(.dateTime.hour(.twoDigits(amPM: .omitted)),                   expectedFormat: "hh",         locale: .enUS)
        verify(.dateTime.hour(.conversationalDefaultDigits(amPM: .omitted)), expectedFormat: "hh",         locale: .enUS)
        verify(.dateTime.hour(.conversationalTwoDigits(amPM: .omitted)),     expectedFormat: "hh",         locale: .enUS)
        verify(.dateTime.hour(.defaultDigits(amPM: .abbreviated)),           expectedFormat: "H",          locale: .enGB)
        verify(.dateTime.hour(.defaultDigits(amPM: .omitted)),               expectedFormat: "H",          locale: .enGB)
        verify(.dateTime.hour(.twoDigits(amPM: .omitted)),                   expectedFormat: "HH",         locale: .enGB)
        verify(.dateTime.hour(.conversationalDefaultDigits(amPM: .omitted)), expectedFormat: "H",          locale: .enGB)
        verify(.dateTime.hour(.conversationalTwoDigits(amPM: .omitted)),     expectedFormat: "HH",         locale: .enGB)
    }
}

final class DateISO8601FormatStyleTests: XCTestCase {
    func test_ISO8601Format() throws {
        func verify(_ formatStyle: _polyfill_DateISO8601FormatStyle, expect: String, date: Foundation.TimeInterval, file: StaticString = #filePath, line: UInt = #line) throws {
            let formatted = formatStyle.format(.init(timeIntervalSinceReferenceDate: 665076946.0)) // 2022-01-28 15:35:46
            XCTAssertEqual(formatted, expect, file: file, line: line)
            XCTAssertEqual(try Foundation.Date(formatted, _polyfill_strategy: formatStyle), .init(timeIntervalSinceReferenceDate: date), file: file, line: line)
        }

        XCTAssertNoThrow(try verify(.init(),                                                                       expect: "2022-01-28T15:35:46Z", date: 665076946.0)) // 2022-01-28 15:35:46
        XCTAssertNoThrow(try verify(.init().year().month().day().dateSeparator(.dash),                             expect: "2022-01-28",           date: 665020800.0)) // 2022-01-28 00:00:00
        XCTAssertNoThrow(try verify(.init().year().month().day().dateSeparator(.omitted),                          expect: "20220128",             date: 665020800.0)) // 2022-01-28 00:00:00
        XCTAssertNoThrow(try verify(.init().weekOfYear().day().dateSeparator(.dash),                               expect: "W04-05",               date: -976406400.0)) // 1970-01-23 00:00:00
        XCTAssertNoThrow(try verify(.init().day().time(includingFractionalSeconds: false).timeSeparator(.colon),   expect: "028T15:35:46",         date: -975918254.0)) // 1970-01-28 15:35:46
        XCTAssertNoThrow(try verify(.init().time(includingFractionalSeconds: false).timeSeparator(.colon),         expect: "15:35:46",             date: -978251054.0)) // 1970-01-01 15:35:46
        XCTAssertNoThrow(try verify(.init().time(includingFractionalSeconds: false).timeZone(separator: .omitted), expect: "15:35:46Z",            date: -978251054.0)) // 1970-01-01 15:35:46
        XCTAssertNoThrow(try verify(.init().time(includingFractionalSeconds: false).timeZone(separator: .colon),   expect: "15:35:46Z",            date: -978251054.0)) // 1970-01-01 15:35:46
        XCTAssertNoThrow(try verify(.init().timeZone(separator: .colon).time(includingFractionalSeconds: false)
                          .timeSeparator(.colon),                                                                  expect: "15:35:46Z",            date: -978251054.0)) // 1970-01-01 15:35:46
    }

    func test_ISO8601FormatWithDate() throws {
        let date = Foundation.Date(timeIntervalSinceReferenceDate: 646847792.0) // 2021-07-01 15:56:32

        XCTAssertEqual(date._polyfill_formatted(.iso8601),                                                 "2021-07-01T15:56:32Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.dateSeparator(.omitted)),                         "20210701T15:56:32Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.dateTimeSeparator(.space)),                       "2021-07-01 15:56:32Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.timeSeparator(.omitted)),                         "2021-07-01T155632Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.dateSeparator(.omitted).timeSeparator(.omitted)), "20210701T155632Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false)
                                                        .timeZone(separator: .omitted)),                   "2021-07-01T15:56:32Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().month().day().time(includingFractionalSeconds: true)
                                                        .timeZone(separator: .omitted).dateSeparator(.dash).dateTimeSeparator(.standard)
                                                        .timeSeparator(.colon)),                           "2021-07-01T15:56:32.000Z")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year()),                                          "2021")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().month()),                                  "2021-07")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().month().day()),                            "2021-07-01")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().month().day().dateSeparator(.omitted)),    "20210701")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().weekOfYear()),                             "2021-W26")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().weekOfYear().day()),                       "2021-W26-04")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.year().day()),                                    "2021-182")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.time(includingFractionalSeconds: false)),         "15:56:32")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.time(includingFractionalSeconds: true)),          "15:56:32.000")
        XCTAssertEqual(date._polyfill_formatted(.iso8601.time(includingFractionalSeconds: false)
                                                        .timeZone(separator: .omitted)),                   "15:56:32Z")
    }
}

final class DateISO8601FormatStylePatternMatchingTests: XCTestCase {
    private func matchFullRange(
        _ str: String, formatStyle: _polyfill_DateISO8601FormatStyle = .init(), expectBound: String.Index?, date: Foundation.Date?,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let (upperBound, match) = try formatStyle.consuming(str, startingAt: str.startIndex, in: str.startIndex ..< str.endIndex) ?? (nil, nil)

        XCTAssertEqual(upperBound, expectBound, file: file, line: line)
        XCTAssertEqual(match, date, file: file, line: line)
    }

    func testMatchDefaultISO8601Style() throws {
        XCTAssertNoThrow(try self.matchFullRange("2021-07-01T15:56:32Z",      expectBound: "2021-07-01T15:56:32Z".endIndex, date: .init(timeIntervalSinceReferenceDate: 646847792.0)))
        XCTAssertNoThrow(try self.matchFullRange("2021-07-01T15:56:32Z text", expectBound: "2021-07-01T15:56:32Z".endIndex, date: .init(timeIntervalSinceReferenceDate: 646847792.0)))
        XCTAssertNoThrow(try self.matchFullRange("some 2021-07-01T15:56:32Z", expectBound: nil,                             date: nil))
        XCTAssertNoThrow(try self.matchFullRange("9999-37-40T35:70:99Z",      expectBound: nil,                             date: nil))
    }

    func testPartialMatchISO8601() throws {
        func verify(_ str: String, _ style: _polyfill_DateISO8601FormatStyle, file: StaticString = #filePath, line: UInt = #line) throws {
            try self.matchFullRange(str, formatStyle: style, expectBound: expectLen.map { str.index(str.startIndex, offsetBy: $0) }, date: expectDate, file: file, line: line)
        }

        var expectDate: Foundation.Date?, expectLen: Int?
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32",         ._polyfill_iso8601WithTimeZone()))
        XCTAssertNoThrow(try verify("2021-07-01T235632",           ._polyfill_iso8601WithTimeZone()))
        XCTAssertNoThrow(try verify("2021-07-01 23:56:32Z",        ._polyfill_iso8601WithTimeZone()))
        (expectDate, expectLen) = (.init(timeIntervalSinceReferenceDate: 646876592.0), "2021-07-01T23:56:32".count)
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32",         ._polyfill_iso8601(timeZone: .gmt)))
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32Z",        ._polyfill_iso8601(timeZone: .gmt)))
        XCTAssertNoThrow(try verify("2021-07-01T15:56:32Z",        ._polyfill_iso8601(timeZone: .pst)))
        XCTAssertNoThrow(try verify("2021-07-01T15:56:32+0000",    ._polyfill_iso8601(timeZone: .pst)))
        XCTAssertNoThrow(try verify("2021-07-01T15:56:32+00:00",   ._polyfill_iso8601(timeZone: .pst)))
        (expectDate, expectLen) = (.init(timeIntervalSinceReferenceDate: 646876592.345), "2021-07-01T23:56:32.34567".count)
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32.34567",   ._polyfill_iso8601(timeZone: .gmt, includingFractionalSeconds: true)))
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32.34567Z",  ._polyfill_iso8601(timeZone: .gmt, includingFractionalSeconds: true)))
        (expectDate, expectLen) = (.init(timeIntervalSinceReferenceDate: 646876592.0), "20210701T235632".count)
        XCTAssertNoThrow(try verify("20210701T235632",             ._polyfill_iso8601(timeZone: .gmt, dateSeparator: .omitted, timeSeparator: .omitted)))
        XCTAssertNoThrow(try verify("20210701 235632",             ._polyfill_iso8601(timeZone: .gmt, dateSeparator: .omitted, dateTimeSeparator: .space, timeSeparator: .omitted)))
        (expectDate, expectLen) = (.init(timeIntervalSinceReferenceDate: 646790400.0), "2021-07-01".count)
        XCTAssertNoThrow(try verify("2021-07-01",                  ._polyfill_iso8601Date(timeZone: .gmt)))
        XCTAssertNoThrow(try verify("2021-07-01T15:56:32+08:00",   ._polyfill_iso8601Date(timeZone: .gmt)))
        XCTAssertNoThrow(try verify("2021-07-01 15:56:32+08:00",   ._polyfill_iso8601Date(timeZone: .gmt)))
        XCTAssertNoThrow(try verify("2021-07-01 i love summer",    ._polyfill_iso8601Date(timeZone: .gmt)))
        (expectDate, expectLen) = (.init(timeIntervalSinceReferenceDate: 646790400.0), "20210701".count)
        XCTAssertNoThrow(try verify("20210701",                    ._polyfill_iso8601Date(timeZone: .gmt, dateSeparator: .omitted)))
        XCTAssertNoThrow(try verify("20210701T155632+0800",        ._polyfill_iso8601Date(timeZone: .gmt, dateSeparator: .omitted)))
        XCTAssertNoThrow(try verify("20210701 155632+0800",        ._polyfill_iso8601Date(timeZone: .gmt, dateSeparator: .omitted)))
    }

    func testFullMatch() throws {
        func verify(_ str: String, _ style: _polyfill_DateISO8601FormatStyle, file: StaticString = #filePath, line: UInt = #line) throws {
            try self.matchFullRange(str, formatStyle: style, expectBound: str.endIndex, date: expectedDate, file: file, line: line)
        }

        var expectedDate: Foundation.Date = .init(timeIntervalSinceReferenceDate: 646876592.0) // 2021-07-01 23:56:32
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32Z",        ._polyfill_iso8601WithTimeZone()))
        XCTAssertNoThrow(try verify("20210701 23:56:32Z",          ._polyfill_iso8601WithTimeZone(dateSeparator: .omitted, dateTimeSeparator: .space)))
        XCTAssertNoThrow(try verify("2021-07-01 15:56:32-0800",    ._polyfill_iso8601WithTimeZone(dateTimeSeparator: .space)))
        XCTAssertNoThrow(try verify("2021-07-01T15:56:32-08:00",   ._polyfill_iso8601WithTimeZone()))
        expectedDate = .init(timeIntervalSinceReferenceDate: 646876592.3139999) // 2021-07-01 23:56:32.314
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32.314Z",    ._polyfill_iso8601WithTimeZone(includingFractionalSeconds: true)))
        XCTAssertNoThrow(try verify("2021-07-01T235632.314Z",      ._polyfill_iso8601WithTimeZone(includingFractionalSeconds: true, timeSeparator: .omitted)))
        XCTAssertNoThrow(try verify("2021-07-01T23:56:32.314000Z", ._polyfill_iso8601WithTimeZone(includingFractionalSeconds: true)))
    }
}

final class DateIntervalFormatStyleTests: XCTestCase {
    let minute: Foundation.TimeInterval = 60
    let hour:   Foundation.TimeInterval = 60 * 60
    let day:    Foundation.TimeInterval = 60 * 60 * 24
    let date =  Foundation.Date(timeIntervalSinceReferenceDate: 0)
    let expSep = "\u{202f}"

    func testDefaultFormatStyle() throws {
        var style = _polyfill_DateIntervalFormatStyle()
        style.timeZone = .gmt

        XCTAssertGreaterThan(style.format(self.date ..< self.date + self.hour).count, 0)
    }

    func testBasicFormatStyle() throws {
        let style = _polyfill_DateIntervalFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .gmt)
        XCTAssertEqualIgnoreSeparator(style.format(self.date ..< self.date + self.hour), "1/1/2001, 12:00 – 1:00 AM")
        XCTAssertEqualIgnoreSeparator(style.format(self.date ..< self.date + self.day), "1/1/2001, 12:00 AM – 1/2/2001, 12:00 AM")
        XCTAssertEqualIgnoreSeparator(style.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12:00 AM – 2/2/2001, 12:00 AM")
        
        let dayStyle = _polyfill_DateIntervalFormatStyle(date: .long, locale: .enUS, calendar: .gregorian, timeZone: .gmt)
        XCTAssertEqualIgnoreSeparator(dayStyle.format(self.date ..< self.date + self.hour), "January 1, 2001")
        XCTAssertEqualIgnoreSeparator(dayStyle.format(self.date ..< self.date + self.day), "January 1 – 2, 2001")
        XCTAssertEqualIgnoreSeparator(dayStyle.format(self.date ..< self.date + self.day * 32), "January 1 – February 2, 2001")

        let timeStyle = _polyfill_DateIntervalFormatStyle(time: .standard, locale: .enUS, calendar: .gregorian, timeZone: .gmt)
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.hour), "12:00:00 AM – 1:00:00 AM")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.day), "1/1/2001, 12:00:00 AM – 1/2/2001, 12:00:00 AM")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12:00:00 AM – 2/2/2001, 12:00:00 AM")

        let dateTimeStyle = _polyfill_DateIntervalFormatStyle(date: .numeric, time: .shortened, locale: .enUS, calendar: .gregorian, timeZone: .gmt)
        XCTAssertEqualIgnoreSeparator(dateTimeStyle.format(self.date ..< self.date + self.hour), "1/1/2001, 12:00 – 1:00 AM")
        XCTAssertEqualIgnoreSeparator(dateTimeStyle.format(self.date ..< self.date + self.day), "1/1/2001, 12:00 AM – 1/2/2001, 12:00 AM")
        XCTAssertEqualIgnoreSeparator(dateTimeStyle.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12:00 AM – 2/2/2001, 12:00 AM")
    }

    func testCustomFields() throws {
        let fullDayStyle = _polyfill_DateIntervalFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .gmt).year().month().weekday().day()
        XCTAssertEqualIgnoreSeparator(fullDayStyle.format(self.date ..< self.date + self.hour), "Mon, Jan 1, 2001")
        XCTAssertEqualIgnoreSeparator(fullDayStyle.format(self.date ..< self.date + self.day), "Mon, Jan 1 – Tue, Jan 2, 2001")
        XCTAssertEqualIgnoreSeparator(fullDayStyle.format(self.date ..< self.date + self.day * 32), "Mon, Jan 1 – Fri, Feb 2, 2001")
        
        let timeStyle = _polyfill_DateIntervalFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .gmt).hour().timeZone()
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.hour * 0.5), "12 AM GMT")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.hour), "12 – 1 AM GMT")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.hour * 1.5), "12 – 1 AM GMT")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.day), "1/1/2001, 12 AM GMT – 1/2/2001, 12 AM GMT")
        XCTAssertEqualIgnoreSeparator(timeStyle.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12 AM GMT – 2/2/2001, 12 AM GMT")
        
        let weekDayStyle = _polyfill_DateIntervalFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .gmt).weekday()
        XCTAssertEqualIgnoreSeparator(weekDayStyle.format(self.date ..< self.date + self.hour), "Mon")
        XCTAssertEqualIgnoreSeparator(weekDayStyle.format(self.date ..< self.date + self.day), "Mon – Tue")
        XCTAssertEqualIgnoreSeparator(weekDayStyle.format(self.date ..< self.date + self.day * 32), "Mon – Fri")

        let weekDayHourStyle = _polyfill_DateIntervalFormatStyle(locale: .enUS, calendar: .gregorian, timeZone: .gmt).weekday().hour()
        XCTAssertEqualIgnoreSeparator(weekDayHourStyle.format(self.date ..< self.date + self.hour), "Mon, 12 – 1 AM")
        XCTAssertEqualIgnoreSeparator(weekDayHourStyle.format(self.date ..< self.date + self.day), "Mon 1, 12 AM – Tue 2, 12 AM")
        XCTAssertEqualIgnoreSeparator(weekDayHourStyle.format(self.date ..< self.date + self.day * 32), "Mon, 1/1, 12 AM – Fri, 2/2, 12 AM")
    }

    func testStyleWithCustomFields() throws {
        let dateHourStyle = _polyfill_DateIntervalFormatStyle(date: .numeric, locale: .enUS, calendar: .gregorian, timeZone: .gmt).hour()
        XCTAssertEqualIgnoreSeparator(dateHourStyle.format(self.date ..< self.date + self.hour), "1/1/2001, 12 – 1 AM")
        XCTAssertEqualIgnoreSeparator(dateHourStyle.format(self.date ..< self.date + self.day), "1/1/2001, 12 AM – 1/2/2001, 12 AM")
        XCTAssertEqualIgnoreSeparator(dateHourStyle.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12 AM – 2/2/2001, 12 AM")

        let timeMonthDayStyle = _polyfill_DateIntervalFormatStyle(time: .shortened, locale: .enUS, calendar: .gregorian, timeZone: .gmt).month(.defaultDigits).day()
        XCTAssertEqualIgnoreSeparator(timeMonthDayStyle.format(self.date ..< self.date + self.hour), "1/1, 12:00 – 1:00 AM")
        XCTAssertEqualIgnoreSeparator(timeMonthDayStyle.format(self.date ..< self.date + self.day), "1/1, 12:00 AM – 1/2, 12:00 AM")
        XCTAssertEqualIgnoreSeparator(timeMonthDayStyle.format(self.date ..< self.date + self.day * 32), "1/1, 12:00 AM – 2/2, 12:00 AM")
        
        let noAMPMStyle = _polyfill_DateIntervalFormatStyle(date: .numeric, time: .shortened, locale: .enUS, calendar: .gregorian, timeZone: .gmt).hour(.defaultDigits(amPM: .omitted))
        XCTAssertEqualIgnoreSeparator(noAMPMStyle.format(self.date ..< self.date + self.hour), "1/1/2001, 12:00 – 1:00")
        XCTAssertEqualIgnoreSeparator(noAMPMStyle.format(self.date ..< self.date + self.day), "1/1/2001, 12:00 – 1/2/2001, 12:00")
        XCTAssertEqualIgnoreSeparator(noAMPMStyle.format(self.date ..< self.date + self.day * 32), "1/1/2001, 12:00 – 2/2/2001, 12:00")
    }

    func testLeadingDotSyntax() {
        let range = (self.date ..< self.date + self.hour)
        
        XCTAssertEqual(range._polyfill_formatted(), _polyfill_DateIntervalFormatStyle().format(range))
        XCTAssertEqual(range._polyfill_formatted(date: .numeric, time: .shortened), _polyfill_DateIntervalFormatStyle(date: .numeric, time: .shortened).format(range))
        XCTAssertEqual(range._polyfill_formatted(.interval.day().month().year()), _polyfill_DateIntervalFormatStyle().day().month().year().format(range))
    }
}

final class DateRelativeFormatStyleTests: XCTestCase {
    let oneHour: Foundation.TimeInterval = 60 * 60
    let oneDay:  Foundation.TimeInterval = 60 * 60 * 24

    func testDefaultStyle() throws {
        let style = _polyfill_DateRelativeFormatStyle(locale: .enUS, calendar: .gregorian)
        
        XCTAssertEqual(style.format(.init()), "in 0 seconds")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: self.oneHour)), "in 1 hour")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: self.oneHour * 2)), "in 2 hours")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: self.oneDay)), "in 1 day")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: self.oneDay * 2)), "in 2 days")

        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: -self.oneHour)), "1 hour ago")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: -self.oneHour * 2)), "2 hours ago")

        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: -self.oneHour * 1.5)), "2 hours ago")
        XCTAssertEqual(style.format(.init(timeIntervalSinceNow: self.oneHour * 1.5)), "in 2 hours")
    }

    func testDateRelativeFormatConvenience() throws {
        let now = Foundation.Date()
        let tomorrow = Foundation.Date(timeInterval: self.oneDay + self.oneHour * 2, since: now)
        let future = Foundation.Date(timeInterval: self.oneDay * 14 + self.oneHour * 3, since: now)
        let past = Foundation.Date(timeInterval: -(self.oneDay * 14 + self.oneHour * 2), since: now)

        XCTAssertEqual(past._polyfill_formatted(.relative(presentation: .named)), _polyfill_DateRelativeFormatStyle(presentation: .named, unitsStyle: .wide).format(past))
        XCTAssertEqual(tomorrow._polyfill_formatted(.relative(presentation: .numeric)), _polyfill_DateRelativeFormatStyle(presentation: .numeric, unitsStyle: .wide).format(tomorrow))
        XCTAssertEqual(tomorrow._polyfill_formatted(_polyfill_DateRelativeFormatStyle(presentation: .named)), _polyfill_DateRelativeFormatStyle(presentation: .named).format(tomorrow))

        XCTAssertEqual(
            past._polyfill_formatted(_polyfill_DateRelativeFormatStyle(unitsStyle: .spellOut, capitalizationContext: .beginningOfSentence)),
            _polyfill_DateRelativeFormatStyle(unitsStyle: .spellOut, capitalizationContext: .beginningOfSentence).format(past)
        )
        XCTAssertEqual(future._polyfill_formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)), _polyfill_DateRelativeFormatStyle(unitsStyle: .abbreviated).format(future))
    }

    func testNamedStyleRounding() throws {
        var calendar = Calendar.gregorian
        calendar.timeZone = .gmt
        let named = _polyfill_DateRelativeFormatStyle(presentation: .named, locale: .enUS, calendar: calendar)

        func verifyStyle(_ dateValue: Foundation.TimeInterval, relativeTo: Foundation.TimeInterval, expected: String, file: StaticString = #filePath, line: UInt = #line) {
            let formatted = named.formatRel(.init(timeIntervalSinceReferenceDate: dateValue), refDate: .init(timeIntervalSinceReferenceDate: relativeTo))
            XCTAssertEqual(formatted, expected, file: file, line: line)
        }

        verifyStyle(645019200.0, relativeTo: 645019200.0, expected: "now") // 2021-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645019170.0, relativeTo: 645019200.0, expected: "30 seconds ago") // 2021-06-10 11:59:30 -> 2021-06-10 12:00:00
        verifyStyle(645019140.0, relativeTo: 645019200.0, expected: "1 minute ago") // 2021-06-10 11:59:00 -> 2021-06-10 12:00:00
        verifyStyle(645018600.0, relativeTo: 645019200.0, expected: "10 minutes ago") // 2021-06-10 11:50:00 -> 2021-06-10 12:00:00
        verifyStyle(645018570.0, relativeTo: 645019200.0, expected: "11 minutes ago") // 2021-06-10 11:49:30 -> 2021-06-10 12:00:00
        verifyStyle(645015600.0, relativeTo: 645019200.0, expected: "1 hour ago") // 2021-06-10 11:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645014400.0, relativeTo: 645019200.0, expected: "1 hour ago") // 2021-06-10 10:40:00 -> 2021-06-10 12:00:00
        verifyStyle(645013800.0, relativeTo: 645019200.0, expected: "2 hours ago") // 2021-06-10 10:30:00 -> 2021-06-10 12:00:00
        verifyStyle(645022800.0, relativeTo: 645019200.0, expected: "in 1 hour") // 2021-06-10 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645024000.0, relativeTo: 645019200.0, expected: "in 1 hour") // 2021-06-10 13:20:00 -> 2021-06-10 12:00:00
        verifyStyle(645024600.0, relativeTo: 645019200.0, expected: "in 2 hours") // 2021-06-10 13:30:00 -> 2021-06-10 12:00:00
        verifyStyle(645025800.0, relativeTo: 645019200.0, expected: "in 2 hours") // 2021-06-10 13:50:00 -> 2021-06-10 12:00:00
        verifyStyle(568771200.0, relativeTo: 645019200.0, expected: "2 years ago") // 2019-01-10 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(599529599.0, relativeTo: 645019200.0, expected: "2 years ago") // 2019-12-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(599529600.0, relativeTo: 645019200.0, expected: "last year") // 2020-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(613483200.0, relativeTo: 645019200.0, expected: "last year") // 2020-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(628948800.0, relativeTo: 645019200.0, expected: "6 months ago") // 2020-12-06 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(631152000.0, relativeTo: 645019200.0, expected: "5 months ago") // 2021-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(633830400.0, relativeTo: 645019200.0, expected: "4 months ago") // 2021-02-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(636249600.0, relativeTo: 645019200.0, expected: "3 months ago") // 2021-03-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(638928000.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(639748800.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(641519999.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(641520000.0, relativeTo: 645019200.0, expected: "last month") // 2021-05-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644111999.0, relativeTo: 645019200.0, expected: "last week") // 2021-05-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(644198400.0, relativeTo: 645019200.0, expected: "last week") // 2021-06-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644630399.0, relativeTo: 645019200.0, expected: "5 days ago") // 2021-06-05 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(644630400.0, relativeTo: 645019200.0, expected: "4 days ago") // 2021-06-06 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644839200.0, relativeTo: 645019200.0, expected: "2 days ago") // 2021-06-08 10:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644850000.0, relativeTo: 645019200.0, expected: "2 days ago") // 2021-06-08 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644929200.0, relativeTo: 645019200.0, expected: "yesterday") // 2021-06-09 11:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644936400.0, relativeTo: 645019200.0, expected: "23 hours ago") // 2021-06-09 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645087600.0, relativeTo: 645019200.0, expected: "in 19 hours") // 2021-06-11 07:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645145259.0, relativeTo: 645019200.0, expected: "tomorrow") // 2021-06-11 23:00:59 -> 2021-06-10 12:00:00
        verifyStyle(645188459.0, relativeTo: 645019200.0, expected: "in 2 days") // 2021-06-12 11:00:59 -> 2021-06-10 12:00:00
        verifyStyle(645235199.0, relativeTo: 645019200.0, expected: "in 2 days") // 2021-06-12 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(645235200.0, relativeTo: 645019200.0, expected: "in 3 days") // 2021-06-13 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645839999.0, relativeTo: 645019200.0, expected: "next week") // 2021-06-19 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(645840000.0, relativeTo: 645019200.0, expected: "in 2 weeks") // 2021-06-20 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(646444799.0, relativeTo: 645019200.0, expected: "in 2 weeks") // 2021-06-26 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(646790399.0, relativeTo: 645019200.0, expected: "in 3 weeks") // 2021-06-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(646790400.0, relativeTo: 645019200.0, expected: "in 3 weeks") // 2021-07-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(649468799.0, relativeTo: 645019200.0, expected: "next month") // 2021-07-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(649468800.0, relativeTo: 645019200.0, expected: "in 2 months") // 2021-08-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(652147199.0, relativeTo: 645019200.0, expected: "in 2 months") // 2021-08-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(662688000.0, relativeTo: 645019200.0, expected: "in 7 months") // 2022-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(676555200.0, relativeTo: 645019200.0, expected: "next year") // 2022-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(694223999.0, relativeTo: 645019200.0, expected: "next year") // 2022-12-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(694224000.0, relativeTo: 645019200.0, expected: "in 2 years") // 2023-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(725759999.0, relativeTo: 645019200.0, expected: "in 2 years") // 2023-12-31 23:59:59 -> 2021-06-10 12:00:00
    }

    func testNumericStyleRounding() throws {
        var calendar = Calendar.gregorian
        calendar.timeZone = .gmt
        let numeric = _polyfill_DateRelativeFormatStyle(presentation: .numeric, locale: .enUS, calendar: calendar)

        func verifyStyle(_ dateValue: Foundation.TimeInterval, relativeTo: Foundation.TimeInterval, expected: String, file: StaticString = #filePath, line: UInt = #line) {
            let formatted = numeric.formatRel(.init(timeIntervalSinceReferenceDate: dateValue), refDate: .init(timeIntervalSinceReferenceDate: relativeTo))
            XCTAssertEqual(formatted, expected, file: file, line: line)
        }

        verifyStyle(645019200.0, relativeTo: 645019200.0, expected: "in 0 seconds") // 2021-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645019170.0, relativeTo: 645019200.0, expected: "30 seconds ago") // 2021-06-10 11:59:30 -> 2021-06-10 12:00:00
        verifyStyle(645019140.0, relativeTo: 645019200.0, expected: "1 minute ago") // 2021-06-10 11:59:00 -> 2021-06-10 12:00:00
        verifyStyle(645018600.0, relativeTo: 645019200.0, expected: "10 minutes ago") // 2021-06-10 11:50:00 -> 2021-06-10 12:00:00
        verifyStyle(645018570.0, relativeTo: 645019200.0, expected: "11 minutes ago") // 2021-06-10 11:49:30 -> 2021-06-10 12:00:00
        verifyStyle(645015600.0, relativeTo: 645019200.0, expected: "1 hour ago") // 2021-06-10 11:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645014400.0, relativeTo: 645019200.0, expected: "1 hour ago") // 2021-06-10 10:40:00 -> 2021-06-10 12:00:00
        verifyStyle(645013800.0, relativeTo: 645019200.0, expected: "2 hours ago") // 2021-06-10 10:30:00 -> 2021-06-10 12:00:00
        verifyStyle(645022800.0, relativeTo: 645019200.0, expected: "in 1 hour") // 2021-06-10 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645024000.0, relativeTo: 645019200.0, expected: "in 1 hour") // 2021-06-10 13:20:00 -> 2021-06-10 12:00:00
        verifyStyle(645024600.0, relativeTo: 645019200.0, expected: "in 2 hours") // 2021-06-10 13:30:00 -> 2021-06-10 12:00:00
        verifyStyle(645025800.0, relativeTo: 645019200.0, expected: "in 2 hours") // 2021-06-10 13:50:00 -> 2021-06-10 12:00:00
        verifyStyle(568771200.0, relativeTo: 645019200.0, expected: "2 years ago") // 2019-01-10 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(599529599.0, relativeTo: 645019200.0, expected: "2 years ago") // 2019-12-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(599529600.0, relativeTo: 645019200.0, expected: "1 year ago") // 2020-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(613483200.0, relativeTo: 645019200.0, expected: "1 year ago") // 2020-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(628948800.0, relativeTo: 645019200.0, expected: "6 months ago") // 2020-12-06 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(631152000.0, relativeTo: 645019200.0, expected: "5 months ago") // 2021-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(633830400.0, relativeTo: 645019200.0, expected: "4 months ago") // 2021-02-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(636249600.0, relativeTo: 645019200.0, expected: "3 months ago") // 2021-03-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(638928000.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(639748800.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(641519999.0, relativeTo: 645019200.0, expected: "2 months ago") // 2021-04-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(641520000.0, relativeTo: 645019200.0, expected: "1 month ago") // 2021-05-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644111999.0, relativeTo: 645019200.0, expected: "1 week ago") // 2021-05-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(644198400.0, relativeTo: 645019200.0, expected: "1 week ago") // 2021-06-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644630399.0, relativeTo: 645019200.0, expected: "5 days ago") // 2021-06-05 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(644630400.0, relativeTo: 645019200.0, expected: "4 days ago") // 2021-06-06 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644839200.0, relativeTo: 645019200.0, expected: "2 days ago") // 2021-06-08 10:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644850000.0, relativeTo: 645019200.0, expected: "2 days ago") // 2021-06-08 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644929200.0, relativeTo: 645019200.0, expected: "1 day ago") // 2021-06-09 11:00:00 -> 2021-06-10 12:00:00
        verifyStyle(644936400.0, relativeTo: 645019200.0, expected: "23 hours ago") // 2021-06-09 13:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645087600.0, relativeTo: 645019200.0, expected: "in 19 hours") // 2021-06-11 07:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645145259.0, relativeTo: 645019200.0, expected: "in 1 day") // 2021-06-11 23:00:59 -> 2021-06-10 12:00:00
        verifyStyle(645188459.0, relativeTo: 645019200.0, expected: "in 2 days") // 2021-06-12 11:00:59 -> 2021-06-10 12:00:00
        verifyStyle(645235199.0, relativeTo: 645019200.0, expected: "in 2 days") // 2021-06-12 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(645235200.0, relativeTo: 645019200.0, expected: "in 3 days") // 2021-06-13 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(645839999.0, relativeTo: 645019200.0, expected: "in 1 week") // 2021-06-19 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(645840000.0, relativeTo: 645019200.0, expected: "in 2 weeks") // 2021-06-20 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(646444799.0, relativeTo: 645019200.0, expected: "in 2 weeks") // 2021-06-26 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(646790399.0, relativeTo: 645019200.0, expected: "in 3 weeks") // 2021-06-30 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(646790400.0, relativeTo: 645019200.0, expected: "in 3 weeks") // 2021-07-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(649468799.0, relativeTo: 645019200.0, expected: "in 1 month") // 2021-07-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(649468800.0, relativeTo: 645019200.0, expected: "in 2 months") // 2021-08-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(652147199.0, relativeTo: 645019200.0, expected: "in 2 months") // 2021-08-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(662688000.0, relativeTo: 645019200.0, expected: "in 7 months") // 2022-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(676555200.0, relativeTo: 645019200.0, expected: "in 1 year") // 2022-06-10 12:00:00 -> 2021-06-10 12:00:00
        verifyStyle(694223999.0, relativeTo: 645019200.0, expected: "in 1 year") // 2022-12-31 23:59:59 -> 2021-06-10 12:00:00
        verifyStyle(694224000.0, relativeTo: 645019200.0, expected: "in 2 years") // 2023-01-01 00:00:00 -> 2021-06-10 12:00:00
        verifyStyle(725759999.0, relativeTo: 645019200.0, expected: "in 2 years") // 2023-12-31 23:59:59 -> 2021-06-10 12:00:00
    }
}

final class ParseStrategyMatchTests: XCTestCase {
    func testDate() throws {
        let regex = Regex {
            OneOrMore {
                Capture { _polyfill_DateISO8601FormatStyle() }
            }
        }
        let res = try XCTUnwrap("💁🏽🏳️‍🌈2021-07-01T15:56:32Z".firstMatch(of: regex))

        XCTAssertEqual(res.output.0, "2021-07-01T15:56:32Z")
        XCTAssertEqual(res.output.1, .init(timeIntervalSinceReferenceDate: 646847792.0))
    }

    func testAPIHTTPHeader() throws {
        let header = """
        HTTP/1.1 301 Redirect
        Date: Wed, 16 Feb 2022 23:53:19 GMT
        Connection: close
        Location: https://www.apple.com/
        Content-Type: text/html
        Content-Language: en
        """

        let regex = Regex {
            Capture {
                ._polyfill_date(format: "\(day: .twoDigits) \(month: .abbreviated) \(year: .padded(4))", locale: .enUS, timeZone: .gmt)
            }
        }
        let res = try XCTUnwrap(header.firstMatch(of: regex))

        XCTAssertEqual(res.output.0, "16 Feb 2022")
        XCTAssertEqual(res.output.1, .init(timeIntervalSinceReferenceDate: 666662400.0))
    }

    func testAPIStatement() {
        let statement = """
            CREDIT    04/06/2020    Paypal transfer        $4.99
            DSLIP    04/06/2020    REMOTE ONLINE DEPOSIT  $3,020.85
            CREDIT    04/03/2020    PAYROLL                $69.73
            DEBIT    04/02/2020    ACH TRNSFR             ($38.25)
            DEBIT    03/31/2020    Payment to BoA card    ($27.44)
            DEBIT    03/24/2020    IRX tax payment        ($52,249.98)
            """
        let expectedDateStrings: [Substring] = ["04/06/2020", "04/06/2020", "04/03/2020", "04/02/2020", "03/31/2020", "03/24/2020"]
        let expectedDates = [
            Foundation.Date(timeIntervalSinceReferenceDate: 607824000.0), // 2020-04-06 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607824000.0), // 2020-04-06 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607564800.0), // 2020-04-03 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607478400.0), // 2020-04-02 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607305600.0), // 2020-03-31 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 606700800.0), // 2020-03-24 00:00:00.000
        ]
        let expectedAmounts = [
            Foundation.Decimal(string:"4.99")!, Foundation.Decimal(string:"3020.85")!, Foundation.Decimal(string:"69.73")!,
            Foundation.Decimal(string:"-38.25")!, Foundation.Decimal(string:"-27.44")!, Foundation.Decimal(string:"-52249.98")!
        ]

        let regex = Regex {
            Capture {
                ._polyfill_localizedCurrency(code: "USD", locale: .enUS).sign(strategy: .accounting)
            }
        }

        let money = statement.matches(of: regex)
        XCTAssertEqual(money.map(\.output.0), ["$4.99", "$3,020.85", "$69.73", "($38.25)", "($27.44)", "($52,249.98)"])
        XCTAssertEqual(money.map(\.output.1), expectedAmounts)

        let dateRegex = Regex {
            Capture {
                ._polyfill_date(format: "\(month: .twoDigits)/\(day: .twoDigits)/\(year: .defaultDigits)", locale: .enUS, timeZone: .gmt)
            }
        }
        
        let dateMatches = statement.matches(of: dateRegex)
        XCTAssertEqual(dateMatches.map(\.output.0), expectedDateStrings)
        XCTAssertEqual(dateMatches.map(\.output.1), expectedDates)

        let dot = try! Regex(#"."#)
        let dateCurrencyRegex = Regex {
            Capture {
                ._polyfill_date(format: "\(month: .twoDigits)/\(day: .twoDigits)/\(year: .defaultDigits)", locale: .enUS, timeZone: .gmt)
            }
            "    "
            OneOrMore(dot)
            "  "
            Capture {
                ._polyfill_localizedCurrency(code: "USD", locale: .enUS).sign(strategy: .accounting)
            }
        }

        let matches = statement.matches(of: dateCurrencyRegex)
        XCTAssertEqual(matches.map(\.output.0), [
            "04/06/2020    Paypal transfer        $4.99",
            "04/06/2020    REMOTE ONLINE DEPOSIT  $3,020.85",
            "04/03/2020    PAYROLL                $69.73",
            "04/02/2020    ACH TRNSFR             ($38.25)",
            "03/31/2020    Payment to BoA card    ($27.44)",
            "03/24/2020    IRX tax payment        ($52,249.98)",
        ])
        XCTAssertEqual(matches.map(\.output.1), expectedDates)
        XCTAssertEqual(matches.map(\.output.2), expectedAmounts)

        let numericMatches = statement.matches(of: Regex {
            Capture(._polyfill_date(.numeric, locale: .enUS, timeZone: .gmt))
        })
        XCTAssertEqual(numericMatches.map(\.output.0), expectedDateStrings)
        XCTAssertEqual(numericMatches.map(\.output.1), expectedDates)
    }

    func testAPIStatements2() {
        // Test dates and numbers appearing in unexpeted places
        let statement = """
CREDIT   Apr 06/20    Zombie 5.29lb@$3.99/lb       USD 21.11
DSLIP    Apr 06/20    GMT gain                     USD 3,020.85
CREDIT   Apr 03/20    PAYROLL 03/29/20-04/02/20    USD 69.73
DEBIT    Apr 02/20    ACH TRNSFR Apr 02/20         -USD 38.25
DEBIT    Mar 31/20    March Payment to BoA         -USD 52,249.98
"""

        let dot = try! Regex(#"."#)
        let dateCurrencyRegex = Regex {
            Capture {
                ._polyfill_date(format:"\(month: .abbreviated) \(day: .twoDigits)/\(year: .twoDigits)", locale: .enUS, timeZone: .gmt)
            }
            "    "
            Capture(OneOrMore(dot))
            "  "
            Capture {
                ._polyfill_localizedCurrency(code: "USD", locale: .enUS).presentation(.isoCode)
            }
        }

        let expectedDates = [
            Foundation.Date(timeIntervalSinceReferenceDate: 607824000.0), // 2020-04-06 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607824000.0), // 2020-04-06 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607564800.0), // 2020-04-03 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607478400.0), // 2020-04-02 00:00:00.000
            Foundation.Date(timeIntervalSinceReferenceDate: 607305600.0), // 2020-03-31 00:00:00.000
        ]
        let expectedAmounts = [
            Foundation.Decimal(string:"21.11")!, Foundation.Decimal(string:"3020.85")!, Foundation.Decimal(string:"69.73")!,
            Foundation.Decimal(string:"-38.25")!, Foundation.Decimal(string:"-52249.98")!
        ]

        let matches = statement.matches(of: dateCurrencyRegex)
        XCTAssertEqual(matches.map(\.output.0), [
            "Apr 06/20    Zombie 5.29lb@$3.99/lb       USD 21.11",
            "Apr 06/20    GMT gain                     USD 3,020.85",
            "Apr 03/20    PAYROLL 03/29/20-04/02/20    USD 69.73",
            "Apr 02/20    ACH TRNSFR Apr 02/20         -USD 38.25",
            "Mar 31/20    March Payment to BoA         -USD 52,249.98",
        ])
        XCTAssertEqual(matches.map(\.output.1), expectedDates)
        XCTAssertEqual(matches.map(\.output.3), expectedAmounts)
    }

    func testAPITestSuites() throws {
        let input = "Test Suite 'MergeableSetTests' started at 2021-07-08 10:19:35.418"
        let testSuiteLog = Regex {
            "Test Suite '"
            Capture(OneOrMore(.any, .reluctant)) // name
            "' "
            TryCapture {
                ChoiceOf {    // status
                    "started"
                    "passed"
                    "failed"
                }
            } transform: {
                String($0)
            }
            " at "
            Capture(._polyfill_iso8601(timeZone: .gmt, includingFractionalSeconds: true, dateTimeSeparator: .space))
            Optionally(".")
        }

        let match = try XCTUnwrap(input.wholeMatch(of: testSuiteLog))

        XCTAssertEqual(match.output.0, "Test Suite 'MergeableSetTests' started at 2021-07-08 10:19:35.418")
        XCTAssertEqual(match.output.1, "MergeableSetTests")
        XCTAssertEqual(match.output.2, "started")
        XCTAssertEqual(match.output.3, .init(timeIntervalSinceReferenceDate: 647432375.418)) // 2021-07-08 10:19:35.418
    }

    func testVariousDatesAndTimes() throws {
        func verify(_ str: String, _ strategy: _polyfill_DateParseStrategy, _ expected: String?, file: StaticString = #filePath, line: UInt = #line) throws {
            let match = str.wholeMatch(of: strategy) // Regex<Date>.Match?
            if let expected {
                let match = try XCTUnwrap(match, "<\(str)> did not match, but it should", file: file, line: line)
                let expectedDate = try Foundation.Date(expected, _polyfill_strategy: .iso8601)
                XCTAssertEqual(match.0, expectedDate, file: file, line: line)
            } else {
                XCTAssertNil(match, "<\(str)> should not match, but it did", file: file, line: line)
            }
        }

        XCTAssertNoThrow(try verify("03/05/2020", ._polyfill_date(.numeric, locale: .enUS, timeZone: .gmt), "2020-03-05T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("03/05/2020", ._polyfill_date(.numeric, locale: .enGB, timeZone: .gmt), "2020-05-03T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("03/05/2020, 4:29:24\u{202f}PM", ._polyfill_dateTime(date: .numeric, time: .standard, locale: .enUS, timeZone: .pst), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("03/05/2020, 16:29:24", ._polyfill_dateTime(date: .numeric, time: .standard, locale: .enGB, timeZone: .gmt), "2020-05-03T16:29:24+00:00"))
        XCTAssertNoThrow(try verify("03/05/2020, 4:29:24 PM", ._polyfill_dateTime(date: .numeric, time: .standard, locale: .enGB, timeZone: .pst), nil))
        XCTAssertNoThrow(try verify("03/05/2020, 4:29:24\u{202f}PM PDT", ._polyfill_dateTime(date: .numeric, time: .complete, locale: .enUS, timeZone: .pst), "2020-03-05T16:29:24-07:00"))
        XCTAssertNoThrow(try verify("03/05/2020, 16:29:24 GMT-7", ._polyfill_dateTime(date: .numeric, time: .complete, locale: .enGB, timeZone: .gmt), "2020-05-03T16:29:24-07:00"))
        XCTAssertNoThrow(try verify("03_05_2020", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)_\(year: .defaultDigits)", locale: .enUS, timeZone: .gmt), "2020-03-05T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("03_05_89", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)", locale: .enUS, timeZone: .gmt), "1989-03-05T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("03_05_69", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)", locale: .enUS, timeZone: .gmt), "2069-03-05T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("03_05_89", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)", locale: .enUS, timeZone: .pst), "1989-03-05T00:00:00-08:00"))
        XCTAssertNoThrow(try verify("03_05", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)", locale: .enUS, timeZone: .pst), "1969-03-05T00:00:00-08:00"))
        XCTAssertNoThrow(try verify("03_05_69", ._polyfill_date(format: "\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)", locale: .enUS, timeZone: .pst), "1969-03-05T00:00:00-08:00"))
        XCTAssertNoThrow(try verify("03/05/2020", ._polyfill_date(.numeric, locale: .enUS, timeZone: .pst), "2020-03-05T08:00:00+00:00"))
        XCTAssertNoThrow(try verify("03/05/2020", ._polyfill_date(.numeric, locale: .enGB, timeZone: .pst), "2020-05-03T00:00:00-08:00"))
    }

    func testMatchISO8601String() throws {
        func verify(_ str: String, _ strategy: _polyfill_DateISO8601FormatStyle, _ expected: String?, file: StaticString = #filePath, line: UInt = #line) throws {
            let match = str.wholeMatch(of: strategy)
            if let expected {
                let match = try XCTUnwrap(match, "<\(str)> did not match, but it should", file: file, line: line)
                XCTAssertEqual(match.0, try .init(expected, _polyfill_strategy: .iso8601), file: file, line: line)
            } else {
                XCTAssertNil(match, "<\(str)> should not match, but it did", file: file, line: line)
            }
        }

        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601, "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24Z", ._polyfill_iso8601, "2020-03-05T16:29:24+00:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24", ._polyfill_iso8601(timeZone: .gmt), "2020-03-05T16:29:24+00:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24", ._polyfill_iso8601(timeZone: .pst), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601(timeZone: .gmt), nil))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24", ._polyfill_iso8601(timeZone: .pst), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24", ._polyfill_iso8601WithTimeZone(), nil))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601WithTimeZone(), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("20200305T16:29:24-08:00",   ._polyfill_iso8601WithTimeZone(dateSeparator: .omitted), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601WithTimeZone(dateSeparator: .omitted), nil))
        XCTAssertNoThrow(try verify("2020-03-05 16:29:24-08:00", ._polyfill_iso8601WithTimeZone(dateTimeSeparator: .space), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601WithTimeZone(dateTimeSeparator: .space), nil))
        XCTAssertNoThrow(try verify("2020-03-05 16:29:24-08:00", ._polyfill_iso8601WithTimeZone(dateTimeSeparator: .standard), nil))
        XCTAssertNoThrow(try verify("2020-03-05T162924-08:00",   ._polyfill_iso8601WithTimeZone(timeSeparator: .omitted), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601WithTimeZone(timeSeparator: .omitted), nil))
        XCTAssertNoThrow(try verify("2020-03-05T162924-08:00",   ._polyfill_iso8601WithTimeZone(timeSeparator: .colon), nil))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24-08:00", ._polyfill_iso8601WithTimeZone(timeZoneSeparator: .omitted), "2020-03-05T16:29:24-08:00"))
        XCTAssertNoThrow(try verify("2020-03-05",          ._polyfill_iso8601Date(timeZone: .gmt), "2020-03-05T00:00:00+00:00"))
        XCTAssertNoThrow(try verify("2020-03-05T16:29:24", ._polyfill_iso8601Date(timeZone: .pst), nil))
        XCTAssertNoThrow(try verify("2020-03-05", ._polyfill_iso8601Date(timeZone: .pst), "2020-03-05T00:00:00-08:00"))
    }
}
