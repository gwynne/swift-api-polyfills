import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle {
    /// Formats a duration as an attributed string with the `durationField` attribute key and `FoundationAttributes.DurationFieldAttribute` attribute.
    /// For example, two hour, 43 minute and 26.25 seconds can be formatted as an attributed string, "2:43:26.25" with the following run text and attributes:
    /// ```
    /// 2 { durationField: .hours }
    /// : { nil }
    /// 43 { durationField: .minutes }
    /// : { nil }
    /// 26.25 { durationField: .seconds }
    /// ```
    public struct _polyfill_Attributed: Swift.Sendable {
        var locale: Foundation.Locale
        var pattern: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern
        
        internal init(locale: Foundation.Locale, pattern: Swift.Duration._polyfill_TimeFormatStyle._polyfill_Pattern) {
            self.locale = locale
            self.pattern = pattern
        }
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed: _polyfill_FormatStyle {
    /// Modifies the format style to use the specified locale.
    /// - Parameter locale: The locale to use when formatting a duration.
    /// - Returns: A format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed {
        var new = self
        new.locale = locale
        return new
    }

    /// Formats a duration as an attributed string with `DurationFieldAttribute`.
    /// - Parameter value: The value to format.
    /// - Returns: An attributed string to represent the duration.
    public func format(_ value: Swift.Duration) -> Foundation.AttributedString {
        Self.formatImpl(value: value, locale: self.locale, pattern: self.pattern)
    }

    /// The type of data to format.
    public typealias FormatInput = Swift.Duration
    
    /// The type of the formatted data.
    public typealias FormatOutput = Foundation.AttributedString
}


#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration.TimeFormatStyle {
    /// Formats a duration as an attributed string with the `durationField` attribute key and `FoundationAttributes.DurationFieldAttribute` attribute.
    /// For example, two hour, 43 minute and 26.25 seconds can be formatted as an attributed string, "2:43:26.25" with the following run text and attributes:
    /// ```
    /// 2 { durationField: .hours }
    /// : { nil }
    /// 43 { durationField: .minutes }
    /// : { nil }
    /// 26.25 { durationField: .seconds }
    /// ```
    public typealias Attributed = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed
}

#endif
