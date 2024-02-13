import struct Foundation.URL
import struct Foundation.URLComponents

/// A structure that converts between URL instances and their textual representations.
///
/// Instances of `URL.FormatStyle` create localized, human-readable text from `URL` instances and parse string
/// representations of URLs into instances of `URL`.
///
/// ## Formatting URLs
///
/// Use the `formatted()` method to create a string representation of a `URL` using the default
/// `URL.FormatStyle` configuration. As seen in the following example, the default style creates a
/// string with the scheme, host, and path, but not the port or query.
///
/// ```swift
/// let url = URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
/// let formatted = url.formatted() // "https://www.example.com/path/to/endpoint"
/// ```
///
/// You can specify a format style by providing an argument to the `format(_:)` method. The following example
/// uses the previous URL, but preserves only the host and path.
///
/// ```swift
/// let url = URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
/// let style = URL.FormatStyle(scheme: .never,
///                             user: .never,
///                             password: .never,
///                             host: .always,
///                             port: .never,
///                             path: .always,
///                             query: .never,
///                             fragment: .never)
/// let formatted = style.format(url) // "www.example.com/path/to/endpoint"
/// ```
///
/// Instantiate a style when you want to format multiple `URL` instances with the same style. For one-time
/// access to a default style, you can use the static accessor url at call points that expect the `URL.FormatStyle`
/// type, such as the `format(_:)` method. This means you can write the example above as follows:
///
/// ```swift
/// let url = URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
/// let formatted = url.formatted(.url
///     .scheme(.never)
///     .host(.always)
///     .port(.never)
///     .path(.always)
///     .query(.never)) // "www.example.com/path/to/endpoint"
/// ```
///
/// This example works by taking the default style provided by `url`, then customizing it with calls to the
/// style modifiers in `Customizing style behavior`.
///
/// ## Parsing URLs
///
/// You can use `URL.FormatStyle` to parse strings into `URL` values. To do this, create a `URL.ParseStrategy` from
/// a format style, then call the strategy’s `parse(_:)` method.
///
/// ```swift
/// let style = URL.FormatStyle(scheme: .always,
///                             user: .never,
///                             password: .never,
///                             host: .always,
///                             port: .always,
///                             path: .always,
///                             query: .always,
///                             fragment: .never)
/// let urlString = "https://www.example.com:8080/path/to/endpoint?key=value"
/// let url = try? style.parseStrategy.parse(urlString)
/// ```
///
/// ## Matching regular expressions
///
/// Along with parsing URL values in strings, you can use the regular expression domain-specific language provided
/// by Swift to match and capture URL substrings. The following example scans source input that’s expected to
/// contain a timestamp, some whitespace, and a URL.
///
/// ```swift
/// import RegexBuilder
/// let source = "7/31/2022, 5:15:12\u{202f}AM  https://www.example.com/productList?query=slushie"
/// let matcher = Regex {
///     One(.dateTime(date: .numeric,
///                   time: .standard,
///                   locale: Locale(identifier: "en_US"),
///                   timeZone: TimeZone(identifier: "PST")!))
///     OneOrMore(.horizontalWhitespace)
///     Capture {
///         One(.url(scheme: .required,
///                  user: .optional,
///                  password: .optional,
///                  host: .required,
///                  port: .defaultValue(8088),
///                  path: .optional,
///                  query: .optional,
///                  fragment: .optional))
///     }
/// }
/// guard let match = source.firstMatch(of: matcher) else { return }
/// let url = match.1 // url = https://www.example.com:8088/productList?query=slushie
/// ```
public struct _polyfill_URLFormatStyle: Codable, Hashable, Sendable {
    private var scheme:   ComponentDisplayOption
    private var user:     ComponentDisplayOption
    private var password: ComponentDisplayOption
    private var host:     HostDisplayOption
    private var port:     ComponentDisplayOption
    private var path:     ComponentDisplayOption
    private var query:    ComponentDisplayOption
    private var fragment: ComponentDisplayOption
    
