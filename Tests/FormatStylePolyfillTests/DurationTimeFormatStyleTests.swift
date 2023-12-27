import FormatStylePolyfill
import XCTest

final class DurationTimeFormatStyleTests: XCTestCase {
    private static let enUS = Locale(identifier: "en_US")

    func assertFormattedWithPattern(
        seconds: Int, milliseconds: Int = 0, pattern: Swift.Duration._polyfill_TimeFormatStyle.Pattern, expected: String,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(
            Duration(seconds: Int64(seconds), milliseconds: Int64(milliseconds))._polyfill_formatted(.time(pattern: pattern).locale(Self.enUS)),
            expected,
            file: file, line: line
        )
    }

    func testDurationPatternStyle() {
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinute, expected: "1:02")
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinute(padHourToLength: 1, roundSeconds: .down), expected: "1:01")
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinuteSecond, expected: "1:01:35")
        assertFormattedWithPattern(seconds: 3695, milliseconds: 510, pattern: .hourMinuteSecond(padHourToLength: 1, roundFractionalSeconds: .up), expected: "1:01:36")
        assertFormattedWithPattern(seconds: 3695, pattern: .minuteSecond, expected: "61:35")
        assertFormattedWithPattern(seconds: 3695, pattern: .minuteSecond(padMinuteToLength: 2), expected: "61:35")
        assertFormattedWithPattern(seconds: 3695, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "61:35.00")
        assertFormattedWithPattern(seconds: 3695, milliseconds: 350, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "61:35.35")
    }

    func testDurationPatternPadding() {
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinute(padHourToLength: 2), expected: "01:02")
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinuteSecond(padHourToLength: 2), expected: "01:01:35")
        assertFormattedWithPattern(seconds: 3695, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:01:35.00")
        assertFormattedWithPattern(seconds: 3695, milliseconds: 500, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:01:35.50")
    }

    func testNoFractionParts() {
        assertFormattedWithPattern(seconds: 0, milliseconds: 499, pattern: .minuteSecond, expected: "0:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 500, pattern: .minuteSecond, expected: "0:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 501, pattern: .minuteSecond, expected: "0:01")
        assertFormattedWithPattern(seconds: 0, milliseconds: 999, pattern: .minuteSecond, expected: "0:01")
        assertFormattedWithPattern(seconds: 1, milliseconds: 005, pattern: .minuteSecond, expected: "0:01")
        assertFormattedWithPattern(seconds: 1, milliseconds: 499, pattern: .minuteSecond, expected: "0:01")
        assertFormattedWithPattern(seconds: 1, milliseconds: 501, pattern: .minuteSecond, expected: "0:02")
        assertFormattedWithPattern(seconds: 59, milliseconds: 499, pattern: .minuteSecond, expected: "0:59")
        assertFormattedWithPattern(seconds: 59, milliseconds: 500, pattern: .minuteSecond, expected: "1:00")
        assertFormattedWithPattern(seconds: 59, milliseconds: 501, pattern: .minuteSecond, expected: "1:00")
        assertFormattedWithPattern(seconds: 60, milliseconds: 499, pattern: .minuteSecond, expected: "1:00")
        assertFormattedWithPattern(seconds: 60, milliseconds: 500, pattern: .minuteSecond, expected: "1:00")
        assertFormattedWithPattern(seconds: 60, milliseconds: 501, pattern: .minuteSecond, expected: "1:01")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 490, pattern: .minuteSecond, expected: "16:59")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 500, pattern: .minuteSecond, expected: "17:00")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 510, pattern: .minuteSecond, expected: "17:00")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 490, pattern: .minuteSecond, expected: "60:29")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 500, pattern: .minuteSecond, expected: "60:30")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 510, pattern: .minuteSecond, expected: "60:30")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 490, pattern: .minuteSecond, expected: "60:59")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 500, pattern: .minuteSecond, expected: "61:00")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 510, pattern: .minuteSecond, expected: "61:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 499, pattern: .hourMinuteSecond, expected: "0:00:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 500, pattern: .hourMinuteSecond, expected: "0:00:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 501, pattern: .hourMinuteSecond, expected: "0:00:01")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 499, pattern: .hourMinuteSecond, expected: "0:59:59")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 500, pattern: .hourMinuteSecond, expected: "1:00:00")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 501, pattern: .hourMinuteSecond, expected: "1:00:00")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 499, pattern: .hourMinuteSecond, expected: "1:59:59")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 500, pattern: .hourMinuteSecond, expected: "2:00:00")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 501, pattern: .hourMinuteSecond, expected: "2:00:00")
        assertFormattedWithPattern(seconds: 3569, milliseconds: 499, pattern: .hourMinute, expected: "0:59")
        assertFormattedWithPattern(seconds: 3569, milliseconds: 500, pattern: .hourMinute, expected: "0:59") // 29.5 seconds is still less than half minutes, so it would be rounded down
        assertFormattedWithPattern(seconds: 3570, pattern: .hourMinute, expected: "1:00")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 400, pattern: .hourMinute, expected: "1:00")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 900, pattern: .hourMinute, expected: "1:00")
        assertFormattedWithPattern(seconds: 3630, milliseconds: 000, pattern: .hourMinute, expected: "1:00")
        assertFormattedWithPattern(seconds: 3630, milliseconds: 100, pattern: .hourMinute, expected: "1:01")
        assertFormattedWithPattern(seconds: 3630, milliseconds: 900, pattern: .hourMinute, expected: "1:01")
        assertFormattedWithPattern(seconds: 3631, milliseconds: 000, pattern: .hourMinute, expected: "1:01")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 400, pattern: .hourMinute, expected: "1:01")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 500, pattern: .hourMinute, expected: "1:01")
        assertFormattedWithPattern(seconds: 5369, milliseconds: 400, pattern: .hourMinute, expected: "1:29")
        assertFormattedWithPattern(seconds: 5369, milliseconds: 900, pattern: .hourMinute, expected: "1:29")
        assertFormattedWithPattern(seconds: 5370, milliseconds: 000, pattern: .hourMinute, expected: "1:30")
        assertFormattedWithPattern(seconds: 5370, milliseconds: 100, pattern: .hourMinute, expected: "1:30")
        assertFormattedWithPattern(seconds: 5399, milliseconds: 400, pattern: .hourMinute, expected: "1:30")
        assertFormattedWithPattern(seconds: 5399, milliseconds: 500, pattern: .hourMinute, expected: "1:30")
    }

    func testShowFractionalSeconds() {
        assertFormattedWithPattern(seconds: 0, milliseconds: 499, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:00.50")
        assertFormattedWithPattern(seconds: 0, milliseconds: 999, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:01.00")
        assertFormattedWithPattern(seconds: 1, milliseconds: 005, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:01.00")
        assertFormattedWithPattern(seconds: 1, milliseconds: 499, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:01.50")
        assertFormattedWithPattern(seconds: 1, milliseconds: 999, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:02.00")
        assertFormattedWithPattern(seconds: 59, milliseconds: 994, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "00:59.99")
        assertFormattedWithPattern(seconds: 59, milliseconds: 995, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "01:00.00")
        assertFormattedWithPattern(seconds: 59, milliseconds: 996, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "01:00.00")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 994, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "16:59.99")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 995, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "17:00.00")
        assertFormattedWithPattern(seconds: 1019, milliseconds: 996, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "17:00.00")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 994, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "60:29.99")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 995, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "60:30.00")
        assertFormattedWithPattern(seconds: 3629, milliseconds: 996, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "60:30.00")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 994, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "60:59.99")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 995, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "61:00.00")
        assertFormattedWithPattern(seconds: 3659, milliseconds: 996, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: "61:00.00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 499, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:00:00.50")
        assertFormattedWithPattern(seconds: 0, milliseconds: 994, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:00:00.99")
        assertFormattedWithPattern(seconds: 0, milliseconds: 995, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:00:01.00")
        assertFormattedWithPattern(seconds: 0, milliseconds: 996, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:00:01.00")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 499, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:59:59.50")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 994, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "00:59:59.99")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 995, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:00:00.00")
        assertFormattedWithPattern(seconds: 3599, milliseconds: 996, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:00:00.00")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 499, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:59:59.50")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 994, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "01:59:59.99")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 996, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "02:00:00.00")
        assertFormattedWithPattern(seconds: 7199, milliseconds: 995, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "02:00:00.00")
    }

    func testNegativeValues() {
        assertFormattedWithPattern(seconds: 0, milliseconds: -499, pattern: .hourMinuteSecond, expected: "0:00:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: -500, pattern: .hourMinuteSecond, expected: "0:00:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: -501, pattern: .hourMinuteSecond, expected: "-0:00:01")
        assertFormattedWithPattern(seconds: 0, milliseconds: -499, pattern: .minuteSecond, expected: "0:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: -500, pattern: .minuteSecond, expected: "0:00")
        assertFormattedWithPattern(seconds: 0, milliseconds: -501, pattern: .minuteSecond, expected: "-0:01")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -499, pattern: .hourMinuteSecond, expected: "-0:59:59")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -500, pattern: .hourMinuteSecond, expected: "-1:00:00")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -501, pattern: .hourMinuteSecond, expected: "-1:00:00")
        assertFormattedWithPattern(seconds: -3600 - 59 * 60 - 59, milliseconds: -499, pattern: .hourMinuteSecond, expected: "-1:59:59")
        assertFormattedWithPattern(seconds: -3600 - 59 * 60 - 59, milliseconds: -500, pattern: .hourMinuteSecond, expected: "-2:00:00")
        assertFormattedWithPattern(seconds: -3600 - 59 * 60 - 59, milliseconds: -501, pattern: .hourMinuteSecond, expected: "-2:00:00")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -499, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "-00:59:59.50")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -994, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "-00:59:59.99")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -995, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "-01:00:00.00")
        assertFormattedWithPattern(seconds: -59 * 60 - 59, milliseconds: -996, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: "-01:00:00.00")
    }
}

