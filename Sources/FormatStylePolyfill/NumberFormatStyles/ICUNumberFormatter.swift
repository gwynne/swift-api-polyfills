import enum Foundation.AttributeScopes
import struct Foundation.Decimal
import struct Foundation.AttributedString
import struct Foundation.AttributeContainer
import struct Foundation.Locale
import CLegacyLibICU
import PolyfillCommon

class ICUNumberFormatterBase {
    let uformatter: OpaquePointer

    init?(skeleton: String, localeIdentifier: String) {
        let ustr = Array(skeleton.utf16)

        guard let formatter = try? ICU4Swift.withCheckedStatus(do: { unumf_openForSkeletonAndLocale(ustr, Int32(ustr.count), localeIdentifier, &$0) }) else {
            return nil
        }
        self.uformatter = formatter
    }
    
    deinit {
        unumf_close(uformatter)
    }

    enum Value {
        case integer(Int64)
        case floatingPoint(Double)
        case decimal(Foundation.Decimal)

        var isZero: Bool {
            switch self {
            case .integer(let num):       num == 0
            case .floatingPoint(let num): num == 0
            case .decimal(let num):       num == 0
            }
        }
        
        var doubleValue: Double {
            switch self {
            case .integer(let num):       Double(num)
            case .floatingPoint(let num): num
            case .decimal(let num):       num.doubleValue
            }
        }
        
        var fallbackDescription: String {
            switch self {
            case .integer(let i):       String(i)
            case .floatingPoint(let d): String(d)
            case .decimal(let d):       d.description
            }
        }
    }

    struct AttributePosition {
        let field: UNumberFormatFields
        let begin: Int
        let end: Int
    }
    
    func attributedStringFromPositions(_ positions: [AttributePosition], string: String) -> Foundation.AttributedString {
        typealias NumberPartAttribute   = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart
        typealias NumberSymbolAttribute = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol
    
        var attrstr = Foundation.AttributedString(string)
    
        for attr in positions {
            var container = Foundation.AttributeContainer()
            
            if let part   = NumberPartAttribute(unumberFormatField: attr.field)   { container.numberPart = part }
            if let symbol = NumberSymbolAttribute(unumberFormatField: attr.field) { container.numberSymbol = symbol }
            
            attrstr[Range(String.Index(utf16Offset: attr.begin, in: string) ..< .init(utf16Offset: attr.end, in: string), in: attrstr)!].mergeAttributes(container)
        }
        return attrstr
    }

    func attributedFormatPositions(_ v: Value) -> (String, [AttributePosition])? {
        var result: FormatResult?
        switch v {
        case .integer(let v):       result = try? FormatResult(formatter: self.uformatter, value: v)
        case .floatingPoint(let v): result = try? FormatResult(formatter: self.uformatter, value: v)
        case .decimal(let v):       result = try? FormatResult(formatter: self.uformatter, value: v)
        }
        guard let result, let str = result.string else {
            return nil
        }
        
        do {
            let positer = try ICU4Swift.FieldPositer()
            
            try ICU4Swift.withCheckedStatus { unumf_resultGetAllFieldPositions(result.result, positer.positer, &$0) }
            
            let attributePositions = positer.fields.compactMap {
                AttributePosition(field: UNumberFormatFields(numericCast($0.field)), begin: $0.begin, end: $0.end)
            }
            return (str, attributePositions)
        } catch { return nil }
    }

    func format(_ v: Int64) -> String?   {
        try? FormatResult(formatter: self.uformatter, value: v).string
    }
    
    func format(_ v: Double) -> String?  {
        try? FormatResult(formatter: self.uformatter, value: v).string
    }
    
    func format(_ v: Foundation.Decimal) -> String? {
        try? FormatResult(formatter: self.uformatter, value: v).string
    }
    
    func format(_ v: String) -> String?  {
        try? FormatResult(formatter: self.uformatter, value: v).string
    }

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
        
