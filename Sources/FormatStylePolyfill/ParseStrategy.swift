/// A type that parses an input representation, such as a formatted string, into a provided data type.
///
/// A `ParseStrategy` allows you to convert a formatted representation into a data type, using one
/// of two approaches:
///
/// * Initialize the data type by calling an initializer of that type that takes a formatted instance
///   and a parse strategy as parameters. For example, you can create a `Decimal` from a formatted string
///   with the initializer `init(_:format:lenient:)`.
/// * Create a parse strategy and call its `parse(_:)` method on one or more formatted instances.
///
/// `ParseStrategy` is closely related to `FormatStyle`, which provides the opposite conversion: from data
/// type to formatted representation. To use a parse strategy, you create a `FormatStyle` to define the
/// representation you expect, then access the style’s `parseStrategy` property to get a strategy instance.
///
/// The following example creates a `Decimal.FormatStyle.Currency` format style that uses US dollars and
/// US English number-formatting conventions. It then creates a `Decimal` instance by providing a formatted
/// string to parse and the format style’s `parseStrategy`.
///
/// ```swift
/// let style = Decimal.FormatStyle.Currency(code: "USD",
///                                          locale: Locale(identifier: "en_US"))
/// let parsed = try? Decimal("$12,345.67",
///                            strategy: style.parseStrategy) // 12345.67
/// ```
public protocol _polyfill_ParseStrategy: Codable, Hashable {
    /// The input type parsed by this strategy.
    ///
    /// Conforming types provide a value for this associated type to declare the type of values they parse.
    associatedtype ParseInput

    /// The output type returned by this strategy.
    ///
    /// Conforming types provide a value for this associated type to declare the type of values they return.
    associatedtype ParseOutput

    /// Parses a value, using this strategy.
    ///
    /// This method throws an error if the parse strategy can’t parse `value`.
    ///
    /// - Parameter value: A value whose type matches the strategy’s `ParseInput` type.
    /// - Returns: A parsed value of the type declared by `ParseOutput`.
    func parse(_ value: ParseInput) throws -> ParseOutput
}

/// A type that can convert a given input data type into a representation in an output type.
public protocol _polyfill_ParseableFormatStyle: _polyfill_FormatStyle {
    /// The type this format style uses for its parse strategy.
    associatedtype Strategy: _polyfill_ParseStrategy where
        Strategy.ParseInput == FormatOutput, Strategy.ParseOutput == FormatInput

    /// A `ParseStrategy` that can be used to parse this `FormatStyle`'s output
    var parseStrategy: Strategy { get }
}
