import FormatStylePolyfill
import XCTest

final class BinaryIntegerFormatStyleTests: XCTestCase {
    func checkNSR(value: some BinaryInteger, expected: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(String(decoding: value.numericStringRepresentation.utf8, as: Unicode.ASCII.self), expected, file: file, line: line)
    }

    func testNumericStringRepresentation_builtinIntegersLimits() throws {
        func check<I: FixedWidthInteger>(type: I.Type = I.self, min: String, max: String) {
            checkNSR(value: I.min, expected: min)
            checkNSR(value: I.max, expected: max)
        }
        check(type:  Int8.self,  min: "-128",                 max: "127")
        check(type:  Int16.self, min: "-32768",               max: "32767")
        check(type:  Int32.self, min: "-2147483648",          max: "2147483647")
        check(type:  Int64.self, min: "-9223372036854775808", max: "9223372036854775807")
        check(type: UInt8.self,  min: "0",                    max: "255")
        check(type: UInt16.self, min: "0",                    max: "65535")
        check(type: UInt32.self, min: "0",                    max: "4294967295")
        check(type: UInt64.self, min: "0",                    max: "18446744073709551615")
    }

    func testNumericStringRepresentation_builtinIntegersAroundDecimalMagnitude() throws {
        func check<I: FixedWidthInteger>(type: I.Type = I.self, magnitude: String, oneLess: String, oneMore: String, file: StaticString = #filePath, line: UInt = #line) {
            var mag = I(1)
            while !mag.multipliedReportingOverflow(by: 10).overflow { mag *= 10 }
            
            checkNSR(value: mag, expected: magnitude, file: file, line: line)
            checkNSR(value: mag - 1, expected: oneLess, file: file, line: line)
            checkNSR(value: mag + 1, expected: oneMore, file: file, line: line)
        }
        
        check(type:  Int8.self,  magnitude: "100",                  oneLess: "99",                  oneMore: "101")
        check(type:  Int16.self, magnitude: "10000",                oneLess: "9999",                oneMore: "10001")
        check(type:  Int32.self, magnitude: "1000000000",           oneLess: "999999999",           oneMore: "1000000001")
        check(type:  Int64.self, magnitude: "1000000000000000000",  oneLess: "999999999999999999",  oneMore: "1000000000000000001")
        check(type: UInt8.self,  magnitude: "100",                  oneLess: "99",                  oneMore: "101")
        check(type: UInt16.self, magnitude: "10000",                oneLess: "9999",                oneMore: "10001")
        check(type: UInt32.self, magnitude: "1000000000",           oneLess: "999999999",           oneMore: "1000000001")
        check(type: UInt64.self, magnitude: "10000000000000000000", oneLess: "9999999999999999999", oneMore: "10000000000000000001")
    }

    func testInt32() {
        check( Int32(truncatingIfNeeded: 0x00000000 as UInt32),                           expectation:           "0")
        check( Int32(truncatingIfNeeded: 0x03020100 as UInt32),                           expectation:    "50462976")
        check( Int32(truncatingIfNeeded: 0x7fffffff as UInt32),                           expectation:  "2147483647") //  Int32.max
        check( Int32(truncatingIfNeeded: 0x80000000 as UInt32),                           expectation: "-2147483648") //  Int32.min
        check( Int32(truncatingIfNeeded: 0x81807f7e as UInt32),                           expectation: "-2122285186")
        check( Int32(truncatingIfNeeded: 0xfffefdfc as UInt32),                           expectation:      "-66052")
        check( Int32(truncatingIfNeeded: 0xffffffff as UInt32),                           expectation:          "-1")
    }
    
    func testUInt32() {
        check(UInt32(truncatingIfNeeded: 0x00000000 as UInt32),                           expectation:           "0") // UInt32.min
        check(UInt32(truncatingIfNeeded: 0x03020100 as UInt32),                           expectation:    "50462976")
        check(UInt32(truncatingIfNeeded: 0x7fffffff as UInt32),                           expectation:  "2147483647")
        check(UInt32(truncatingIfNeeded: 0x80000000 as UInt32),                           expectation:  "2147483648")
        check(UInt32(truncatingIfNeeded: 0x81807f7e as UInt32),                           expectation:  "2172682110")
        check(UInt32(truncatingIfNeeded: 0xfffefdfc as UInt32),                           expectation:  "4294901244")
        check(UInt32(truncatingIfNeeded: 0xffffffff as UInt32),                           expectation:  "4294967295") // UInt32.max
    }
    
    func testInt64() {
        check( Int64(truncatingIfNeeded: 0x0000000000000000 as UInt64),                   expectation:                    "0")
        check( Int64(truncatingIfNeeded: 0x0706050403020100 as UInt64),                   expectation:   "506097522914230528")
        check( Int64(truncatingIfNeeded: 0x7fffffffffffffff as UInt64),                   expectation:  "9223372036854775807") //  Int64.max
        check( Int64(truncatingIfNeeded: 0x8000000000000000 as UInt64),                   expectation: "-9223372036854775808") //  Int64.max
        check( Int64(truncatingIfNeeded: 0x838281807f7e7d7c as UInt64),                   expectation: "-8970465118873813636")
        check( Int64(truncatingIfNeeded: 0xfffefdfcfbfaf9f8 as UInt64),                   expectation:     "-283686952306184")
        check( Int64(truncatingIfNeeded: 0xffffffffffffffff as UInt64),                   expectation:                   "-1")
    }
    
