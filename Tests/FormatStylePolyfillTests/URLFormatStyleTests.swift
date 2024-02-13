import Algorithms
import FormatStylePolyfill
import class XCTest.XCTestCase
import func XCTest.XCTAssert
import func XCTest.XCTAssertEqual
import func XCTest.XCTAssertFalse
import func XCTest.XCTAssertNil
import func XCTest.XCTAssertThrowsError
import struct Foundation.Locale
import struct Foundation.TimeZone
import struct Foundation.URL
import struct Foundation.URLComponents
import RegexBuilder

extension URLComponents {
    var stringPort: String? {
        get { self.port.map(String.init(_:)) }
        set { self.port = newValue.flatMap(Int.init(_:)) }
    }
    
    var optionalPath: String? {
        get { self.path }
        set { self.path = newValue ?? "" }
    }
}

final class URLFormatStyleTests: XCTestCase {
    func testDocExamples() {
        // These are all originally taken from doc comments; they've been harshly trimmed, but are functionally identical.
        let endpointUrl = Foundation.URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
        
        XCTAssertEqual(_polyfill_URLFormatStyle(scheme: .never, port: .never).format(endpointUrl), "www.example.com/path/to/endpoint")
        XCTAssertEqual(endpointUrl._polyfill_formatted(), "https://www.example.com/path/to/endpoint")
        XCTAssertEqual(endpointUrl._polyfill_formatted(.url.scheme(.never).port(.never)), "www.example.com/path/to/endpoint")
        XCTAssertEqual(
            endpointUrl._polyfill_formatted(.url.scheme(.never).host(.omitSpecificSubdomains(["www"])).port(.never)),
            "example.com/path/to/endpoint"
        )

        let style = _polyfill_URLFormatStyle(
            scheme: .never,
            host: .omitSpecificSubdomains(["www"], includeMultiLevelSubdomains: true),
            port: .never
        )
        
        XCTAssertEqual(Foundation.URL(string: "https://www.example.com/path/one")!._polyfill_formatted(style), "example.com/path/one")
        XCTAssertEqual(Foundation.URL(string: "https://beta.example.com/path/two")!._polyfill_formatted(style), "beta.example.com/path/two")
        XCTAssertEqual(Foundation.URL(string: "https://beta.staging.west.example.com/three")!._polyfill_formatted(style), "west.example.com/three")
        XCTAssertEqual(Foundation.URL(string: "https://query.example.com/four?key4=value4")!._polyfill_formatted(style), "query.example.com/four")
    }
    
