import FormatStylePolyfill
import class XCTest.XCTestCase
import func XCTest.XCTAssert
import func XCTest.XCTAssertEqual
import func XCTest.XCTAssertNotNil
import func XCTest.XCTSkipUnless
import struct Foundation.Locale
import struct Foundation.Decimal

final class NumberFormatStyleTests: XCTestCase {
    let enUSLocale = Foundation.Locale(identifier: "en_US")

    private func verifyInt<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String],
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Int, F.FormatOutput == String {
        let data: [Int] = [-98, -9, 0, 9, 98]
        
        for (dat, exp) in zip(data, expected) { XCTAssertEqual(style.format(dat), exp, file: file, line: line) }
    }

    private func verifyDbl<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String],
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Double, F.FormatOutput == String {
        let data: [Double] = [87650, 8765, 876.5, 87.65, 8.765, 0.8765, 0.08765, 0.008765, 0, -0.008765, -876.5, -87650]
        
        for (dat, exp) in zip(data, expected) { XCTAssertEqual(style.format(dat), exp, file: file, line: line) }
    }

    private func verifyDec<F: _polyfill_FormatStyle>(
        _ style: F, _ expected: [String],
        file: StaticString = #filePath, line: UInt = #line
    ) where F.FormatInput == Foundation.Decimal, F.FormatOutput == String {
        let data: [Foundation.Decimal] = [
            .init(string:"87650")!, .init(string:"8765")!, .init(string:"876.5")!, .init(string:"87.65")!, .init(string:"8.765")!, .init(string:"0.8765")!,
            .init(string:"0.08765")!, .init(string:"0.008765")!, .init(string:"0")!, .init(string:"-0.008765")!, .init(string:"-876.5")!, .init(string:"-87650")!
        ]
        
        for (dat, exp) in zip(data, expected) { XCTAssertEqual(dat._polyfill_formatted(style), exp, file: file, line: line) }
    }

    func testIntegerFormatStyle() throws {
        func test(_ style: _polyfill_IntegerFormatStyle<Int>, expected: [String], file: StaticString = #filePath, line: UInt = #line) {
            let data: [Int] = [87650000, 8765000, 876500, 87650, 8765, 876, 87, 8, 0]
            
            for (dat, exp) in zip(data, expected) { XCTAssertEqual(style.format(dat), exp, file: file, line: line) }
        }
        
        test(_polyfill_IntegerFormatStyle<Int>(locale: self.enUSLocale),
             expected: ["87,650,000", "8,765,000", "876,500", "87,650", "8,765", "876", "87", "8", "0"])
        test(_polyfill_IntegerFormatStyle<Int>(locale: self.enUSLocale).notation(.scientific),
             expected: ["8.765E7", "8.765E6", "8.765E5", "8.765E4", "8.765E3", "8.76E2", "8.7E1", "8E0", "0E0"])
        test(_polyfill_IntegerFormatStyle<Int>(locale: self.enUSLocale).sign(strategy: .always()),
             expected: ["+87,650,000", "+8,765,000", "+876,500", "+87,650", "+8,765", "+876", "+87", "+8", "+0"])
    }

   func testIntegerFormatStyleFixedWidthLimits() throws {
        func test<I: FixedWidthInteger>(type: I.Type = I.self, min: String, max: String) {
            let sign = (min.first == "-" ? "-" : "")

            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: Foundation.Locale(identifier: "en_US_POSIX")).format(I.min), I.min.description)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: Foundation.Locale(identifier: "en_US_POSIX")).format(I.max), I.max.description)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: self.enUSLocale).format(I.min), min)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>(locale: self.enUSLocale).format(I.max), max)
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Percent(locale: self.enUSLocale).format(I.min), min + "%")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Percent(locale: self.enUSLocale).format(I.max), max + "%")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Currency(code: "USD", locale: self.enUSLocale).presentation(.narrow).format(I.min), "\(sign)$\(min.trimmingPrefix("-")).00")
            XCTAssertEqual(_polyfill_IntegerFormatStyle<I>.Currency(code: "USD", locale: self.enUSLocale).presentation(.narrow).format(I.max), "$\(max).00")
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
        let style = _polyfill_IntegerFormatStyle<Int>(locale: self.enUSLocale)
        
        self.verifyInt(style.precision(.significantDigits(3...3)), ["-98.0", "-9.00", "0.00", "9.00", "98.0"])
        self.verifyInt(style.precision(.significantDigits(2...)),  ["-98", "-9.0", "0.0", "9.0", "98"])
        self.verifyInt(style.precision(.integerAndFractionLength(integerLimits: 4..., fractionLimits: 0...0)), ["-0,098", "-0,009", "0,000", "0,009", "0,098"])
    }

    func testIntegerFormatStyle_Percent() throws {
        let style = _polyfill_IntegerFormatStyle<Int>.Percent(locale: self.enUSLocale)
        
        self.verifyInt(style, ["-98%", "-9%", "0%", "9%", "98%"])
        self.verifyInt(style.precision(.significantDigits(3...3)), ["-98.0%", "-9.00%", "0.00%", "9.00%", "98.0%"])
    }

    func testIntegerFormatStyle_Currency() throws {
        let style = _polyfill_IntegerFormatStyle<Int>.Currency(code: "GBP", locale: self.enUSLocale)
        
        self.verifyInt(style.presentation(.narrow),      ["-£98.00", "-£9.00", "£0.00", "£9.00", "£98.00"])
        self.verifyInt(style.presentation(.isoCode),     ["-GBP 98.00", "-GBP 9.00", "GBP 0.00", "GBP 9.00", "GBP 98.00"])
        self.verifyInt(style.presentation(.standard),    ["-£98.00", "-£9.00", "£0.00", "£9.00", "£98.00"])
        self.verifyInt(style.presentation(.fullName),    ["-98.00 British pounds", "-9.00 British pounds", "0.00 British pounds", "9.00 British pounds", "98.00 British pounds"])
        
        let styleUSD = _polyfill_IntegerFormatStyle<Int>.Currency(code: "USD", locale: Foundation.Locale(identifier: "en_CA"))
        
        self.verifyInt(styleUSD.presentation(.standard), ["-US$98.00", "-US$9.00", "US$0.00", "US$9.00", "US$98.00"])
    }

    func testFloatingPointFormatStyle() throws {
        let style = _polyfill_FloatingPointFormatStyle<Double>(locale: self.enUSLocale)
        
        self.verifyDbl(style.precision(.significantDigits(...2)), ["88,000", "8,800", "880", "88", "8.8", "0.88", "0.088", "0.0088", "0", "-0.0088", "-880", "-88,000"])
        self.verifyDbl(style.precision(.fractionLength(1...3)),   ["87,650.0", "8,765.0", "876.5", "87.65", "8.765", "0.876", "0.088", "0.009", "0.0", "-0.009", "-876.5", "-87,650.0"])
        self.verifyDbl(style.precision(.integerLength(3...)),     ["87,650", "8,765", "876.5", "087.65", "008.765", "000.8765", "000.08765", "000.008765", "000", "-000.008765", "-876.5", "-87,650"])
        self.verifyDbl(style.precision(.integerLength(1...3)),    ["650", "765", "876.5", "87.65", "8.765", "0.8765", "0.08765", "0.008765", "0", "-0.008765", "-876.5", "-650"])
        self.verifyDbl(style.precision(.integerLength(2...2)),    ["50", "65", "76.5", "87.65", "08.765", "00.8765", "00.08765", "00.008765", "00", "-00.008765", "-76.5", "-50"])
        self.verifyDbl(style.precision(.integerAndFractionLength(integerLimits: 2...2, fractionLimits: 0...0)), ["50", "65", "76", "88", "09", "01", "00", "00", "00", "-00", "-76", "-50"])
        self.verifyDbl(style.precision(.integerAndFractionLength(integerLimits: 3..., fractionLimits: 0...0)),  ["87,650", "8,765", "876", "088", "009", "001", "000", "000", "000", "-000", "-876", "-87,650"])
        self.verifyDbl(style.precision(.integerLength(0)),     ["87,650", "8,765", "876.5", "87.65", "8.765", ".8765", ".08765", ".008765", "0", "-.008765", "-876.5", "-87,650"])
        self.verifyDbl(style.precision(.integerLength(0...0)), ["87,650", "8,765", "876.5", "87.65", "8.765", ".8765", ".08765", ".008765", "0", "-.008765", "-876.5", "-87,650"])
        self.verifyDbl(style.precision(.integerAndFractionLength(integerLimits: 0...0, fractionLimits: 2...2)), ["87,650.00", "8,765.00", "876.50", "87.65", "8.76", ".88", ".09", ".01", ".00", "-.01", "-876.50", "-87,650.00"])
    }

    func testFloatingPointFormatStyle_Percent() throws {
        let style = _polyfill_FloatingPointFormatStyle<Double>.Percent(locale: self.enUSLocale)
        
        self.verifyDbl(style, ["8,765,000%", "876,500%", "87,650%", "8,765%", "876.5%", "87.65%", "8.765%", "0.8765%", "0%", "-0.8765%", "-87,650%", "-8,765,000%"])
        self.verifyDbl(style.precision(.significantDigits(2)), ["8,800,000%", "880,000%", "88,000%", "8,800%", "880%", "88%", "8.8%", "0.88%", "0.0%", "-0.88%", "-88,000%", "-8,800,000%"])
    }

    func testFloatingPointFormatStyle_BigNumber() throws {
        let bigData: [(Double, String)] = [
            (  9007199254740992, "9,007,199,254,740,992.00"), // Maximum integer that can be precisely represented by a double
            (-9007199254740992, "-9,007,199,254,740,992.00"), // Minimum integer that can be precisely represented by a double
            (9007199254740992.5, "9,007,199,254,740,992.00"), // Would round to the closest
            (9007199254740991.5, "9,007,199,254,740,992.00"), // Would round to the closest
        ]
        let style = _polyfill_FloatingPointFormatStyle<Double>(locale: self.enUSLocale).precision(.fractionLength(2...))
        
        for (v, expected) in bigData { XCTAssertEqual(style.format(v), expected) }
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.number.locale(self.enUSLocale)),
                       "179,769,313,486,231,570,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.number.locale(self.enUSLocale)),                          "∞")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.number.locale(self.enUSLocale)),             "0")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(self.enUSLocale)),                               "NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(self.enUSLocale).precision(.fractionLength(2))), "NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.number.locale(Foundation.Locale(identifier: "uz_Cyrl"))),      "ҳақиқий сон эмас")
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.percent.locale(self.enUSLocale)),
                       "17,976,931,348,623,157,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000%")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.percent.locale(self.enUSLocale)),                          "∞%")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.percent.locale(self.enUSLocale)),             "0%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(self.enUSLocale)),                               "NaN%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(self.enUSLocale).precision(.fractionLength(2))), "NaN%")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.percent.locale(Foundation.Locale(identifier: "uz_Cyrl"))),      "ҳақиқий сон эмас%")
        XCTAssertEqual(Float64.greatestFiniteMagnitude._polyfill_formatted(.currency(code: "USD").locale(self.enUSLocale)),
                       "$179,769,313,486,231,570,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000.00")
        XCTAssertEqual(Float64.infinity._polyfill_formatted(.currency(code: "USD").locale(self.enUSLocale)),                          "$∞")
        XCTAssertEqual(Float64.leastNonzeroMagnitude._polyfill_formatted(.currency(code: "USD").locale(self.enUSLocale)),             "$0.00")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(self.enUSLocale)),                               "$NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(self.enUSLocale).precision(.fractionLength(2))), "$NaN")
        XCTAssertEqual(Float64.nan._polyfill_formatted(.currency(code: "USD").locale(Foundation.Locale(identifier: "uz_Cyrl"))),      "ҳақиқий сон эмас US$")
    }

    func testFormattedAttributedLeadingDotSyntax() throws {
        let int = 42
        let float = 3.14159
        let decimal = Foundation.Decimal(2.999)
        
        XCTAssertEqual(int._polyfill_formatted(.number.attributed),                    _polyfill_IntegerFormatStyle().attributed.format(int))
        XCTAssertEqual(int._polyfill_formatted(.percent.attributed),                   _polyfill_IntegerFormatStyle.Percent().attributed.format(int))
        XCTAssertEqual(int._polyfill_formatted(.currency(code: "GBP").attributed),     _polyfill_IntegerFormatStyle.Currency(code: "GBP").attributed.format(int))
        
        XCTAssertEqual(float._polyfill_formatted(.number.attributed),                  _polyfill_FloatingPointFormatStyle<Double>().attributed.format(float))
        XCTAssertEqual(float._polyfill_formatted(.percent.attributed),                 _polyfill_FloatingPointFormatStyle<Double>.Percent().attributed.format(float))
        XCTAssertEqual(float._polyfill_formatted(.currency(code: "GBP").attributed),   _polyfill_FloatingPointFormatStyle<Double>.Currency(code: "GBP").attributed.format(float))

        XCTAssertEqual(decimal._polyfill_formatted(.number.attributed),                _polyfill_DecimalFormatStyle().attributed.format(decimal))
        XCTAssertEqual(decimal._polyfill_formatted(.percent.attributed),               _polyfill_DecimalFormatStyle.Percent().attributed.format(decimal))
        XCTAssertEqual(decimal._polyfill_formatted(.currency(code: "GBP").attributed), _polyfill_DecimalFormatStyle.Currency(code: "GBP").attributed.format(decimal))
    }

    func testDecimalFormatStyle() throws {
        let style = _polyfill_DecimalFormatStyle(locale: self.enUSLocale)
        
        self.verifyDec(style.precision(.significantDigits(...2)),   ["88,000", "8,800", "880", "88", "8.8", "0.88", "0.088", "0.0088", "0", "-0.0088", "-880", "-88,000"])
        self.verifyDec(style.precision(.fractionLength(1 ... 3)),   ["87,650.0", "8,765.0", "876.5", "87.65", "8.765", "0.876", "0.088", "0.009", "0.0", "-0.009", "-876.5", "-87,650.0"])
        self.verifyDec(style.precision(.fractionLength(0)),         ["87,650", "8,765", "876", "88", "9", "1", "0", "0", "0", "-0", "-876", "-87,650"])
        self.verifyDec(style.precision(.integerLength(3...)),       ["87,650", "8,765", "876.5", "087.65", "008.765", "000.8765", "000.08765", "000.008765", "000", "-000.008765", "-876.5", "-87,650"])
        self.verifyDec(style.precision(.integerAndFractionLength(integerLimits: 3..., fractionLimits: 0 ... 0)),
                       ["87,650", "8,765", "876", "088", "009", "001", "000", "000", "000", "-000", "-876", "-87,650"])
        self.verifyDec(style.precision(.integerLength(1...3)),      ["650", "765", "876.5", "87.65", "8.765", "0.8765", "0.08765", "0.008765", "0", "-0.008765", "-876.5", "-650"])
        self.verifyDec(style.precision(.integerAndFractionLength(integerLimits: 1 ... 3, fractionLimits: 0 ... 0)),
                       ["650", "765", "876", "88", "9", "1", "0", "0", "0", "-0", "-876", "-650"])
        self.verifyDec(style.precision(.integerLength(2 ... 2)),    ["50", "65", "76.5", "87.65", "08.765", "00.8765", "00.08765", "00.008765", "00", "-00.008765", "-76.5", "-50"])
        self.verifyDec(style.precision(.integerAndFractionLength(integerLimits: 2 ... 2, fractionLimits: 0 ... 0)),
                       ["50", "65", "76", "88", "09", "01", "00", "00", "00", "-00", "-76", "-50"])
    }

    func testDecimalFormatStyle_Percent() throws {
        let style = _polyfill_DecimalFormatStyle.Percent(locale: self.enUSLocale)
        
        self.verifyDec(style.precision(.significantDigits(...2)),
                       ["8,800,000%", "880,000%", "88,000%", "8,800%", "880%", "88%", "8.8%", "0.88%", "0%", "-0.88%", "-88,000%", "-8,800,000%"])
        self.verifyDec(style.precision(.fractionLength(1 ... 3)),
                       ["8,765,000.0%", "876,500.0%", "87,650.0%", "8,765.0%", "876.5%", "87.65%", "8.765%", "0.876%", "0.0%", "-0.876%", "-87,650.0%", "-8,765,000.0%"])
        self.verifyDec(style.precision(.integerLength(3...)),
                       ["8,765,000%", "876,500%", "87,650%", "8,765%", "876.5%", "087.65%", "008.765%", "000.8765%", "000%", "-000.8765%", "-87,650%", "-8,765,000%"])
        self.verifyDec(style.precision(.integerLength(1 ... 3)),
                       ["0%", "500%", "650%", "765%", "876.5%", "87.65%", "8.765%", "0.8765%", "0%", "-0.8765%", "-650%", "-0%"])
        self.verifyDec(style.precision(.integerLength(2 ... 2)),
                       ["00%", "00%", "50%", "65%", "76.5%", "87.65%", "08.765%", "00.8765%", "00%", "-00.8765%", "-50%", "-00%"])
    }

    func testDecimalFormatStyle_Currency() throws {
        let style = _polyfill_DecimalFormatStyle.Currency(code: "USD", locale: self.enUSLocale)
        
        self.verifyDec(style, ["$87,650.00", "$8,765.00", "$876.50", "$87.65", "$8.76", "$0.88", "$0.09", "$0.01", "$0.00", "-$0.01", "-$876.50", "-$87,650.00"])
    }

    func testDecimal_withCustomShorthand() throws {
        try XCTSkipUnless(Foundation.Locale.autoupdatingCurrent.language.isEquivalent(to: self.enUSLocale.language),
                          "This test can only be run with the system set to the en_US language")
        
        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(.number.grouping(.never)), "12345")
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(.percent.sign(strategy: .always())), "+1,234,567.8%")
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD").sign(strategy: .accounting)), "($3,000.14)")
    }

    func testDecimal_withShorthand_enUS() throws {
        try XCTSkipUnless(Foundation.Locale.autoupdatingCurrent.language.isEquivalent(to: self.enUSLocale.language),
                          "This test can only be run with the system set to the en_US language")
        
        XCTAssertEqual((12345 as Foundation.Decimal      )._polyfill_formatted(.number              ), "12,345")
        XCTAssertEqual((12345.678 as Foundation.Decimal  )._polyfill_formatted(.number              ), "12,345.678")
        XCTAssertEqual((0 as Foundation.Decimal          )._polyfill_formatted(.number              ), "0")
        XCTAssertEqual((3.14159 as Foundation.Decimal    )._polyfill_formatted(.number              ), "3.14159")
        XCTAssertEqual((-3.14159 as Foundation.Decimal   )._polyfill_formatted(.number              ), "-3.14159")
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.number              ), "-3,000.14159")
        XCTAssertEqual((0.12345 as Foundation.Decimal    )._polyfill_formatted(.percent             ), "12.345%")
        XCTAssertEqual((0.0012345 as Foundation.Decimal  )._polyfill_formatted(.percent             ), "0.12345%")
        XCTAssertEqual((12345 as Foundation.Decimal      )._polyfill_formatted(.percent             ), "1,234,500%")
        XCTAssertEqual((12345.678 as Foundation.Decimal  )._polyfill_formatted(.percent             ), "1,234,567.8%")
        XCTAssertEqual((0 as Foundation.Decimal          )._polyfill_formatted(.percent             ), "0%")
        XCTAssertEqual((3.14159 as Foundation.Decimal    )._polyfill_formatted(.percent             ), "314.159%")
        XCTAssertEqual((-3.14159 as Foundation.Decimal   )._polyfill_formatted(.percent             ), "-314.159%")
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.percent             ), "-300,014.159%")
        XCTAssertEqual((12345 as Foundation.Decimal      )._polyfill_formatted(.currency(code:"USD")), "$12,345.00")
        XCTAssertEqual((12345.678 as Foundation.Decimal  )._polyfill_formatted(.currency(code:"USD")), "$12,345.68")
        XCTAssertEqual((0 as Foundation.Decimal          )._polyfill_formatted(.currency(code:"USD")), "$0.00")
        XCTAssertEqual((3.14159 as Foundation.Decimal    )._polyfill_formatted(.currency(code:"USD")), "$3.14")
        XCTAssertEqual((-3.14159 as Foundation.Decimal   )._polyfill_formatted(.currency(code:"USD")), "-$3.14")
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), "-$3,000.14")
    }

    func testDecimal_default() throws {
        let style = _polyfill_DecimalFormatStyle()

        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(), style.format(12345))
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(), style.format(12345.678))
        XCTAssertEqual((0 as Foundation.Decimal)._polyfill_formatted(), style.format(0))
        XCTAssertEqual((3.14159 as Foundation.Decimal)._polyfill_formatted(), style.format(3.14159))
        XCTAssertEqual((-3.14159 as Foundation.Decimal)._polyfill_formatted(), style.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(), style.format(-3000.14159))
    }

    func testDecimal_default_enUS() throws {
        try XCTSkipUnless(Foundation.Locale.autoupdatingCurrent.language.isEquivalent(to: self.enUSLocale.language),
                          "This test can only be run with the system set to the en_US language")
        
        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(), "12,345")
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(), "12,345.678")
        XCTAssertEqual((0 as Foundation.Decimal)._polyfill_formatted(), "0")
        XCTAssertEqual((3.14159 as Foundation.Decimal)._polyfill_formatted(), "3.14159")
        XCTAssertEqual((-3.14159 as Foundation.Decimal)._polyfill_formatted(), "-3.14159")
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(), "-3,000.14159")
    }

    func testDecimal_withShorthand() throws {
        let style = _polyfill_DecimalFormatStyle()

        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(.number), style.format(12345))
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(.number), style.format(12345.678))
        XCTAssertEqual((0 as Foundation.Decimal)._polyfill_formatted(.number), style.format(0))
        XCTAssertEqual((3.14159 as Foundation.Decimal)._polyfill_formatted(.number), style.format(3.14159))
        XCTAssertEqual((-3.14159 as Foundation.Decimal)._polyfill_formatted(.number), style.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.number), style.format(-3000.14159))

        let percentStyle = _polyfill_DecimalFormatStyle.Percent()

        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(12345))
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(12345.678))
        XCTAssertEqual((0 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(0))
        XCTAssertEqual((3.14159 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(3.14159))
        XCTAssertEqual((-3.14159 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.percent), percentStyle.format(-3000.14159))

        let currencyStyle = _polyfill_DecimalFormatStyle.Currency(code: "USD")

        XCTAssertEqual((12345 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(12345))
        XCTAssertEqual((12345.678 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(12345.678))
        XCTAssertEqual((0 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(0))
        XCTAssertEqual((3.14159 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(3.14159))
        XCTAssertEqual((-3.14159 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(-3.14159))
        XCTAssertEqual((-3000.14159 as Foundation.Decimal)._polyfill_formatted(.currency(code:"USD")), currencyStyle.format(-3000.14159))
    }
}

final class NumberParseStrategyTests: XCTestCase {
    func testIntStrategy() throws {
        let strategy = _polyfill_IntegerParseStrategy(format: _polyfill_IntegerFormatStyle<Int>(), lenient: true)
        
        XCTAssert(try strategy.parse("123,123") == 123123)
        XCTAssert(try strategy.parse(" -123,123 ") == -123123)
        XCTAssert(try strategy.parse("+8,765,000") == 8765000)
        XCTAssert(try strategy.parse("+87,650,000") == 87650000)
    }

    func testParsingCurrency() throws {
        let currencyStyle = _polyfill_IntegerFormatStyle<Int>.Currency(code: "USD", locale: Foundation.Locale(identifier: "en_US"))
        let strategy = _polyfill_IntegerParseStrategy(format: currencyStyle, lenient: true)
        
        XCTAssertEqual(try strategy.parse("$1.00"), 1)
        XCTAssertEqual(try strategy.parse("1.00 US dollars"), 1)
        XCTAssertEqual(try strategy.parse("USD\u{00A0}1.00"), 1)

        XCTAssertEqual(try strategy.parse("$1,234.56"), 1234)
        XCTAssertEqual(try strategy.parse("1,234.56 US dollars"), 1234)
        XCTAssertEqual(try strategy.parse("USD\u{00A0}1,234.56"), 1234)

        XCTAssertEqual(try strategy.parse("-$1,234.56"), -1234)
        XCTAssertEqual(try strategy.parse("-1,234.56 US dollars"), -1234)
        XCTAssertEqual(try strategy.parse("-USD\u{00A0}1,234.56"), -1234)

        let accounting = _polyfill_IntegerParseStrategy(format: currencyStyle.sign(strategy: .accounting), lenient: true)
        
        XCTAssertEqual(try accounting.parse("($1,234.56)"), -1234)
    }

    func testParsingIntStyle() throws {
        func verifyResult(_ testData: [String], _ expected: [Int], _ style: _polyfill_IntegerFormatStyle<Int>, file: StaticString = #filePath, line: UInt = #line) throws {
            for (tst, exp) in zip(testData, expected) {
                XCTAssertEqual(try Int(tst, _polyfill_strategy: style.parseStrategy), exp, file: file, line: line)
            }
        }

        let style = _polyfill_IntegerFormatStyle<Int>(locale: Foundation.Locale(identifier: "en_US"))
        let data = [87650000, 8765000, 876500, 87650, 8765, 876, 87, 8, 0]

        try verifyResult(["8.765E7", "8.765E6", "8.765E5", "8.765E4", "8.765E3", "8.76E2", "8.7E1", "8E0", "0E0"], data, style.notation(.scientific))
        try verifyResult(["87,650,000.", "8,765,000.", "876,500.", "87,650.", "8,765.", "876.", "87.", "8.", "0."], data, style.decimalSeparator(strategy: .always))
    }

    func testRoundtripParsing_percent() throws {
        func verifyRoundtripPercent(_ testData: [Int], _ style: _polyfill_IntegerFormatStyle<Int>.Percent, file: StaticString = #filePath, line: UInt = #line) throws {
            for value in testData {
                let str = style.format(value)

                XCTAssertEqual(value, try Int(str, _polyfill_strategy: style.parseStrategy), file: file, line: line)
                XCTAssertEqual(value, try Int(str, _polyfill_format: style, lenient: false), file: file, line: line)
            }
        }

        let percentStyle = _polyfill_IntegerFormatStyle<Int>.Percent(locale: Foundation.Locale(identifier: "en_US"))
        let testData: [Int] = [87650000, 8765000, 876500, 87650, 8765, 876, 87, 8, 0]
        let negativeData: [Int] = [-87650000, -8765000, -876500, -87650, -8765, -876, -87, -8]
        
        try verifyRoundtripPercent(testData, percentStyle)
        try verifyRoundtripPercent(testData, percentStyle.sign(strategy: .always()))
        try verifyRoundtripPercent(testData, percentStyle.grouping(.never))
        try verifyRoundtripPercent(testData, percentStyle.notation(.scientific))
        try verifyRoundtripPercent(testData, percentStyle.decimalSeparator(strategy: .always))

        try verifyRoundtripPercent(negativeData, percentStyle)
        try verifyRoundtripPercent(negativeData, percentStyle.grouping(.never))
        try verifyRoundtripPercent(negativeData, percentStyle.notation(.scientific))
        try verifyRoundtripPercent(negativeData, percentStyle.decimalSeparator(strategy: .always))

        func verifyRoundtripPercent(_ testData: [Double], _ style: _polyfill_FloatingPointFormatStyle<Double>.Percent, file: StaticString = #filePath, line: UInt = #line) throws {
            for value in testData {
                let str = style.format(value)
                
                XCTAssertEqual(value, try Double(str, _polyfill_format: style, lenient: true), file: file, line: line)
                XCTAssertEqual(value, try Double(str, _polyfill_format: style, lenient: false), file: file, line: line)
            }
        }

        let floatData = testData.map { Double($0) }
        let floatStyle = _polyfill_FloatingPointFormatStyle<Double>.Percent(locale: Foundation.Locale(identifier: "en_US"))
        
        try verifyRoundtripPercent(floatData, floatStyle)
        try verifyRoundtripPercent(floatData, floatStyle.sign(strategy: .always()))
        try verifyRoundtripPercent(floatData, floatStyle.grouping(.never))
        try verifyRoundtripPercent(floatData, floatStyle.notation(.scientific))
        try verifyRoundtripPercent(floatData, floatStyle.decimalSeparator(strategy: .always))
    }

    func test_roundtripCurrency() throws {
        let testData: [Int] = [87650000, 8765000, 876500, 87650, 8765, 876, 87, 8, 0]
        let negativeData: [Int] = [-87650000, -8765000, -876500, -87650, -8765, -876, -87, -8]

        func verifyRoundtripCurrency(_ testData: [Int], _ style: _polyfill_IntegerFormatStyle<Int>.Currency, file: StaticString = #filePath, line: UInt = #line) throws {
            for value in testData {
                let str = style.format(value)

                XCTAssertEqual(value, try Int(str, _polyfill_strategy: style.parseStrategy), file: file, line: line)
                XCTAssertEqual(value, try Int(str, _polyfill_format: style, lenient: false), file: file, line: line)
            }
        }

        let currencyStyle = _polyfill_IntegerFormatStyle<Int>.Currency(code: "USD", locale: Foundation.Locale(identifier: "en_US"))
        
        try verifyRoundtripCurrency(testData, currencyStyle)
        try verifyRoundtripCurrency(testData, currencyStyle.sign(strategy: .always()))
        try verifyRoundtripCurrency(testData, currencyStyle.grouping(.never))
        try verifyRoundtripCurrency(testData, currencyStyle.presentation(.isoCode))
        try verifyRoundtripCurrency(testData, currencyStyle.presentation(.fullName))
        try verifyRoundtripCurrency(testData, currencyStyle.presentation(.narrow))
        try verifyRoundtripCurrency(testData, currencyStyle.decimalSeparator(strategy: .always))

        try verifyRoundtripCurrency(negativeData, currencyStyle)
        try verifyRoundtripCurrency(negativeData, currencyStyle.sign(strategy: .accountingAlways()))
        try verifyRoundtripCurrency(negativeData, currencyStyle.grouping(.never))
        try verifyRoundtripCurrency(negativeData, currencyStyle.presentation(.isoCode))
        try verifyRoundtripCurrency(negativeData, currencyStyle.presentation(.fullName))
        try verifyRoundtripCurrency(negativeData, currencyStyle.presentation(.narrow))
        try verifyRoundtripCurrency(negativeData, currencyStyle.decimalSeparator(strategy: .always))
    }

    let testNegativePositiveDecimalData: [Foundation.Decimal] = [
        .init(string: "87650")!,
        .init(string: "8765")!,
        .init(string: "876.5")!,
        .init(string: "87.65")!,
        .init(string: "8.765")!,
        .init(string: "0.8765")!,
        .init(string: "0.08765")!,
        .init(string: "0.008765")!,
        .init(string: "0")!,
        .init(string: "-0.008765")!,
        .init(string: "-876.5")!,
        .init(string: "-87650")!
    ]

    func testDecimalParseStrategy() throws {
        func verifyRoundtrip(_ testData: [Foundation.Decimal], _ style: _polyfill_DecimalFormatStyle, file: StaticString = #filePath, line: UInt = #line) throws {
            for value in testData {
                let str = style.format(value)

                XCTAssertEqual(value, try Foundation.Decimal(str, _polyfill_strategy: _polyfill_DecimalParseStrategy(formatStyle: style, lenient: true)), file: file, line: line)
            }
        }

        let style = _polyfill_DecimalFormatStyle(locale: Foundation.Locale(identifier: "en_US"))
        
        try verifyRoundtrip(self.testNegativePositiveDecimalData, style)
    }

    func testDecimalParseStrategy_Currency() throws {
        let currencyStyle = _polyfill_DecimalFormatStyle.Currency(code: "USD", locale: Foundation.Locale(identifier: "en_US"))
        let strategy = _polyfill_DecimalParseStrategy(formatStyle: currencyStyle, lenient: true)
        
        XCTAssertEqual(try strategy.parse("$1.00"), 1)
        XCTAssertEqual(try strategy.parse("1.00 US dollars"), 1)
        XCTAssertEqual(try strategy.parse("USD\u{00A0}1.00"), 1)

        XCTAssertEqual(try strategy.parse("$1,234.56"), Foundation.Decimal(string: "1234.56")!)
        XCTAssertEqual(try strategy.parse("1,234.56 US dollars"), Foundation.Decimal(string: "1234.56")!)
        XCTAssertEqual(try strategy.parse("USD\u{00A0}1,234.56"), Foundation.Decimal(string: "1234.56")!)

        XCTAssertEqual(try strategy.parse("-$1,234.56"), Foundation.Decimal(string: "-1234.56")!)
        XCTAssertEqual(try strategy.parse("-1,234.56 US dollars"), Foundation.Decimal(string: "-1234.56")!)
        XCTAssertEqual(try strategy.parse("-USD\u{00A0}1,234.56"), Foundation.Decimal(string: "-1234.56")!)
    }
}

final class NumberExtensionParseStrategyTests: XCTestCase {
    let enUS = Foundation.Locale(identifier: "en_US")

    func testDecimal_stringLength() throws {
        let numberStyle = _polyfill_DecimalFormatStyle(locale: self.enUS)
        
        XCTAssertNotNil(try Foundation.Decimal("-3,000.14159", _polyfill_format: numberStyle))
        XCTAssertNotNil(try Foundation.Decimal("-3.14159",     _polyfill_format: numberStyle))
        XCTAssertNotNil(try Foundation.Decimal("12,345.678",   _polyfill_format: numberStyle))
        XCTAssertNotNil(try Foundation.Decimal("0.00",         _polyfill_format: numberStyle))

        let percentStyle = _polyfill_DecimalFormatStyle.Percent(locale: self.enUS)
        
        XCTAssertNotNil(try Foundation.Decimal("-3,000.14159%", _polyfill_format: percentStyle))
        XCTAssertNotNil(try Foundation.Decimal("-3.14159%",     _polyfill_format: percentStyle))
        XCTAssertNotNil(try Foundation.Decimal("12,345.678%",   _polyfill_format: percentStyle))
        XCTAssertNotNil(try Foundation.Decimal("0.00%",         _polyfill_format: percentStyle))

        let currencyStyle = _polyfill_DecimalFormatStyle.Currency(code: "USD", locale: self.enUS)
        
        XCTAssertNotNil(try Foundation.Decimal("$12,345.00",     _polyfill_format: currencyStyle))
        XCTAssertNotNil(try Foundation.Decimal("$12345.68",      _polyfill_format: currencyStyle))
        XCTAssertNotNil(try Foundation.Decimal("$0.00",          _polyfill_format: currencyStyle))
        XCTAssertNotNil(try Foundation.Decimal("-$3000.0000014", _polyfill_format: currencyStyle))
    }

    func testDecimal_withFormat() throws {
        XCTAssertEqual(try Foundation.Decimal("+3000", _polyfill_format: .number.locale(self.enUS).grouping(.never).sign(strategy: .always())), Foundation.Decimal(3000))
        XCTAssertEqual(try Foundation.Decimal("$3000", _polyfill_format: .currency(code: "USD").locale(self.enUS).grouping(.never)), Foundation.Decimal(3000))
    }

    func testDecimal_withFormat_localeDependent() throws {
        try XCTSkipUnless(Foundation.Locale.autoupdatingCurrent.language.isEquivalent(to: .init(identifier: "en_US")),
                          "This test can only be run with the system set to the en_US language")

        XCTAssertEqual(try Foundation.Decimal("-3,000.14159", _polyfill_format: .number), Foundation.Decimal(-3000.14159))
        XCTAssertEqual(try Foundation.Decimal("-3.14159",     _polyfill_format: .number), Foundation.Decimal(-3.14159))
        XCTAssertEqual(try Foundation.Decimal("12,345.678",   _polyfill_format: .number), Foundation.Decimal(12345.678))
        XCTAssertEqual(try Foundation.Decimal("0.00",         _polyfill_format: .number), 0)

        XCTAssertEqual(try Foundation.Decimal("-3,000.14159%", _polyfill_format: .percent), Foundation.Decimal(-30.0014159))
        XCTAssertEqual(try Foundation.Decimal("-314.159%",     _polyfill_format: .percent), Foundation.Decimal(-3.14159))
        XCTAssertEqual(try Foundation.Decimal("12,345.678%",   _polyfill_format: .percent), Foundation.Decimal(123.45678))
        XCTAssertEqual(try Foundation.Decimal("0.00%",         _polyfill_format: .percent), 0)

        XCTAssertEqual(try Foundation.Decimal("$12,345.00",     _polyfill_format: .currency(code: "USD")), Foundation.Decimal(12345))
        XCTAssertEqual(try Foundation.Decimal("$12345.68",      _polyfill_format: .currency(code: "USD")), Foundation.Decimal(12345.68))
        XCTAssertEqual(try Foundation.Decimal("$0.00",          _polyfill_format: .currency(code: "USD")), Foundation.Decimal(0))
        XCTAssertEqual(try Foundation.Decimal("-$3000.0000014", _polyfill_format: .currency(code: "USD")), Foundation.Decimal(string: "-3000.0000014")!)
    }
}
