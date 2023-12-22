#if !canImport(Darwin)

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle {
    /// A format style that converts between floating-point currency values and their textual representations.
    public typealias Currency = _polyfill_Currency
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle.Currency {
    /// The type the format style uses for configuration settings.
    public typealias Configuration = _polyfill_FloatingPointFormatStyle._polyfill_Currency._polyfill_Configuration
}

#endif
