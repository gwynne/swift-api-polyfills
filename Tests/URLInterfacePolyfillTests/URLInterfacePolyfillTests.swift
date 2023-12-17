import Foundation
import XCTest

final class URLInterfacePolyfillTests: XCTestCase {
    func testEncodedHostBehavior() {
        do {
            var components = URLComponents()
            components.host = "asd/ëf"
            print("Plain host set to \"asdf\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
        }
        do {
            var components = URLComponents()
            components.percentEncodedHost = "asd/ëf"
            print("%enc host set to \"asdf\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
        }
        do {
            var components = URLComponents()
            components.encodedHost = "asd/ëf"
            print("Enc host set to \"asdf\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
        }

        do {
            var components = URLComponents()
            components.host = "////"
            print("Plain host set to \"////\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
//        do {
//            var components = URLComponents()
//            components.percentEncodedHost = "////"
//            print("%enc host set to \"////\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
//        }
//        do {
//            var components = URLComponents()
//            components.encodedHost = "////"
//            print("Enc host set to \"////\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
//        }

        do {
            var components = URLComponents()
            components.host = "%2F%2F%2F%2F"
            print("Plain host set to \"%2F%2F%2F%2F\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
        do {
            var components = URLComponents()
            components.percentEncodedHost = "%2F%2F%2F%2F"
            print("%enc host set to \"%2F%2F%2F%2F\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
//        do {
//            var components = URLComponents()
//            components.encodedHost = "%2F%2F%2F%2F"
//            print("Enc host set to \"%2F%2F%2F%2F\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
//        }

        do {
            var components = URLComponents()
            components.host = "ëëëë"
            print("Plain host set to \"ëëëë\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
//        do {
//            var components = URLComponents()
//            components.percentEncodedHost = "ëëëë"
//            print("%enc host set to \"ëëëë\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
//        }
//        do {
//            var components = URLComponents()
//            components.encodedHost = "ëëëë"
//            print("Enc host set to \"ëëëë\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
//        }

        do {
            var components = URLComponents()
            components.host = "%C3%AB"
            print("Plain host set to \"%C3%AB\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
        do {
            var components = URLComponents()
            components.percentEncodedHost = "%C3%AB"
            print("%enc host set to \"%C3%AB\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
//        do {
//            var components = URLComponents()
//            components.encodedHost = "%C3%AB"
//            print("Enc host set to \"%C3%AB\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
//        }

        do {
            var components = URLComponents()
            components.host = "xn--cda"
            print("Plain host set to \"xn--cda\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
        do {
            var components = URLComponents()
            components.percentEncodedHost = "xn--cda"
            print("%enc host set to \"xn--cda\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>")")//, enc host \(components.encodedHost ?? "<>")")
        }
//        do {
//            var components = URLComponents()
//            components.encodedHost = "xn--cda"
//            print("Enc host set to \"xn--cda\"- host \(components.host ?? "<>"), %-enc host \(components.percentEncodedHost ?? "<>"), enc host \(components.encodedHost ?? "<>")")
//        }

    }
}