        init(formatter: OpaquePointer, value: Foundation.Decimal) throws {
            var str = value.description
            
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { status in
                str.withUTF8 {
                    unumf_formatDecimal(formatter, $0.baseAddress, Int32($0.count), self.result, &status)
                }
            }
        }
        
        init(formatter: OpaquePointer, value: String) throws {
            var value = value
            
            self.result = try ICU4Swift.withCheckedStatus { unumf_openResult(&$0) }
            try ICU4Swift.withCheckedStatus { status in
                value.withUTF8 {
                    unumf_formatDecimal(formatter, $0.baseAddress, Int32($0.count), self.result, &status)
                }
            }
        }
        
        deinit {
            unumf_closeResult(result)
        }
        
        var string: String? {
            ICU4Swift.withResizingUCharBuffer { unumf_resultToString(self.result, $0, $1, &$2) }
        }
    }
}

final class ICUNumberFormatter: ICUNumberFormatterBase {
    private struct Signature: Hashable {
        let collection: _polyfill_NumberFormatStyleConfiguration.Collection
        let localeIdentifier: String
    }

    private static let cache = FormatterCache<Signature, ICUNumberFormatter?>()
    
    private static func _create(with signature: Signature) -> ICUNumberFormatter? {
        Self.cache.formatter(for: signature) {
            .init(skeleton: signature.collection.skeleton, localeIdentifier: signature.localeIdentifier)
        }
    }

    static func create(for style: _polyfill_IntegerFormatStyle<some BinaryInteger>) -> ICUNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_DecimalFormatStyle) -> ICUNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>) -> ICUNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else {
            return Foundation.AttributedString(v.fallbackDescription)
        }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

final class ICUCurrencyNumberFormatter: ICUNumberFormatterBase {
    private struct Signature : Hashable {
        let collection: _polyfill_CurrencyFormatStyleConfiguration.Collection
        let currencyCode: String
        let localeIdentifier: String
    }

    private static let cache = FormatterCache<Signature, ICUCurrencyNumberFormatter?>()

    private static func skeleton(for signature: Signature) -> String {
        "currency/\(signature.currencyCode)\(signature.collection.skeleton.isEmpty ? "" : " \(signature.collection.skeleton)")"
    }

    private static func _create(with signature: Signature) -> ICUCurrencyNumberFormatter? {
        Self.cache.formatter(for: signature) {
            .init(skeleton: Self.skeleton(for: signature), localeIdentifier: signature.localeIdentifier)
        }
    }