    /// Creates a URL format style with the given display options.
    ///
    /// Explicitly create a URL format style in situations where you want to format multiple URLs with the
    /// same style configuration. For one-time use, call `formatted()` for a default style, or create a style
    /// with url and customize it with the modifiers in `Customizing style behavior`.
    ///
    /// - Parameters:
    ///   - scheme: An option to control display of the URL scheme component.
    ///   - user: An option to control display of the URL user component.
    ///   - password: An option to control display of the URL password component.
    ///   - host: An option to control display of the URL host component.
    ///   - port: An option to control display of the URL port component.
    ///   - path: An option to control display of the URL path component.
    ///   - query: An option to control display of the URL query component.
    ///   - fragment: An option to control display of the URL fragment component.
    public init(
        scheme:   ComponentDisplayOption = .always,
        user:     ComponentDisplayOption = .never,
        password: ComponentDisplayOption = .never,
        host:     HostDisplayOption      = .always,
        port:     ComponentDisplayOption = .omitIfHTTPFamily,
        path:     ComponentDisplayOption = .always,
        query:    ComponentDisplayOption = .never,
        fragment: ComponentDisplayOption = .never
    ) {
        self.scheme = scheme
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.path = path
        self.query = query
        self.fragment = fragment
    }

    /// Modifies a format style to display a URL’s scheme component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the scheme.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func scheme(_ strategy: ComponentDisplayOption = .always) -> Self {
        var new = self
        new.scheme = strategy
        return new
    }

    /// Modifies a format style to display a URL’s user component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the user
    ///   component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func user(_ strategy: ComponentDisplayOption = .never) -> Self {
        var new = self
        new.user = strategy
        return new
    }

    /// Modifies a format style to display a URL’s password component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the
    ///   password component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func password(_ strategy: ComponentDisplayOption = .never) -> Self {
        var new = self
        new.password = strategy
        return new
    }

    /// Modifies a format style to display a URL’s host component in accordance with the provided option.
    ///
    /// - Parameter strategy: A host display option that indicates when, if ever, to display the host component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func host(_ strategy: HostDisplayOption = .always) -> Self {
        var new = self
        new.host = strategy
        return new
    }

    /// Modifies a format style to display a URL’s port component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the
    ///   port component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func port(_ strategy: ComponentDisplayOption = .omitIfHTTPFamily) -> Self {
        var new = self
        new.port = strategy
        return new
    }

    /// Modifies a format style to display a URL’s path component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the
    ///   path component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func path(_ strategy: ComponentDisplayOption = .always) -> Self {
        var new = self
        new.path = strategy
        return new
    }

    /// Modifies a format style to display a URL’s query component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the
    ///   query component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func query(_ strategy: ComponentDisplayOption = .never) -> Self {
        var new = self
        new.query = strategy
        return new
    }

    /// Modifies a format style to display a URL’s fragment component in accordance with the provided option.
    ///
    /// - Parameter strategy: A component display option that indicates when, if ever, to display the
    ///   fragment component.
    /// - Returns: A modified `URL.FormatStyle` that incorporates the specified behavior.
    public func fragment(_ strategy: ComponentDisplayOption = .never) -> Self {
        var new = self
        new.fragment = strategy
        return new
    }
}

extension _polyfill_URLFormatStyle {
    /// An enumeration of the components of a URL, for use in creating format style options that depend on
    /// a component’s value.
    ///
    /// You use this type with style-modifying methods like `displayWhen(_:matches:)` in
    /// `URL.FormatStyle.ComponentDisplayOption` and `omitWhen(_:matches:)` in
    /// `URL.FormatStyle.HostDisplayOption`.
    public enum Component: Int, Codable, Hashable, Sendable, CustomStringConvertible {
        /// The URL format style scheme component.
        case scheme   = 1
        
        /// The URL format style user component.
        case user     = 2
        
        /// The URL format style password component.
        case password = 4
        
        /// The URL format style host component.
        case host     = 8
        
        /// The URL format style port component.
        case port     = 16
        
        /// The URL format style path component.
        case path     = 32
        
        /// The URL format style query component.
        case query    = 64
        
        /// The URL format style fragment component.
        case fragment = 128
        
        // See `CustomStringConvertible.description`.
        public var description: String {
            switch self {
            case .scheme:   "scheme"
            case .user:     "user"
            case .password: "password"
            case .host:     "host"
            case .port:     "port"
            case .path:     "path"
            case .query:    "query"
            case .fragment: "fragment"
            }
        }
    }

