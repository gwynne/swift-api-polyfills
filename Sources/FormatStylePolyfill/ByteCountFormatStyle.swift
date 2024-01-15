import struct Foundation.Locale
import struct Foundation.AttributedString
import enum Foundation.AttributeScopes
import struct Foundation.Decimal
import CLegacyLibICU
import PolyfillCommon

/// A format style that provides string representations of byte counts.
///
/// The following example creates an Int representing 1,024 bytes, and then formats it as an expression of
/// memory storage, with the default byte count format style.
///
/// ```swift
/// let count: Int64 = 1024
/// let formatted = count.formatted(.byteCount(style: .memory)) // "1 kB"
/// ```
///
/// You can also customize a byte count format style, and use this to format one or more `Int64` instances. The
/// following example creates a format style to only use kilobyte units, and to spell out the exact byte count
/// of the measurement.
///
/// ```swift
/// let style = ByteCountFormatStyle(style: .memory,
///                                  allowedUnits: [.kb],
///                                  spellsOutZero: true,
///                                  includesActualByteCount: false,
///                                  locale: Locale(identifier: "en_US"))
/// let counts: [Int64] = [0, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
/// let formatted = counts.map ( {style.format($0) } ) // ["Zero kB", "1 kB", "2 kB", "4 kB", "8 kB", "16 kB", "32 kB", "64 kB"]
/// ```
public struct _polyfill_ByteCountFormatStyle: _polyfill_FormatStyle, Sendable {
    /// An attributed format style based on the byte count format style.
    ///
    /// Use this modifier to create a `ByteCountFormatStyle.Attributed` instance, which formats values as
    /// `AttributedString` instances. These attributed strings contain attributes from the
    /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
    /// determine which runs of the attributed string represent different parts of the formatted value.
    public var attributed: _polyfill_ByteCountFormatStyle.Attributed
    
    /// Initializes a byte count format style.
    ///
    /// - Parameters:
    ///   - style: The style of byte count to express, such as memory or file system storage.
    ///   - allowedUnits: The units the format style can use to express the byte count.
    ///   - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte
    ///     values as text, like `Zero kB`.
    ///   - includesActualByteCount: A Boolean value that indicates whether the format style should include the
    ///     exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
    ///   - locale: The locale to use to format the numeric part of the byte count.
    ///
    /// In situations that can infer the `ByteCountFormatStyle` type, you can call
    /// `byteCount(style:allowedUnits:spellsOutZero:includesActualByteCount:)` instead of explicitly using this
    /// initializer. This is the case when you call `formatted(_:)` on a `BinaryInteger`.
    public init(
        style: Style = .file,
        allowedUnits: Units = .all,
        spellsOutZero: Bool = true,
        includesActualByteCount: Bool = false,
        locale: Foundation.Locale = .autoupdatingCurrent
    ) {
        self.attributed = .init(
            style: style,
            allowedUnits: allowedUnits,
            spellsOutZero: spellsOutZero,
            includesActualByteCount: includesActualByteCount,
            locale: locale
        )
    }

    /// The semantic style the format style uses to represent a byte count value.
    public var style: Style {
        get { self.attributed.style }
        set { self.attributed.style = newValue }
    }
    
    /// The units the format style can use to express the byte count.
    public var allowedUnits: Units {
        get { self.attributed.allowedUnits }
        set { self.attributed.allowedUnits = newValue }
    }
    
    /// A Boolean value that indicates whether the format style should spell out zero-byte values as text.
    ///
    /// When this value is `true`, the format style produces output like `Zero kB`.
    public var spellsOutZero: Bool {
        get { self.attributed.spellsOutZero }
        set { self.attributed.spellsOutZero = newValue }
    }
    
    /// A Boolean value that indicates whether the format style should include the exact byte count, in
    /// addition to expressing it in terms of units.
    ///
    /// When this value is `true`, a format style produces output like `1 kB (1,024 bytes)`.
    public var includesActualByteCount: Bool {
        get { self.attributed.includesActualByteCount }
        set { self.attributed.includesActualByteCount = newValue }
    }
    
    /// The locale to use to format the numeric part of the byte count.
    ///
    /// To change the format style’s locale, use `locale(_:)`.
    public var locale: Foundation.Locale {
        get { self.attributed.locale }
        set { self.attributed.locale = newValue }
    }
    
    enum Unit: Int, Hashable, Comparable, Strideable {
        case byte = 0
        case kilobyte
        case megabyte
        case gigabyte
        case terabyte
        case petabyte
        case exabyte
        case zettabyte
        case yottabyte

        var name: String { Self.unitNames[self.rawValue] }
        var decimalSize: Int64 { Self.decimalByteSizes[self.rawValue] }
        var binarySize: Int64 { Self.binaryByteSizes[self.rawValue] }

