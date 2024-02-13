import struct Foundation.URL
import struct Foundation.URLComponents
import RegexBuilder

/// A parse strategy for creating URLs from formatted strings.
///
/// Create an explicit `URL.ParseStrategy` to parse multiple strings according to the same parse strategy. The
/// following example creates a customized strategy, then applies it to multiple URL candidate strings.
///
/// ```swift
/// let strategy = URL.ParseStrategy(
///     scheme: .defaultValue("https"),
///     user: .optional,
///     password: .optional,
///     host: .required,
///     port: .optional,
///     path: .required,
///     query: .required,
///     fragment: .optional)
/// let urlStrings = [
///     "example.com?key1=value1", // no scheme or path
///     "https://example.com?key2=value2", // no path
///     "https://example.com", // no query
///     "https://example.com/path?key4=value4", // complete
///     "//example.com/path?key5=value5" // complete except for default-able scheme
/// ]
/// let urls = urlStrings.map { try? strategy.parse($0) }
/// // [nil, nil, nil, Optional(https://example.com/path?key4=value4), Optional(https://example.com/path?key5=value5)]
/// ```
///
/// You don’t need to instantiate a parse strategy instance to parse a single string. Instead, use the `URL`
/// initializer `init(_:strategy:)`, passing in a string to parse and a customized strategy, typically created
/// with one of the static accessors. The following example parses a URL string, with a custom strategy that
/// provides a default value for the port component if the source string doesn’t specify one.
///
/// ```swift
/// let urlString = "https://internal.example.com/path/to/endpoint?key=value"
/// let url = try? URL(urlString, strategy: .url
///     .port(.defaultValue(8080))) // https://internal.example.com:8080/path/to/endpoint?key=value
/// ```
public struct _polyfill_URLParseStrategy: Codable, Hashable, Sendable {
    private var scheme:   ComponentParseStrategy<String>
    private var user:     ComponentParseStrategy<String>
    private var password: ComponentParseStrategy<String>
    private var host:     ComponentParseStrategy<String>
    private var port:     ComponentParseStrategy<String>
    private var path:     ComponentParseStrategy<String>
    private var query:    ComponentParseStrategy<String>
    private var fragment: ComponentParseStrategy<String>
    
    /// Creates a new `ParseStrategy` with the given configurations.
    ///
    /// - Parameters:
    ///   - scheme: A strategy for parsing the scheme component.
    ///   - user: A strategy for parsing the user component.
    ///   - password: A strategy for parsing the password component.
    ///   - host: A strategy for parsing the host component.
    ///   - port: A strategy for parsing the port component.
    ///   - path: A strategy for parsing the path component.
    ///   - query: A strategy for parsing the query component.
    ///   - fragment: A strategy for parsing the fragment component.
    public init(
        scheme:   ComponentParseStrategy<String> = .required,
        user:     ComponentParseStrategy<String> = .optional,
        password: ComponentParseStrategy<String> = .optional,
        host:     ComponentParseStrategy<String> = .required,
        port:     ComponentParseStrategy<Int>    = .optional,
        path:     ComponentParseStrategy<String> = .optional,
        query:    ComponentParseStrategy<String> = .optional,
        fragment: ComponentParseStrategy<String> = .optional
    ) {
        self.scheme = scheme
        self.user = user
        self.password = password
        self.host = host
        self.port = .init(port)
        self.path = path
        self.query = query
        self.fragment = fragment
    }