    func testFormatMatrix() throws {
        let host = "foo.bar.www.example.com"
        let urls = [
            "https:",
            "//\(host)",
            "ftp://\(host)",
            "https://\(host)",
            "https://user@\(host)",
            "https://user:pass@\(host)",
            "https://user:pass@\(host):8080",
            "https://user:pass@\(host):8080/path/to/endpoint",
            "https://user:pass@\(host):8080/path/to/endpoint?key=value",
            "https://user:pass@\(host):8080/path/to/endpoint?key=value#anchor",
            "https://user:pass@1.2.3.4:8080/path/to/endpoint?key=value#anchor",
            "https://user:pass@[aa:bb:cc:dd:ee:ff]:8080/path/to/endpoint?key=value#anchor",
        ].map { Foundation.URL(string: $0)! }
        
        func check(_ style: _polyfill_URLFormatStyle, expect: [String], file: StaticString = #filePath, line: UInt = #line) {
            assert(expect.count == urls.count)
            
            for (url, expected) in zip(urls, expect) {
                XCTAssertEqual(url._polyfill_formatted(style), expected, file: file, line: line)
            }
        }
        
        check(.url.scheme(.never), expect: [
            "", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)",
            "\(host)/path/to/endpoint", "\(host)/path/to/endpoint", "\(host)/path/to/endpoint",
            "1.2.3.4/path/to/endpoint", "[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.scheme(.omitIfHTTPFamily), expect: [
            "", "\(host)", "ftp://\(host)", "\(host)", "\(host)", "\(host)", "\(host)",
            "\(host)/path/to/endpoint", "\(host)/path/to/endpoint", "\(host)/path/to/endpoint",
            "1.2.3.4/path/to/endpoint", "[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.scheme(.displayWhen(.host, matches: ["\(host)"])), expect: [
            "", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host)",
            "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint",
            "1.2.3.4/path/to/endpoint", "[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.scheme(.displayWhen(.host, matches: ["www.example.com"])), expect: [
            "", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)",
            "\(host)/path/to/endpoint", "\(host)/path/to/endpoint", "\(host)/path/to/endpoint",
            "1.2.3.4/path/to/endpoint", "[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.scheme(.omitWhen(.host, matches: ["\(host)"])), expect: [
            "https:", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)", "\(host)",
            "\(host)/path/to/endpoint", "\(host)/path/to/endpoint", "\(host)/path/to/endpoint",
            "https://1.2.3.4/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.user(.always).password(.always), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://user:pass@\(host)", "https://user:pass@\(host)",
            "https://user:pass@\(host)/path/to/endpoint", "https://user:pass@\(host)/path/to/endpoint", "https://user:pass@\(host)/path/to/endpoint", "https://user:pass@1.2.3.4/path/to/endpoint",
            "https://user:pass@[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.host(.never), expect: [
            "https:", "", "ftp:", "https:", "https:", "https:", "https:",
            "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint",
        ])
        check(.url.host(.displayWhen(.host, matches: [host])), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host)",
            "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint",
            "https:/path/to/endpoint", "https:/path/to/endpoint",
        ])
        check(.url.host(.omitWhen(.host, matches: [host])), expect: [
            "https:", "", "ftp:", "https:", "https:", "https:", "https:", "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint",
            "https://1.2.3.4/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.host(.omitIfHTTPFamily), expect: [
            "https:", "\(host)", "ftp://\(host)", "https:", "https:", "https:", "https:",
            "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint", "https:/path/to/endpoint",
        ])
        check(.url.host(.omitSpecificSubdomains([], includeMultiLevelSubdomains: true)), expect: [
            "https:", "www.example.com", "ftp://www.example.com", "https://www.example.com", "https://www.example.com", "https://www.example.com", "https://www.example.com",
            "https://www.example.com/path/to/endpoint", "https://www.example.com/path/to/endpoint", "https://www.example.com/path/to/endpoint",
            "https://1.2.3.4/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.host(.omitSpecificSubdomains(["www", "foo"], includeMultiLevelSubdomains: false)), expect: [
            "https:", "bar.www.example.com", "ftp://bar.www.example.com",
            "https://bar.www.example.com", "https://bar.www.example.com", "https://bar.www.example.com", "https://bar.www.example.com",
            "https://bar.www.example.com/path/to/endpoint", "https://bar.www.example.com/path/to/endpoint", "https://bar.www.example.com/path/to/endpoint",
            "https://1.2.3.4/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.host(.omitSpecificSubdomains(["www", "foo"], includeMultiLevelSubdomains: true)), expect: [
            "https:", "example.com", "ftp://example.com", "https://example.com", "https://example.com", "https://example.com", "https://example.com",
            "https://example.com/path/to/endpoint", "https://example.com/path/to/endpoint", "https://example.com/path/to/endpoint",
            "https://1.2.3.4/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint",
        ])
        check(.url.host(.omitSpecificSubdomains(["www", "foo"], includeMultiLevelSubdomains: true, when: .host, matches: ["\(host)"])), expect: [
            "https:", "example.com", "ftp://example.com", "https://example.com", "https://example.com", "https://example.com", "https://example.com",
            "https://example.com/path/to/endpoint", "https://example.com/path/to/endpoint", "https://example.com/path/to/endpoint",
            "https:/path/to/endpoint", "https:/path/to/endpoint",
        ])
        check(.url.port(.always), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host):8080",
            "https://\(host):8080/path/to/endpoint", "https://\(host):8080/path/to/endpoint", "https://\(host):8080/path/to/endpoint",
            "https://1.2.3.4:8080/path/to/endpoint", "https://[aa:bb:cc:dd:ee:ff]:8080/path/to/endpoint",
        ])
        check(.url.path(.never), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host)",
            "https://\(host)", "https://\(host)", "https://\(host)", "https://1.2.3.4", "https://[aa:bb:cc:dd:ee:ff]",
        ])
        check(.url.query(.always), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host)",
            "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint?key=value", "https://\(host)/path/to/endpoint?key=value",
            "https://1.2.3.4/path/to/endpoint?key=value", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint?key=value",
        ])
        check(.url.fragment(.always), expect: [
            "https:", "\(host)", "ftp://\(host)", "https://\(host)", "https://\(host)", "https://\(host)", "https://\(host)",
            "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint", "https://\(host)/path/to/endpoint#anchor",
            "https://1.2.3.4/path/to/endpoint#anchor", "https://[aa:bb:cc:dd:ee:ff]/path/to/endpoint#anchor",
        ])
    }
    
    func testDescriptions() {
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.scheme.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.user.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.password.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.host.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.port.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.path.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.query.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.Component.fragment.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.ComponentDisplayOption.always.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.ComponentDisplayOption.never.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.ComponentDisplayOption.omitIfHTTPFamily.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.HostDisplayOption.always.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.HostDisplayOption.never.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.HostDisplayOption.omitIfHTTPFamily.description.isEmpty)
        XCTAssertFalse(_polyfill_URLFormatStyle.HostDisplayOption.omitSpecificSubdomains(when: .host, matches: []).description.isEmpty)
    }
}

