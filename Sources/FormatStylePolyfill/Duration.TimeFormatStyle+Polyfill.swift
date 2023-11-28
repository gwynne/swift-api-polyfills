import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public struct _polyfill_TimeFormatStyle: _polyfill_FormatStyle, Sendable {
        /// The locale to use when formatting the duration.
        public var locale: Foundation.Locale

        /// The pattern to display a Duration with.
        public var pattern: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle {
    /// Creates an instance using the provided pattern and locale.
    /// - Parameters:
    ///   - pattern: A `Pattern` to specify the units to include in the displayed string and the behavior of the units.
    ///   - locale: The `Locale` used to create the string representation of the duration.
    public init(pattern: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern, locale: Foundation.Locale = .autoupdatingCurrent) {
        self.pattern = pattern
        self.locale = locale
    }

    /// Creates a locale-aware string representation from a duration value.
    /// - Parameter value: The value to format.
    /// - Returns: A string representation of the duration.
    public func format(_ value: Swift.Duration) -> String {
        self.pattern.format(value, in: self.locale)
    }

    /// Modifies the format style to use the specified locale.
    /// - Parameter locale: The locale to use when formatting a duration.
    /// - Returns: A format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Swift.Duration._polyfill_TimeFormatStyle {
        var res = self
        res.locale = locale
        return res
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public typealias TimeFormatStyle = Swift.Duration._polyfill_TimeFormatStyle
}

#endif
