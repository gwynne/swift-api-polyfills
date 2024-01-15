import FormatStylePolyfill
import XCTest

let week = 604800
let day = 86400
let hour = 3600
let minute = 60

extension Duration {
    init(weeks: Int64 = 0, days: Int64 = 0, hours: Int64 = 0, minutes: Int64 = 0, seconds: Int64 = 0, milliseconds: Int64 = 0, microseconds: Int64 = 0) {
        self = .init(secondsComponent: Int64(weeks * 604800 + days * 86400 + hours * 3600 + minutes * 60 + seconds),
                     attosecondsComponent: Int64(milliseconds * 1_000_000_000_000_000 + microseconds * 1_000_000_000_000))
    }
}

final class DurationUnitsFormatStyleTests : XCTestCase {
    let enUS = Locale(identifier: "en_US")

    func testDurationUnitsFormatStyleAPI() {
        let d1 = Duration.seconds(2 * 3600 + 43 * 60 + 24) // 2hr 43min 24s
        let d2 = Duration.seconds(43 * 60 + 24) // 43min 24s
        let d3 = Duration(seconds: 24, milliseconds: 490)
        let d4 = Duration.seconds(43 * 60 + 5) // 43min 5s
        let d0 = Duration.seconds(0)
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS)), "2 hours, 43 minutes, 24 seconds")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS)), "43 minutes, 24 seconds")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS)), "24 seconds")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS)), "0 seconds")
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS)), "2 hours, 43 minutes, 24 seconds")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS)), "0 hours, 43 minutes, 24 seconds")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS)), "0 hours, 0 minutes, 24 seconds")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS)), "0 hours, 0 minutes, 0 seconds")
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1).locale(enUS)), "3 hr")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1).locale(enUS)), "43 min")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1).locale(enUS)), "24 sec")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1).locale(enUS)), "0 sec")
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).locale(enUS)), "2.72 hr")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).locale(enUS)), "43.40 min")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).locale(enUS)), "24.49 sec")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).locale(enUS)), "0.00 sec")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 2)).locale(enUS)), "00 hours, 43 minutes, 24 seconds")
        XCTAssertEqual(d4._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 2)).locale(enUS)), "00 hours, 43 minutes, 05 seconds")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 2)).locale(enUS)), "00 hours, 00 minutes, 00 seconds")
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2).locale(enUS)), "02 hours, 43 minutes, 24 seconds")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2).locale(enUS)), "43 minutes, 24 seconds")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2).locale(enUS)), "24 seconds")
        XCTAssertEqual(d4._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2).locale(enUS)), "43 minutes, 05 seconds")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2).locale(enUS)), "00 seconds")
        XCTAssertEqual(d1._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "02 hours, 43 minutes, 24.00 seconds")
        XCTAssertEqual(d2._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "43 minutes, 24.00 seconds")
        XCTAssertEqual(d3._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "24.49 seconds")
        XCTAssertEqual(d4._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "43 minutes, 05.00 seconds")
        XCTAssertEqual(d0._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "00.00 seconds")
        XCTAssertEqual(Duration(minutes: 43, seconds: 24, milliseconds: 490)._polyfill_formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, valueLength: 2, fractionalPart: .show(length: 2)).locale(enUS)), "43 minutes, 24.49 seconds")
    }

    func verify(
        seconds: Int, milliseconds: Int,
        allowedUnits: Set<_polyfill_DurationUnitsFormatStyle.Unit>,
        fractionalSecondsLength: Int = 0,
        rounding: FloatingPointRoundingRule = .toNearestOrEven,
        increment: Double? = nil,
        expected: String,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let d = Duration(seconds: Int64(seconds), milliseconds: Int64(milliseconds))
        XCTAssertEqual(d._polyfill_formatted(.units(
            allowed: allowedUnits,
            zeroValueUnits: .show(length: 1),
            fractionalPart: .show(length: fractionalSecondsLength, rounded: rounding, increment: increment)
        ).locale(self.enUS)), expected, file: file, line: line)
    }

    func testNoFractionParts() {
        verify(seconds: 0, milliseconds: 499,  allowedUnits: [.minutes, .seconds], expected: "0 min, 0 sec")
        verify(seconds: 0, milliseconds: 500,  allowedUnits: [.minutes, .seconds], expected: "0 min, 0 sec")
        verify(seconds: 0, milliseconds: 501,  allowedUnits: [.minutes, .seconds], expected: "0 min, 1 sec")
        verify(seconds: 0, milliseconds: 999,  allowedUnits: [.minutes, .seconds], expected: "0 min, 1 sec")
        verify(seconds: 1, milliseconds: 005,  allowedUnits: [.minutes, .seconds], expected: "0 min, 1 sec")
        verify(seconds: 1, milliseconds: 499,  allowedUnits: [.minutes, .seconds], expected: "0 min, 1 sec")
        verify(seconds: 1, milliseconds: 501,  allowedUnits: [.minutes, .seconds], expected: "0 min, 2 sec")
        verify(seconds: 59, milliseconds: 499, allowedUnits: [.minutes, .seconds], expected: "0 min, 59 sec")
        verify(seconds: 59, milliseconds: 500, allowedUnits: [.minutes, .seconds], expected: "1 min, 0 sec")
        verify(seconds: 59, milliseconds: 501, allowedUnits: [.minutes, .seconds], expected: "1 min, 0 sec")
        verify(seconds: 60, milliseconds: 499, allowedUnits: [.minutes, .seconds], expected: "1 min, 0 sec")
        verify(seconds: 60, milliseconds: 500, allowedUnits: [.minutes, .seconds], expected: "1 min, 0 sec")
        verify(seconds: 60, milliseconds: 501, allowedUnits: [.minutes, .seconds], expected: "1 min, 1 sec")
        verify(seconds: 1019, milliseconds: 490, allowedUnits: [.minutes, .seconds], expected: "16 min, 59 sec")
        verify(seconds: 1019, milliseconds: 500, allowedUnits: [.minutes, .seconds], expected: "17 min, 0 sec")
        verify(seconds: 1019, milliseconds: 510, allowedUnits: [.minutes, .seconds], expected: "17 min, 0 sec")
        verify(seconds: 3629, milliseconds: 490, allowedUnits: [.minutes, .seconds], expected: "60 min, 29 sec")
        verify(seconds: 3629, milliseconds: 500, allowedUnits: [.minutes, .seconds], expected: "60 min, 30 sec")
        verify(seconds: 3629, milliseconds: 510, allowedUnits: [.minutes, .seconds], expected: "60 min, 30 sec")
        verify(seconds: 3659, milliseconds: 490, allowedUnits: [.minutes, .seconds], expected: "60 min, 59 sec")
        verify(seconds: 3659, milliseconds: 500, allowedUnits: [.minutes, .seconds], expected: "61 min, 0 sec")
        verify(seconds: 3659, milliseconds: 510, allowedUnits: [.minutes, .seconds], expected: "61 min, 0 sec")
        verify(seconds: 0, milliseconds: 499,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 0 sec")
        verify(seconds: 0, milliseconds: 500,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 0 sec")
        verify(seconds: 0, milliseconds: 501,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 1 sec")
        verify(seconds: 0, milliseconds: 999,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 1 sec")
        verify(seconds: 1, milliseconds: 005,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 1 sec")
        verify(seconds: 1, milliseconds: 499,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 1 sec")
        verify(seconds: 1, milliseconds: 501,  allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 2 sec")
        verify(seconds: 59, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 59 sec")
        verify(seconds: 59, milliseconds: 500, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 1 min, 0 sec")
        verify(seconds: 59, milliseconds: 501, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 1 min, 0 sec")
        verify(seconds: 1019, milliseconds: 490, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 16 min, 59 sec")
        verify(seconds: 1019, milliseconds: 500, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 17 min, 0 sec")
        verify(seconds: 1019, milliseconds: 510, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 17 min, 0 sec")
        verify(seconds: 3629, milliseconds: 490, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 0 min, 29 sec")
        verify(seconds: 3629, milliseconds: 500, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 0 min, 30 sec")
        verify(seconds: 3629, milliseconds: 510, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 0 min, 30 sec")
        verify(seconds: 3659, milliseconds: 490, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 0 min, 59 sec")
        verify(seconds: 3659, milliseconds: 500, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 1 min, 0 sec")
        verify(seconds: 3659, milliseconds: 510, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 1 min, 0 sec")
        verify(seconds: 7199, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], expected: "1 hr, 59 min, 59 sec")
        verify(seconds: 7199, milliseconds: 500, allowedUnits: [.hours, .minutes, .seconds], expected: "2 hr, 0 min, 0 sec")
        verify(seconds: 7199, milliseconds: 501, allowedUnits: [.hours, .minutes, .seconds], expected: "2 hr, 0 min, 0 sec")
        verify(seconds: 3569, milliseconds: 499, allowedUnits: [.hours, .minutes], expected: "0 hr, 59 min")
        verify(seconds: 3569, milliseconds: 500, allowedUnits: [.hours, .minutes], expected: "0 hr, 59 min") // 29.5 seconds is still less than half minutes, so it would be rounded down
        verify(seconds: 3570, milliseconds: 0,  allowedUnits: [.hours, .minutes], expected: "1 hr, 0 min")
        verify(seconds: 3629, milliseconds: 400, allowedUnits: [.hours, .minutes], expected: "1 hr, 0 min")
        verify(seconds: 3629, milliseconds: 900, allowedUnits: [.hours, .minutes], expected: "1 hr, 0 min")
        verify(seconds: 3630, milliseconds: 000, allowedUnits: [.hours, .minutes], expected: "1 hr, 0 min")
        verify(seconds: 3630, milliseconds: 100, allowedUnits: [.hours, .minutes], expected: "1 hr, 1 min")
        verify(seconds: 3630, milliseconds: 900, allowedUnits: [.hours, .minutes], expected: "1 hr, 1 min")
        verify(seconds: 3631, milliseconds: 000, allowedUnits: [.hours, .minutes], expected: "1 hr, 1 min")
        verify(seconds: 3659, milliseconds: 400, allowedUnits: [.hours, .minutes], expected: "1 hr, 1 min")
        verify(seconds: 3659, milliseconds: 500, allowedUnits: [.hours, .minutes], expected: "1 hr, 1 min")
        verify(seconds: 5369, milliseconds: 400, allowedUnits: [.hours, .minutes], expected: "1 hr, 29 min")
        verify(seconds: 5369, milliseconds: 900, allowedUnits: [.hours, .minutes], expected: "1 hr, 29 min")
        verify(seconds: 5370, milliseconds: 000, allowedUnits: [.hours, .minutes], expected: "1 hr, 30 min")
        verify(seconds: 5370, milliseconds: 100, allowedUnits: [.hours, .minutes], expected: "1 hr, 30 min")
        verify(seconds: 5399, milliseconds: 400, allowedUnits: [.hours, .minutes], expected: "1 hr, 30 min")
        verify(seconds: 5399, milliseconds: 500, allowedUnits: [.hours, .minutes], expected: "1 hr, 30 min")
    }

    func testShowFractionParts() {
        verify(seconds: 0, milliseconds: 499,  allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 0.50 sec")
        verify(seconds: 0, milliseconds: 999,  allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 1.00 sec")
        verify(seconds: 1, milliseconds: 005,  allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 1.00 sec")
        verify(seconds: 1, milliseconds: 499,  allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 1.50 sec")
        verify(seconds: 1, milliseconds: 999,  allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 2.00 sec")
        verify(seconds: 59, milliseconds: 994, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "0 min, 59.99 sec")
        verify(seconds: 59, milliseconds: 995, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "1 min, 0.00 sec")
        verify(seconds: 59, milliseconds: 996, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "1 min, 0.00 sec")
        verify(seconds: 1019, milliseconds: 994, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "16 min, 59.99 sec")
        verify(seconds: 1019, milliseconds: 995, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "17 min, 0.00 sec")
        verify(seconds: 1019, milliseconds: 996, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "17 min, 0.00 sec")
        verify(seconds: 3629, milliseconds: 994, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "60 min, 29.99 sec")
        verify(seconds: 3629, milliseconds: 995, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "60 min, 30.00 sec")
        verify(seconds: 3629, milliseconds: 996, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "60 min, 30.00 sec")
        verify(seconds: 3659, milliseconds: 994, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "60 min, 59.99 sec")
        verify(seconds: 3659, milliseconds: 995, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "61 min, 0.00 sec")
        verify(seconds: 3659, milliseconds: 996, allowedUnits: [.minutes, .seconds], fractionalSecondsLength: 2, expected: "61 min, 0.00 sec")
        verify(seconds: 0, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 0 min, 0.50 sec")
        verify(seconds: 0, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 0 min, 0.99 sec")
        verify(seconds: 0, milliseconds: 995, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 0 min, 1.00 sec")
        verify(seconds: 0, milliseconds: 996, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 0 min, 1.00 sec")
        verify(seconds: 3599, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 59 min, 59.50 sec")
        verify(seconds: 3599, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "0 hr, 59 min, 59.99 sec")
        verify(seconds: 3599, milliseconds: 995, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "1 hr, 0 min, 0.00 sec")
        verify(seconds: 3599, milliseconds: 996, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "1 hr, 0 min, 0.00 sec")
        verify(seconds: 3599, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .down, expected: "0 hr, 59 min, 59.49 sec")
        verify(seconds: 3599, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .up,   expected: "0 hr, 59 min, 59.50 sec")
        verify(seconds: 3599, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .down, increment: 1, expected: "0 hr, 59 min, 59.00 sec")
        verify(seconds: 3599, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .up,   increment: 1, expected: "1 hr, 0 min, 0.00 sec")
        verify(seconds: 3599, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .down,  expected: "0 hr, 59 min, 59.99 sec")
        verify(seconds: 3599, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .up,    expected: "1 hr, 0 min, 0.00 sec")
        verify(seconds: 3599, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .down,  increment: 1, expected: "0 hr, 59 min, 59.00 sec")
        verify(seconds: 3599, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, rounding: .up,    increment: 1, expected: "1 hr, 0 min, 0.00 sec")
        verify(seconds: 7199, milliseconds: 499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "1 hr, 59 min, 59.50 sec")
        verify(seconds: 7199, milliseconds: 994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "1 hr, 59 min, 59.99 sec")
        verify(seconds: 7199, milliseconds: 996, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "2 hr, 0 min, 0.00 sec")
        verify(seconds: 7199, milliseconds: 995, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "2 hr, 0 min, 0.00 sec")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, expected: "0 hr, 59.99 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 0.000001, expected: "0 hr, 59.99 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 0.000001, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 0.01, expected: "0 hr, 59.99 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 0.01, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 0.1, expected: "0 hr, 59.90 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 0.1, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "0 hr, 59.50 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 0.8, expected: "0 hr, 59.20 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 0.8, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, increment: 1.0, expected: "0 hr, 59.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 499, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   increment: 1.0, expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 994, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, expected: "0 hr, 59.99 min")
        verify(seconds: minute * 59 + 59, milliseconds: 994, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   expected: "1 hr, 0.00 min")
        verify(seconds: minute * 59 + 59, milliseconds: 995, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .down, expected: "0 hr, 59.99 min")
        verify(seconds: minute * 59 + 59, milliseconds: 995, allowedUnits: [.hours, .minutes], fractionalSecondsLength: 2, rounding: .up,   expected: "1 hr, 0.00 min")
        let w3_d5_h4_m59 = week * 3 + day * 5 + hour * 4 + minute * 59
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .up,   expected: "3.75 wks")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .down, expected: "3.74 wks")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "4.00 wks")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3.50 wks")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   expected: "3 wks, 5.21 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, expected: "3 wks, 5.20 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "3 wks, 5.50 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3 wks, 5.00 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   increment: 1, expected: "3 wks, 6.00 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, increment: 1, expected: "3 wks, 5.00 days")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .up,   expected: "3 wks, 5 days, 4.99 hr")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .down, expected: "3 wks, 5 days, 4.98 hr")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "3 wks, 5 days, 5.00 hr")
        verify(seconds: w3_d5_h4_m59, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3 wks, 5 days, 4.50 hr")
        let w3_d6_h23_m59_s30 = week * 3 + day * 6 + hour * 23 + minute * 59 + 30
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .up,   expected: "4.00 wks")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .down, expected: "3.99 wks")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "4.00 wks")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3.50 wks")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   expected: "4 wks, 0.00 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, expected: "3 wks, 6.99 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "4 wks, 0.00 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3 wks, 6.50 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .up,   increment: 1, expected: "4 wks, 0.00 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days ], fractionalSecondsLength: 2, rounding: .down, increment: 1, expected: "3 wks, 6.00 days")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .up,   expected: "4 wks, 0 days, 0.00 hr")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .down, expected: "3 wks, 6 days, 23.99 hr")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .up,   increment: 0.5, expected: "4 wks, 0 days, 0.00 hr")
        verify(seconds: w3_d6_h23_m59_s30, milliseconds: 0, allowedUnits: [ .weeks, .days, .hours ], fractionalSecondsLength: 2, rounding: .down, increment: 0.5, expected: "3 wks, 6 days, 23.50 hr")
    }

    func testDurationUnitsFormatStyleAPI_largerThanDay() {
        var duration: Duration!
        let allowedUnits: Set<_polyfill_DurationUnitsFormatStyle.Unit> = [.weeks, .days, .hours]
        func assertZeroValueUnit(
            _ zeroFormat: _polyfill_DurationUnitsFormatStyle.ZeroValueUnitsDisplayStrategy, _ expected: String,
            file: StaticString = #filePath, line: UInt = #line
        ) {
            XCTAssertEqual(duration._polyfill_formatted(.units(allowed: allowedUnits, width: .wide, zeroValueUnits: zeroFormat).locale(self.enUS)), expected, file: file, line: line)
        }
        func assertMaxUnitCount(
            _ maxUnitCount: Int, fractionalPart: _polyfill_DurationUnitsFormatStyle.FractionalPartDisplayStrategy, _ expected: String,
            file: StaticString = #filePath, line: UInt = #line
        ) {
            XCTAssertEqual(duration._polyfill_formatted(.units(
                allowed: allowedUnits, width: .wide, maximumUnitCount: maxUnitCount, fractionalPart: fractionalPart).locale(self.enUS)
            ), expected, file: file, line: line)
        }
        duration = Duration.seconds(26 * 86400 + 4 * 3600) // 3wk, 5day, 4hr
        assertZeroValueUnit(.hide, "3 weeks, 5 days, 4 hours")
        assertZeroValueUnit(.show(length: 2), "03 weeks, 05 days, 04 hours")
        assertMaxUnitCount(1, fractionalPart: .hide, "4 weeks")
        assertMaxUnitCount(1, fractionalPart: .show(length: 2), "3.74 weeks")
        assertMaxUnitCount(1, fractionalPart: .show(length: 2, rounded: .towardZero), "3.73 weeks")
        assertMaxUnitCount(1, fractionalPart: .show(length: 2, increment: 0.5), "3.50 weeks")
        assertMaxUnitCount(2, fractionalPart: .hide, "3 weeks, 5 days")
        assertMaxUnitCount(2, fractionalPart: .show(length: 2, rounded: .towardZero), "3 weeks, 5.16 days")
        duration = Duration.seconds(21 * 86400 + 13 * 3600) // 3wk, 0day, 13hr
        assertZeroValueUnit(.hide, "3 weeks, 13 hours")
        assertZeroValueUnit(.show(length: 2), "03 weeks, 00 days, 13 hours")
        assertMaxUnitCount(1, fractionalPart: .hide, "3 weeks")
        assertMaxUnitCount(1, fractionalPart: .show(length: 2), "3.08 weeks")
        assertMaxUnitCount(2, fractionalPart: .hide, "3 weeks, 13 hours")
        duration = Duration.seconds(13 * 3600 + 20 * 60) // 13hr 20 min
        assertZeroValueUnit(.hide, "13 hours")
        assertZeroValueUnit(.show(length: 2), "00 weeks, 00 days, 13 hours")
        assertMaxUnitCount(1, fractionalPart: .hide, "13 hours")
        assertMaxUnitCount(1, fractionalPart: .show(length: 2), "13.33 hours")
    }

    func testZeroValueUnits() {
        var duration: Duration
        var allowedUnits: Set<_polyfill_DurationUnitsFormatStyle.Unit>
        func test(
            _ zeroFormat: _polyfill_DurationUnitsFormatStyle.ZeroValueUnitsDisplayStrategy, _ expected: String,
            file: StaticString = #filePath, line: UInt = #line
        ) {
            XCTAssertEqual(duration._polyfill_formatted(.units(allowed: allowedUnits, width: .wide, zeroValueUnits: zeroFormat).locale(enUS)), expected, file: file, line: line)
        }
        duration = Duration.milliseconds(999)
        allowedUnits =  [.seconds, .milliseconds]
        test(.hide, "999 milliseconds")
        test(.show(length: 0), "999 milliseconds")
        test(.show(length: 1), "0 seconds, 999 milliseconds")
        test(.show(length: 2), "00 seconds, 999 milliseconds")
        test(.show(length: 3), "000 seconds, 999 milliseconds")
        test(.show(length: 4), "0,000 seconds, 0,999 milliseconds")
        test(.show(length: -1), "999 milliseconds") // negative value is treated as `hide`
        allowedUnits =  [.seconds, .milliseconds, .microseconds]
        test(.hide, "999 milliseconds")
        test(.show(length: 0), "999 milliseconds")
        test(.show(length: 1), "0 seconds, 999 milliseconds, 0 microseconds")
        test(.show(length: 2), "00 seconds, 999 milliseconds, 00 microseconds")
        test(.show(length: 3), "000 seconds, 999 milliseconds, 000 microseconds")
        test(.show(length: 4), "0,000 seconds, 0,999 milliseconds, 0,000 microseconds")
        allowedUnits =  [.minutes, .seconds]
        test(.hide, "1 second")
        test(.show(length: 0), "1 second")
        test(.show(length: 1), "0 minutes, 1 second")
        test(.show(length: 2), "00 minutes, 01 second")
        test(.show(length: 3), "000 minutes, 001 second")
        test(.show(length: 4), "0,000 minutes, 0,001 second")
        duration = Duration.nanoseconds(999)
        allowedUnits =  [.seconds, .milliseconds ]
        test(.hide, "0 milliseconds")
        test(.show(length: 0), "0 milliseconds")
        test(.show(length: 1), "0 seconds, 0 milliseconds")
        test(.show(length: 2), "00 seconds, 00 milliseconds")
        test(.show(length: 3), "000 seconds, 000 milliseconds")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds")
        allowedUnits =  [.seconds, .milliseconds, .microseconds ]
        test(.hide, "1 microsecond")
        test(.show(length: 0), "1 microsecond")
        test(.show(length: 1), "0 seconds, 0 milliseconds, 1 microsecond")
        test(.show(length: 2), "00 seconds, 00 milliseconds, 01 microsecond")
        test(.show(length: 3), "000 seconds, 000 milliseconds, 001 microsecond")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds, 0,001 microsecond")
        allowedUnits =  [.seconds, .milliseconds, .microseconds, .nanoseconds ]
        test(.hide, "999 nanoseconds")
        test(.show(length: 0), "999 nanoseconds")
        test(.show(length: 1), "0 seconds, 0 milliseconds, 0 microseconds, 999 nanoseconds")
        test(.show(length: 2), "00 seconds, 00 milliseconds, 00 microseconds, 999 nanoseconds")
        test(.show(length: 3), "000 seconds, 000 milliseconds, 000 microseconds, 999 nanoseconds")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds, 0,000 microseconds, 0,999 nanoseconds")
        duration = Duration.microseconds(99) + Duration.nanoseconds(999)
        allowedUnits =  [.seconds, .milliseconds ]
        test(.hide, "0 milliseconds")
        test(.show(length: 0), "0 milliseconds")
        test(.show(length: 1), "0 seconds, 0 milliseconds")
        test(.show(length: 2), "00 seconds, 00 milliseconds")
        test(.show(length: 3), "000 seconds, 000 milliseconds")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds")
        allowedUnits =  [.seconds, .milliseconds, .microseconds ]
        test(.hide, "100 microseconds")
        test(.show(length: 0), "100 microseconds")
        test(.show(length: 1), "0 seconds, 0 milliseconds, 100 microseconds")
        test(.show(length: 2), "00 seconds, 00 milliseconds, 100 microseconds")
        test(.show(length: 3), "000 seconds, 000 milliseconds, 100 microseconds")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds, 0,100 microseconds")
        allowedUnits =  [.seconds, .milliseconds, .microseconds, .nanoseconds ]
        test(.hide, "99 microseconds, 999 nanoseconds")
        test(.show(length: 0), "99 microseconds, 999 nanoseconds")
        test(.show(length: 1), "0 seconds, 0 milliseconds, 99 microseconds, 999 nanoseconds")
        test(.show(length: 2), "00 seconds, 00 milliseconds, 99 microseconds, 999 nanoseconds")
        test(.show(length: 3), "000 seconds, 000 milliseconds, 099 microseconds, 999 nanoseconds")
        test(.show(length: 4), "0,000 seconds, 0,000 milliseconds, 0,099 microseconds, 0,999 nanoseconds")
    }

    func testLengthRangeExpression() {
        var duration: Duration
        var allowedUnits: Set<_polyfill_DurationUnitsFormatStyle.Unit>
        func verify(intLimits: some RangeExpression<Int>, fracLimits: some RangeExpression<Int>, _ expected: String, file: StaticString = #filePath, line: UInt = #line) {
            let style = _polyfill_DurationUnitsFormatStyle(allowedUnits: allowedUnits, width: .abbreviated, valueLengthLimits: intLimits, fractionalPart: .init(lengthLimits: fracLimits)).locale(self.enUS)
            let formatted = style.format(duration)
            XCTAssertEqual(formatted, expected, file: file, line: line)
        }
        let oneThousandWithMaxPadding = "000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,001,000"
        let padding996 = "000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000"
        let maxFractionalTrailing = String(repeating: "0", count: 998)
        let trailing979 = String(repeating: "0", count: 979)
        let trailing983 = String(repeating: "0", count: 983)
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min...,   fracLimits: Int.min...Int.min, "0 wks")
        verify(intLimits: 5...,         fracLimits: Int.min...Int.min, "00,000 wks")
        verify(intLimits: Int.max...,   fracLimits: Int.min...Int.min, "\(padding996),000 wks")
        verify(intLimits: Int.min...,   fracLimits: 5...5, ".00165 wks")
        verify(intLimits: 5...,         fracLimits: 5...5, "00,000.00165 wks")
        verify(intLimits: Int.max...,   fracLimits: 5...5, "\(padding996),000.00165 wks")
        verify(intLimits: Int.min...,   fracLimits: Int.max...Int.max, ".0016534391534391533\(trailing979) wks")
        verify(intLimits: 5...,         fracLimits: Int.max...Int.max, "00,000.0016534391534391533\(trailing979) wks")
        verify(intLimits: Int.max...,   fracLimits: Int.max...Int.max, "\(padding996),000.0016534391534391533\(trailing979) wks")
        allowedUnits = [.minutes]
        verify(intLimits: Int.min...,   fracLimits: Int.min...Int.min, "17 min")
        verify(intLimits: 5...,         fracLimits: Int.min...Int.min, "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: Int.min...Int.min, "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: 5...5, "16.66667 min")
        verify(intLimits: 5...,         fracLimits: 5...5, "00,016.66667 min")
        verify(intLimits: Int.max...,   fracLimits: 5...5, "\(padding996),016.66667 min")
        verify(intLimits: Int.min...,   fracLimits: Int.max...Int.max, "16.666666666666668\(trailing983) min")
        verify(intLimits: 5...,         fracLimits: Int.max...Int.max, "00,016.666666666666668\(trailing983) min")
        verify(intLimits: Int.max...,   fracLimits: Int.max...Int.max, "\(padding996),016.666666666666668\(trailing983) min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min...,   fracLimits: Int.min...Int.min, "1,000 sec")
        verify(intLimits: 5...,         fracLimits: Int.min...Int.min, "01,000 sec")
        verify(intLimits: Int.max...,   fracLimits: Int.min...Int.min, "\(oneThousandWithMaxPadding) sec")
        verify(intLimits: Int.min...,   fracLimits: 5...5, "1,000.00000 sec")
        verify(intLimits: 5...,         fracLimits: 5...5, "01,000.00000 sec")
        verify(intLimits: Int.max...,   fracLimits: 5...5, "\(oneThousandWithMaxPadding).00000 sec")
        verify(intLimits: Int.min...,   fracLimits: Int.max...Int.max, "1,000.\(maxFractionalTrailing) sec")
        verify(intLimits: 5...,         fracLimits: Int.max...Int.max, "01,000.\(maxFractionalTrailing) sec")
        verify(intLimits: Int.max...,   fracLimits: Int.max...Int.max, "\(oneThousandWithMaxPadding).\(maxFractionalTrailing) sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min...,   fracLimits: Int.min...,   ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: Int.min...,   "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: Int.min...,   "\(padding996),000.0016534391534391533 wks")
        verify(intLimits: Int.min...,   fracLimits: 2...,   ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: 2...,   "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: 2...,   "\(padding996),000.0016534391534391533 wks")
        verify(intLimits: Int.min...,   fracLimits: Int.max...,   ".0016534391534391533\(trailing979) wks")
        verify(intLimits: 5...,         fracLimits: Int.max...,   "00,000.0016534391534391533\(trailing979) wks")
        verify(intLimits: Int.max...,   fracLimits: Int.max...,   "\(padding996),000.0016534391534391533\(trailing979) wks")
        allowedUnits = [.minutes] // 1000 sec ~= 16.666666666666 mins
        verify(intLimits: Int.min...,   fracLimits: Int.min...,   "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: Int.min...,   "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: Int.min...,   "\(padding996),016.666666666666668 min")
        verify(intLimits: Int.min...,   fracLimits: 2...,   "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: 2...,   "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: 2...,   "\(padding996),016.666666666666668 min")
        verify(intLimits: Int.min...,   fracLimits: Int.max...,   "16.666666666666668\(trailing983) min")
        verify(intLimits: 5...,         fracLimits: Int.max...,   "00,016.666666666666668\(trailing983) min")
        verify(intLimits: Int.max...,   fracLimits: Int.max...,   "\(padding996),016.666666666666668\(trailing983) min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min...,   fracLimits: Int.min...,   "1,000 sec")
        verify(intLimits: 5...,         fracLimits: Int.min...,   "01,000 sec")
        verify(intLimits: Int.max...,   fracLimits: Int.min...,   "\(oneThousandWithMaxPadding) sec")
        verify(intLimits: Int.min...,   fracLimits: 2...,   "1,000.00 sec")
        verify(intLimits: 5...,         fracLimits: 2...,   "01,000.00 sec")
        verify(intLimits: Int.max...,   fracLimits: 2...,   "\(oneThousandWithMaxPadding).00 sec")
        verify(intLimits: Int.min...,   fracLimits: Int.max...,   "1,000.\(maxFractionalTrailing) sec")
        verify(intLimits: 5...,         fracLimits: Int.max...,   "01,000.\(maxFractionalTrailing) sec")
        verify(intLimits: Int.max...,   fracLimits: Int.max...,   "\(oneThousandWithMaxPadding).\(maxFractionalTrailing) sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min...,   fracLimits: ...Int.min,   "0 wks")
        verify(intLimits: 5...,         fracLimits: ...Int.min,   "00,000 wks")
        verify(intLimits: Int.max...,   fracLimits: ...Int.min,   "\(padding996),000 wks")
        verify(intLimits: Int.min...,   fracLimits: ...5,   ".00165 wks")
        verify(intLimits: 5...,         fracLimits: ...5,   "00,000.00165 wks")
        verify(intLimits: Int.max...,   fracLimits: ...5,   "\(padding996),000.00165 wks")
        verify(intLimits: Int.min...,   fracLimits: ...Int.max,   ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: ...Int.max,   "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: ...Int.max,   "\(padding996),000.0016534391534391533 wks")
        allowedUnits = [.minutes]
        verify(intLimits: Int.min...,   fracLimits: ...Int.min,   "17 min")
        verify(intLimits: 5...,         fracLimits: ...Int.min,   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: ...Int.min,   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: ...5,   "16.66667 min")
        verify(intLimits: 5...,         fracLimits: ...5,   "00,016.66667 min")
        verify(intLimits: Int.max...,   fracLimits: ...5,   "\(padding996),016.66667 min")
        verify(intLimits: Int.min...,   fracLimits: ...Int.max, "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: ...Int.max, "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: ...Int.max, "\(padding996),016.666666666666668 min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min...,   fracLimits: ...Int.min,   "1,000 sec")
        verify(intLimits: 5...,         fracLimits: ...Int.min,   "01,000 sec")
        verify(intLimits: Int.max...,   fracLimits: ...Int.min,   "\(oneThousandWithMaxPadding) sec")
        verify(intLimits: Int.min...,   fracLimits: ...5,   "1,000 sec")
        verify(intLimits: 5...,         fracLimits: ...5,   "01,000 sec")
        verify(intLimits: Int.max...,   fracLimits: ...5,   "\(oneThousandWithMaxPadding) sec")
        verify(intLimits: Int.min...,   fracLimits: ...Int.max,   "1,000 sec")
        verify(intLimits: 5...,         fracLimits: ...Int.max,   "01,000 sec")
        verify(intLimits: Int.max...,   fracLimits: ...Int.max,   "\(oneThousandWithMaxPadding) sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [ .weeks ]
        verify(intLimits: 5...,         fracLimits: ..<Int.min, "00,000 wks")
        verify(intLimits: 5...,         fracLimits: ..<0,       "00,000 wks")
        verify(intLimits: 5...,         fracLimits: ..<Int.max, "00,000.0016534391534391533 wks")
        allowedUnits = [ .minutes ]
        verify(intLimits: Int.min...,   fracLimits: ..<Int.min,   "17 min")
        verify(intLimits: 5...,         fracLimits: ..<Int.min,   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: ..<Int.min,   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: ..<(Int.min + 1),   "17 min")
        verify(intLimits: 5...,         fracLimits: ..<(Int.min + 1),   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: ..<(Int.min + 1),   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: ..<5,   "16.6667 min")
        verify(intLimits: 5...,         fracLimits: ..<5,   "00,016.6667 min")
        verify(intLimits: Int.max...,   fracLimits: ..<5,   "\(padding996),016.6667 min")
        verify(intLimits: Int.min...,   fracLimits: ..<Int.max,   "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: ..<Int.max,   "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: ..<Int.max,   "\(padding996),016.666666666666668 min")
        duration = Duration.seconds(1_000)
        allowedUnits = [ .weeks ]
        verify(intLimits: Int.min...,   fracLimits: ...Int.min,   "0 wks")
        verify(intLimits: 5...,         fracLimits: ...Int.min,   "00,000 wks")
        verify(intLimits: Int.max...,   fracLimits: ...Int.min,   "\(padding996),000 wks")
        verify(intLimits: Int.min...,   fracLimits: ...(Int.min + 1),   "0 wks")
        verify(intLimits: 5...,         fracLimits: ...(Int.min + 1),   "00,000 wks")
        verify(intLimits: Int.max...,   fracLimits: ...(Int.min + 1),   "\(padding996),000 wks")
        verify(intLimits: Int.min...,   fracLimits: ...Int.max,   ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: ...Int.max,   "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: ...Int.max,   "\(padding996),000.0016534391534391533 wks")
        allowedUnits = [ .minutes ]
        verify(intLimits: Int.min...,   fracLimits: ...Int.min,   "17 min")
        verify(intLimits: 5...,         fracLimits: ...Int.min,   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: ...Int.min,   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: ...(Int.min + 1),   "17 min")
        verify(intLimits: 5...,         fracLimits: ...(Int.min + 1),   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: ...(Int.min + 1),   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: ...Int.max,   "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: ...Int.max,   "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: ...Int.max,   "\(padding996),016.666666666666668 min")
        duration = Duration.seconds(1_000)
        allowedUnits = [ .weeks ]
        verify(intLimits: Int.min...,   fracLimits: Int.min...Int.max, ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: Int.min...Int.max, "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: Int.min...Int.max, "\(padding996),000.0016534391534391533 wks")
        verify(intLimits: Int.min...,   fracLimits: Int.min...(-1),   "0 wks")
        verify(intLimits: 5...,         fracLimits: Int.min...(-1),   "00,000 wks")
        verify(intLimits: Int.max...,   fracLimits: Int.min...(-1),   "\(padding996),000 wks")
        verify(intLimits: Int.min...,   fracLimits: 5...Int.max,   ".0016534391534391533 wks")
        verify(intLimits: 5...,         fracLimits: 5...Int.max,   "00,000.0016534391534391533 wks")
        verify(intLimits: Int.max...,   fracLimits: 5...Int.max,   "\(padding996),000.0016534391534391533 wks")
        verify(intLimits: Int.min...,   fracLimits: 5...10, ".0016534392 wks")
        verify(intLimits: 5...,         fracLimits: 5...10, "00,000.0016534392 wks")
        verify(intLimits: Int.max...,   fracLimits: 5...10, "\(padding996),000.0016534392 wks")
        allowedUnits = [ .minutes ]
        verify(intLimits: Int.min...,   fracLimits: Int.min...Int.max, "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: Int.min...Int.max, "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: Int.min...Int.max, "\(padding996),016.666666666666668 min")
        verify(intLimits: Int.min...,   fracLimits: Int.min...(-1),   "17 min")
        verify(intLimits: 5...,         fracLimits: Int.min...(-1),   "00,017 min")
        verify(intLimits: Int.max...,   fracLimits: Int.min...(-1),   "\(padding996),017 min")
        verify(intLimits: Int.min...,   fracLimits: 5...Int.max,   "16.666666666666668 min")
        verify(intLimits: 5...,         fracLimits: 5...Int.max,   "00,016.666666666666668 min")
        verify(intLimits: Int.max...,   fracLimits: 5...Int.max,   "\(padding996),016.666666666666668 min")
        verify(intLimits: Int.min...,   fracLimits: 5...10, "16.6666666667 min")
        verify(intLimits: 5...,         fracLimits: 5...10, "00,016.6666666667 min")
        verify(intLimits: Int.max...,   fracLimits: 5...10, "\(padding996),016.6666666667 min")
        duration = Duration.seconds(1_000)
        allowedUnits = [.minutes, .seconds]
        verify(intLimits: Int.min...,   fracLimits: 2...,   "16 min, 40.00 sec")
        verify(intLimits: 0...,         fracLimits: 2...,   "16 min, 40.00 sec")
        verify(intLimits: 1...,         fracLimits: 2...,   "16 min, 40.00 sec")
        verify(intLimits: 5...,         fracLimits: 2...,   "00,016 min, 00,040.00 sec")
        verify(intLimits: Int.max...,      fracLimits: 2...,   "\(padding996),016 min, \(padding996),040.00 sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min...,   fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: 5...,         fracLimits: 10...10,   "00,000.0016534392 wks")
        verify(intLimits: Int.max...,   fracLimits: 10...10,   "\(padding996),000.0016534392 wks")
        allowedUnits = [.minutes]
        verify(intLimits: Int.min...,   fracLimits: 2...2,   "16.67 min")
        verify(intLimits: 5...,         fracLimits: 2...2,   "00,016.67 min")
        verify(intLimits: Int.max...,   fracLimits: 2...2,   "\(padding996),016.67 min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min...,   fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: 5...,         fracLimits: 2...2,   "01,000.00 sec")
        verify(intLimits: Int.max...,   fracLimits: 2...2,   "\(oneThousandWithMaxPadding).00 sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min..<Int.max,    fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: Int.min..<0,          fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: Int.min..<3,          fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: 5..<Int.max,          fracLimits: 10...10,   "00,000.0016534392 wks")
        allowedUnits = [.minutes]
        verify(intLimits: Int.min..<Int.max,    fracLimits: 2...2,   "16.67 min")
        verify(intLimits: Int.min..<0,          fracLimits: 2...2,   "16.67 min")
        verify(intLimits: Int.min..<3,          fracLimits: 2...2,   "16.67 min")
        verify(intLimits: 5..<Int.max,          fracLimits: 2...2,   "00,016.67 min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min..<Int.max,    fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: Int.min..<0,          fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: Int.min..<3,          fracLimits: 2...2,   ".00 sec") // This is not wrong, albeit confusing: we can't fit one thousand into three digits
        verify(intLimits: 5..<Int.max,          fracLimits: 2...2,   "01,000.00 sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: Int.min...Int.max,    fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: Int.min...(-1),       fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: Int.min...3,          fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: 5...Int.max,          fracLimits: 10...10,   "00,000.0016534392 wks")
        allowedUnits = [.minutes]
        verify(intLimits: Int.min...Int.max,    fracLimits: 2...2,   "16.67 min")
        verify(intLimits: Int.min...(-1),       fracLimits: 2...2,   "16.67 min")
        verify(intLimits: Int.min...3,          fracLimits: 2...2,   "16.67 min")
        verify(intLimits: 5...Int.max,          fracLimits: 2...2,   "00,016.67 min")
        allowedUnits = [.seconds]
        verify(intLimits: Int.min...Int.max,    fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: Int.min...(-1),       fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: Int.min...3,          fracLimits: 2...2,   ".00 sec")
        verify(intLimits: 5...Int.max,          fracLimits: 2...2,   "01,000.00 sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: ...Int.min,   fracLimits: 10...10,    ".0016534392 wks")
        verify(intLimits: ...3,         fracLimits: 10...10,    ".0016534392 wks")
        verify(intLimits: ...Int.max,   fracLimits: 10...10,    ".0016534392 wks")
        allowedUnits = [.minutes]
        verify(intLimits: ...Int.min,   fracLimits: 2...2,   "16.67 min")
        verify(intLimits: ...3,         fracLimits: 2...2,   "16.67 min")
        verify(intLimits: ...Int.max,   fracLimits: 2...2,   "16.67 min")
        allowedUnits = [.seconds]
        verify(intLimits: ...Int.min,   fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: ...3,         fracLimits: 2...2,   ".00 sec")
        verify(intLimits: ...Int.max,   fracLimits: 2...2,   "1,000.00 sec")
        duration = Duration.seconds(1_000)
        allowedUnits = [.weeks]
        verify(intLimits: ..<Int.min,   fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: ..<0,         fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: ..<3,         fracLimits: 10...10,   ".0016534392 wks")
        verify(intLimits: ..<Int.max,   fracLimits: 10...10,   ".0016534392 wks")
        allowedUnits = [.minutes]
        verify(intLimits: ..<Int.min,   fracLimits: 2...2,   "16.67 min")
        verify(intLimits: ..<0,         fracLimits: 2...2,   "16.67 min")
        verify(intLimits: ..<3,         fracLimits: 2...2,   "16.67 min")
        verify(intLimits: ..<Int.max,   fracLimits: 2...2,   "16.67 min")
        allowedUnits = [.seconds]
        verify(intLimits: ..<Int.min,   fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: ..<0,         fracLimits: 2...2,   "1,000.00 sec")
        verify(intLimits: ..<3,         fracLimits: 2...2,   ".00 sec")
        verify(intLimits: ..<Int.max,   fracLimits: 2...2,   "1,000.00 sec")
    }

    func testNegativeValues() {
        verify(seconds: 0, milliseconds: -499, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 0 sec")
        verify(seconds: 0, milliseconds: -500, allowedUnits: [.hours, .minutes, .seconds], expected: "0 hr, 0 min, 0 sec")
        verify(seconds: 0, milliseconds: -501, allowedUnits: [.hours, .minutes, .seconds], expected: "-0 hr, 0 min, 1 sec")
        verify(seconds: 0, milliseconds: -499, allowedUnits: [.minutes, .seconds], expected: "0 min, 0 sec")
        verify(seconds: 0, milliseconds: -500, allowedUnits: [.minutes, .seconds], expected: "0 min, 0 sec")
        verify(seconds: 0, milliseconds: -501, allowedUnits: [.minutes, .seconds], expected: "-0 min, 1 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -499, allowedUnits: [.hours, .minutes, .seconds], expected: "-0 hr, 59 min, 59 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -500, allowedUnits: [.hours, .minutes, .seconds], expected: "-1 hr, 0 min, 0 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -501, allowedUnits: [.hours, .minutes, .seconds], expected: "-1 hr, 0 min, 0 sec")
        verify(seconds: -3600 - 59 * 60 - 59, milliseconds: -499, allowedUnits: [.hours, .minutes, .seconds], expected: "-1 hr, 59 min, 59 sec")
        verify(seconds: -3600 - 59 * 60 - 59, milliseconds: -500, allowedUnits: [.hours, .minutes, .seconds], expected: "-2 hr, 0 min, 0 sec")
        verify(seconds: -3600 - 59 * 60 - 59, milliseconds: -501, allowedUnits: [.hours, .minutes, .seconds], expected: "-2 hr, 0 min, 0 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -499, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "-0 hr, 59 min, 59.50 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -994, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "-0 hr, 59 min, 59.99 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -995, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "-1 hr, 0 min, 0.00 sec")
        verify(seconds: -59 * 60 - 59, milliseconds: -996, allowedUnits: [.hours, .minutes, .seconds], fractionalSecondsLength: 2, expected: "-1 hr, 0 min, 0.00 sec")
        verify(seconds: -59, milliseconds: -499, allowedUnits: [.seconds], fractionalSecondsLength: 2, expected: "-59.50 sec")
        verify(seconds: -59, milliseconds: -994, allowedUnits: [.seconds], fractionalSecondsLength: 2, expected: "-59.99 sec")
        verify(seconds: -59, milliseconds: -995, allowedUnits: [.seconds], fractionalSecondsLength: 2, expected: "-60.00 sec")
        verify(seconds: -59, milliseconds: -996, allowedUnits: [.seconds], fractionalSecondsLength: 2, expected: "-60.00 sec")
    }
}

extension Sequence<DurationUnitAttributedFormatStyleTests.Segment> {
    var attributedString: AttributedString {
        self.map { tuple in
            var attrs = AttributeContainer()
            if let field = tuple.1 {
                attrs = attrs.durationField(field)
            }
            if let measureComponent = tuple.2 {
                attrs = attrs.measurement(measureComponent)
            }

            return AttributedString(tuple.0, attributes: attrs)
        }.reduce(AttributedString(), +)
    }
}

final class DurationUnitAttributedFormatStyleTests: XCTestCase {
    typealias Segment = (String, AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field?, AttributeScopes.FoundationAttributes.MeasurementAttribute.Component?)
    let enUS = Locale(identifier: "en_US")
    let frFR = Locale(identifier: "fr_FR")

    func testAttributedStyle_enUS() {
        let d1 = Duration.seconds(2 * 3600 + 43 * 60 + 24) // 2hr 43min 24s
        let d2 = Duration.seconds(43 * 60 + 24) // 43min 24s
        let d3 = Duration.seconds(24.490) // 24s 490ms
        let d0 = Duration.seconds(0)
        let d4 = Duration.seconds(21 * 86400 + 13 * 3600) // 3wk, 0day, 13hr
        let d5 = Duration.seconds(26 * 86400 + 4 * 3600) // 3wk, 5day, 4hr
        XCTAssertEqual(d1.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS).attributed), [("2", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit), (", ", nil, nil), ("43", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("24", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d2.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS).attributed), [("43", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("24", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d3.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS).attributed), [("24", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d0.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(enUS).attributed), [("0", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d4.formatted(.units(allowed: [.weeks, .days, .hours], width: .wide).locale(enUS).attributed), [("3", .weeks, .value), (" ", .weeks, nil), ("weeks", .weeks, .unit), (", ", nil, nil), ("13", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit)].attributedString)
        XCTAssertEqual(d5.formatted(.units(allowed: [.weeks, .days, .hours], width: .wide).locale(enUS).attributed), [("3", .weeks, .value), (" ", .weeks, nil), ("weeks", .weeks, .unit), (", ", nil, nil), ("5", .days, .value), (" ", .days, nil), ("days", .days, .unit), (", ", nil, nil), ("4", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit)].attributedString)
        XCTAssertEqual(d2.formatted(.units(allowed:[.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS).attributed), [("0", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit), (", ", nil, nil), ("43", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("24", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d3.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS).attributed), [("0", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit), (", ", nil, nil), ("0", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("24", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d0.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS).attributed), [("0", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit), (", ", nil, nil), ("0", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("0", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d4.formatted(.units(allowed: [.weeks, .days, .hours], width: .wide, zeroValueUnits: .show(length: 1)).locale(enUS).attributed), [("3", .weeks, .value), (" ", .weeks, nil), ("weeks", .weeks, .unit), (", ", nil, nil), ("0", .days, .value), (" ", .days, nil), ("days", .days, .unit), (", ", nil, nil), ("13", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit)].attributedString)
        XCTAssertEqual(d0.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide, zeroValueUnits: .show(length: 2)).locale(enUS).attributed), [("00", .hours, .value), (" ", .hours, nil), ("hours", .hours, .unit), (", ", nil, nil), ("00", .minutes, .value), (" ", .minutes, nil), ("minutes", .minutes, .unit), (", ", nil, nil), ("00", .seconds, .value), (" ", .seconds, nil), ("seconds", .seconds, .unit)].attributedString)
        XCTAssertEqual(d1.formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).attributed.locale(enUS)), [("2.72", .hours, .value), (" ", .hours, nil), ("hr", .hours, .unit)].attributedString)
        XCTAssertEqual(d0.formatted(.units(allowed:[.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1, fractionalPart: .show(length: 2)).attributed.locale(enUS)), [("0.00", .seconds, .value), (" ", .seconds, nil), ("sec", .seconds, .unit)].attributedString)
        XCTAssertEqual(d4.formatted(.units(allowed: [.weeks, .days, .hours], width: .wide, maximumUnitCount: 1, fractionalPart: .show(length: 2)).locale(enUS).attributed), [("3.08", .weeks, .value), (" ", .weeks, nil), ("weeks", .weeks, .unit)].attributedString)
    }

    func testAttributedStyle_frFR() {
        let d1 = Duration.seconds(2 * 3600 + 43 * 60 + 24) // 2hr 43min 24s
        let d0 = Duration.seconds(0)
        let nbsp = " "
        XCTAssertEqual(d1.formatted(.units(allowed: [.seconds], width: .wide).locale(frFR).attributed), [("9 804", .seconds, .value), (nbsp, .seconds, nil), ("secondes", .seconds, .unit)].attributedString)
        XCTAssertEqual(d0.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(frFR).attributed), [("0", .seconds, .value), (nbsp, .seconds, nil), ("seconde", .seconds, .unit)].attributedString)
    }
}
