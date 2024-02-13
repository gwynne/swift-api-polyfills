import struct Foundation.Decimal

extension _polyfill_NumberFormatStyleConfiguration.Collection {
    var skeleton: String {
        [
            self.scale?.skeleton,
            self.precision?.skeleton(with: self.roundingIncrement) ?? self.roundingIncrement?.skeleton,
            self.group?.skeleton,
            self.signDisplayStrategy?.skeleton,
            self.decimalSeparatorStrategy?.skeleton,
            self.rounding?.skeleton,
            self.notation?.skeleton
        ].compactMap { $0 }.joined(separator: " ").trimmed
    }
}

extension _polyfill_NumberFormatStyleConfiguration.Precision {
    private static func integerStem(min: Int?, max: Int?, prefix: String = "") -> String {
        switch (min, max) {
        case (0, 0):          "\(prefix)integer-width/*"
        case (let min, let max?) where (min ?? 0) <= max:
                              "\(prefix)integer-width/\("#".repeated(max - (min ?? 0)))\("0".repeated(min ?? 0))"
        case (let min?, nil): "\(prefix)integer-width/+\("0".repeated(min))"
        case (_, _):          ""
        }
    }

    private static func fractionalStem(min: Int?, max: Int?) -> String {
        switch (min, max) {
        case (_, 0):          "precision-integer"
        case let (min, max?) where (min ?? 0) <= max:
                              ".\("0".repeated(min ?? 0))\("#".repeated(max - (min ?? 0)))"
        case let (min?, nil): ".\("0".repeated(min))+"
        case (_, _):          ""
        }
    }

    func skeleton(with roundingIncrement: _polyfill_NumberFormatStyleConfiguration.RoundingIncrement?) -> String {
        guard let stem = roundingIncrement?.skeleton, !stem.isEmpty else {
            return self.skeleton
        }
        
        guard case .integerAndFractionalLength(let minInt, let maxInt, let minFrac, _) = self.option else {
            return stem
        }
        
        return stem +
               "0".repeated(Swift.max(0,
                   (minFrac ?? 0) - (stem.lastIndex(of: ".").map { stem.distance(from: stem.index(after: $0), to: stem.endIndex) } ?? 0)
               )) +
               " \(Self.integerStem(min: minInt, max: maxInt))"
    }

    private static func significantDigitsSkeleton(min: Int, max: Int?) -> String {
        "@".repeated(min) + (max.map { "#".repeated($0 - min) } ?? "+")
    }

    private static func integerAndFractionalLengthSkeleton(minInt: Int?, maxInt: Int?, minFrac: Int?, maxFrac: Int?) -> String {
        [
            self.fractionalStem(min: minFrac, max: maxFrac),
            self.integerStem(min: minInt, max: maxInt),
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var skeleton: String {
        switch self.option {
        case let .significantDigits(min, max):
            Self.significantDigitsSkeleton(min: min, max: max)
        case let .integerAndFractionalLength(minI, maxI, minF, maxF):
            Self.integerAndFractionalLengthSkeleton(minInt: minI, maxInt: maxI, minFrac: minF, maxFrac: maxF)
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.Grouping {
    var skeleton: String {
        self.option == .automatic ? "" : "group-off"
    }
}

extension _polyfill_NumberFormatStyleConfiguration.DecimalSeparatorDisplayStrategy {
    var skeleton: String {
        self.option == .always ? "decimal-always" : "decimal-auto"
    }
}

extension _polyfill_NumberFormatStyleConfiguration.SignDisplayStrategy {
   var skeleton: String {
        switch (self.positive, self.zero, self.negative) {
        case (.always, .always, _): "sign-always"
        case (.always, .hidden, _): "sign-except-zero"
        case (.hidden, _, .always): "sign-auto"
        case (.hidden, _, .hidden): "sign-never"
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.Notation {
    var skeleton: String {
        switch self.option {
        case .scientific:  "scientific"
        case .automatic:   ""
        case .compactName: "compact-short"
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.RoundingIncrement {
    var skeleton: String {
        switch self {
        case .integer(let value)       where value > 0: "precision-increment/\(Foundation.Decimal(value))"
        case .floatingPoint(let value) where value > 0: "precision-increment/\(Foundation.Decimal(value))"
        default:                                        ""
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.RoundingRule {
    var skeleton: String {
        switch self {
        case .awayFromZero:            "rounding-mode-up"
        case .toNearestOrAwayFromZero: "rounding-mode-half-up"
        case .toNearestOrEven:         "rounding-mode-half-even"
        case .up:                      "rounding-mode-ceiling"
        case .down:                    "rounding-mode-floor"
        case .towardZero:              "rounding-mode-down"
        @unknown default:              ""
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.Scale {
    var skeleton: String {
        "scale/\(Foundation.Decimal(self))"
    }
}

extension _polyfill_NumberFormatStyleConfiguration.Precision.Option: Codable {
    private enum CodingKeys: CodingKey {
        case minSignificantDigits
        case maxSignificantDigits
        case minIntegerLength
        case maxIntegerLength
        case minFractionalLength
        case maxFractionalLength
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let minSignificantDigits = try container.decodeIfPresent(Int.self, forKey: .minSignificantDigits),
           let maxSignificantDigits = try container.decodeIfPresent(Int.self, forKey: .maxSignificantDigits)
        {
            self = .significantDigits(min: minSignificantDigits, max: maxSignificantDigits)
        } else if let minInt = try container.decodeIfPresent(Int.self, forKey: .minIntegerLength),
                  let maxInt = try container.decodeIfPresent(Int.self, forKey: .maxIntegerLength),
                  let minFrac = try container.decodeIfPresent(Int.self, forKey: .minFractionalLength),
                  let maxFrac = try container.decodeIfPresent(Int.self, forKey: .maxFractionalLength)
        {
            self = .integerAndFractionalLength(minInt: minInt, maxInt: maxInt, minFraction: minFrac, maxFraction: maxFrac)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid Precision"))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .significantDigits(let min, let max):
            try container.encode(min, forKey: .minSignificantDigits)
            try container.encode(max, forKey: .maxSignificantDigits)
        case .integerAndFractionalLength(let minInt, let maxInt, let minFraction, let maxFraction):
            try container.encode(minInt, forKey: .minIntegerLength)
            try container.encode(maxInt, forKey: .maxIntegerLength)
            try container.encode(minFraction, forKey: .minFractionalLength)
            try container.encode(maxFraction, forKey: .maxFractionalLength)
        }
    }
}

extension _polyfill_NumberFormatStyleConfiguration.RoundingIncrement: Codable {
    private enum CodingKeys: CodingKey {
        case integer
        case floatingPoint
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try container.decodeIfPresent(Int.self, forKey: .integer) {
            self = .integer(value: value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .floatingPoint) {
            self = .floatingPoint(value: value)
        } else {
            self = .floatingPoint(value: 0.5)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .integer(let value):       try container.encode(value, forKey: .integer)
        case .floatingPoint(let value): try container.encode(value, forKey: .floatingPoint)
        }
    }
}