    /// A type that indicates whether a formatted URL should include a component.
    public struct ComponentDisplayOption: Codable, Hashable, CustomStringConvertible, Sendable {
        enum Option: Int, Codable, Hashable, Sendable {
            case omitted
            case displayed
        }

        struct Condition: Hashable, Codable, Sendable {
            let component: _polyfill_URLFormatStyle.Component
            let requirements: Set<String>
        }

        var option: Option
        var condition: Condition?

        // See `CustomStringConvertible.description`.
        public var description: String {
            switch (self.option, self.condition) {
            case (.displayed, nil): "always"
            case (.omitted, nil): "never"
            case (let opt, let cond?): "\(opt)(condition: if \(cond.component) matches \(cond.requirements))"
            }
        }

        /// A display option that always displays the component.
        public static var always: Self {
            .init(option: .displayed)
        }

        /// A display option that never displays the component.
        public static var never: Self {
            .init(option: .omitted)
        }

        /// Returns a display option that displays the component when a specified component meets the
        /// specified requirements.
        ///
        /// - Parameters:
        ///   - component: A component to compare. This may or may not be the component the strategy modifies.
        ///     For example, a display option for the query might match against known values for the path.
        ///   - requirements: A set of string values to match against. Matching any member of the set allows
        ///     the format style to display the component.
        /// - Returns: A display option that displays the component when a specified component meets the
        ///   specified requirements.
        public static func displayWhen(
            _ component: _polyfill_URLFormatStyle.Component,
            matches requirements: Set<String>
        ) -> Self {
            .init(
                option: .displayed,
                condition: .init(component: component, requirements: requirements)
            )
        }

        /// Returns a display option that omits the component when a specified component meets the
        /// specified requirements.
        ///
        /// - Parameters:
        ///   - component: A component to compare. This may or may not be the component the strategy modifies.
        ///     For example, a display option for the password might match against known values for the user.
        ///   - requirements: A set of string values to match against. Matching any member of the set informs
        ///     the format style to omit the component.
        /// - Returns: A display option that omits the component when a specified component meets the
        ///   specified requirements.
        public static func omitWhen(
            _ component: _polyfill_URLFormatStyle.Component,
            matches requirements: Set<String>
        ) -> Self {
            .init(
                option: .omitted,
                condition: .init(component: component, requirements: requirements)
            )
        }

        /// A display option that omits the component if the URL scheme is any flavor of HTTP.
        public static var omitIfHTTPFamily: Self {
            .omitWhen(
                .scheme,
                matches: ["http", "https"]
            )
        }
    }

    /// A type that indicates whether a formatted URL should include the host component.
    public struct HostDisplayOption: Codable, Hashable, CustomStringConvertible, Sendable {
        var option: ComponentDisplayOption.Option
        var condition: ComponentDisplayOption.Condition?
        var omitSpecificSubdomains: Set<String>
        var omitMultiLevelSubdomains: Bool

        // See `CustomStringConvertible.description`.
        public var description: String {
            switch (self.option, self.condition) {
            case (.displayed, let condition):
                """
                displayed(\
                omitMultiLevelSubdomains: \(self.omitMultiLevelSubdomains), \
                omitSpecificSubdomains: \(self.omitSpecificSubdomains), \
                condition: \(condition.map { "if \($0.component) matches \($0.requirements)" } ?? "no condition")\
                )
                """
            case (.omitted, nil): "never"
            case (.omitted, let condition?): "omitted(condition: \(condition))"
            }
        }
        
        /// A display option that always displays the host component.
        public static var always: Self {
            .init(
                option: .displayed,
                condition: nil,
                omitSpecificSubdomains: [],
                omitMultiLevelSubdomains: false
            )
        }

        /// A display option that never displays the host component.
        public static var never: Self {
            .init(
                option: .omitted,
                condition: nil,
                omitSpecificSubdomains: [],
                omitMultiLevelSubdomains: false
            )
        }

