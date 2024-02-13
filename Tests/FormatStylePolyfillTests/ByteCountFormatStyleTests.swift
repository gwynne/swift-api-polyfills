import FormatStylePolyfill
import XCTest

final class ByteCountFormatStyleTests : XCTestCase {
    private static let locales = [
        Locale(identifier: "en_US"),
        .init(identifier: "fr_FR"),
        .init(identifier: "zh_TW"),
        .init(identifier: "zh_CN"),
        .init(identifier: "ar"),
    ]

    func test_zeroSpelledOutKb() {
        let localizedZerosSpelledOutKb: [Locale: String] = [
            Locale(identifier: "en_US"): "Zero kB",
            Locale(identifier: "fr_FR"): "Zéro ko",
            Locale(identifier: "zh_TW"): "0 kB",
            Locale(identifier: "zh_CN"): "0 kB",
            Locale(identifier: "ar"): "صفر كيلوبايت",
        ]

        for locale in Self.locales {
            XCTAssertEqual(
                0._polyfill_formatted(.byteCount(style: .memory, spellsOutZero: true).locale(locale)),
                localizedZerosSpelledOutKb[locale],
                "locale: \(locale.identifier) failed expectation"
            )
        }
    }

    func test_zeroSpelledOutBytes() {
        let localizedZerosSpelledOutBytes: [Locale: String] = [
            Locale(identifier: "en_US"): "Zero bytes",
            Locale(identifier: "fr_FR"): "Zéro octet",
            Locale(identifier: "zh_TW"): "0 byte",
            Locale(identifier: "zh_CN"): "0字节",
            Locale(identifier: "ar"): "صفر بايت",
        ]

        for locale in Self.locales {
            XCTAssertEqual(
                0._polyfill_formatted(.byteCount(style: .memory, allowedUnits: .bytes, spellsOutZero: true).locale(locale)),
                localizedZerosSpelledOutBytes[locale],
                "locale: \(locale.identifier) failed expectation"
            )
        }
    }

    private static let localizedSingular: [Locale: [String]] = [
        Locale(identifier: "en_US"): ["1 byte",     "1 kB",       "1 MB",       "1 GB",       "1 TB",       "1 PB"],
        Locale(identifier: "fr_FR"): ["1 octet",    "1 ko",       "1 Mo",       "1 Go",       "1 To",       "1 Po"],
        Locale(identifier: "zh_TW"): ["1 byte",     "1 kB",       "1 MB",       "1 GB",       "1 TB",       "1 PB"],
        Locale(identifier: "zh_CN"): ["1 byte",     "1 kB",       "1 MB",       "1 GB",       "1 TB",       "1 PB"],
        Locale(identifier: "ar"):    ["١ بايت", "١ كيلوبايت", "١ ميغابايت", "١ غيغابايت", "١ تيرابايت", "١ بيتابايت"]
    ]

    #if false
    func test_singularUnitsBinary() {
        for locale in Self.locales {
            for i in 0...5 {
                let value: Int64 = (1 << (i * 10))
                
                XCTAssertEqual(value._polyfill_formatted(.byteCount(style: .memory).locale(locale)), Self.localizedSingular[locale]![i])
            }
        }
    }

    func test_singularUnitsDecimal() {
        for locale in Self.locales {
            for i in 0...5 {
                XCTAssertEqual(Int64(Double.pow(10.0, Double(i * 3)))._polyfill_formatted(.byteCount(style: .file).locale(locale)), Self.localizedSingular[locale]![i])
            }
        }
    }
    #endif

    func test_localizedParens() {
        XCTAssertEqual(
            1024._polyfill_formatted(.byteCount(style: _polyfill_ByteCountFormatStyle.Style.binary, includesActualByteCount: true).locale(.init(identifier: "zh_TW"))),
            "1 kB（1,024 byte）"
        )
        XCTAssertEqual(
            1024._polyfill_formatted(.byteCount(style: _polyfill_ByteCountFormatStyle.Style.binary, includesActualByteCount: true).locale(.init(identifier: "en_US"))),
            "1 kB (1,024 bytes)"
        )
    }

    func testActualByteCount() {
        XCTAssertEqual(
            1024._polyfill_formatted(.byteCount(style: _polyfill_ByteCountFormatStyle.Style.file, includesActualByteCount: true)),
            "1 kB (1,024 bytes)"
        )
    }

    func test_RTL() {
        XCTAssertEqual(
            1024._polyfill_formatted(.byteCount(style: _polyfill_ByteCountFormatStyle.Style.binary, includesActualByteCount: true).locale(.init(identifier: "ar"))),
            "١ كيلوبايت (١٬٠٢٤ بايت)"
        )
    }