    func testUInt64() {
        check(UInt64(truncatingIfNeeded: 0x0000000000000000 as UInt64),                   expectation:                    "0") // UInt64.min
        check(UInt64(truncatingIfNeeded: 0x0706050403020100 as UInt64),                   expectation:   "506097522914230528")
        check(UInt64(truncatingIfNeeded: 0x7fffffffffffffff as UInt64),                   expectation:  "9223372036854775807")
        check(UInt64(truncatingIfNeeded: 0x8000000000000000 as UInt64),                   expectation:  "9223372036854775808")
        check(UInt64(truncatingIfNeeded: 0x838281807f7e7d7c as UInt64),                   expectation:  "9476278954835737980")
        check(UInt64(truncatingIfNeeded: 0xfffefdfcfbfaf9f8 as UInt64),                   expectation: "18446460386757245432")
        check(UInt64(truncatingIfNeeded: 0xffffffffffffffff as UInt64),                   expectation: "18446744073709551615") // UInt64.max
    }
    
    func testInt128() {
        check(x64: [0x0000000000000000, 0x0000000000000000] as [UInt64], isSigned: true,  expectation:                                        "0")
        check(x64: [0x0706050403020100, 0x0f0e0d0c0b0a0908] as [UInt64], isSigned: true,  expectation:   "20011376718272490338853433276725592320")
        check(x64: [0xffffffffffffffff, 0x7fffffffffffffff] as [UInt64], isSigned: true,  expectation:  "170141183460469231731687303715884105727") //  Int128.max
        check(x64: [0x0000000000000000, 0x8000000000000000] as [UInt64], isSigned: true,  expectation: "-170141183460469231731687303715884105728") //  Int128.min
        check(x64: [0xf7f6f5f4f3f2f1f0, 0xfffefdfcfbfaf9f8] as [UInt64], isSigned: true,  expectation:      "-5233100606242806050955395731361296")
        check(x64: [0xffffffffffffffff, 0xffffffffffffffff] as [UInt64], isSigned: true,  expectation:                                       "-1")
    }
    
    func testUInt128() {
        check(x64: [0x0000000000000000, 0x0000000000000000] as [UInt64], isSigned: false, expectation:                                        "0") // UInt128.min
        check(x64: [0x0706050403020100, 0x0f0e0d0c0b0a0908] as [UInt64], isSigned: false, expectation:   "20011376718272490338853433276725592320")
        check(x64: [0x0000000000000000, 0x8000000000000000] as [UInt64], isSigned: false, expectation:  "170141183460469231731687303715884105728")
        check(x64: [0xf7f6f5f4f3f2f1f0, 0xfffefdfcfbfaf9f8] as [UInt64], isSigned: false, expectation:  "340277133820332220657323652036036850160")
        check(x64: [0xffffffffffffffff, 0x7fffffffffffffff] as [UInt64], isSigned: false, expectation:  "170141183460469231731687303715884105727")
        check(x64: [0xffffffffffffffff, 0xffffffffffffffff] as [UInt64], isSigned: false, expectation:  "340282366920938463463374607431768211455") // UInt128.max
    }
    
    func testSignExtendingDoesNotChangeTheResult() {
        check(words: [ 0            ] as [UInt],                        areSigned: true,  expectation:  "0")
        check(words: [ 0,  0        ] as [UInt],                        areSigned: true,  expectation:  "0")
        check(words: [ 0,  0,  0    ] as [UInt],                        areSigned: true,  expectation:  "0")
        check(words: [ 0,  0,  0,  0] as [UInt],                        areSigned: true,  expectation:  "0")
        
        check(words: [~0            ] as [UInt],                        areSigned: true,  expectation: "-1")
        check(words: [~0, ~0        ] as [UInt],                        areSigned: true,  expectation: "-1")
        check(words: [~0, ~0, ~0    ] as [UInt],                        areSigned: true,  expectation: "-1")
        check(words: [~0, ~0, ~0, ~0] as [UInt],                        areSigned: true,  expectation: "-1")
        
        check(words: [ 0            ] as [UInt],                        areSigned: false, expectation:  "0")
        check(words: [ 0,  0        ] as [UInt],                        areSigned: false, expectation:  "0")
        check(words: [ 0,  0,  0    ] as [UInt],                        areSigned: false, expectation:  "0")
        check(words: [ 0,  0,  0,  0] as [UInt],                        areSigned: false, expectation:  "0")
    }
    
    func check(_ integer: some BinaryInteger, expectation: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(integer.description, expectation, file: file, line: line)
        
        check(ascii: integer.numericStringRepresentation.utf8, expectation: expectation, file: file, line: line)
        check(words: Array(integer.words), areSigned: type(of: integer).isSigned, expectation: expectation, file: file, line: line)
    }
    
    func check(x64: [UInt64], isSigned: Bool, expectation: String, file: StaticString = #filePath, line: UInt = #line) {
        check(words: x64.flatMap(\.words), areSigned: isSigned, expectation: expectation, file: file, line: line)
    }
    
    func check(words: [UInt], areSigned: Bool, expectation: String, file: StaticString = #filePath, line: UInt = #line) {
        var words = words

        check(ascii: numericStringRepresentationForWords(&words, isSigned: areSigned).utf8, expectation: expectation, file: file, line: line)
    }
    
    func check(ascii: some Collection<UInt8>, expectation: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(String(decoding: ascii, as: Unicode.ASCII.self), expectation, file: file, line: line)
    }
}
