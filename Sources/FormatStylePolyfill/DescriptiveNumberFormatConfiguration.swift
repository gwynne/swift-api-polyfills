import CLegacyLibICU
import class Foundation.NumberFormatter
import class Foundation.Formatter

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public enum _polyfill_DescriptiveNumberFormatConfiguration {
    public typealias CapitalizationContext = _polyfill_FormatStyleCapitalizationContext
    
    public struct Presentation: Codable, Hashable, Sendable {
        enum Option: Int, Codable, Hashable {
            case spellOut = 1
            case ordinal  = 2
            case cardinal = 3

            fileprivate var numberFormatterStyle: Foundation.NumberFormatter.Style {
                switch self {
                case .spellOut: .spellOut
                case .ordinal: .ordinal
                case .cardinal: .spellOut
                }
            }
        }

        var option: Option

        public static var spellOut: Self { .init(rawValue: 1) }
        public static var ordinal: Self  { .init(rawValue: 2) }
        static var cardinal: Self        { .init(rawValue: 3) }
        
        init(rawValue: Int) { self.option = .init(rawValue: rawValue)! }
    }

    struct Collection: Codable, Hashable {
        var presentation: Presentation
        var capitalizationContext: CapitalizationContext?

        var icuNumberFormatStyle: UNumberFormatStyle {
            switch self.presentation.option {
            case .spellOut: .spellout
            case .ordinal:  .ordinal
            case .cardinal: .spellout
            }
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct _polyfill_FormatStyleCapitalizationContext: Codable, Hashable, Sendable {
    public static var unknown: Self             { .init(.unknown) }
    public static var standalone: Self          { .init(.standalone) }
    public static var listItem: Self            { .init(.listItem) }
    public static var beginningOfSentence: Self { .init(.beginningOfSentence) }
    public static var middleOfSentence: Self    { .init(.middleOfSentence) }

    enum Option: Int, Codable, Hashable {
        case unknown
        case standalone
        case listItem
        case beginningOfSentence
        case middleOfSentence
    }

    var option: Option

    private init(_ option: Option) { self.option = option }

    var icuContext: UDisplayContext {
        switch self.option {
        case .unknown:             UDISPCTX_CAPITALIZATION_NONE
        case .standalone:          UDISPCTX_CAPITALIZATION_FOR_STANDALONE
        case .listItem:            UDISPCTX_CAPITALIZATION_FOR_UI_LIST_OR_MENU
        case .beginningOfSentence: UDISPCTX_CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE
        case .middleOfSentence:    UDISPCTX_CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE
        }
    }

    var formatterContext: Foundation.Formatter.Context {
        switch self.option {
        case .unknown:             .unknown
        case .standalone:          .standalone
        case .listItem:            .listItem
        case .beginningOfSentence: .beginningOfSentence
        case .middleOfSentence:    .middleOfSentence
        }
    }

}