final class URLParseStrategyTests: XCTestCase {
    func testDocExamples() throws {
        let strategy = _polyfill_URLParseStrategy(scheme: .defaultValue("https"), host: .required, path: .required, query: .required)

        XCTAssertThrowsError(try strategy.parse("example.com?key1=value1"))
        XCTAssertThrowsError(try strategy.parse("https://example.com?key2=value2"))
        XCTAssertThrowsError(try strategy.parse("https://example.com"))
        XCTAssertEqual(try strategy.parse("https://example.com/path?key4=value4"), Foundation.URL(string: "https://example.com/path?key4=value4")!)
        XCTAssertEqual(try strategy.parse("//example.com/path?key5=value5"), Foundation.URL(string: "https://example.com/path?key5=value5")!)
                
        XCTAssertEqual(
            try Foundation.URL("https://internal.example.com/path/to/endpoint?key=value", _polyfill_strategy: .url.port(.defaultValue(8080))),
            Foundation.URL(string: "https://internal.example.com:8080/path/to/endpoint?key=value")!
        )

        XCTAssertEqual(
            "7/31/2022, 5:15:12\u{202f}AM  https://www.example.com/productList?query=slushie".firstMatch(of: Regex {
                One(._polyfill_dateTime(date: .numeric, time: .standard, locale: .init(identifier: "en_US"), timeZone: .init(identifier: "PST")!))
                OneOrMore(.horizontalWhitespace)
                Capture { One(._polyfill_url(port: .defaultValue(8088))) }
            })?.1,
            Foundation.URL(string: "https://www.example.com:8088/productList?query=slushie")!
        )
    }
    
