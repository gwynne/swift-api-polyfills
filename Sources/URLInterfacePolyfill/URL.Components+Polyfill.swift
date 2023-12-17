import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import class Foundation.FileManager
import PolyfillCommon

private let _polyfill_URLComponents_idnaInstance = try! ICU4Swift.IDNA()

extension URLComponents {
    /// Initializes a `URLComponents` with a URL string and the option to add (or skip) IDNA- and percent-encoding
    /// of invalid characters. If `encodingInvalidCharacters` is false, and the URL string is invalid according to
    /// RFC 3986, `nil` is returned. If `encodingInvalidCharacters` is true, `URLComponents` will try to encode the
    /// string to create a valid URL. If the URL string is still invalid after encoding, `nil` is returned.
    ///
    /// - Parameter URLString: The URL string.
    /// - Parameter encodingInvalidCharacters: `true` if `URLComponents` should try to encode invalid strings.
    public init?(string URLString: String, _polyfill_encodingInvalidCharacters: Bool) {
        guard let url = URL(string: URLString, _polyfill_encodingInvalidCharacters: _polyfill_encodingInvalidCharacters) else {
            return nil
        }
        self.init(url: url, resolvingAgainstBaseURL: false)
    }

    /// The host subcomponent, percent- or IDNA-encoded, as needed.
    ///
    /// The behavior of the related properties `host` and `percentEncodedHost` differs between macOS and other
    /// platforms. On Darwin platforms, setting any of the three properties to any given value will detect whether
    /// the value is already percent-encoded or IDNA-encoded and update the internal representation appropriately.
    /// On other platforms, setting the percent-encoded host or IDNA-encoded host to a value containing unencoded
    /// characters triggers an assertion failure; this is the behavior described below (taken from the discussion
    /// text for the legacy `percentEncodedHost` property this accessor is designed to replace):
    ///
    /// The getter for this property retains any percent encoding this component may have. Setting this property
    /// assumes the component string is already correctly percent encoded. Attempting to set an incorrectly
    /// percent encoded string will cause a `fatalError`. Although ';' is a legal path character, it is recommended
    /// that it be percent-encoded for best compatibility with `URL`
    /// (`String.addingPercentEncoding(withAllowedCharacters:)` will percent-encode any ';' characters if you pass
    /// `CharacterSet.urlHostAllowed`).
    public var _polyfill_encodedHost: String? {
        get {
            self.host
                .flatMap { $0.contains(where: { !$0.isASCII }) ? (try? _polyfill_URLComponents_idnaInstance.encode(name: $0)) : $0 }
                .flatMap { $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) }
        }
        set {
            #if canImport(Darwin)
            if var newValue {
                if newValue.contains(where: { !$0.isASCII }) { newValue = (try? _polyfill_URLComponents_idnaInstance.encode(name: newValue)) ?? newValue }
                self.percentEncodedHost = newValue // let Darwin deal with the percent-encoding part
            }
            #else
            // N.B.: Per https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/NSURLComponents.swift#L228,
            // validity failure yields a fatal error with no message.
            guard !(newValue?.contains(where: { !$0.isASCII }) ?? false) else { fatalError() }
            self.percentEncodedHost = newValue
            #endif
        }
    }
}

extension URL {
    /// Initializes a `URL` with a URL string and the option to add (or skip) IDNA- and percent-encoding of
    /// invalid characters. If `encodingInvalidCharacters` is `false`, and the URL string is invalid according to
    /// RFC 3986, `nil` is returned. If `encodingInvalidCharacters` is `true`, `URL` will try to encode the string
    /// to create a valid URL. If the URL string is still invalid after encoding, `nil` is returned.
    ///
    /// - Parameter URLString: The URL string.
    /// - Parameter encodingInvalidCharacters: `true` if `URL` should try to encode invalid strings.
    /// - Returns: An `URL` instance for a valid URL, or `nil` if the URL is invalid.
    public init?(string URLString: String, _polyfill_encodingInvalidCharacters: Bool) {
        // FIXME: We don't implement `encodingInvalidCharacters` at this time; we just act as if it's always false.
        // FIXME: As CoreFoundation doesn't deign to make its parser available, we'd have to write or emebd our own,
        // FIXME: which for now is considered beyond our scope.
        self.init(string: URLString)
    }

    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the host
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the host should be percent encoded, defaults to `true`.
    /// - Returns: the host component of the URL
    public func _polyfill_host(percentEncoded: Bool = true) -> String? {
        percentEncoded ? URLComponents(url: self, resolvingAgainstBaseURL: false)?._polyfill_encodedHost : self.host
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the user
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the user should be percent encoded, defaults to `true`.
    /// - Returns: the user component of the URL.
    public func _polyfill_user(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self.user?.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) : self.user
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the password
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the password should be percent encoded, defaults to `true`.
    /// - Returns: the password component of the URL.
    public func _polyfill_password(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self.password?.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed) : self.password
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path
    /// component of the URL; otherwise it returns an empty string.
    ///
    /// > Note: This function will resolve against the base `URL`.
    ///
    /// - Parameter percentEncoded: whether the path should be percent encoded, defaults to `true`.
    /// - Returns: the path component of the URL.
    public func _polyfill_path(percentEncoded: Bool = true) -> String {
        (percentEncoded ? self.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) : self.path) ?? "/"
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the fragment
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the fragment should be percent encoded, defaults to `true`.
    /// - Returns: the fragment component of the URL.
    public func _polyfill_fragment(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self.fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) : self.fragment
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the query
    /// of the URL; otherwise it returns nil.
    /// 
    /// - Parameter percentEncoded: whether the query should be percent encoded, defaults to `true`.
    /// - Returns: the query component of the URL.
    public func _polyfill_query(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self.query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) : self.query
    }

