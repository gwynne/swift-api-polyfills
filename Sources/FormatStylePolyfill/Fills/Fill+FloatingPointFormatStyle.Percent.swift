#if !canImport(Darwin)

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle {
    /// A format style that converts between floating-point percentage values and their textual representations.
    public typealias Percent = _polyfill_FloatingPointFormatStyle._polyfill_Percent
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle.Percent {
    /// The type the format style uses for configuration settings.
    public typealias Configuration = _polyfill_FloatingPointFormatStyle._polyfill_Percent._polyfill_Configuration
}

#endif