    func testAttributed() {
        var expected: [BCSegment]

        expected = [
            .init(string: "Zero",                                              byteCount: .spelledOutValue),
            .space,
            .init(string: "kB",                                                byteCount: .unit(.kb))
        ]
        XCTAssertEqual(0._polyfill_formatted(.byteCount(style: .file, spellsOutZero: true).attributed), expected.attributedString)
        expected = [
            .intOne,
            .space,
            .init(string: "byte",                                              byteCount: .unit(.byte))
        ]
        XCTAssertEqual(1._polyfill_formatted(.byteCount(style: .file).attributed), expected.attributedString)
        expected = [
            .intOne,
            .init(string: ",",   number: .integer, symbol: .groupingSeparator, byteCount: .value),
            .init(string: "000", number: .integer,                             byteCount: .value),
            .space,
            .init(string: "bytes",                                             byteCount: .unit(.byte))
        ]
        XCTAssertEqual(1000._polyfill_formatted(.byteCount(style: .memory).attributed), expected.attributedString)
        expected = [
            .intOne,
            .init(string: ",",   number: .integer, symbol: .groupingSeparator, byteCount: .value),
            .init(string: "016", number: .integer,                             byteCount: .value),
            .space,
            .init(string: "kB",                                                byteCount: .unit(.kb))
        ]
        XCTAssertEqual(1_040_000._polyfill_formatted(.byteCount(style: .memory).attributed), expected.attributedString)
        expected = [
            .intOne,
            .init(string: ".",                     symbol: .decimalSeparator,  byteCount: .value),
            .init(string: "1",   number: .fraction,                            byteCount: .value),
            .space,
            .init(string: "MB",                                                byteCount: .unit(.mb))
        ]
        XCTAssertEqual(1_100_000._polyfill_formatted(.byteCount(style: .file).attributed), expected.attributedString)
        expected = [
            .init(string: "4",   number: .integer,                             byteCount: .value),
            .init(string: ".",                     symbol: .decimalSeparator,  byteCount: .value),
            .init(string: "2",   number: .fraction,                            byteCount: .value),
            .space,
            .init(string: "GB",                                                byteCount: .unit(.gb)),
            .space,
            .openParen,
            .init(string: "4",   number: .integer,                             byteCount: .actualByteCount),
            .init(string: ",",   number: .integer, symbol: .groupingSeparator, byteCount: .actualByteCount),
            .init(string: "200", number: .integer,                             byteCount: .actualByteCount),
            .init(string: ",",   number: .integer, symbol: .groupingSeparator, byteCount: .actualByteCount),
            .init(string: "000", number: .integer,                             byteCount: .actualByteCount),
            .init(string: ",",   number: .integer, symbol: .groupingSeparator, byteCount: .actualByteCount),
            .init(string: "000", number: .integer,                             byteCount: .actualByteCount),
            .space,
            .init(string: "bytes",                                             byteCount: .unit(.byte)),
            .closedParen
        ]
        XCTAssertEqual(Int64(4_200_000_000)._polyfill_formatted(.byteCount(style: .file, includesActualByteCount: true).attributed), expected.attributedString)
    }

    func testEveryAllowedUnit() {
        // 84270854: The largest unit supported currently is pb
        let expectations: [_polyfill_ByteCountFormatStyle.Units: String] = [
            .bytes: "10,000,000,000,000,000 bytes",
            .kb: "10,000,000,000,000 kB",
            .mb: "10,000,000,000 MB",
            .gb: "10,000,000 GB",
            .tb: "10,000 TB",
            .pb: "10 PB",
            .eb: "10 PB",
            .zb: "10 PB",
            .ybOrHigher: "10 PB"
        ]

        for (units, expectation) in expectations {
            XCTAssertEqual(10_000_000_000_000_000._polyfill_formatted(.byteCount(style: .file, allowedUnits: units).locale(Locale(identifier: "en_US"))), expectation)
        }
    }
}

fileprivate struct BCSegment {
    let string: String
    let number: AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart?
    let symbol: AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol?
    let byteCount: AttributeScopes.FoundationAttributes.ByteCountAttribute.Component?

    init(
        string: String,
        number: AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart? = nil,
        symbol: AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol? = nil,
        byteCount: AttributeScopes.FoundationAttributes.ByteCountAttribute.Component? = nil
    ) {
        self.string = string
        self.number = number
        self.symbol = symbol
        self.byteCount = byteCount
    }

    static var space: Self       { .init(string: " ") }
    static var openParen: Self   { .init(string: "(") }
    static var closedParen: Self { .init(string: ")") }
    static var intOne: Self      { .init(string: "1", number: .integer, byteCount: .value) }
}

extension Sequence<BCSegment> {
    var attributedString: AttributedString {
        self.map { segment in
            var attributed = AttributedString(segment.string)

            if let symbol = segment.symbol       { attributed.numberSymbol = symbol }
            if let number = segment.number       { attributed.numberPart = number }
            if let byteCount = segment.byteCount { attributed.byteCount = byteCount }

            return attributed
        }.reduce(into: .init()) { $0 += $1 }
    }
}
