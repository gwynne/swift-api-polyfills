#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public typealias TimeFormatStyle = Swift.Duration._polyfill_TimeFormatStyle
}

#endif