        func distance(to other: Self) -> Int { other.rawValue - self.rawValue }
        func advanced(by n: Int) -> Self { .init(rawValue: self.rawValue + n)! }
        
        private static let unitNames = [
            "byte",
            "kilobyte",
            "megabyte",
            "gigabyte",
            "terabyte",
            "petabyte",
            "exabyte",
            "zettabyte",
            "yottabyte"
        ]
        
        private static let decimalByteSizes: [Int64] = [
            1,
            1_000,
            1_000_000,
            1_000_000_000,
            1_000_000_000_000,
            1_000_000_000_000_000,
            1_000_000_000_000_000_000,
            .max,//1_000_000_000_000_000_000_000,
            .max,//1_000_000_000_000_000_000_000_000,
        ]
        
        private static let binaryByteSizes: [Int64] = [
            1,                          // 1 << 0
            1_024,                      // 1 << 10
            1_048_576,                  // 1 << 20
            1_073_741_824,              // 1 << 30
            1_099_511_627_776,          // 1 << 40
            1_125_899_906_842_624,      // 1 << 50
            1_152_921_504_606_846_976,  // 1 << 60
            .max,//1_180_591_620_717_411_303_424 // 1 << 70
            .max,//1_208_925_819_614_629_174_706_176 // 1 << 80
        ]
    }

    /// Formats a numeric byte count, using this style.
    ///
    /// - Parameter value: The 64-bit byte count to format.
    /// - Returns: A formatted representation of `value`, formatted according to the style’s configuration.
    ///
    /// Use this method when you want to create a single style instance, and then use it to format multiple
    /// values. The following example creates a `ByteCountFormatStyle` to format values as kilobyte counts,
    /// then applies this style to an array of `Int64` values.
    ///
    /// ```swift
    /// let style = ByteCountFormatStyle(style: .memory,
    ///                                  allowedUnits: [.kb],
    ///                                  spellsOutZero: true,
    ///                                  includesActualByteCount: false,
    ///                                  locale: Locale(identifier: "en_US"))
    /// let counts: [Int64] = [0, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
    /// let formatted = counts.map ( {style.format($0) } ) // ["Zero kB", "1 kB", "2 kB", "4 kB", "8 kB", "16 kB", "32 kB", "64 kB"]
    /// ```
    ///
    /// To format a single integer, use the `BinaryInteger` instance method `formatted(_:)`, passing in an
    /// instance of `IntegerFormatStyle`, or `formatted()` to use a default style.
    public func format(_ value: Int64) -> String { .init(self.attributed.format(value).characters) }
    
    /// Modifies the format style to use the specified locale.
    ///
    /// - Parameter locale: The locale to apply to the format style.
    /// - Returns: A format style that uses the specified locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
    
    /// The semantic style to use when formatting a byte count value.
    public enum Style: Int, Codable, Hashable, Sendable {
        /// A style for representing file system storage.
        case file = 0
        
        /// The style for representing memory usage.
        case memory
        
        /// A style for representing byte counts as decimal values.
        case decimal
        
        /// A style for representing byte counts as binary values.
        case binary
    }

    /// The units to use when formatting a byte count, such as kilobytes or gigabytes.
    public struct Units: OptionSet, Codable, Hashable, Sendable {
        /// The raw value of the unit.
        public var rawValue: Int

        /// Creates a unit from a corresponding raw value.
        /// 
        /// - Parameter rawValue: A raw value that corresponds to one of the defined unit types.
        public init(rawValue: Int)         { self.rawValue = (rawValue == 0 ? 0x0FFFF : rawValue) }

        /// A value that indicates a format style should express byte counts in individual bytes.
        public static var bytes: Self      { .init(rawValue: 1 << 0) }
        
        /// The kilobytes unit.
        public static var kb: Self         { .init(rawValue: 1 << 1) }
        
        /// The megabytes unit.
        public static var mb: Self         { .init(rawValue: 1 << 2) }
        
        /// The gigabytes unit.
        public static var gb: Self         { .init(rawValue: 1 << 3) }
        
        /// The terabytes unit.
        public static var tb: Self         { .init(rawValue: 1 << 4) }
        
        /// The petabytes unit.
        public static var pb: Self         { .init(rawValue: 1 << 5) }
        
        /// The exabytes unit.
        public static var eb: Self         { .init(rawValue: 1 << 6) }
        
        /// The zettabytes unit.
        public static var zb: Self         { .init(rawValue: 1 << 7) }
        
        /// A value that indicates a format style should express byte counts as yottabytes or higher.
        public static var ybOrHigher: Self { .init(rawValue: 0x0FF << 8) }

        /// A value that allows the use of all byte-count units.
        public static var all: Self        { .init(rawValue: 0) }
        