    func testVariousParses() throws {
        let up = "user:pass", host = "foo.bar.www.example.com", host4 = "1.2.3.4:8080", host6 = "[aa:bb:cc:dd:ee:ff]:8080"
        let path = "/path/to/endpoint", qf = "?key=value#anchor"
        let strings = [
            "https:",
            "//\(host)",
            "ftp://\(host)",
            "https://\(host)",
            "https://user@\(host)",
            "https://\(up)@\(host)",
            "https://\(up)@\(host):8080",
            "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value",
            "https://\(up)@\(host):8080\(path)\(qf)",
            "https://\(up)@\(host4)\(path)\(qf)",
            "https://\(up)@\(host6)\(path)\(qf)",
        ]
        let base = _polyfill_URLParseStrategy(scheme: .optional, host: .optional)
        
        func check(_ strategy: _polyfill_URLParseStrategy, expect: [String?], file: StaticString = #filePath, line: UInt = #line) {
            assert(expect.count == strings.count)
            for (string, expected) in zip(strings, expect) {
                XCTAssertEqual(try? strategy.parse(string), expected.map { URL(string: $0)! }, file: file, line: line)
            }
        }
        
        check(base.scheme(.required), expect: [
            "https:", nil, "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.user(.required), expect: [
            nil, nil, nil, nil, "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.user(.required).password(.required).host(.required).port(.required).path(.required).query(.required).fragment(.required), expect: [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base
            .scheme(.defaultValue("abcd"))
            .user(.defaultValue("u")).password(.defaultValue("p"))
            .host(.defaultValue("h"))
            .path(.defaultValue("/T"))
            .query(.defaultValue("q")).fragment(.defaultValue("f")),
        expect: [
            "https://u:p@h/T?q#f", "abcd://u:p@\(host)/T?q#f", "ftp://u:p@\(host)/T?q#f", "https://u:p@\(host)/T?q#f", "https://user:p@\(host)/T?q#f",
            "https://\(up)@\(host)/T?q#f", "https://\(up)@\(host):8080/T?q#f", "https://\(up)@\(host):8080\(path)?q#f", "https://\(up)@\(host):8080\(path)?key=value#f",
            "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.scheme(.defaultValue("%")), expect: [
            "https:", "//\(host)", "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.scheme(.defaultValue("")), expect: [
            "https:", "//\(host)", "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.user(.defaultValue("")), expect: [
            "https://@", "//@\(host)", "ftp://@\(host)", "https://@\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.password(.defaultValue("")), expect: [
            "https://:@", "//:@\(host)", "ftp://:@\(host)", "https://:@\(host)", "https://user:@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.host(.defaultValue("")), expect: [
            "https://", "//\(host)", "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.path(.defaultValue("")), expect: [
            "https:", "//\(host)", "ftp://\(host)", "https://\(host)", "https://user@\(host)", "https://\(up)@\(host)", "https://\(up)@\(host):8080", "https://\(up)@\(host):8080\(path)",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.query(.defaultValue("")), expect: [
            "https:?", "//\(host)?", "ftp://\(host)?", "https://\(host)?", "https://user@\(host)?", "https://\(up)@\(host)?", "https://\(up)@\(host):8080?", "https://\(up)@\(host):8080\(path)?",
            "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.fragment(.defaultValue("")), expect: [
            "https:%23", "//\(host)#", "ftp://\(host)#", "https://\(host)#", "https://user@\(host)#", "https://\(up)@\(host)#", "https://\(up)@\(host):8080#", "https://\(up)@\(host):8080\(path)#",
            "https://\(up)@\(host):8080\(path)?key=value#", "https://\(up)@\(host):8080\(path)\(qf)", "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
        check(base.path(.defaultValue("x")), expect: [
            "https:x", nil, nil, nil, nil, nil, nil, "https://\(up)@\(host):8080\(path)", "https://\(up)@\(host):8080\(path)?key=value", "https://\(up)@\(host):8080\(path)\(qf)",
            "https://\(up)@\(host4)\(path)\(qf)", "https://\(up)@\(host6)\(path)\(qf)",
        ])
    }
    
    func testParseStrategyOfFormat() {
        XCTAssertEqual(try _polyfill_URLFormatStyle().scheme(.always).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().scheme(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().user(.always).parseStrategy.parse("http://user@abc.def/xyz"), URL(string: "http://user@abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().user(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().password(.always).parseStrategy.parse("http://:pass@abc.def/xyz"), URL(string: "http://:pass@abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().password(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().host(.always).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().host(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().path(.always).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().path(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().port(.always).parseStrategy.parse("http://abc.def:1/xyz"), URL(string: "http://abc.def:1/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().port(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().path(.always).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().path(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().query(.always).parseStrategy.parse("http://abc.def/xyz?"), URL(string: "http://abc.def/xyz?")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().query(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().fragment(.always).parseStrategy.parse("http://abc.def/xyz#"), URL(string: "http://abc.def/xyz#")!)
        XCTAssertEqual(try _polyfill_URLFormatStyle().fragment(.never).parseStrategy.parse("http://abc.def/xyz"), URL(string: "http://abc.def/xyz")!)
    }

    func testDescriptions() {
        XCTAssertFalse(_polyfill_URLParseStrategy.ComponentParseStrategy<String>.required.description.isEmpty)
        XCTAssertFalse(_polyfill_URLParseStrategy.ComponentParseStrategy<String>.optional.description.isEmpty)
        XCTAssertFalse(_polyfill_URLParseStrategy.ComponentParseStrategy<String>.defaultValue("").description.isEmpty)
    }
}
