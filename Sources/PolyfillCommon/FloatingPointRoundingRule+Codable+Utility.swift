#if !canImport(Darwin)

#if $RetroactiveAttribute
extension Swift.FloatingPointRoundingRule: @retroactive Codable {}
#else
extension Swift.FloatingPointRoundingRule: Codable {}
#endif

extension Swift.FloatingPointRoundingRule {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        switch try container.decode(Int.self) {
        case 0: self = .toNearestOrAwayFromZero
        case 1: self = .toNearestOrEven
        case 2: self = .up
        case 3: self = .down
        case 4: self = .towardZero
        case 5: self = .awayFromZero
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid enumeration case")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .toNearestOrAwayFromZero: try container.encode(0)
        case         .toNearestOrEven: try container.encode(1)
        case                      .up: try container.encode(2)
        case                    .down: try container.encode(3)
        case              .towardZero: try container.encode(4)
        case            .awayFromZero: try container.encode(5)
        @unknown default:
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: "Unknown enumeration case"))
        }
    }
}

#endif