        /// Returns a display option that displays the host component when a specified component matches
        /// against a set of requirement values.
        ///
        /// - Parameters:
        ///   - component: A component to compare. This may or may not be the host component itself.
        ///   - requirements: A set of string values to match against. Matching any member of the set allows
        ///     the format style to display the component.
        /// - Returns: A display option that displays the host component when a specified component meets
        ///   the specified requirements.
        public static func displayWhen(
            _ component: _polyfill_URLFormatStyle.Component,
            matches requirements: Set<String>
        ) -> Self {
            .omitSpecificSubdomains(
                when: component,
                matches: requirements
            )
        }

        /// Returns a display option that displays the host component when a specified component matches against
        /// a set of requirement values.
        ///
        /// - Parameters:
        ///   - component: A component to compare. This may or may not be the host component itself.
        ///   - requirements: A set of string values to match against. Matching any member of the set informs
        ///     the format style to omit the component.
        /// - Returns: A display option that omits the host component when a specified component meets
        ///   the specified requirements.
        public static func omitWhen(
            _ component: _polyfill_URLFormatStyle.Component,
            matches requirements: Set<String>
        ) -> Self {
            .init(
                option: .omitted,
                condition: .init(component: component, requirements: requirements),
                omitSpecificSubdomains: [],
                omitMultiLevelSubdomains: false
            )
        }

        /// A display option that omits the host component if the URL scheme is HTTP or HTTPS.
        public static var omitIfHTTPFamily: Self {
            .omitWhen(
                .scheme,
                matches: ["http", "https"]
            )
        }

        /// Returns a display option that omits the host component if it matches a set of subdomains.
        ///
        /// - Parameters:
        ///   - subdomainsToOmit: A set of subdomains to omit, such as `[”www”, “mobile”, “m”]`. Matching any
        ///     member of this set omits the host from the formatted output.
        ///   - omitMultiLevelSubdomains: A Boolean value to manage display of multi-level subdomains. If `true`,
        ///     format style omits additional subdomains if there are more than two in addition to the top-level
        ///     domain (TLD). For example, when this value is true, `api.code.developer.example.com` becomes
        ///     `developer.example.com`, because the TLD is `“com”`. By comparison,
        ///     `api.code.developer.example.com.cn` has a TLD of `“com.cn”`, so it becomes `developer.example.com.cn`.
        /// - Returns: A display option that omits the host component if it matches a set of subdomains.
        public static func omitSpecificSubdomains(
            _ subdomainsToOmit: Set<String> = [],
            includeMultiLevelSubdomains omitMultiLevelSubdomains: Bool = false
        ) -> Self {
            .init(
                option: .displayed,
                condition: nil,
                omitSpecificSubdomains: subdomainsToOmit,
                omitMultiLevelSubdomains: omitMultiLevelSubdomains
            )
        }

        /// Returns a display option that omits the host component if it matches a set of subdomains and a
        /// specified component matches a set of requirements.
        ///
        /// - Parameters:
        ///   - subdomainsToOmit: A set of subdomains to omit, such as `[”www”, “mobile”, “m”]`. Matching any
        ///     member of this set omits the host from the formatted output.
        ///   - omitMultiLevelSubdomains: A Boolean value to manage display of multi-level subdomains. If `true`,
        ///     format style omits additional subdomains if there are more than two in addition to the top-level
        ///     domain (TLD). For example, when this value is true, `api.code.developer.example.com` becomes
        ///     `developer.example.com`, because the TLD is `“com”`. By comparison,
        ///     `api.code.developer.example.com.cn` has a TLD of `“com.cn”`, so it becomes `developer.example.com.cn`.
        ///   - component: A component to compare. This may or may not be the host component itself.
        ///   - requirements: A set of string values to match against. Matching any member of the set informs
        ///     the format style to omit the component.
        /// - Returns: A display option that omits the host component if it matches a set of subdomains and a
        ///   specified component meets the specified requirements.
        public static func omitSpecificSubdomains(
            _ subdomainsToOmit: Set<String> = [],
            includeMultiLevelSubdomains omitMultiLevelSubdomains: Bool = false,
            when component: _polyfill_URLFormatStyle.Component,
            matches requirements: Set<String>
        ) -> Self {
            .init(
                option: .displayed,
                condition: .init(component: component, requirements: requirements),
                omitSpecificSubdomains: subdomainsToOmit,
                omitMultiLevelSubdomains: omitMultiLevelSubdomains
            )
        }
    }
}

