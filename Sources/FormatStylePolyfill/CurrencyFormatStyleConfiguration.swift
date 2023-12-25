import Foundation
import CLegacyLibICU

/// Configuration settings for formatting currency values.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@_documentation(visibility: internal)
public enum _polyfill_CurrencyFormatStyleConfiguration {
    /// The type used to configure grouping for currency format styles.
    public typealias Grouping = _polyfill_NumberFormatStyleConfiguration.Grouping
    
    /// The type used to configure precision for currency format styles.
    public typealias Precision = _polyfill_NumberFormatStyleConfiguration.Precision
    
    /// The type used to configure decimal separator display strategies for currency format styles.
    public typealias DecimalSeparatorDisplayStrategy = _polyfill_NumberFormatStyleConfiguration.DecimalSeparatorDisplayStrategy
    
    /// The type used to configure rounding rules for currency format styles.
    public typealias RoundingRule = _polyfill_NumberFormatStyleConfiguration.RoundingRule

    /// A structure used to configure sign display strategies for currency format styles.
    public struct SignDisplayStrategy: Codable, Hashable, Sendable {
        enum Option: Int, Hashable, Codable {
            case always
            case hidden
        }
        
        let positive: Option
        let negative: Option
        let zero: Option
        let accounting: Bool
        
        /// A strategy to automatically configure sign display.
        public static var automatic: Self {
            .init(positive: .hidden, negative: .always, zero: .hidden, accounting: false)
        }
        
        /// A strategy to never show the sign.
        public static var never: Self {
            .init(positive: .hidden, negative: .hidden, zero: .hidden, accounting: false)
        }
        
        /// A sign display strategy to always show the sign, with a configurable behavior for handling zero values.
        ///
        /// - Parameter showZero: A Boolean value that indicates whether to show the sign symbol on zero values.
        ///   Defaults to `true`.
        /// - Returns: A sign display strategy that always displays the sign, and uses the specified handling of
        ///   zero values.
        public static func always(showZero: Bool = true) -> Self {
            .init(positive: .always, negative: .always, zero: showZero ? .always : .hidden, accounting: false)
        }
        
        /// A sign display strategy to use accounting principles.
        ///
        /// This strategy always shows the currency symbol, and shows negative values in parenthesis. Examples
        /// of this strategy include `$123`, `$0`, and `($123)`.
        public static var accounting: Self {
            .init(positive: .hidden, negative: .always, zero: .hidden, accounting: true)
        }
        
        /// A sign display strategy to use accounting principles, with a configurable behavior for handling
        /// zero values.
        ///
        /// - Parameter showZero: A Boolean value that indicates whether to show the sign symbol on zero values.
        ///   Defaults to `false`.
        /// - Returns: A strategy that uses accounting principles, and the specified handling of zero values.
        public static func accountingAlways(showZero: Bool = false) -> Self {
            .init(positive: .always, negative: .always, zero: showZero ? .always : .hidden, accounting: true)
        }
    }

    /// A structure used to configure the presentation of currency format styles.
    public struct Presentation: Codable, Hashable, Sendable {
        enum Option: Int, Codable, Hashable {
            case narrow
            case standard
            case isoCode
            case fullName
        }
        
        let option: Option

        /// A presentation that shows a condensed expression of the currency.
        ///
        /// This presentation produces output like `$123.00`.
        public static var narrow: Self { .init(option: .narrow) }
        
        /// A presentation that shows a standard expression of the currency.
        ///
        /// This presentation produces output like `US$ 123.00`.
        public static var standard: Self { .init(option: .standard) }
        
        /// A presentation that shows the ISO code of the currency.
        ///
        /// This presentation produces output like `USD 123.00`.
        public static var isoCode: Self { .init(option: .isoCode) }
        
        /// A presentation that shows the full name of the currency.
        ///
        /// This presentation produces output like `123.00 US dollars`.
        public static var fullName: Self { .init(option: .fullName) }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_CurrencyFormatStyleConfiguration {
    typealias RoundingIncrement = _polyfill_NumberFormatStyleConfiguration.RoundingIncrement

    struct Collection: Codable, Hashable {
        var presentation:             Presentation
        var scale:                     Double?
        var precision:                Precision?
        var roundingIncrement:        RoundingIncrement?
        var group:                    Grouping?
        var signDisplayStrategy:      SignDisplayStrategy?
        var decimalSeparatorStrategy: DecimalSeparatorDisplayStrategy?
        var rounding:                 RoundingRule?
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_CurrencyFormatStyleConfiguration.Collection {
    var skeleton: String {
        [
            self.presentation.skeleton,
            self.scale?.skeleton,
            self.precision?.skeleton(with: self.roundingIncrement) ?? self.roundingIncrement?.skeleton,
            self.group?.skeleton,
            self.signDisplayStrategy?.skeleton,
            self.decimalSeparatorStrategy?.skeleton,
            self.rounding?.skeleton,
        ].compacted().joined(separator: " ").trimmed
    }

    var icuNumberFormatStyle: UNumberFormatStyle {
        switch (self.signDisplayStrategy?.accounting, self.presentation.option) {
        case (true?, _): .currencyAccounting
        case (_, .narrow): .currencyNarrow
        case (_, .standard): .currencyStandard
        case (_, .isoCode): .currencyISO
        case (_, .fullName): .currencyFullName
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_CurrencyFormatStyleConfiguration.SignDisplayStrategy {
    var skeleton: String {
        switch (self.accounting, self.positive, self.zero, self.negative) {
            case (true,  .always, .always, _): "sign-accounting-always"
            case (true,  .always, .hidden, _): "sign-accounting-except-zero"
            case (true,  .hidden, _,       _): "sign-accounting"
            case (false, .always, .always, _): "sign-always"
            case (false, .always, .hidden, _): "sign-except-zero"
            case (false, .hidden, _, .always): "sign-auto"
            case (false, .hidden, _, .hidden): "sign-never"
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_CurrencyFormatStyleConfiguration.Presentation {
    var skeleton: String {
        switch self.option {
        case .narrow: "unit-width-narrow"
        case .standard: "unit-width-short"
        case .isoCode: "unit-width-iso-code"
        case .fullName: "unit-width-full-name"
        }
    }
}

extension UNumberFormatStyle {
    static let currencyAccounting = UNUM_CURRENCY_ACCOUNTING
    static let currencyFullName = UNUM_CURRENCY_PLURAL
    static let currencyISO = UNUM_CURRENCY_ISO
    static let currencyNarrow = UNUM_CURRENCY
    static let currencyStandard = UNUM_CURRENCY_STANDARD
    static let decimal = UNUM_DECIMAL
    static let percent = UNUM_PERCENT
    static let spellout = UNUM_SPELLOUT
    static let ordinal = UNUM_ORDINAL
    static let scientific = UNUM_SCIENTIFIC
}
