#if !canImport(Darwin)

import struct Foundation.Decimal

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal {
    public typealias FormatStyle = Foundation.Decimal._polyfill_FormatStyle
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal.FormatStyle {
        /// The type the format style uses for configuration settings.
    public typealias Configuration = Foundation.Decimal._polyfill_FormatStyle._polyfill_Configuration
    
    /// A format style that converts between decimal percentage values and their textual representations.
    public typealias Percent = Foundation.Decimal._polyfill_FormatStyle._polyfill_Percent

    /// A format style that converts between decimal currency values and their textual representations.
    public typealias Currency = Foundation.Decimal._polyfill_FormatStyle._polyfill_Currency

    /// A format style that converts integers into attributed strings.
    public typealias Attributed = Foundation.Decimal._polyfill_FormatStyle._polyfill_Attributed
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal.FormatStyle.Percent {
    /// The type the format style uses for configuration settings.
    public typealias Configuration = Foundation.Decimal._polyfill_FormatStyle._polyfill_Percent._polyfill_Configuration
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal.FormatStyle.Currency {
    /// The type the format style uses for configuration settings.
    public typealias Configuration = Foundation.Decimal._polyfill_FormatStyle.Currency._polyfill_Configuration
}

#endif
