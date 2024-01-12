import FormatStylePolyfill
import XCTest

final class ListFormatStyleTests: XCTestCase {
    func test_orList() {
        let style = _polyfill_ListFormatStyle<_polyfill_StringStyle, [String]>.list(type: .or, width: .standard).locale(.init(identifier: "en_US"))
        XCTAssertEqual(["one", "two"]._polyfill_formatted(style), "one or two")
        XCTAssertEqual(["one", "two", "three"]._polyfill_formatted(style), "one, two, or three")
    }

    func test_andList() {
        let style = _polyfill_ListFormatStyle<_polyfill_StringStyle, [String]>.list(type: .and, width: .standard).locale(.init(identifier: "en_US"))
        XCTAssertEqual(["one", "two"]._polyfill_formatted(style), "one and two")
        XCTAssertEqual(["one", "two", "three"]._polyfill_formatted(style), "one, two, and three")
    }

    func test_narrowList() {
        let style = _polyfill_ListFormatStyle<_polyfill_StringStyle, [String]>.list(type: .and, width: .narrow).locale(.init(identifier: "en_US"))
        XCTAssertEqual(["one", "two"]._polyfill_formatted(style), "one, two")
        XCTAssertEqual(["one", "two", "three"]._polyfill_formatted(style), "one, two, three")
    }

    func test_shortList() {
        let style = _polyfill_ListFormatStyle<_polyfill_StringStyle, [String]>.list(type: .and, width: .short).locale(.init(identifier: "en_US"))
        XCTAssertEqual(["one", "two"]._polyfill_formatted(style), "one & two")
        XCTAssertEqual(["one", "two", "three"]._polyfill_formatted(style), "one, two, & three")
    }
}