    static func create(for style: _polyfill_IntegerFormatStyle<some BinaryInteger>.Currency) -> ICUCurrencyNumberFormatter? {
        self._create(with: .init(collection: style.collection, currencyCode: style.currencyCode, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_DecimalFormatStyle.Currency) -> ICUCurrencyNumberFormatter? {
        self._create(with: .init(collection: style.collection, currencyCode: style.currencyCode, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>.Currency) -> ICUCurrencyNumberFormatter? {
        self._create(with: .init(collection: style.collection, currencyCode: style.currencyCode, localeIdentifier: style.locale.identifier))
    }

    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else {
            return .init(v.fallbackDescription)
        }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

final class ICUPercentNumberFormatter: ICUNumberFormatterBase {
    private struct Signature: Hashable {
        let collection: _polyfill_NumberFormatStyleConfiguration.Collection
        let localeIdentifier: String
    }

    private static let cache = FormatterCache<Signature, ICUPercentNumberFormatter?>()

    private static func skeleton(for signature: Signature) -> String {
        "percent\(signature.collection.skeleton.isEmpty ? "" : " \(signature.collection.skeleton)")"
    }

    private static func _create(with signature: Signature) -> ICUPercentNumberFormatter? {
        Self.cache.formatter(for: signature) {
            .init(skeleton: Self.skeleton(for: signature), localeIdentifier: signature.localeIdentifier)
        }
    }

    static func create(for style: _polyfill_IntegerFormatStyle<some BinaryInteger>.Percent) -> ICUPercentNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_DecimalFormatStyle.Percent) -> ICUPercentNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    static func create(for style: _polyfill_FloatingPointFormatStyle<some BinaryFloatingPoint>.Percent) -> ICUPercentNumberFormatter? {
        self._create(with: .init(collection: style.collection, localeIdentifier: style.locale.identifier))
    }

    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else {
            return .init(v.fallbackDescription)
        }
        return self.attributedStringFromPositions(attributes, string: str)
    }
}

final class ICUByteCountNumberFormatter: ICUNumberFormatterBase {
    private struct Signature : Hashable {
        let skeleton: String
        let localeIdentifier: String
    }

    private static let cache = FormatterCache<Signature, ICUByteCountNumberFormatter?>()

    static func create(for skeleton: String, locale: Foundation.Locale) -> ICUByteCountNumberFormatter? {
        Self.cache.formatter(for: .init(skeleton: skeleton, localeIdentifier: locale.identifier)) {
            .init(skeleton: skeleton, localeIdentifier: locale.identifier)
        }
    }

    func attributedFormat(_ v: Value, unit: _polyfill_ByteCountFormatStyle.Unit) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else {
            return .init(v.fallbackDescription)
        }
        return self.attributedStringFromPositions(attributes, string: str, unit: unit)
    }

    private func attributedStringFromPositions(
        _ positions: [ICUNumberFormatter.AttributePosition],
        string: String,
        unit: _polyfill_ByteCountFormatStyle.Unit
    ) -> Foundation.AttributedString {
        typealias NumberPartAttribute   = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart
        typealias NumberSymbolAttribute = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol
        typealias ByteCountAttribute    = Foundation.AttributeScopes.FoundationAttributes.ByteCountAttribute.Component

        var attrstr = Foundation.AttributedString(string)

        for attr in positions {
            var container = Foundation.AttributeContainer()

            if let part   = NumberPartAttribute(unumberFormatField: attr.field)            { container.numberPart = part }
            if let symbol = NumberSymbolAttribute(unumberFormatField: attr.field)          { container.numberSymbol = symbol }
            if let comp   = ByteCountAttribute(unumberFormatField: attr.field, unit: unit) { container.byteCount = comp }

            attrstr[Range(String.Index(utf16Offset: attr.begin, in: string) ..< .init(utf16Offset: attr.end, in: string), in: attrstr)!].mergeAttributes(container)
        }
        return attrstr
    }
}

final class ICUMeasurementNumberFormatter: ICUNumberFormatterBase {
    private struct Signature : Hashable {
        let skeleton: String
        let localeIdentifier: String
    }
    
    private static let cache = FormatterCache<Signature, ICUMeasurementNumberFormatter?>()

    static func create(for skeleton: String, locale: Locale) -> ICUMeasurementNumberFormatter? {
        Self.cache.formatter(for: .init(skeleton: skeleton, localeIdentifier: locale.identifier)) {
            .init(skeleton: skeleton, localeIdentifier: locale.identifier)
        }
    }

    func attributedFormat(_ v: Value) -> Foundation.AttributedString {
        guard let (str, attributes) = self.attributedFormatPositions(v) else {
            return .init(v.fallbackDescription)
        }
        return self.attributedStringFromPositions(attributes, string: str)
    }

    override func attributedStringFromPositions(
        _ positions: [ICUNumberFormatter.AttributePosition],
        string: String
    ) -> Foundation.AttributedString {
        typealias NumberPartAttribute   = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart
        typealias NumberSymbolAttribute = Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol
        typealias MeasurementAttribute  = Foundation.AttributeScopes.FoundationAttributes.MeasurementAttribute.Component

        var attrstr = Foundation.AttributedString(string)

        for attr in positions {
            var container = Foundation.AttributeContainer()

            if let part   = NumberPartAttribute(unumberFormatField: attr.field)   { container.numberPart = part }
            if let symbol = NumberSymbolAttribute(unumberFormatField: attr.field) { container.numberSymbol = symbol }
            if let comp   = MeasurementAttribute(unumberFormatField: attr.field)  { container.measurement = comp }

            attrstr[Range(String.Index(utf16Offset: attr.begin, in: string) ..< .init(utf16Offset: attr.end, in: string), in: attrstr)!].mergeAttributes(container)
        }
        return attrstr
    }

    enum Usage: String {
        case general = "default"
        case person
        case food
        case personHeight = "person-height"
        case road
        case focalLength = "focal-length"
        case rainfall
        case snowfall
        case visibility = "visiblty"
        case barometric = "baromtrc"
        case wind
        case weather
        case fluid
        case asProvided
    }

    enum UnitWidth: String, Codable {
        case wide = "unit-width-full-name"
        case abbreviated = "unit-width-short"
        case narrow = "unit-width-narrow"
    }

    static func skeleton(
        _ unitSkeleton: String?,
        width: UnitWidth,
        usage: Usage?,
        numberFormatStyle: _polyfill_FloatingPointFormatStyle<Double>?
    ) -> String {
        var stem = ""
        
        if let unitSkeleton {
            stem += unitSkeleton + " " + width.rawValue
            if let usage {
                stem += " usage/" + usage.rawValue
            }
        }
        
        if let numberFormatSkeleton = numberFormatStyle?.collection.skeleton {
            if !stem.isEmpty {
                stem += " "
            }
            stem += numberFormatSkeleton
        }

        return stem
    }
}

final class ICULegacyNumberFormatter {
    let uformatter: UnsafeMutablePointer<UNumberFormat?>

    private init(type: UNumberFormatStyle, localeIdentifier: String) throws {
        self.uformatter = try ICU4Swift.withCheckedStatus { unum_open(type, nil, 0, localeIdentifier, nil, &$0) }
    }

    deinit {
        unum_close(self.uformatter)
    }

    func setAttribute(_ attr: UNumberFormatAttribute, value: Int) {
        unum_setAttribute(self.uformatter, attr, Int32(value))
    }
    
    func setAttribute(_ attr: UNumberFormatAttribute, value: Bool) {
        unum_setAttribute(self.uformatter, attr, value ? 1 : 0)
    }
    
    func setAttribute(_ attr: UNumberFormatTextAttribute, value: String) throws {
        try ICU4Swift.withCheckedStatus { unum_setTextAttribute(self.uformatter, attr, Array(value.utf16), Int32(value.utf16.count), &$0) }
    }

    func parseAsInt(_ string: some StringProtocol) -> Int64? {
        try? ICU4Swift.withCheckedStatus { unum_parseInt64(self.uformatter, Array(string.utf16), Int32(string.utf16.count), nil, &$0) }
    }

    func parseAsInt(_ string: some StringProtocol, upperBound: inout Int32) -> Int64? {
        try? ICU4Swift.withCheckedStatus { unum_parseInt64(self.uformatter, Array(string.utf16), Int32(string.utf16.count), &upperBound, &$0) }
    }

    func parseAsDouble(_ string: some StringProtocol) -> Double? {
        try? ICU4Swift.withCheckedStatus { unum_parseDouble(self.uformatter, Array(string.utf16), Int32(string.utf16.count), nil, &$0) }
    }

    func parseAsDouble(_ string: some StringProtocol, upperBound: inout Int32) -> Double? {
        try? ICU4Swift.withCheckedStatus { unum_parseDouble(self.uformatter, Array(string.utf16), Int32(string.utf16.count), &upperBound, &$0) }
    }

    func parseAsDecimal(_ string: some StringProtocol) -> Foundation.Decimal? {
        var upperBound = 0 as Int32

        return self.parseAsDecimal(string, upperBound: &upperBound)
    }

    func parseAsDecimal(_ string: some StringProtocol, upperBound: inout Int32) -> Foundation.Decimal? {
        guard let formattable = try? ICU4Swift.withCheckedStatus(do: { ufmt_open(&$0) }) else {
            return nil
        }
        defer { ufmt_close(formattable) }

        guard let _ = try? ICU4Swift.withCheckedStatus(do: {
            let arr = Array(string.utf16)
            unum_parseToUFormattable(self.uformatter, formattable, arr, Int32(arr.count), &upperBound, &$0)
        }) else {
            return nil
        }
        
        guard let decNumChars = try? ICU4Swift.withCheckedStatus(do: { ufmt_getDecNumChars(formattable, nil, &$0) }) else {
            return nil
        }

        return String(validatingUTF8: decNumChars).flatMap { Foundation.Decimal(string: $0) }
    }

    func format(_ v: Double) -> String? {
        ICU4Swift.withResizingUCharBuffer { unum_formatDouble(self.uformatter, v, $0, $1, nil, &$2) }
    }
    
    func format(_ v: Int64) -> String? {
        ICU4Swift.withResizingUCharBuffer { unum_formatInt64(self.uformatter, v, $0, $1, nil, &$2) }
    }
    
    func format(_ v: Foundation.Decimal) -> String? {
        ICU4Swift.withResizingUCharBuffer { unum_formatDecimal(self.uformatter, v.description, Int32(v.description.count), $0, $1, nil, &$2) }
    }

    func setPrecision(_ precision: _polyfill_NumberFormatStyleConfiguration.Precision?) {
        switch precision?.option {
        case .significantDigits(let min, let max)?:
            self.setAttribute(UNUM_SIGNIFICANT_DIGITS_USED, value: true)
            self.setAttribute(UNUM_MIN_SIGNIFICANT_DIGITS,  value: min)
            if let max {
                self.setAttribute(UNUM_MAX_SIGNIFICANT_DIGITS, value: max)
            }
        case .integerAndFractionalLength(let minInt, let maxInt, let minFrac, let maxFrac)?:
            self.setAttribute(UNUM_SIGNIFICANT_DIGITS_USED, value: false)
            if let minInt {
                self.setAttribute(UNUM_MIN_INTEGER_DIGITS,  value: minInt)
            }
            if let maxInt {
                self.setAttribute(UNUM_MAX_INTEGER_DIGITS,  value: maxInt)
            }
            if let minFrac {
                self.setAttribute(UNUM_MIN_FRACTION_DIGITS, value: minFrac)
            }
            if let maxFrac {
                self.setAttribute(UNUM_MAX_FRACTION_DIGITS, value: maxFrac)
            }
        default: break
        }
    }

    func setMultiplier(_ multiplier: Double?) {
        if let multiplier {
            self.setAttribute(UNUM_MULTIPLIER, value: Int(multiplier))
        }
    }

    func setGrouping(_ group: _polyfill_NumberFormatStyleConfiguration.Grouping?) {
        if group?.option == .hidden {
            self.setAttribute(UNUM_GROUPING_USED, value: false)
        }
    }

    func setDecimalSeparator(_ decimalSeparator: _polyfill_NumberFormatStyleConfiguration.DecimalSeparatorDisplayStrategy?) {
        if decimalSeparator?.option == .always {
            self.setAttribute(UNUM_DECIMAL_ALWAYS_SHOWN, value: true)
        }
    }

    func setRoundingIncrement(_ increment: _polyfill_NumberFormatStyleConfiguration.RoundingIncrement?) {
        switch increment {
        case .integer(let value)?:       self.setAttribute(UNUM_ROUNDING_INCREMENT, value: value)
        case .floatingPoint(let value)?: unum_setDoubleAttribute(self.uformatter, UNUM_ROUNDING_INCREMENT, value)
        default: break
        }
    }

    func setCapitalizationContext(_ context: _polyfill_FormatStyleCapitalizationContext) {
        try? ICU4Swift.withCheckedStatus { unum_setContext(self.uformatter, context.icuContext, &$0) }
    }

    enum NumberFormatType: Hashable, Codable {
        case number(_polyfill_NumberFormatStyleConfiguration.Collection)
        case percent(_polyfill_NumberFormatStyleConfiguration.Collection)
        case currency(_polyfill_CurrencyFormatStyleConfiguration.Collection)
        case descriptive(_polyfill_DescriptiveNumberFormatConfiguration.Collection)
    }

    private struct Signature: Hashable {
        let type: NumberFormatType
        let localeIdentifier: String
        let lenient: Bool

        func createNumberFormatter() -> ICULegacyNumberFormatter {
            let icuType: UNumberFormatStyle = switch self.type {
            case .number(let config): config.notation == .scientific ? UNUM_SCIENTIFIC : UNUM_DECIMAL
            case .percent: UNUM_PERCENT
            case .currency(let config): config.icuNumberFormatStyle
            case .descriptive(let config): config.icuNumberFormatStyle
            }
            
            let formatter = try! ICULegacyNumberFormatter(type: icuType, localeIdentifier: self.localeIdentifier)
            
            formatter.setAttribute(UNUM_LENIENT_PARSE, value: self.lenient)
            switch self.type {
            case .number(let config), .percent(let config):
                formatter.setMultiplier(config.scale)
                formatter.setPrecision(config.precision)
                formatter.setGrouping(config.group)
                formatter.setDecimalSeparator(config.decimalSeparatorStrategy)
                formatter.setRoundingIncrement(config.roundingIncrement)
                if config.signDisplayStrategy?.positive == .always {
                    formatter.setAttribute(UNUM_SIGN_ALWAYS_SHOWN, value: true)
                }
            case .currency(let config):
                formatter.setMultiplier(config.scale)
                formatter.setPrecision(config.precision)
                formatter.setGrouping(config.group)
                formatter.setDecimalSeparator(config.decimalSeparatorStrategy)
                formatter.setRoundingIncrement(config.roundingIncrement)
                if config.signDisplayStrategy?.positive == .always {
                    formatter.setAttribute(UNUM_SIGN_ALWAYS_SHOWN, value: true)
                }
            case .descriptive(let config):
                if let capitalizationContext = config.capitalizationContext {
                    formatter.setCapitalizationContext(capitalizationContext)
                }
                if config.presentation.option == .cardinal {
                    do {
                        try formatter.setAttribute(UNUM_DEFAULT_RULESET, value: "%spellout-cardinal")
                    } catch {
                        try? formatter.setAttribute(UNUM_DEFAULT_RULESET, value: "%spellout-cardinal-feminine")
                    }
                }
            }
            return formatter
        }
    }

    private static let cache = FormatterCache<Signature, ICULegacyNumberFormatter>()

    static func formatter(
        for type: NumberFormatType,
        locale: Foundation.Locale,
        lenient: Bool = false
    ) -> ICULegacyNumberFormatter {
        let sig = Signature(type: type, localeIdentifier: locale.identifier, lenient: lenient)
        
        return Self.cache.formatter(for: sig, creator: sig.createNumberFormatter)
    }
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

extension Foundation.AttributeScopes.FoundationAttributes.ByteCountAttribute.Component {
    init?(unumberFormatField: UNumberFormatFields, unit: _polyfill_ByteCountFormatStyle.Unit) {
        switch unumberFormatField {
        case UNUM_INTEGER_FIELD, UNUM_FRACTION_FIELD, UNUM_DECIMAL_SEPARATOR_FIELD,
             UNUM_GROUPING_SEPARATOR_FIELD, UNUM_SIGN_FIELD:
            self = .value
        case UNUM_MEASURE_UNIT_FIELD:       self = .unit(.init(unit))
        default: return nil
        }
    }
}