extension _polyfill_URLFormatStyle: _polyfill_FormatStyle {
    /// Formats a URL, using this style.
    ///
    /// - Parameter value: The URL to format.
    /// - Returns: A string representation of `value`, formatted according to the style’s configuration.
    ///
    /// Use this method when you want to create a single style instance, and then use it to format multiple
    /// URL instances. The following example creates a custom format style and then uses it to format a variety
    /// of URLs in an array:
    ///
    /// ```swift
    /// let style = URL.FormatStyle(
    ///     scheme: .never,
    ///     user: .never,
    ///     password: .never,
    ///     host: .omitSpecificSubdomains(["www", "mobile", "m."],
    ///                                   includeMultiLevelSubdomains: true),
    ///     port: .never,
    ///     path: .always,
    ///     query: .never,
    ///     fragment: .never)
    /// let urls = [
    ///     URL(string: "https://www.example.com/path/one")!,
    ///     URL(string: "https://beta.example.com/path/two")!,
    ///     URL(string: "https://beta.staging.west.example.com/three")!,
    ///     URL(string: "https://query.example.com/four?key4=value4")!
    /// ]
    /// let formatted = urls.map { $0.formatted(style) } // ["example.com/path/one", "beta.example.com/path/two", "west.example.com/three", "query.example.com/four"]
    /// ```
    ///
    /// To format a single URL instance, use the `URL` instance method `formatted(_:)` method passing in an
    /// instance of `URL.FormatStyle`, or `formatted()` to use a default style.
    public func format(_ value: Foundation.URL) -> String {
        self.formatImpl(value)
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_URLFormatStyle {
    /// A default style for formatting a URL.
    ///
    /// Use the dot-notation form of this type property when the call point allows the use of `URL.FormatStyle`.
    /// You typically do this when calling the `formatted(_:)` method of `URL`.
    ///
    /// The format style provided by this static accessor provides a default behavior. To customize formatting
    /// behavior, use the modifiers in `Customizing style behavior`.
    ///
    /// The following example shows the use of a customized URL format style, created by modifying the default
    /// style. The custom style strips the scheme and port and omits the `www` subdomain, but leaves the path
    /// intact. This produces a simplified URL representation that a browser could use as a window title.
    ///
    /// ```swift
    /// let url = URL(string: "http://www.example.com:8080/path/to/file.txt")!
    /// let formatted = url.formatted(.url
    ///     .scheme(.never)
    ///     .host(.omitSpecificSubdomains(["www"]))
    ///     .port(.never)) // "example.com/path/to/file.txt"
    /// ```
    public static var url: Self {
        .init()
    }
}

extension Foundation.URL {
    /// Formats the URL, using the provided format style.
    ///
    /// - Parameter format: The format style to apply when formatting the URL.
    /// - Returns: A formatted string representation of the URL.
    ///
    /// Use this method when you want to format a single URL value with a specific format style, or call
    /// it repeatedly with different format styles. The following example uses the static accessor `url` to
    /// get a default style, then modifies its behavior to include or omit different URL components when
    /// `formatted(_:)` creates the string:
    ///
    /// ```swift
    /// let url = URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted(.url
    ///     .scheme(.never)
    ///     .host(.always)
    ///     .port(.never)
    ///     .path(.always)
    ///     .query(.never)) // "www.example.com/path/to/endpoint"
    /// ```
    public func _polyfill_formatted<F>(
        _ format: F
    ) -> F.FormatOutput
        where F: _polyfill_FormatStyle, F.FormatInput == Self
    {
        format.format(self)
    }

    /// Formats the URL using a default format style.
    ///
    /// Use this method to create a string representation of a URL using the default `URL.FormatStyle`
    /// configuration. As seen in the following example, the default style creates a string with the
    /// scheme, host, and path, but not the port or query.
    ///
    /// ```swift
    /// let url = URL(string: "https://www.example.com:8080/path/to/endpoint?key=value")!
    /// let formatted = url.formatted() // "https://www.example.com/path/to/endpoint"
    /// ```
    ///
    /// To customize formatting of the URL, use `formatted(_:)`, passing in a customized `FormatStyle`.
    ///
    /// - Returns: A string representation of the URL, formatted according to the default format style.
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_URLFormatStyle())
    }
}

