#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration.TimeFormatStyle {
    /// The units to display a Duration with and configurations for the units.
    public typealias Pattern = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern
}

#endif
