import struct Foundation.AttributedString
import struct Foundation.Locale

extension _polyfill_DurationTimeFormatStyle {
    /// Formats a duration as an attributed string with the `durationField` attribute key and
    /// `FoundationAttributes.DurationFieldAttribute` attribute.
    ///
    /// For example, two hour, 43 minute and 26.25 seconds can be formatted as an attributed string,
    /// "2:43:26.25" with the following run text and attributes:
    ///
    /// ```swift
    /// 2 { durationField: .hours }
    /// : { nil }
    /// 43 { durationField: .minutes }
    /// : { nil }
    /// 26.25 { durationField: .seconds }
    /// ```
    public struct Attributed: Swift.Sendable {
        var locale: Foundation.Locale
        var pattern: _polyfill_DurationTimeFormatStyle.Pattern
        
        internal init(locale: Foundation.Locale, pattern: _polyfill_DurationTimeFormatStyle.Pattern) {
            self.locale = locale
            self.pattern = pattern
        }
    }
}

extension _polyfill_DurationTimeFormatStyle.Attributed: _polyfill_FormatStyle {
    /// Modifies the format style to use the specified locale.
    /// - Parameter locale: The locale to use when formatting a duration.
    /// - Returns: A format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
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