extension Sequence<DurationTimeAttributedStyleTests.Segment> {
    var attributedString: AttributedString {
        self.map { tuple in
            var attrs = AttributeContainer()
            if let field = tuple.1 { attrs = attrs.durationField(field) }
            return AttributedString(tuple.0, attributes: attrs)
        }.reduce(AttributedString(), +)
    }
}

final class DurationTimeAttributedStyleTests: XCTestCase {
    typealias Segment = (String, AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field?)
    let enUS = Locale(identifier: "en_US")

    func assertWithPattern(seconds: Int, milliseconds: Int = 0, pattern: Swift.Duration._polyfill_TimeFormatStyle.Pattern, expected: [Segment], locale: Locale = Locale(identifier: "en_US"), file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(Duration(seconds: Int64(seconds), milliseconds: Int64(milliseconds))._polyfill_formatted(.time(pattern: pattern).locale(locale).attributed), expected.attributedString, file: file, line: line)
    }

    func testAttributedStyle_enUS() {
        assertWithPattern(seconds: 3695, pattern: .hourMinute, expected: [("1", .hours), (":", nil), ("02", .minutes)])
        assertWithPattern(seconds: 3695, pattern: .hourMinute(padHourToLength: 1, roundSeconds: .down), expected: [("1", .hours), (":", nil), ("01", .minutes)])
        assertWithPattern(seconds: 3695, pattern: .hourMinuteSecond, expected: [("1", .hours), (":", nil), ("01", .minutes), (":", nil), ("35", .seconds)])
        assertWithPattern(seconds: 3695, milliseconds: 500, pattern: .hourMinuteSecond(padHourToLength: 1, roundFractionalSeconds: .up), expected: [("1", .hours), (":", nil), ("01", .minutes), (":", nil), ("36", .seconds)])
        assertWithPattern(seconds: 3695, pattern: .minuteSecond, expected: [("61", .minutes), (":", nil), ("35", .seconds)])
        assertWithPattern(seconds: 3695, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: [("61", .minutes), (":", nil), ("35.00", .seconds)])
        assertWithPattern(seconds: 3695, milliseconds: 350, pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2), expected: [("61", .minutes), (":", nil), ("35.35", .seconds)])
        assertWithPattern(seconds: 3695, pattern: .hourMinute(padHourToLength: 2), expected: [("01", .hours), (":", nil), ("02", .minutes)])
        assertWithPattern(seconds: 3695, pattern: .hourMinuteSecond(padHourToLength: 2), expected: [("01", .hours), (":", nil), ("01", .minutes), (":", nil), ("35", .seconds)])
        assertWithPattern(seconds: 3695, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: [("01", .hours), (":", nil), ("01", .minutes), (":", nil), ("35.00", .seconds)])
        assertWithPattern(seconds: 3695, milliseconds: 500, pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 2), expected: [("01", .hours), (":", nil), ("01", .minutes), (":", nil), ("35.50", .seconds)])
    }
}