        /// A value that indicates a format style should use the most appropriate units to express a byte count.
        public static var `default`: Self  { .all }

        fileprivate var smallestUnit: Unit { (Unit.byte ... .petabyte).first(where: { self.contains(.init(rawValue: $0.rawValue)) }) ?? .petabyte }
    }

    /// A format style that converts byte counts into attributed strings.
    ///
    /// Use the `attributed` modifier on a `ByteCountFormatStyle` to create a format style of this type.
    ///
    /// The attributed strings that this fomat style creates contain attributes from the
    /// `AttributeScopes.FoundationAttributes.NumberFormatAttributes` attribute scope. Use these attributes to
    /// determine which runs of the attributed string represent different parts of the formatted value.
    public struct Attributed: _polyfill_FormatStyle, Sendable {
        /// The semantic style the format style uses to represent a byte count value.
        public var style: Style
        
        /// The units the format style can use to express the byte count.
        public var allowedUnits: Units

        /// A Boolean value that indicates whether the format style should spell out zero-byte values as text.
        ///
        /// When this value is `true`, the format style produces output like `Zero kB`.
        public var spellsOutZero: Bool

        /// A Boolean value that indicates whether the format style should include the exact byte count, in
        /// addition to expressing it in terms of units.
        ///
        /// When this value is `true`, a format style produces output like `1 kB (1,024 bytes)`.
        public var includesActualByteCount: Bool

        /// The locale to use to format the numeric part of the byte count.
        ///
        /// To change the format style’s locale, use `locale(_:)`.
        public var locale: Foundation.Locale

        /// Modifies the format style to use the specified locale.
        ///
        /// - Parameter locale: The locale to apply to the format style.
        /// - Returns: A format style that uses the specified locale.
        public func locale(_ locale: Foundation.Locale) -> Self {
            var new = self
            new.locale = locale
            return new
        }

        fileprivate static let maxDecimalSizes = [
            999,
            999499,
            999949999,
            999994999999,
            999994999999999,
            Int64.max
        ]
        
        fileprivate static let maxBinarySizes = [
            1023,
            1048063,
            1073689395,
            1099506259066,
            1125894409284485,
            Int64.max
        ]

        func useSpelloutZero(forLocale locale: Foundation.Locale, unit: Unit) -> Bool {
            guard unit == .byte || unit == .kilobyte else { return false }
            guard let languageCode = locale.language.languageCode?.identifier.lowercased() else { return false }
            switch (unit, languageCode) {
            case (_, "ar"), (_, "da"), (_, "el"), (_, "en"), (_, "fr"), (_, "hi"),
                 (_, "hr"), (_, "id"), (_, "it"), (_, "ms"), (_, "pt"), (_, "ro"), (_, "th"): return true
            case (.byte, "ca"), (.byte, "no"): return true
            default: return false
            }
        }

        private func formatImpl(_ value: ICUNumberFormatter.Value) -> Foundation.AttributedString {
            let unit: Unit = self.allowedUnits.contains(.kb) ? .kilobyte : .byte
            
            if self.spellsOutZero, value.isZero {
                let numberFormatter = ICUByteCountNumberFormatter.create(
                    for: "measure-unit/digital-\(unit.name)\(unit == .byte ? " unit-width-full-name" : "")",
                    locale: self.locale
                )
                guard var attributedFormat = numberFormatter?.attributedFormat(.integer(.zero), unit: unit) else {
                    return unit == .byte ? "Zero bytes" : "Zero kB"
                }
                guard self.useSpelloutZero(forLocale: locale, unit: unit) else { return attributedFormat }
                guard let zeroFormatted = ICULegacyNumberFormatter.formatter(
                    for: .descriptive(.init(presentation: .cardinal, capitalizationContext: .beginningOfSentence)),
                    locale: self.locale
                ).format(Int64.zero) else {
                    return attributedFormat
                }
                var attributedZero = Foundation.AttributedString(zeroFormatted)
                attributedZero.byteCount = .spelledOutValue
                for (value, range) in attributedFormat.runs[\.byteCount] where value == .value { attributedFormat.replaceSubrange(range, with: attributedZero) }
                return attributedFormat
            }

            let decimal: Bool, maxSizes: [Int64]
            switch self.style {
            case .file, .decimal: (decimal, maxSizes) = (true, Self.maxDecimalSizes)
            case .memory, .binary: (decimal, maxSizes) = (false, Self.maxBinarySizes)
            }
            let bestUnit: Unit = {
                var bestUnit = self.allowedUnits.smallestUnit
                for (idx, size) in maxSizes.enumerated() {
                    guard self.allowedUnits.contains(.init(rawValue: 1 << idx)) else { continue }
                    bestUnit = Unit(rawValue: idx)!
                    if abs(value.doubleValue) < Double(size) { break }
                }
                return bestUnit
            }()
            let denominator = decimal ? bestUnit.decimalSize : bestUnit.binarySize
            let unitValue = value.doubleValue / Double(denominator)
            let precisionSkeleton: String = switch bestUnit {
                case .byte, .kilobyte: "."
                case .megabyte: ".#"
                default: ".##"
            }
            let formatter = ICUByteCountNumberFormatter.create(
                for: "\(precisionSkeleton) measure-unit/digital-\(bestUnit.name) \(bestUnit == .byte ? "unit-width-full-name" : "")",
                locale: self.locale
            )
            var attributedString = formatter!.attributedFormat(.floatingPoint(unitValue), unit: bestUnit)

            if self.includesActualByteCount {
                let byteFormatter = ICUByteCountNumberFormatter.create(for: "measure-unit/digital-byte unit-width-full-name", locale: self.locale)
                let localizedParens = localizedParens(locale: self.locale)
                attributedString.append(Foundation.AttributedString(localizedParens.0))
                var attributedBytes = byteFormatter!.attributedFormat(value, unit: .byte)
                for (value, range) in attributedBytes.runs[\.byteCount] where value == .value { attributedBytes[range].byteCount = .actualByteCount }
                attributedString.append(attributedBytes)
                attributedString.append(Foundation.AttributedString(localizedParens.1))
            }
            return attributedString
        }

