import FormatStylePolyfill
import XCTest

final class NumberFormatStyleTests: XCTestCase {
    let enUSLocale = Locale(identifier: "en_US")

    func _testNegPosInt<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String], _ testName: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Int, F.FormatOutput == String {
        let data: [Int] = [ -98, -9, 0, 9, 98 ]
        for i in 0 ..< data.count { XCTAssertEqual(style.format(data[i]), expected[i], testName, file: file, line: line) }
    }

    func _testNegPosDbl<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String], _ testName: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Double, F.FormatOutput == String {
        let data: [Double] = [ 87650, 8765, 876.5, 87.65, 8.765, 0.8765, 0.08765, 0.008765, 0, -0.008765, -876.5, -87650 ]
        for i in 0 ..< data.count { XCTAssertEqual(style.format(data[i]), expected[i], testName, file: file, line: line) }
    }

    func _testNegPosDec<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String], _ testName: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Decimal, F.FormatOutput == String {
        let data: [Decimal] = [
            .init(string:"87650")!, .init(string:"8765")!, .init(string:"876.5")!, .init(string:"87.65")!, .init(string:"8.765")!, .init(string:"0.8765")!,
            .init(string:"0.08765")!, .init(string:"0.008765")!, .init(string:"0")!, .init(string:"-0.008765")!, .init(string:"-876.5")!, .init(string:"-87650")!
        ]
        for i in 0 ..< data.count { XCTAssertEqual((data[i])._polyfill_formatted(style), expected[i], testName, file: file, line: line) }
    }

    func testIntegerFormatStyle() throws {
        func test(_ style: _polyfill_IntegerFormatStyle<Int>, expected: [String]) {
            let data: [Int] = [87650000, 8765000, 876500, 87650, 8765, 876, 87, 8, 0]
            for i in 0 ..< data.count { XCTAssertEqual(style.format(data[i]), expected[i]) }
        }
        test(_polyfill_IntegerFormatStyle<Int>(locale: enUSLocale), expected: ["87,650,000", "8,765,000", "876,500", "87,650", "8,765", "876", "87", "8", "0"])
        test(_polyfill_IntegerFormatStyle<Int>(locale: enUSLocale).notation(.scientific), expected: ["8.765E7", "8.765E6", "8.765E5", "8.765E4", "8.765E3", "8.76E2", "8.7E1", "8E0", "0E0"])
        test(_polyfill_IntegerFormatStyle<Int>(locale: enUSLocale).sign(strategy: .always()), expected: ["+87,650,000", "+8,765,000", "+876,500", "+87,650", "+8,765", "+876", "+87", "+8", "+0"])
    }

   func testIntegerFormatStyleFixedWidthLimits() throws {
        func test<I: FixedWidthInteger>(type: I.Type = I.self, min: String, max: String) {
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: Locale(identifier: "en_US_POSIX")).format(I.min), I.min.description)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: Locale(identifier: "en_US_POSIX")).format(I.max), I.max.description)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: enUSLocale).format(I.min), min)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: enUSLocale).format(I.max), max)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Percent(locale: enUSLocale).format(I.min), min + "%")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Percent(locale: enUSLocale).format(I.max), max + "%")
            let negativeSign = (min.first == "-" ? "-" : "")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Currency(code: "USD", locale: enUSLocale).presentation(.narrow).format(I.min), "\(negativeSign)$\(min.drop(while: { $0 == "-" })).00")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Currency(code: "USD", locale: enUSLocale).presentation(.narrow).format(I.max), "$\(max).00")
        }
        test(type: Int8.self,   min: "-128",                       max: "127")
        test(type: Int16.self,  min: "-32,768",                    max: "32,767")
        test(type: Int32.self,  min: "-2,147,483,648",             max: "2,147,483,647")
        test(type: Int64.self,  min: "-9,223,372,036,854,775,808", max: "9,223,372,036,854,775,807")
        test(type: UInt8.self,  min: "0",                          max: "255")
        test(type: UInt16.self, min: "0",                          max: "65,535")
        test(type: UInt32.self, min: "0",                          max: "4,294,967,295")
        test(type: UInt64.self, min: "0",                          max: "18,446,744,073,709,551,615")
    }

    func testInteger_Precision() throws {
        let style = _polyfill_IntegerFormatStyle<Int>(locale: enUSLocale)
        _testNegPosInt(style.precision(.significantDigits(3...3)), ["-98.0", "-9.00", "0.00", "9.00", "98.0"], "exact significant digits")
        _testNegPosInt(style.precision(.significantDigits(2...)),  ["-98", "-9.0", "0.0", "9.0", "98"],        "min significant digits")
        _testNegPosInt(style.precision(.integerAndFractionLength(integerLimits: 4..., fractionLimits: 0...0)), ["-0,098", "-0,009", "0,000", "0,009", "0,098"])
    }

    func testIntegerFormatStyle_Percent() throws {
        let style = _polyfill_IntegerFormatStyle<Int>.Percent(locale: enUSLocale)
        _testNegPosInt(style, ["-98%", "-9%", "0%", "9%", "98%"], "percent default")
        _testNegPosInt(style.precision(.significantDigits(3...3)), ["-98.0%", "-9.00%", "0.00%", "9.00%", "98.0%"], "percent + significant digit")
    }

    func testIntegerFormatStyle_Currency() throws {
        let style = _polyfill_IntegerFormatStyle<Int>.Currency(code: "GBP", locale: enUSLocale)
        _testNegPosInt(style.presentation(.narrow),   ["-£98.00", "-£9.00", "£0.00", "£9.00", "£98.00"], "currency narrow")
        _testNegPosInt(style.presentation(.isoCode),  ["-GBP 98.00", "-GBP 9.00", "GBP 0.00", "GBP 9.00", "GBP 98.00"], "currency isoCode")
        _testNegPosInt(style.presentation(.standard), ["-£98.00", "-£9.00", "£0.00", "£9.00", "£98.00"], "currency standard")
        _testNegPosInt(style.presentation(.fullName), ["-98.00 British pounds", "-9.00 British pounds", "0.00 British pounds", "9.00 British pounds", "98.00 British pounds"], "currency fullname")
        let styleUSD = _polyfill_IntegerFormatStyle<Int>.Currency(code: "USD", locale: Locale(identifier: "en_CA"))
        _testNegPosInt(styleUSD.presentation(.standard), ["-US$98.00", "-US$9.00", "US$0.00", "US$9.00", "US$98.00"], "currency standard")
    }

    func testFloatingPointFormatStyle() throws {
        let style = _polyfill_FloatingPointFormatStyle<Double>(locale: enUSLocale)
        _testNegPosDbl(style.precision(.significantDigits(...2)), ["88,000", "8,800", "880", "88", "8.8", "0.88", "0.088", "0.0088", "0", "-0.0088", "-880", "-88,000"])
        _testNegPosDbl(style.precision(.fractionLength(1...3)), ["87,650.0", "8,765.0", "876.5", "87.65", "8.765", "0.876", "0.088", "0.009", "0.0", "-0.009", "-876.5", "-87,650.0"])
        _testNegPosDbl(style.precision(.integerLength(3...)), ["87,650", "8,765", "876.5", "087.65", "008.765", "000.8765", "000.08765", "000.008765", "000", "-000.008765", "-876.5", "-87,650"])
        _testNegPosDbl(style.precision(.integerLength(1...3)), ["650", "765", "876.5", "87.65", "8.765", "0.8765", "0.08765", "0.008765", "0", "-0.008765", "-876.5", "-650"])
        _testNegPosDbl(style.precision(.integerLength(2...2)), ["50", "65", "76.5", "87.65", "08.765", "00.8765", "00.08765", "00.008765", "00", "-00.008765", "-76.5", "-50"])
        _testNegPosDbl(style.precision(.integerAndFractionLength(integerLimits: 2...2, fractionLimits: 0...0)), ["50", "65", "76", "88", "09", "01", "00", "00", "00", "-00", "-76", "-50"])
        _testNegPosDbl(style.precision(.integerAndFractionLength(integerLimits: 3..., fractionLimits: 0...0)), ["87,650", "8,765", "876", "088", "009", "001", "000", "000", "000", "-000", "-876", "-87,650"])
        _testNegPosDbl(style.precision(.integerLength(0)), ["87,650", "8,765", "876.5", "87.65", "8.765", ".8765", ".08765", ".008765", "0", "-.008765", "-876.5", "-87,650"])
        _testNegPosDbl(style.precision(.integerLength(0...0)), ["87,650", "8,765", "876.5", "87.65", "8.765", ".8765", ".08765", ".008765", "0", "-.008765", "-876.5", "-87,650"])
        _testNegPosDbl(style.precision(.integerAndFractionLength(integerLimits: 0...0, fractionLimits: 2...2)), ["87,650.00", "8,765.00", "876.50", "87.65", "8.76", ".88", ".09", ".01", ".00", "-.01", "-876.50", "-87,650.00"])
    }

    func testFloatingPointFormatStyle_Percent() throws {
        let style = _polyfill_FloatingPointFormatStyle<Double>.Percent(locale: enUSLocale)
        _testNegPosDbl(style, ["8,765,000%", "876,500%", "87,650%", "8,765%", "876.5%", "87.65%", "8.765%", "0.8765%", "0%", "-0.8765%", "-87,650%", "-8,765,000%"])
        _testNegPosDbl(style.precision(.significantDigits(2)), ["8,800,000%", "880,000%", "88,000%", "8,800%", "880%", "88%", "8.8%", "0.88%", "0.0%", "-0.88%", "-88,000%", "-8,800,000%"])
    }

    func testFloatingPointFormatStyle_BigNumber() throws {
        let bigData: [(Double, String)] = [
            (9007199254740992, "9,007,199,254,740,992.00"), // Maximum integer that can be precisely represented by a double
            (-9007199254740992, "-9,007,199,254,740,992.00"), // Minimum integer that can be precisely represented by a double
            (9007199254740992.5, "9,007,199,254,740,992.00"), // Would round to the closest
            (9007199254740991.5, "9,007,199,254,740,992.00"), // Would round to the closest
        ]
        let style = _polyfill_FloatingPointFormatStyle<Double>(locale: enUSLocale).precision(.fractionLength(2...))
        for (v, expected) in bigData { XCTAssertEqual(style.format(v), expected) }
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.number.locale(enUSLocale)), "179,769,313,486,231,570,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.number.locale(enUSLocale)), "∞")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.number.locale(enUSLocale)), "0")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(enUSLocale)), "NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(enUSLocale).precision(.fractionLength(2))), "NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(Locale(identifier: "uz_Cyrl"))), "ҳақиқий сон эмас")
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.percent.locale(enUSLocale)), "17,976,931,348,623,157,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000%")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.percent.locale(enUSLocale)), "∞%")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.percent.locale(enUSLocale)), "0%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(enUSLocale)), "NaN%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(enUSLocale).precision(.fractionLength(2))), "NaN%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(Locale(identifier: "uz_Cyrl"))), "ҳақиқий сон эмас%")
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.currency(code: "USD").locale(enUSLocale)), "$179,769,313,486,231,570,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000.00")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.currency(code: "USD").locale(enUSLocale)), "$∞")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.currency(code: "USD").locale(enUSLocale)), "$0.00")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(enUSLocale)), "$NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(enUSLocale).precision(.fractionLength(2))), "$NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(Locale(identifier: "uz_Cyrl"))), "ҳақиқий сон эмас US$")
    }

    func testFormattedAttributedLeadingDotSyntax() throws {
        let int = 42
        XCTAssertEqual(int._polyfill_formatted(.number.attributed), _polyfill_IntegerFormatStyle().attributed.format(int))
        XCTAssertEqual(int._polyfill_formatted(.percent.attributed), _polyfill_IntegerFormatStyle.Percent().attributed.format(int))
        XCTAssertEqual(int._polyfill_formatted(.currency(code: "GBP").attributed), _polyfill_IntegerFormatStyle.Currency(code: "GBP").attributed.format(int))
        let float = 3.14159
        XCTAssertEqual(float._polyfill_formatted(.number.attributed), _polyfill_FloatingPointFormatStyle<Double>().attributed.format(float))
        XCTAssertEqual(float._polyfill_formatted(.percent.attributed), _polyfill_FloatingPointFormatStyle<Double>.Percent().attributed.format(float))
        XCTAssertEqual(float._polyfill_formatted(.currency(code: "GBP").attributed), _polyfill_FloatingPointFormatStyle<Double>.Currency(code: "GBP").attributed.format(float))
        let decimal = Decimal(2.999)
        XCTAssertEqual(decimal._polyfill_formatted(.number.attributed), Decimal._polyfill_FormatStyle().attributed.format(decimal))
        XCTAssertEqual(decimal._polyfill_formatted(.percent.attributed), Decimal._polyfill_FormatStyle.Percent().attributed.format(decimal))
        XCTAssertEqual(decimal._polyfill_formatted(.currency(code: "GBP").attributed), Decimal._polyfill_FormatStyle.Currency(code: "GBP").attributed.format(decimal))
    }

    func testDecimalFormatStyle() throws {
        let style = Decimal._polyfill_FormatStyle(locale: enUSLocale)
        _testNegPosDec(style.precision(.significantDigits(...2)), ["88,000", "8,800", "880", "88", "8.8", "0.88", "0.088", "0.0088", "0", "-0.0088", "-880", "-88,000"])
        _testNegPosDec(style.precision(.fractionLength(1...3)), ["87,650.0", "8,765.0", "876.5", "87.65", "8.765", "0.876", "0.088", "0.009", "0.0", "-0.009", "-876.5", "-87,650.0"])
        _testNegPosDec(style.precision(.fractionLength(0)), ["87,650", "8,765", "876", "88", "9", "1", "0", "0", "0", "-0", "-876", "-87,650"])
        _testNegPosDec(style.precision(.integerLength(3...)), ["87,650", "8,765", "876.5", "087.65", "008.765", "000.8765", "000.08765", "000.008765", "000", "-000.008765", "-876.5", "-87,650"])
        _testNegPosDec(style.precision(.integerAndFractionLength(integerLimits: 3..., fractionLimits: 0...0)), ["87,650", "8,765", "876", "088", "009", "001", "000", "000", "000", "-000", "-876", "-87,650"])
        _testNegPosDec(style.precision(.integerLength(1...3)), ["650", "765", "876.5", "87.65", "8.765", "0.8765", "0.08765", "0.008765", "0", "-0.008765", "-876.5", "-650"])
        _testNegPosDec(style.precision(.integerAndFractionLength(integerLimits: 1...3, fractionLimits: 0...0)), ["650", "765", "876", "88", "9", "1", "0", "0", "0", "-0", "-876", "-650"])
        _testNegPosDec(style.precision(.integerLength(2...2)), ["50", "65", "76.5", "87.65", "08.765", "00.8765", "00.08765", "00.008765", "00", "-00.008765", "-76.5", "-50"])
        _testNegPosDec(style.precision(.integerAndFractionLength(integerLimits: 2...2, fractionLimits: 0...0)), ["50", "65", "76", "88", "09", "01", "00", "00", "00", "-00", "-76", "-50"])
    }

    func testDecimalFormatStyle_Percent() throws {
        let style = Decimal._polyfill_FormatStyle.Percent(locale: enUSLocale)
        _testNegPosDec(style.precision(.significantDigits(...2)), ["8,800,000%", "880,000%", "88,000%", "8,800%", "880%", "88%", "8.8%", "0.88%", "0%", "-0.88%", "-88,000%", "-8,800,000%"])
        _testNegPosDec(style.precision(.fractionLength(1...3)), ["8,765,000.0%", "876,500.0%", "87,650.0%", "8,765.0%", "876.5%", "87.65%", "8.765%", "0.876%", "0.0%", "-0.876%", "-87,650.0%", "-8,765,000.0%"])
        _testNegPosDec(style.precision(.integerLength(3...)), ["8,765,000%", "876,500%", "87,650%", "8,765%", "876.5%", "087.65%", "008.765%", "000.8765%", "000%", "-000.8765%", "-87,650%", "-8,765,000%"])
        _testNegPosDec(style.precision(.integerLength(1...3)), ["0%", "500%", "650%", "765%", "876.5%", "87.65%", "8.765%", "0.8765%", "0%", "-0.8765%", "-650%", "-0%"])
        _testNegPosDec(style.precision(.integerLength(2...2)), ["00%", "00%", "50%", "65%", "76.5%", "87.65%", "08.765%", "00.8765%", "00%", "-00.8765%", "-50%", "-00%"])
    }

    func testDecimalFormatStyle_Currency() throws {
        let style = Decimal._polyfill_FormatStyle.Currency(code: "USD", locale: enUSLocale)
        _testNegPosDec(style, ["$87,650.00", "$8,765.00", "$876.50", "$87.65", "$8.76", "$0.88", "$0.09", "$0.01", "$0.00", "-$0.01", "-$876.50", "-$87,650.00"], "currency style")
    }

    func testDecimal_withCustomShorthand() throws {
        try XCTSkipUnless(Locale.autoupdatingCurrent.language.isEquivalent(to: Locale.Language(identifier: "en_US")), "This test can only be run with the system set to the en_US language")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.number.grouping(.never)), "12345")
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.percent.sign(strategy: .always())), "+1,234,567.8%")
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.currency(code:"USD").sign(strategy: .accounting)), "($3,000.14)")
    }

    func testDecimal_withShorthand_enUS() throws {
        try XCTSkipUnless(Locale.autoupdatingCurrent.language.isEquivalent(to: Locale.Language(identifier: "en_US")), "This test can only be run with the system set to the en_US language")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.number), "12,345")
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.number), "12,345.678")
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.number), "0")
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.number), "3.14159")
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.number), "-3.14159")
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.number), "-3,000.14159")
        XCTAssertEqual((0.12345 as Decimal)._polyfill_formatted(.percent), "12.345%")
        XCTAssertEqual((0.0012345 as Decimal)._polyfill_formatted(.percent), "0.12345%")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.percent), "1,234,500%")
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.percent), "1,234,567.8%")
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.percent), "0%")
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.percent), "314.159%")
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.percent), "-314.159%")
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.percent), "-300,014.159%")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.currency(code:"USD")), "$12,345.00")
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.currency(code:"USD")), "$12,345.68")
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.currency(code:"USD")), "$0.00")
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), "$3.14")
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), "-$3.14")
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), "-$3,000.14")
    }

    func testDecimal_default() throws {
        let style = Decimal.FormatStyle()
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(), style.format(12345))
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(), style.format(12345.678))
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(), style.format(0))
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(), style.format(3.14159))
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(), style.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(), style.format(-3000.14159))
    }

    func testDecimal_default_enUS() throws {
        try XCTSkipUnless(Locale.autoupdatingCurrent.language.isEquivalent(to: Locale.Language(identifier: "en_US")), "This test can only be run with the system set to the en_US language")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(), "12,345")
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(), "12,345.678")
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(), "0")
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(), "3.14159")
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(), "-3.14159")
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(), "-3,000.14159")
    }

    func testDecimal_withShorthand() throws {
        let style = Decimal.FormatStyle()
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.number), style.format(12345))
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.number), style.format(12345.678))
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.number), style.format(0))
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.number), style.format(3.14159))
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.number), style.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.number), style.format(-3000.14159))
        let percentStyle = Decimal.FormatStyle.Percent()
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.percent), percentStyle.format(12345))
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.percent), percentStyle.format(12345.678))
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.percent), percentStyle.format(0))
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.percent), percentStyle.format(3.14159))
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.percent), percentStyle.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.percent), percentStyle.format(-3000.14159))
        let currencyStyle = Decimal.FormatStyle.Currency(code: "USD")
        XCTAssertEqual((12345 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(12345))
        XCTAssertEqual((12345.678 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(12345.678))
        XCTAssertEqual((0 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(0))
        XCTAssertEqual((3.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(3.14159))
        XCTAssertEqual((-3.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(-3000.14159))
    }
}

