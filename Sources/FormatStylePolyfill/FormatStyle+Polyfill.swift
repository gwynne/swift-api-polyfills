import Foundation

/// A type that can convert a given data type into a representation.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
public protocol _polyfill_FormatStyle: Swift.Codable, Swift.Hashable {
    /// The type of data to format.
    associatedtype FormatInput

    /// The type of the formatted data.
    associatedtype FormatOutput

    /// Creates a `FormatOutput` instance from `value`.
    func format(_ value: Self.FormatInput) -> Self.FormatOutput

    /// If the format allows selecting a locale, returns a copy of this format with the new locale set. Default implementation returns an unmodified self.
    func locale(_ locale: Foundation.Locale) -> Self
}

#if !canImport(Darwin)

/// A type that can convert a given data type into a representation.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public typealias FormatStyle = _polyfill_FormatStyle

#endif
