import Foundation
import CLegacyLibICU
import PolyfillCommon

typealias ICUNumberFormatterSkeleton = String

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol {
    init?(unumberFormatField: UNumberFormatFields) { switch unumberFormatField {
        case UNUM_DECIMAL_SEPARATOR_FIELD: self = .decimalSeparator
        case UNUM_GROUPING_SEPARATOR_FIELD: self = .groupingSeparator
        case UNUM_CURRENCY_FIELD: self = .currency
        case UNUM_PERCENT_FIELD: self = .percent
        case UNUM_SIGN_FIELD: self = .sign
        default: return nil
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart {
    init?(unumberFormatField: UNumberFormatFields) { switch unumberFormatField {
        case UNUM_INTEGER_FIELD: self = .integer
        case UNUM_FRACTION_FIELD: self = .fraction
        default: return nil
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AttributeScopes.FoundationAttributes.MeasurementAttribute.Component {
    init?(unumberFormatField: UNumberFormatFields) { switch unumberFormatField {
        case UNUM_INTEGER_FIELD: self = .value
        case UNUM_FRACTION_FIELD: self = .value
        case UNUM_DECIMAL_SEPARATOR_FIELD: self = .value
        case UNUM_GROUPING_SEPARATOR_FIELD: self = .value
        case UNUM_SIGN_FIELD: self = .value
        case UNUM_CURRENCY_FIELD: return nil
        case UNUM_PERCENT_FIELD: return nil
        case UNUM_MEASURE_UNIT_FIELD: self = .unit
        default: return nil
    } }
}
extension Decimal {
    fileprivate subscript(index: UInt32) -> UInt16 {
        switch index {
        case 0: self._mantissa.0; case 1: self._mantissa.1; case 2: self._mantissa.2; case 3: self._mantissa.3
        case 4: self._mantissa.4; case 5: self._mantissa.5; case 6: self._mantissa.6; case 7: self._mantissa.7
        default: fatalError("Invalid index \(index) for _mantissa")
        }
    }
    fileprivate var doubleValue: Double {
        if self._length == 0 { return self._isNegative == 1 ? Double.nan : 0 }
        var d = 0.0
        for idx in (0 ..< Swift.min(self._length, 8)).reversed() { d = Double(self[idx]).addingProduct(d, 65536) }
        if self._exponent < 0 { d /= pow(10.0, Double(-self._exponent)) } else { d *= pow(10.0, Double(self._exponent)) }
        return self._isNegative != 0 ? -d : d
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
internal class ICUNumberFormatterBase {
    final class FieldPositer {
        let positer: OpaquePointer
        
        init() throws { self.positer = try ICU4Swift.withCheckedStatus { ufieldpositer_open(&$0) } }
        deinit { ufieldpositer_close(self.positer) }
        
        var fields: Fields { .init(positer: self) }
        
        struct Fields: Sequence {
            struct Element { var field: Int, begin: Int, end: Int }
        
            let positer: FieldPositer
        
            func makeIterator() -> Iterator { .init(positer: self.positer) }
        
            struct Iterator: IteratorProtocol {
                var beginIndex: Int32 = 0, endIndex: Int32 = 0, positer: FieldPositer

                init(positer: FieldPositer) { self.positer = positer }

                mutating func next() -> Element? {
                    let next = ufieldpositer_next(self.positer.positer, &self.beginIndex, &self.endIndex)
                    guard next >= 0 else { return nil }
                    return Element(field: Int(next), begin: Int(self.beginIndex), end: Int(self.endIndex))
                }
            }
        }
    }

    let uformatter: OpaquePointer
    init?(skeleton: String, localeIdentifier: String) {
        let ustr = Array(skeleton.utf16)
        var status = U_ZERO_ERROR
        guard let formatter = unumf_openForSkeletonAndLocale(ustr, Int32(ustr.count), localeIdentifier, &status) else { return nil }
        guard status.isSuccess else {
            unumf_close(formatter)
            return nil
        }
        self.uformatter = formatter
    }
    deinit { unumf_close(uformatter) }

    enum Value {
        case integer(Int64), floatingPoint(Double), decimal(Decimal)
        var isZero: Bool { switch self {
            case .integer(let num): num == 0
            case .floatingPoint(let num): num == 0
            case .decimal(let num): num == 0
        } }
        var doubleValue: Double { switch self {
            case .integer(let num): Double(num)
            case .floatingPoint(let num): num
            case .decimal(let num): num.doubleValue
        } }
        var fallbackDescription: String {
            switch self {
            case .integer(let i): return String(i)
            case .floatingPoint(let d): return String(d)
            case .decimal(let d): return d.description
            }
        }
    }

    struct AttributePosition { let field: UNumberFormatFields, begin: Int, end: Int }
    func attributedStringFromPositions(_ positions: [AttributePosition], string: String) -> Foundation.AttributedString {
        typealias NumberPartAttribute = AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart
        typealias NumberSymbolAttribute = AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol
        var attrstr = Foundation.AttributedString(string)
        for attr in positions {
            var container = AttributeContainer()
            if let part = NumberPartAttribute(unumberFormatField: attr.field) { container.numberPart = part }
            if let symbol = NumberSymbolAttribute(unumberFormatField: attr.field) { container.numberSymbol = symbol }
            attrstr[Range(String.Index(utf16Offset: attr.begin, in: string) ..< .init(utf16Offset: attr.end, in: string), in: attrstr)!].mergeAttributes(container)
        }
        return attrstr
    }

    func attributedFormatPositions(_ v: Value) -> (String, [AttributePosition])? {
        var result: FormatResult?
        switch v {
        case .integer(let v): result = try? FormatResult(formatter: self.uformatter, value: v)
        case .floatingPoint(let v): result = try? FormatResult(formatter: self.uformatter, value: v)
        case .decimal(let v): result = try? FormatResult(formatter: self.uformatter, value: v)
        }
        guard let result, let str = result.string else { return nil }
        do {
            let positer = try FieldPositer()
            try ICU4Swift.withCheckedStatus { unumf_resultGetAllFieldPositions(result.result, positer.positer, &$0) }
            let attributePositions = positer.fields.compactMap { next -> AttributePosition? in
                return AttributePosition(field: UNumberFormatFields(numericCast(next.field)), begin: next.begin, end: next.end)
            }
            return (str, attributePositions)
        } catch { return nil }
    }

    func format(_ v: Int64) -> String? { try? FormatResult(formatter: self.uformatter, value: v).string }
    func format(_ v: Double) -> String? { try? FormatResult(formatter: self.uformatter, value: v).string }
    func format(_ v: Decimal) -> String? { try? FormatResult(formatter: self.uformatter, value: v).string }
    func format(_ v: String) -> String? { try? FormatResult(formatter: self.uformatter, value: v).string }

    class FormatResult {
        var result: OpaquePointer
        init(formatter: OpaquePointer, value: Int64) throws {
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { unumf_formatInt(formatter, value, self.result, &$0) }
        }
        init(formatter: OpaquePointer, value: Double) throws {
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { unumf_formatDouble(formatter, value, self.result, &$0) }
        }
        init(formatter: OpaquePointer, value: Decimal) throws {
            var str = value.description
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { status in str.withUTF8 { unumf_formatDecimal(formatter, $0.baseAddress, Int32($0.count), self.result, &status) } }
        }
        init(formatter: OpaquePointer, value: String) throws {
            var value = value
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { status in value.withUTF8 { unumf_formatDecimal(formatter, $0.baseAddress, Int32($0.count), self.result, &status) } }
        }
        deinit { unumf_closeResult(result) }
        var string: String? { _withResizingUCharBuffer { unumf_resultToString(self.result, $0, $1, &$2) } }
    }
}

func _withResizingUCharBuffer(initialSize: Int32 = 32, _ body: (UnsafeMutablePointer<UChar>, Int32, inout UErrorCode) -> Int32?) -> String? {
    withUnsafeTemporaryAllocation(of: UChar.self, capacity: Int(initialSize)) { var status = U_ZERO_ERROR
        if let len = body($0.baseAddress!, initialSize, &status) {
            if status == U_BUFFER_OVERFLOW_ERROR {
                return withUnsafeTemporaryAllocation(of: UChar.self, capacity: Int(len + 1)) { var innerStatus = U_ZERO_ERROR
                    if let innerLen = body($0.baseAddress!, len + 1, &innerStatus) {
                        if innerStatus.isSuccess && innerLen > 0 { return String(decodingCString: $0.baseAddress!, as: UTF16.self) }
                    }
                    return nil
                }
            } else if status.isSuccess && len > 0 { return String(decodingCString: $0.baseAddress!, as: UTF16.self) }
        }
        return nil
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class ICUNumberFormatter: ICUNumberFormatterBase {
    fileprivate struct Signature: Hashable {
        let collection: _polyfill_NumberFormatStyleConfiguration.Collection
        let localeIdentifier: String
    }
    private static func _create(with signature: Signature) -> ICUNumberFormatter? {
        .init(skeleton: signature.collection.skeleton, localeIdentifier: signature.localeIdentifier)
    }
    static func create(for style: Decimal._polyfill_FormatStyle) -> ICUNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }
    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>) -> ICUNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }
    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else { return Foundation.AttributedString(v.fallbackDescription) }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class ICUCurrencyNumberFormatter: ICUNumberFormatterBase {
    fileprivate struct Signature : Hashable {
        let collection: _polyfill_CurrencyFormatStyleConfiguration.Collection
        let currencyCode: String
        let localeIdentifier: String
    }
    private static func skeleton(for signature: Signature) -> String {
        "currency/\(signature.currencyCode)\(signature.collection.skeleton.isEmpty ? "" : " \(signature.collection.skeleton)")"
    }
    static private func _create(with signature: Signature) -> ICUCurrencyNumberFormatter? {
        .init(skeleton: Self.skeleton(for: signature), localeIdentifier: signature.localeIdentifier)
    }
    static func create(for style: Decimal._polyfill_FormatStyle._polyfill_Currency) -> ICUCurrencyNumberFormatter? {
        self._create(with: .init(collection: style.collection, currencyCode: style.currencyCode, localeIdentifier: style.locale.identifier))
    }
    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>._polyfill_Currency) -> ICUCurrencyNumberFormatter? {
        self._create(with: .init(collection: style.collection, currencyCode: style.currencyCode, localeIdentifier: style.locale.identifier))
    }
    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else { return .init(v.fallbackDescription) }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class ICUPercentNumberFormatter: ICUNumberFormatterBase {
    fileprivate struct Signature: Hashable {
        let collection: _polyfill_NumberFormatStyleConfiguration.Collection
        let localeIdentifier: String
    }
    private static func skeleton(for signature: Signature) -> String {
        "percent\(signature.collection.skeleton.isEmpty ? "" : " \(signature.collection.skeleton)")"
    }
    private static func _create(with signature: Signature) -> ICUPercentNumberFormatter? {
        .init(skeleton: Self.skeleton(for: signature), localeIdentifier: signature.localeIdentifier)
    }
    static func create(for style: Decimal._polyfill_FormatStyle._polyfill_Percent) -> ICUPercentNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }
    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>._polyfill_Percent) -> ICUPercentNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }
    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else { return .init(v.fallbackDescription) }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class ICUMeasurementNumberFormatter: ICUNumberFormatterBase {
    fileprivate struct Signature: Hashable {
        let skeleton: String
        let localeIdentifier: String
    }

    static func create(for skeleton: String, locale: Locale) -> ICUMeasurementNumberFormatter? {
        .init(skeleton: skeleton, localeIdentifier: locale.identifier)
    }

    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else { return .init(v.fallbackDescription) }
        return self.attributedStringFromPositions(attributes, string: str)
    }

    override func attributedStringFromPositions(_ positions: [ICUNumberFormatter.AttributePosition], string: String) -> Foundation.AttributedString {
        typealias NumberPartAttribute = AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart
        typealias NumberSymbolAttribute = AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol
        typealias MeasurementAttribute = AttributeScopes.FoundationAttributes.MeasurementAttribute.Component
        var attrstr = Foundation.AttributedString(string)
        for attr in positions {
            var container = AttributeContainer()
            if let part = NumberPartAttribute(unumberFormatField: attr.field) { container.numberPart = part }
            if let symbol = NumberSymbolAttribute(unumberFormatField: attr.field) { container.numberSymbol = symbol }
            if let comp = MeasurementAttribute(unumberFormatField: attr.field) { container.measurement = comp }
            attrstr[Range(String.Index(utf16Offset: attr.begin, in: string) ..< .init(utf16Offset: attr.end, in: string), in: attrstr)!].mergeAttributes(container)
        }
        return attrstr
    }

    internal enum Usage: String {
        case general = "default", person, food, personHeight = "person-height", road, focalLength = "focal-length",
             rainfall, snowfall, visibility = "visiblty", barometric = "baromtrc", wind, weather, fluid, asProvided
    }

    enum UnitWidth: String, Codable {
        case wide = "unit-width-full-name", abbreviated = "unit-width-short", narrow = "unit-width-narrow"
    }

    static func skeleton(_ unitSkeleton: String?, width: UnitWidth, usage: Usage?, numberFormatStyle: _polyfill_FloatingPointFormatStyle<Double>?) -> String {
        var stem = ""
        if let unitSkeleton = unitSkeleton {
            stem += unitSkeleton + " " + width.rawValue
            if let usage { stem += " usage/" + usage.rawValue }
        }
        if let numberFormatSkeleton = numberFormatStyle?.collection.skeleton {
            if !stem.isEmpty { stem += " " }
            stem += numberFormatSkeleton
        }
        return stem
    }
}