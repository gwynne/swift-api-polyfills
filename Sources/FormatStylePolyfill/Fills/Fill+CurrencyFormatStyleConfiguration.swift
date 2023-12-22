#if !canImport(Darwin)

/// Configuration settings for formatting currency values.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias CurrencyFormatStyleConfiguration = _polyfill_CurrencyFormatStyleConfiguration

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension CurrencyFormatStyleConfiguration {
    /// The type used to configure grouping for currency format styles.
    public typealias Grouping = _polyfill_CurrencyFormatStyleConfiguration._polyfill_Grouping
    
    /// The type used to configure precision for currency format styles.
    public typealias Precision = _polyfill_CurrencyFormatStyleConfiguration._polyfill_Precision
    
    /// The type used to configure decimal separator display strategies for currency format styles.
    public typealias DecimalSeparatorDisplayStrategy = _polyfill_CurrencyFormatStyleConfiguration._polyfill_DecimalSeparatorDisplayStrategy
    
    /// The type used to configure rounding rules for currency format styles.
    public typealias RoundingRule = _polyfill_CurrencyFormatStyleConfiguration._polyfill_RoundingRule

    /// A structure used to configure sign display strategies for currency format styles.
    public typealias SignDisplayStrategy = _polyfill_CurrencyFormatStyleConfiguration._polyfill_SignDisplayStrategy

    /// A structure used to configure the presentation of currency format styles.
    public typealias Presentation = _polyfill_CurrencyFormatStyleConfiguration._polyfill_Presentation
}

#endif