extension _polyfill_URLFormatStyle: _polyfill_ParseableFormatStyle {
    /// A `ParseStrategy` that can be used to parse this `FormatStyle`'s output
    public var parseStrategy: _polyfill_URLParseStrategy {
        .init(
            scheme:   self.scheme   == .always ? .required : .optional,
            user:     self.user     == .always ? .required : .optional,
            password: self.password == .always ? .required : .optional,
            host:     self.host     == .always ? .required : .optional,
            port:     self.port     == .always ? .required : .optional,
            path:     self.path     == .always ? .required : .optional,
            query:    self.query    == .always ? .required : .optional,
            fragment: self.fragment == .always ? .required : .optional
        )
    }
}

extension _polyfill_ParseableFormatStyle where Self == _polyfill_URLFormatStyle {
    /// A default style for formatting a URL.
    ///
    /// Use the dot-notation form of this type property when the call point allows the use of
    /// `URL.ParseableFormatStyle`. You typically do this when calling the `formatted(_:)` method of `URL`.
    ///
    /// The format style provided by this static accessor provides a default behavior. To customize formatting
    /// behavior, use the modifiers in `Customizing style behavior`.
    ///
    /// The following example shows the use of a customized URL format style, created by modifying the default
    /// style. The custom style strips the scheme and port and omits the `www` subdomain, but leaves the path
    /// intact. This produces a simplified URL representation that a browser could use as a window title.
    ///
    /// ```swift
    /// let url = URL(string: "http://www.example.com:8080/path/to/file.txt")!
    /// let formatted = url.formatted(.url
    ///     .scheme(.never)
    ///     .host(.omitSpecificSubdomains(["www"]))
    ///     .port(.never)) // "example.com/path/to/file.txt"
    /// ```
    public static var url: Self {
        .init()
    }
}

// MARK: - Implementation guts

extension Foundation.URL {
    /// If the given URL has this component, return its unencoded value.
    fileprivate func component(_ component: _polyfill_URLFormatStyle.Component) -> String? {
        switch component {
        case .scheme:   self.scheme
        case .user:     self.user(percentEncoded: false)
        case .password: self.password(percentEncoded: false)
        case .host:
            // URL.host() doesn't include the `[]`s for `[]`-enclosed hosts
            URLComponents(url: self, resolvingAgainstBaseURL: true).flatMap(\.host)
        case .port:     self.port.map(String.init(_:))
        case .path:     self.path(percentEncoded: false)
        case .query:    self.query(percentEncoded: false)
        case .fragment: self.fragment(percentEncoded: false)
        }
    }
}

extension _polyfill_URLFormatStyle {
    /// Return the configured display option for the given component. For `.host`, returns only the option an
    /// condition; the omit options must be handled separately.
    private func option(for component: Component) -> ComponentDisplayOption {
        switch component {
        case .scheme:   self.scheme
        case .user:     self.user
        case .password: self.password
        case .host:     .init(option: self.host.option, condition: self.host.condition)
        case .port:     self.port
        case .path:     self.path
        case .query:    self.query
        case .fragment: self.fragment
        }
    }

    /// Resolve the configured option for the given component. If the option resolves in favor of display, and the
    /// URL has the requesting component, the value of that component is returned. In all other cases, returns `nil`.
    private func applyOption(for component: _polyfill_URLFormatStyle.Component, to value: Foundation.URL) -> String? {
        guard let baseComponent = value.component(component) else { return nil } // bail if there's nothing to display

        let config = self.option(for: component)
        
        if let cond = config.condition { // if no condition, always pass
            guard let comp = value.component(cond.component), cond.requirements.contains(comp) else {
                return config.option == .displayed ? nil : baseComponent // failed; invert condition
            }
        }
        return config.option == .displayed ? baseComponent : nil // passed; obey condition
    }

