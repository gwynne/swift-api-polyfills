import struct Foundation.Locale
import struct Foundation.AttributedString
import enum Foundation.AttributeScopes
import struct Foundation.Decimal
import CLegacyLibICU
import PolyfillCommon

public struct _polyfill_ByteCountFormatStyle: _polyfill_FormatStyle, Sendable {
    public var attributed: _polyfill_ByteCountFormatStyle.Attributed

    public init(
        style: Style = .file,
        allowedUnits: Units = .all,
        spellsOutZero: Bool = true,
        includesActualByteCount: Bool = false,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.attributed = .init(
            style: style,
            allowedUnits: allowedUnits,
            spellsOutZero: spellsOutZero,
            includesActualByteCount: includesActualByteCount,
            locale: locale
        )
    }

    public var style: Style {
        get { self.attributed.style }
        set { self.attributed.style = newValue }
    }
    
    public var allowedUnits: Units {
        get { self.attributed.allowedUnits }
        set { self.attributed.allowedUnits = newValue }
    }
    
    public var spellsOutZero: Bool {
        get { self.attributed.spellsOutZero }
        set { self.attributed.spellsOutZero = newValue }
    }
    
    public var includesActualByteCount: Bool {
        get { self.attributed.includesActualByteCount }
        set { self.attributed.includesActualByteCount = newValue }
    }
    
    public var locale: Locale {
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

    public func format(_ value: Int64) -> String { .init(self.attributed.format(value).characters) }

    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }

    public enum Style: Int, Codable, Hashable, Sendable {
        case file = 0
        case memory
        case decimal
        case binary
    }

    public struct Units: OptionSet, Codable, Hashable, Sendable {
        public var rawValue: Int

        public init(rawValue: Int)         { self.rawValue = (rawValue == 0 ? 0x0FFFF : rawValue) }

        public static var bytes: Self      { .init(rawValue: 1 << 0) }
        public static var kb: Self         { .init(rawValue: 1 << 1) }
        public static var mb: Self         { .init(rawValue: 1 << 2) }
        public static var gb: Self         { .init(rawValue: 1 << 3) }
        public static var tb: Self         { .init(rawValue: 1 << 4) }
        public static var pb: Self         { .init(rawValue: 1 << 5) }
        public static var eb: Self         { .init(rawValue: 1 << 6) }
        public static var zb: Self         { .init(rawValue: 1 << 7) }
        public static var ybOrHigher: Self { .init(rawValue: 0x0FF << 8) }

        public static var all: Self        { .init(rawValue: 0) }
        public static var `default`: Self  { .all }

        fileprivate var smallestUnit: Unit { (Unit.byte ... .petabyte).first(where: { self.contains(.init(rawValue: $0.rawValue)) }) ?? .petabyte }
    }

    public struct Attributed: _polyfill_FormatStyle, Sendable {
        public var style: Style
        public var allowedUnits: Units
        public var spellsOutZero: Bool
        public var includesActualByteCount: Bool
        public var locale: Locale

        public func locale(_ locale: Locale) -> Self {
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

        func useSpelloutZero(forLocale locale: Locale, unit: Unit) -> Bool {
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
                attributedString.append(AttributedString(localizedParens.0))
                var attributedBytes = byteFormatter!.attributedFormat(value, unit: .byte)
                for (value, range) in attributedBytes.runs[\.byteCount] where value == .value { attributedBytes[range].byteCount = .actualByteCount }
                attributedString.append(attributedBytes)
                attributedString.append(AttributedString(localizedParens.1))
            }
            return attributedString
        }

        public func format(_ value: Int64) -> Foundation.AttributedString { self.formatImpl(.integer(value)) }
    }
}

public extension _polyfill_FormatStyle where Self == _polyfill_ByteCountFormatStyle {
    static func byteCount(
        style: _polyfill_ByteCountFormatStyle.Style,
        allowedUnits: _polyfill_ByteCountFormatStyle.Units = .all,
        spellsOutZero: Bool = true,
        includesActualByteCount: Bool = false
    ) -> Self {
        .init(style: style, allowedUnits: allowedUnits, spellsOutZero: spellsOutZero, includesActualByteCount: includesActualByteCount)
    }
}

private func localizedParens(locale: Locale) -> (String, String) {
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
