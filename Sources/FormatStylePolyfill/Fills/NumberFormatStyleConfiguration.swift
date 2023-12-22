#if !canImport(Darwin)

/// Configuration settings for formatting numbers of different types.
///
/// This type is effectively a namespace to collect types that configure parts of a formatted number,
/// such as grouping, precision, and separator and sign characters.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias NumberFormatStyleConfiguration = _polyfill_NumberFormatStyleConfiguration

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NumberFormatStyleConfiguration {
    /// The type used for rounding rule values.
    ///
    /// `NumberFormatStyleConfiguration` uses the `FloatingPointRoundingRule` enumeration for rounding rule values.
    public typealias RoundingRule = _polyfill_NumberFormatStyleConfiguration._polyfill_RoundingRule
    
    /// A structure that an integer format style uses to configure grouping.
    public typealias Grouping = _polyfill_NumberFormatStyleConfiguration._polyfill_Grouping
    
    /// A structure that an integer format style uses to configure precision.
    public typealias Precision = _polyfill_NumberFormatStyleConfiguration._polyfill_Precision

    /// A structure that an integer format style uses to configure a decimal separator display strategy.
    public typealias DecimalSeparatorDisplayStrategy = _polyfill_NumberFormatStyleConfiguration._polyfill_DecimalSeparatorDisplayStrategy

    /// A structure that an integer format style uses to configure a sign display strategy.
    public typealias SignDisplayStrategy = _polyfill_NumberFormatStyleConfiguration._polyfill_SignDisplayStrategy

    /// A structure that an integer format style uses to configure notation.
    public typealias Notation = _polyfill_NumberFormatStyleConfiguration._polyfill_Notation
}

#endif