    /// Resolve the configured host options, including resolving the generic component configuration first.
    ///
    /// > Warning: Unlike the native Darwin implementation of `URL.FormatStyle`, this implementation does _not_
    /// > perform TLD suffix matching or recognize SLDs. This decision was made for several reasons:
    /// >
    /// > 1. Doing so would require having a copy of the [Public Suffix List] available, and - given the obvious
    /// >    absurdity of trying to load the list over the network in real time (especially in this context) -
    /// >    creating an obligation to keep the list up to date.
    /// > 2. The PSL has [several other well-known drawbacks][psldrawbacks], not the least of which is the
    /// >    questionable provenance of much of its content.
    /// > 3. The `URL.FormatStyle.HostDisplayOption` configurations which make use of TLD matching are primarily
    /// >    useful for (and used by) WebKit; it is not expected that a majority or even a significant minority
    /// >    of users will ever run into this.
    /// >
    /// > In the future, for the sake of covering the common cases, we may choose to implement logic such that TLDs
    /// > that match one of ICU's available region codes will be assumed to have an SLD and treated accordingly.
    /// > This is **not** currently implemented because it's likely to be wrong as often as it's right, the results
    /// > of which are more destructive than doing nothing.
    ///
    /// [Public Suffix List]: https://publicsuffix.org
    /// [psldrawbacks]: https://itp.cdn.icann.org/en/files/security-and-stability-advisory-committee-ssac-reports/sac-070-en.pdf
    private func applyHostOption(to value: Foundation.URL) -> String? {
        switch self.host.option {
        // If there aren't any host-specific settings, or it's an omit rule, just pass the buck
        case .displayed where self.host.omitSpecificSubdomains.isEmpty && !self.host.omitMultiLevelSubdomains,
             .omitted:
            return self.applyOption(for: .host, to: value)
        
        case .displayed:
            /// 1. Check there's a host component at all, and if there's a condition, apply it.
            guard let base = self.applyOption(for: .host, to: value) else {
                return nil
            }
            
            /// 2. Bail if the host looks like an IPv4, IPv6, or IP-future address (very lazy check); additional config doesn't apply.
            if (base.first == "[" && base.last == "]") || base.allSatisfy({ $0 == "." || $0.isNumber }) {
                return base
            }
            
            // 3. Split the host component into a list of labels.
            var labels = base.split(separator: ".", omittingEmptySubsequences: false)
            
            /// 4. Apply `omitMultiLevelSubdomains`.
            if self.host.omitMultiLevelSubdomains, let idx = labels.index(labels.endIndex, offsetBy: -3, limitedBy: labels.startIndex) {
                labels.removeSubrange(..<idx)
            }
            
            /// 5. Apply `subdomainsToOmit`.
            if labels.count > 2, self.host.omitSpecificSubdomains.contains(String(labels[0])) {
                labels.removeFirst()
            }
            
            return labels.joined(separator: ".")
        }
    }

    /// The actual formatting implementation - this is the sole piece of both functional and non-representational code
    /// across the entire format style type.
    private func formatImpl(_ value: Foundation.URL) -> String {
        let scheme   = self.applyOption(for: .scheme, to: value)
        let host     = self.applyHostOption(to: value)
        let user     = host != nil ? self.applyOption(for: .user, to: value) : nil
        let password = host != nil ? self.applyOption(for: .password, to: value) : nil
        let port     = host != nil ? self.applyOption(for: .port, to: value) : nil
        let path     = self.applyOption(for: .path, to: value)
        let query    = self.applyOption(for: .query, to: value)
        let fragment = self.applyOption(for: .fragment, to: value)
        
        return """
        \(scheme.map   { "\($0):" } ?? "")\
        \(scheme != nil && host != nil ? "//" : "")\
        \(user.map     { "\($0)" }    ?? "")\
        \(password.map { ":\($0)" }   ?? "")\
        \((user ?? password) != nil ? "@" : "")\
        \(host.map     { "\($0)" }    ?? "")\
        \(port.map     { ":\($0)" }   ?? "")\
        \(path.map     { "\($0)" }    ?? "")\
        \(query.map    { "?\($0)" }   ?? "")\
        \(fragment.map { "#\($0)" }   ?? "")
        """
    }
}
