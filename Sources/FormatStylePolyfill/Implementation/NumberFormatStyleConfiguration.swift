/// Configuration settings for formatting numbers of different types.
///
/// This type is effectively a namespace to collect types that configure parts of a formatted number,
/// such as grouping, precision, and separator and sign characters.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
public enum _polyfill_NumberFormatStyleConfiguration {
    internal struct Collection: Codable, Hashable, Sendable {
        var scale: Scale?
        var precision: _polyfill_Precision?
        var group: _polyfill_Grouping?
        var signDisplayStrategy: _polyfill_SignDisplayStrategy?
        var decimalSeparatorStrategy: _polyfill_DecimalSeparatorDisplayStrategy?
        var rounding: _polyfill_RoundingRule?
        var roundingIncrement: RoundingIncrement?
        var notation: _polyfill_Notation?
    }
    
    enum RoundingIncrement: Hashable, CustomStringConvertible {
        case integer(value: Int), floatingPoint(value: Double)

        var description: String { switch self {
            case .integer(let value): String(value)
            case .floatingPoint(let value): String(value)
        } }
    }

    typealias Scale = Double

    /// The type used for rounding rule values.
    ///
    /// `NumberFormatStyleConfiguration` uses the `FloatingPointRoundingRule` enumeration for rounding rule values.
    public typealias _polyfill_RoundingRule = Swift.FloatingPointRoundingRule

    /// A structure that an integer format style uses to configure grouping.
    public struct _polyfill_Grouping : Codable, Hashable, CustomStringConvertible, Sendable {
        enum Option: Int, Codable, Hashable { case automatic, hidden }
        
        let option: Option

        /// A grouping behavior that automatically applies locale-appropriate grouping.
        public static var automatic: Self { .init(option: .automatic) }
        
        /// A grouping behavior that never groups digits.
        public static var never: Self { .init(option: .hidden) }

        public var description: String { self.option == .automatic ? "automatic" : "never" }
    }
    
    /// A structure that an integer format style uses to configure precision.
    public struct _polyfill_Precision: Codable, Hashable, Sendable {
        enum Option: Hashable {
            case significantDigits(Range<Int>)
            case integerAndFractionalLength(minInt: Int?, maxInt: Int?, minFraction: Int?, maxFraction: Int?)
        }

        let option: Option

        private static let validPartLength = 0 ..< 999
        private static let validSignificantDigits = 1 ..< 999

        /// Returns a precision that constrains formatted values to a range of significant digits.
        ///
        /// When using this precision, the formatter rounds values that have more sigificant digits than
        /// the maximum of the range, as seen in the following example:
        ///
        /// ```swift
        /// let myNum = 123456.formatted(.number
        ///     .precision(.significantDigits(2...4))
        ///     .rounded(rule: .down)) // "123,400"
        /// ```
        ///
        /// - Parameter limits: A range from the minimum to the maximum number of significant digits to
        ///   use when formatting values.
        /// - Returns: A precision that constrains formatted values to a range of significant digits.
        public static func significantDigits(_ limits: some RangeExpression<Int>) -> Self {
            .init(option: .significantDigits(limits.relative(to: Int.min ..< Int.max).clamped(to: self.validSignificantDigits)))
        }

        /// Returns a precision that constrains formatted values to a given number of significant digits.
        ///
        /// When using this precision, the formatter rounds values that have more sigificant digits than
        /// the maximum of the range, as seen in the following example:
        ///
        /// ```swift
        /// let myNum = 123456.formatted(.number
        ///     .precision(.significantDigits(2...4))
        ///     .rounded(rule: .down)) // "123,400"
        /// ```
        ///
        /// - Parameter digits: The maximum number of significant digits to use when formatting values.
        /// - Returns: A precision that constrains formatted values to a given number of significant digits.
        public static func significantDigits(_ digits: Int) -> Self { .significantDigits(digits ... digits) }

        /// Returns a precision that constrains formatted values to ranges of allowed digits in the
        /// integer and fraction parts.
        ///
        /// When using this precision, the formatter rounds values that have more digits than the maximum
        /// of the range, as seen in the following example:
        ///
        /// ```swift
        /// let myNum = 12345.6789.formatted(.number
        ///      .precision(.integerAndFractionLength(integerLimits: 2...,
        ///                                           fractionLimits: 2...3))
        ///      .rounded(rule: .down)) // "12,345.678"
        /// ```
        ///
        /// - Parameters:
        ///   - integerLimits: A range from the minimum to the maximum number of digits to use when formatting
        //      the integer part of a number.
        ///   - fractionLimits: A range from the minimum to the maximum number of digits to use when formatting
        ///     the fraction part of a number.
        /// - Returns: A precision that constrains formatted values to ranges of digits in the integer and
        ///   fraction parts.
        public static func integerAndFractionLength(integerLimits: some RangeExpression<Int>, fractionLimits: some RangeExpression<Int>) -> Self {
            let intBounds = integerLimits.relative(to: Int.max ..< .max).clamped(to: 0 ..< .max)
            let fracBounds = fractionLimits.relative(to: Int.max ..< .max).clamped(to: 0 ..< .max)
            
            return .init(option: .integerAndFractionalLength(minInt: intBounds.lowerBound, maxInt: intBounds.upperBound, minFraction: fracBounds.lowerBound, maxFraction: fracBounds.upperBound))
        }
        
