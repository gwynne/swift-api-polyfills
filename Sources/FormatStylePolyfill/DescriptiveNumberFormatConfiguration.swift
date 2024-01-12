import CLegacyLibICU

public enum _polyfill_DescriptiveNumberFormatConfiguration {
    public typealias CapitalizationContext = _polyfill_FormatStyleCapitalizationContext
    
    public struct Presentation: Codable, Hashable, Sendable {
        enum Option: Int, Codable, Hashable {
            case spellOut = 1
            case ordinal  = 2
            case cardinal = 3
        }

        let option: Option
        private init(_ option: Option) { self.option = option }

        public static var spellOut: Self { .init(.spellOut) }
        public static var ordinal: Self  { .init(.ordinal) }
        static var cardinal: Self        { .init(.cardinal) }
    }

    struct Collection: Codable, Hashable {
        var presentation: Presentation
        var capitalizationContext: CapitalizationContext?

        var icuNumberFormatStyle: UNumberFormatStyle {
            switch self.presentation.option {
            case .spellOut, .cardinal: .spellout
            case .ordinal: .ordinal
            }
        }
    }
}

public struct _polyfill_FormatStyleCapitalizationContext: Codable, Hashable, Sendable {
    public static var unknown: Self             { .init(UDISPCTX_CAPITALIZATION_NONE)                      }
    public static var standalone: Self          { .init(UDISPCTX_CAPITALIZATION_FOR_STANDALONE)            }
    public static var listItem: Self            { .init(UDISPCTX_CAPITALIZATION_FOR_UI_LIST_OR_MENU)       }
    public static var beginningOfSentence: Self { .init(UDISPCTX_CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) }
    public static var middleOfSentence: Self    { .init(UDISPCTX_CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE)    }
    
    private init(_ icuContext: UDisplayContext) { self.icuContext = icuContext }
    
    private enum CodingKeys: String, CodingKey { case option }
    
    public init(from decoder: any Decoder) throws {
        self.init(try .init(0x10 | ((5 - decoder.container(keyedBy: CodingKeys.self).decode(UInt32.self, forKey: .option)) % 5)))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(5 - (self.icuContext.rawValue & 0xf) - 1, forKey: .option)
    }

    let icuContext: UDisplayContext
}

extension UDisplayContext: Hashable {}
