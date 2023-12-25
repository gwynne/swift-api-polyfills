#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// A ``FormatStyle`` that displays a duration as a list of duration units, such as
    /// "2 hours, 43 minutes, 26 seconds" in English.
    public typealias UnitsFormatStyle = Swift.Duration._polyfill_UnitsFormatStyle
}

#endif