        /// Returns a precision that constrains formatted values a given number of allowed digits in the
        /// integer and fraction parts.
        ///
        /// When using this precision, the formatter pads values with fewer digits than the specified digits
        /// for the integer or fraction parts. Similarly, it rounds values that have more digits than specified.
        /// The following example shows this behavior, padding the integer part while rounding the fraction:
        ///
        /// ```
        /// let myNum = 12345.6789.formatted(.number
        ///     .precision(.integerAndFractionLength(integer: 6,
        ///                                          fraction: 3))
        ///     .rounded(rule: .down)) // "012,345.678"
        /// ```
        ///
        /// - Parameters:
        ///   - integer: The number of digits to use when formatting the integer part of a number.
        ///   - fraction: The number of digits to use when formatting the fraction part of a number.
        /// - Returns: A precision that constrains formatted values a given number of digits in the
        ///   integer and fraction parts.
        public static func integerAndFractionLength(integer: Int, fraction: Int) -> Self {
            .init(option: .integerAndFractionalLength(minInt: integer, maxInt: integer, minFraction: fraction, maxFraction: fraction))
        }
        
        /// Returns a precision that constrains formatted values to a range of allowed digits in the integer part.
        ///
        /// - Parameter limits: A range from the minimum to the maximum number of digits to use when formatting
        ///   the integer part of a number.
        /// - Returns: A precision that constrains formatted values to ranges of digits in the integer part.
        public static func integerLength(_ limits: some RangeExpression<Int>) -> Self {
            let bounds = limits.relative(to: Int.min ..< .max).clamped(to: 0 ..< .max)
            return .init(option: .integerAndFractionalLength(minInt: bounds.lowerBound, maxInt: bounds.upperBound, minFraction: nil, maxFraction: nil))
        }
        
        /// Returns a precision that constrains formatted values to a given number of allowed digits in
        /// the integer part.
        ///
        /// - Parameter limits: The number of digits to use when formatting the integer part of a number.
        /// - Returns: A precision that constrains formatted values to a given number of allowed digits in the integer part.
        public static func integerLength(_ length: Int) -> Self {
            .init(option: .integerAndFractionalLength(minInt: length, maxInt: length, minFraction: nil, maxFraction: nil))
        }

        /// Returns a precision that constrains formatted values to a range of allowed digits in the fraction part.
        ///
        /// - Parameter limits: A range from the minimum to the maximum number of digits to use when formatting
        ///   the fraction part of a number.
        /// - Returns: A precision that constrains formatted values to a range of allowed digits in the fraction part.
        public static func fractionLength(_ limits: some RangeExpression<Int>) -> Self {
            let bounds = limits.relative(to: Int.min ..< .max).clamped(to: 0 ..< .max)
            return .init(option: .integerAndFractionalLength(minInt: nil, maxInt: nil, minFraction: bounds.lowerBound, maxFraction: bounds.upperBound))
        }

        /// Returns a precision that constrains formatted values to a given number of allowed digits in
        /// the fraction part.
        ///
        /// - Parameter length: The number of digits to use when formatting the fraction part of a number.
        /// - Returns: A precision that constrains formatted values to a given number of allowed digits in
        ///   the fraction part.
        public static func fractionLength(_ length: Int) -> Self {
            .init(option: .integerAndFractionalLength(minInt: nil, maxInt: nil, minFraction: length, maxFraction: length))
        }
    }

    /// A structure that an integer format style uses to configure a decimal separator display strategy.
    public struct _polyfill_DecimalSeparatorDisplayStrategy: Codable, Hashable, CustomStringConvertible, Sendable {
        enum Option: Int, Codable, Hashable { case automatic, always }
        let option: Option

        /// A strategy to automatically configure locale-appropriate decimal separator display behavior.
        public static var automatic: Self { .init(option: .automatic) }
        
        /// A strategy that always displays decimal separators.
        public static var always: Self { .init(option: .always) }
        
        public var description: String { self.option == .automatic ? "automatic" : "always" }
    }

    /// A structure that an integer format style uses to configure a sign display strategy.
    public struct _polyfill_SignDisplayStrategy: Codable, Hashable, CustomStringConvertible, Sendable {
        enum Option: Int, Hashable, Codable { case always, hidden }

        let positive: Option
        let negative: Option
        let zero: Option

        /// A strategy to automatically configure locale-appropriate sign display behavior.
        public static var automatic: Self { .init(positive: .hidden, negative: .always, zero: .hidden) }
        
        /// A strategy to never display sign symbols.
        public static var never: Self { .init(positive: .hidden, negative: .hidden, zero: .hidden) }
        
        /// A strategy to always display sign symbols.
        ///
        /// - Parameter includingZero: A Boolean value that determines whether the format style should
        ///   apply sign characters to zero values. Defaults to `true`.
        /// - Returns: A strategy to always display sign symbols, with the given behavior for zero values.
        public static func always(includingZero z: Bool = true) -> Self { .init(positive: .always, negative: .always, zero: z ? .always : .hidden) }

        public var description: String {
            switch (self.positive, self.zero, self.negative) {
            case (.always, .always, _): "always(includingZero: true)"
            case (.always, .hidden, _): "always(includingZero: false)"
            case (.hidden, _, .always): "automatic"
            case (.hidden, _, .hidden): "never"
            }
        }

    }

    /// A structure that an integer format style uses to configure notation.
    public struct _polyfill_Notation: Codable, Hashable, CustomStringConvertible, Sendable {
        enum Option: Int, Codable, Hashable { case automatic, scientific, compactName }
        let option: Option

        /// A notation constant that formats values with scientific notation.
        public static var scientific: Self { .init(option: .scientific) }
        
        /// A notation that automatically provides locale-appropriate behavior.
        public static var automatic: Self { .init(option: .automatic) }
        
        /// A locale-appropriate compact name notation.
        public static var compactName: Self { .init(option: .compactName) }

        public var description: String { switch self.option {
            case .scientific: "scientific"
            case .automatic: "automatic"
            case .compactName: "compact name"
        } }
    }
}