    /// Modifies a parse strategy to parse a URL’s scheme component in accordance with the provided behavior.
    /// 
    /// - Parameter strategy: A strategy for parsing the scheme component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func scheme(_ strategy: ComponentParseStrategy<String> = .required) -> Self {
        var new = self
        new.scheme = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s user component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the user component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func user(_ strategy: ComponentParseStrategy<String> = .optional) -> Self {
        var new = self
        new.user = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s password component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the password component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func password(_ strategy: ComponentParseStrategy<String> = .optional) -> Self {
        var new = self
        new.password = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s host component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the host component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func host(_ strategy: ComponentParseStrategy<String> = .required) -> Self {
        var new = self
        new.host = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s port component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the port component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func port(_ strategy: ComponentParseStrategy<Int> = .optional) -> Self {
        var new = self
        new.port = .init(strategy)
        return new
    }

    /// Modifies a parse strategy to parse a URL’s path component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the path component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func path(_ strategy: ComponentParseStrategy<String> = .optional) -> Self {
        var new = self
        new.path = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s query component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the query component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func query(_ strategy: ComponentParseStrategy<String> = .optional) -> Self {
        var new = self
        new.query = strategy
        return new
    }

    /// Modifies a parse strategy to parse a URL’s fragment component in accordance with the provided behavior.
    ///
    /// - Parameter strategy: A strategy for parsing the fragment component.
    /// - Returns: A modified `URL.ParseStrategy` that incorporates the specified behavior.
    public func fragment(_ strategy: ComponentParseStrategy<String> = .optional) -> Self {
        var new = self
        new.fragment = strategy
        return new
    }
}

extension _polyfill_URLParseStrategy {
    /// The strategy used to parse one component of a URL.
    /// 
    /// Use this type with the `URL.ParseStrategy` initializer and static accessors, or its modifier methods,
    /// to specify behavior for parsing components of a URL. This allows you to reject URL candidate strings
    /// that lack required components — such as a scheme, host, or path — or to fill in default values while parsing.
    public enum ComponentParseStrategy<Component>: Codable, Hashable, CustomStringConvertible, Sendable
        where Component: Codable, Component: Hashable, Component: Sendable
    {
        /// A strategy that requires the presence of the associated component for parsing to succeed.
        case required

        /// A strategy that treats the presence of the associated component as optional.
        case optional

        /// A strategy that provides a default value for a component if it’s absent in the source string.
        ///
        /// - Parameter Component: A value to use in the parsed URL if the component is absent in the source string.
        case defaultValue(Component)
        
        // See `CustomStringConvertible.description`.
        public var description: String {
            switch self {
            case .required: "required"
            case .optional: "optional"
            case .defaultValue(let component): "assumeValueIfMissing(\(String(describing: component))"
            }
        }
        
        /// Given a strategy with `BinaryInteger` type, translate it to a strategy of `String` type.
        fileprivate init(_ other: ComponentParseStrategy<some BinaryInteger>) where Self == ComponentParseStrategy<String> {
            switch other {
            case .required: self = .required
            case .optional: self = .optional
            case .defaultValue(let value): self = .defaultValue("\(value)")
            }
        }
        
        /// `true` if `self` is `.defaultValue`, regardless of the associated value.
        fileprivate var hasDefaultValue: Bool {
            if case .defaultValue(_) = self { true } else { false }
        }
    }
}

extension _polyfill_URLParseStrategy: _polyfill_ParseStrategy {
    /// Parses a URL string in accordance with this strategy and returns the parsed value.
    /// 
    /// - Parameter value: The string to parse.
    /// - Returns: The parsed URL.
    ///
    /// Use this method to repeatedly parse URL strings with the same `URL.ParseStrategy`. To parse a single
    /// URL string, use the `URL` initializer `init(_:strategy:)`.
    ///
    /// This method throws an error if the parse strategy can’t parse the provided string.
    public func parse(_ value: String) throws -> Foundation.URL {
        guard let result = self.parseImpl(value, startingAt: value.startIndex, in: value.startIndex ..< value.endIndex)?.output else {
            throw parseError(value, examples: "https://user:password@www.example.com/path?color=red#name.")
        }
        return result
    }
}

extension Foundation.URL {
    /// Creates a URL instance by parsing the provided input in accordance with a parse strategy.
    ///
    /// - Parameters:
    ///   - value: The value to parse, as the input type accepted by strategy. For `URL.ParseStrategy`,
    ///     this is `String`.
    ///   - strategy: A parse strategy to apply when parsing `value`.
    ///
    /// The following example parses a URL string, with a custom strategy that provides a default value
    /// for the port component if the source string doesn’t specify one.
    ///
    /// ```swift
    /// let urlString = "https://internal.example.com/path/to/endpoint?key=value"
    /// let url = try? URL(urlString, strategy: .url
    ///     .port(.defaultValue(8080))) // https://internal.example.com:8080/path/to/endpoint?key=value
    /// ```
    public init<T>(
        _ value: T.ParseInput,
        _polyfill_strategy: T
    ) throws
        where T: _polyfill_ParseStrategy, T.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(value)
    }
}

extension _polyfill_URLParseStrategy: CustomConsumingRegexComponent {
    // See `RegexComponent.RegexOutput`.
    public typealias RegexOutput = Foundation.URL

    // See `CustomConsumingRegexComponents.consuming(_:startingAt:in:)`.
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Foundation.URL)? {
        self.parseImpl(input, startingAt: index, in: bounds)
    }
}

extension _polyfill_ParseStrategy where Self == _polyfill_URLParseStrategy {
    /// A default strategy for parsing a URL.
    ///
    /// Use the dot-notation form of this type property when the call point allows the use of `URL.ParseStrategy`.
    /// Typically, you use this with the `URL` initializer `init(_:strategy:)`.
    ///
    /// The parse strategy provided by this static accessor provides a default behavior. To customize parsing
    /// behavior, use the modifiers in `Customizing strategy behavior`.
    public static var url: Self {
        .init()
    }
}

extension RegexComponent where Self == _polyfill_URLParseStrategy {
    /// Returns a custom strategy for parsing a URL.
    /// 
    /// - Parameters:
    ///   - scheme: A strategy for parsing the scheme component.
    ///   - user: A strategy for parsing the user component.
    ///   - password: A strategy for parsing the password component.
    ///   - host: A strategy for parsing the host component.
    ///   - port: A strategy for parsing the port component.
    ///   - path: A strategy for parsing the path component.
    ///   - query: A strategy for parsing the query component.
    ///   - fragment: A strategy for parsing the fragment component.
    /// - Returns: A strategy for parsing URL strings, with the specified behavior for each component.
    ///
    /// Use the dot-notation form of this method when the call point allows the use of `URL.ParseStrategy`.
    /// Typically, you use this with the `URL` initializer `init(_:strategy:)`.
    public static func _polyfill_url(
        scheme:   Self.ComponentParseStrategy<String> = .required,
        user:     Self.ComponentParseStrategy<String> = .optional,
        password: Self.ComponentParseStrategy<String> = .optional,
        host:     Self.ComponentParseStrategy<String> = .required,
        port:     Self.ComponentParseStrategy<Int>    = .optional,
        path:     Self.ComponentParseStrategy<String> = .optional,
        query:    Self.ComponentParseStrategy<String> = .optional,
        fragment: Self.ComponentParseStrategy<String> = .optional
    ) -> Self {
        .init(
            scheme: scheme,
            user: user,
            password: password,
            host: host,
            port: port,
            path: path,
            query: query,
            fragment: fragment
        )
    }
}

// MARK: - Implementation guts

extension _polyfill_URLParseStrategy {
    /// Checks for and applies the effects of `.required` and `.defaultValue` in URL components after
    /// parsing (as part of the temporary crummy implementation - this is done differently if the real
    /// version is ever written).
    private func applyOptions(for url: Foundation.URL) -> Foundation.URL? {
        if ((url.scheme     ?? "").isEmpty && self.scheme   == .required) ||
           ((url.user()     ?? "").isEmpty && self.user     == .required) ||
           ((url.password() ?? "").isEmpty && self.password == .required) ||
           ((url.host()     ?? "").isEmpty && self.host     == .required) ||
           (url.port == nil                && self.port     == .required) ||
           (url.path().isEmpty             && self.path     == .required) ||
           (url.query() == nil             && self.query    == .required) ||
           (url.fragment() == nil          && self.fragment == .required)
        {
            return nil
        }
        
        guard ((url.scheme     ?? "").isEmpty && self.scheme.hasDefaultValue)   ||
              ((url.user()     ?? "").isEmpty && self.user.hasDefaultValue)     ||
              ((url.password() ?? "").isEmpty && self.password.hasDefaultValue) ||
              ((url.host()     ?? "").isEmpty && self.host.hasDefaultValue)     ||
              (url.port == nil                && self.port.hasDefaultValue)     ||
              (url.path().isEmpty             && self.path.hasDefaultValue)     ||
              ((url.query()    ?? "").isEmpty && self.query.hasDefaultValue)    ||
              ((url.fragment() ?? "").isEmpty && self.fragment.hasDefaultValue)
        else {
            return url
        }
        
        var components = Foundation.URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if (components.scheme ?? "").isEmpty, case .defaultValue(let value) = self.scheme {
            components.scheme = value.wholeMatch(of: /[A-Za-z][A-Za-z0-9+\-.]*/).map { .init($0.0) }
        }
        if (components.user ?? "").isEmpty, case .defaultValue(let value) = self.user {
            components.user = value
        }
        if (components.password ?? "").isEmpty, case .defaultValue(let value) = self.password {
            components.password = value
        }
        if (components.host ?? "").isEmpty, case .defaultValue(let value) = self.host {
            components.host = value
        }
        if components.port == nil, case .defaultValue(let value) = self.port {
            components.port = Int(value)!
        }
        if components.path.isEmpty, case .defaultValue(let value) = self.path {
            guard value.starts(with: "/") || value.isEmpty || (components.host ?? "").isEmpty else {
                return nil
            }
            components.path = value
        }
        if (components.query ?? "").isEmpty, case .defaultValue(let value) = self.query {
            components.query = value
        }
        if (components.fragment ?? "").isEmpty, case .defaultValue(let value) = self.fragment {
            components.fragment = value
        }
        return components.url
    }
    
