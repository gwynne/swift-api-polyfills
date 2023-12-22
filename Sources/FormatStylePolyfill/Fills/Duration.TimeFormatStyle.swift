#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public typealias TimeFormatStyle = Swift.Duration._polyfill_TimeFormatStyle
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension FormatStyle where Self == Swift.Duration.TimeFormatStyle {
    /// A factory variable to create a time format style to format a duration.
    ///
    /// - Parameter pattern: A `Pattern` to specify the units to include in the displayed string and the
    ///   behavior of the units.
    /// - Returns: A format style to format a duration.
    public static func time(pattern: Swift.Duration.TimeFormatStyle.Pattern) -> Self {
        self._polyfill_time(pattern: pattern)
    }
}

#endif
