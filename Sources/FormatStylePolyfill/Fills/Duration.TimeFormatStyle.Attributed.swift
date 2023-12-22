#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration.TimeFormatStyle {
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
    public typealias Attributed = Swift.Duration._polyfill_TimeFormatStyle._polyfill_Attributed
}

#endif