    /// The actual parsing implementation - this is the sole piece of both functional and non-representational code
    /// across the entire parse strategy type.
    private func parseImpl(
        _ value: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) -> (upperBound: String.Index, output: Foundation.URL)? {
        guard bounds.contains(index) else {
            return nil
        }
        
        // Temporary extremely lazy and incredibly inefficient implementation.
        var end = bounds.upperBound
        
        while end > index {
            if let url = Foundation.URL(string: String(value[index ..< end])) {
                guard let url = self.applyOptions(for: url) else {
                    return nil
                }
                
                return (upperBound: end, output: url)
            }
            value.formIndex(before: &end)
        }
        return nil
        /*
        var upperBound = index, urlString = ""
        
        // URI           = scheme ":" hier-part [ "?" query ] [ "#" fragment ]
        // scheme        = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
        if let schemeMatch = value[upperBound ..< bounds.upperBound].prefixMatch(of: /[A-Za-z][A-Za-z0-9+\-.]*:/) {
            upperBound = schemeMatch.range.upperBound
            urlString += schemeMatch.output
        } else if case .defaultValue(let def) = self.scheme {
            guard def.wholeMatch(of: /(?:[A-Za-z][A-Za-z0-9+\-.]*)/) != nil else { return nil }
            urlString += "\(def):"
        } else if self.scheme == .required {
            return nil
        }
        
        if let hierMatch = value[upperBound ..< bounds.upperBound].prefixMatch(of: /\/\//) {
            upperBound = hierMatch.range.upperBound
            urlString += hierMatch.output
            
            let authorityMatch = value[upperBound ..< bounds.upperBound].prefixMatch(of: #/ /#)
        } else if [self.user, self.password, self.host, self.port].contains(.required) {
            return nil
        }
        */
    }
}
