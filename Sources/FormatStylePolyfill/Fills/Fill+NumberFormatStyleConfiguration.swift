#if !canImport(Darwin)

/// Configuration settings for formatting numbers of different types.
///
/// This type is effectively a namespace to collect types that configure parts of a formatted number,
/// such as grouping, precision, and separator and sign characters.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias NumberFormatStyleConfiguration = _polyfill_NumberFormatStyleConfiguration

#endif