        /// Formats a numeric byte count, using this style.
        ///
        /// Use this method when you want to create a single style instance, and then use it to format
        /// multiple values. To format a single integer, use the `BinaryInteger` instance method
        /// `formatted(_:)`, passing in an instance of `ByteCountFormatStyle.Attributed`, or `formatted()`
        /// to use a default style.
        ///
        /// - Parameter value: The 64-bit byte count to format.
        /// - Returns: A formatted representation of `value`, formatted according to the style’s configuration.
        public func format(_ value: Int64) -> Foundation.AttributedString { self.formatImpl(.integer(value)) }
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_ByteCountFormatStyle {
    /// Returns a format style for formatting a numeric value as a byte count of data storage.
    ///
    /// - Parameters:
    ///   - style: The style of byte count to express, such as memory or file system storage.
    ///   - allowedUnits: The units the format style can use to express the byte count.
    ///   - spellsOutZero: A Boolean value that indicates whether the format style should spell out zero-byte
    ///     values as text, like `Zero kB`.
    ///   - includesActualByteCount: A Boolean value that indicates whether the format style should include the
    ///     exact byte count, in addition to expressing it in terms of units. For example, `1 kB (1,024 bytes)`.
    /// - Returns: A format style for formatting a measurement of data storage, customized with the
    ///   provided behaviors.
    ///
    /// Use this type method when you need a byte count format style at a call point that infers the
    /// `ByteCountFormatStyle` type. Typically, this is the case when you call `formatted(_:)` on a `BinaryInteger`,
    /// as seen in the following example.
    ///
    /// ```swift
    /// let count = 1024
    /// let formatted = count.formatted(.byteCount(style: .memory)) // "1 kB"
    /// ```
    public static func byteCount(
        style: _polyfill_ByteCountFormatStyle.Style,
        allowedUnits: _polyfill_ByteCountFormatStyle.Units = .all,
        spellsOutZero: Bool = true,
        includesActualByteCount: Bool = false
    ) -> Self {
        .init(style: style, allowedUnits: allowedUnits, spellsOutZero: spellsOutZero, includesActualByteCount: includesActualByteCount)
    }
}

private func localizedParens(locale: Foundation.Locale) -> (String, String) {
    let ulocdata = try! locale.identifier.withCString { localeIdent in try ICU4Swift.withCheckedStatus { ulocdata_open(localeIdent, &$0) } }
    defer { ulocdata_close(ulocdata) }
    let exemplars = try! ICU4Swift.withCheckedStatus { ulocdata_getExemplarSet(ulocdata, nil, 0, ULOCDATA_ES_PUNCTUATION, &$0) }
    defer { uset_close(exemplars) }
    return uset_contains(exemplars!, 0x0000FF08) != 0 ? ("（", "）") : (" (", ")")
}

extension Foundation.AttributeScopes.FoundationAttributes.ByteCountAttribute.Unit {
    init(_ unit: _polyfill_ByteCountFormatStyle.Unit) {
        switch unit {
        case .byte: self = .byte
        case .kilobyte: self = .kb
        case .megabyte: self = .mb
        case .gigabyte: self = .gb
        case .terabyte: self = .tb
        case .petabyte: self = .pb
        case .exabyte: self = .eb
        case .zettabyte: self = .zb
        case .yottabyte: self = .yb
        }
    }
}