    /// Returns a URL constructed by appending the given list of `URLQueryItem` to self.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public func _polyfill_appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)! // should not be possible to fail given the URL must be valid
        
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url(relativeTo: self.baseURL)! // again, failure isn't supposed to be possible here
    }

    /// Appends a list of `URLQueryItem` to the receiver.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public mutating func _polyfill_append(queryItems: [URLQueryItem]) {
        self = self._polyfill_appending(queryItems: queryItems)
    }
}

#if !canImport(Darwin)

extension URLComponents {
    /// Initializes a `URLComponents` with a URL string and the option to add (or skip) IDNA- and percent-encoding
    /// of invalid characters. If `encodingInvalidCharacters` is false, and the URL string is invalid according to
    /// RFC 3986, `nil` is returned. If `encodingInvalidCharacters` is true, `URLComponents` will try to encode the
    /// string to create a valid URL. If the URL string is still invalid after encoding, `nil` is returned.
    ///
    /// - Parameter URLString: The URL string.
    /// - Parameter encodingInvalidCharacters: `true` if `URLComponents` should try to encode invalid strings.
    public init?(string URLString: String, encodingInvalidCharacters: Bool) {
        self.init(string: URLString, _polyfill_encodingInvalidCharacters: encodingInvalidCharacters)
    }
    
    /// The host subcomponent, percent- or IDNA-encoded, as needed.
    ///
    /// The behavior of the related properties `host` and `percentEncodedHost` differs between macOS and other
    /// platforms. On Darwin platforms, setting any of the three properties to any given value will detect whether
    /// the value is already percent-encoded or IDNA-encoded and update the internal representation appropriately.
    /// On other platforms, setting the percent-encoded host or IDNA-encoded host to a value containing unencoded
    /// characters triggers an assertion failure; this is the behavior described below (taken from the discussion
    /// text for the legacy `percentEncodedHost` property this accessor is designed to replace):
    ///
    /// The getter for this property retains any percent encoding this component may have. Setting this property
    /// assumes the component string is already correctly percent encoded. Attempting to set an incorrectly
    /// percent encoded string will cause a `fatalError`. Although ';' is a legal path character, it is recommended
    /// that it be percent-encoded for best compatibility with `URL`
    /// (`String.addingPercentEncoding(withAllowedCharacters:)` will percent-encode any ';' characters if you pass
    /// `CharacterSet.urlHostAllowed`).
    public var encodedHost: String? {
        self._polyfill_encodedHost
    }
}

extension URL {
    /// Initializes a `URL` with a URL string and the option to add (or skip) IDNA- and percent-encoding of
    /// invalid characters. If `encodingInvalidCharacters` is `false`, and the URL string is invalid according to
    /// RFC 3986, `nil` is returned. If `encodingInvalidCharacters` is `true`, `URL` will try to encode the string
    /// to create a valid URL. If the URL string is still invalid after encoding, `nil` is returned.
    ///
    /// - Parameter URLString: The URL string.
    /// - Parameter encodingInvalidCharacters: `true` if `URL` should try to encode invalid strings.
    /// - Returns: An `URL` instance for a valid URL, or `nil` if the URL is invalid.
    public init?(string URLString: String, encodingInvalidCharacters: Bool) {
        self.init(string: URLString, _polyfill_encodingInvalidCharacters: encodingInvalidCharacters)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the host
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the host should be percent encoded, defaults to `true`.
    /// - Returns: the host component of the URL
    public func host(percentEncoded: Bool = true) -> String? {
        self._polyfill_host(percentEncoded: percentEncoded)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the user
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the user should be percent encoded, defaults to `true`.
    /// - Returns: the user component of the URL.
    public func user(percentEncoded: Bool = true) -> String? {
        self._polyfill_user(percentEncoded: percentEncoded)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the password
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the password should be percent encoded, defaults to `true`.
    /// - Returns: the password component of the URL.
    public func password(percentEncoded: Bool = true) -> String? {
        self._polyfill_password(percentEncoded: percentEncoded)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path
    /// component of the URL; otherwise it returns an empty string.
    ///
    /// > Note: This function will resolve against the base `URL`.
    ///
    /// - Parameter percentEncoded: whether the path should be percent encoded, defaults to `true`.
    /// - Returns: the path component of the URL.
    public func path(percentEncoded: Bool = true) -> String {
        self._polyfill_path(percentEncoded: percentEncoded)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the fragment
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the fragment should be percent encoded, defaults to `true`.
    /// - Returns: the fragment component of the URL.
    public func fragment(percentEncoded: Bool = true) -> String? {
        self._polyfill_fragment(percentEncoded: percentEncoded)
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the query
    /// of the URL; otherwise it returns nil.
    /// 
    /// - Parameter percentEncoded: whether the query should be percent encoded, defaults to `true`.
    /// - Returns: the query component of the URL.
    public func query(percentEncoded: Bool = true) -> String? {
        self._polyfill_query(percentEncoded: percentEncoded)
    }
    
    /// Returns a URL constructed by appending the given list of `URLQueryItem` to self.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public func appending(queryItems: [URLQueryItem]) -> URL {
        self._polyfill_appending(queryItems: queryItems)
    }
    
    /// Appends a list of `URLQueryItem` to the receiver.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public mutating func append(queryItems: [URLQueryItem]) {
        self._polyfill_append(queryItems: queryItems)
    }
}

#endif
