import struct Foundation.Decimal

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
        ].compacted().joined(separator: " ").trimmed
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.Precision {
    private static func integerStem(min: Int, max: Int?) -> String { switch (min, max) {
        case (0, 0): "integer-width/*"
        case let (min, max?) where min <= max: "integer-width/\("#".repeated(max - min))\("0".repeated(min))"
        case let (min, nil): "integer-width/+\("0".repeated(min))"
        case (_, .some): ""
    } }

    private static func fractionalStem(min: Int, max: Int?) -> String { switch (min, max) {
        case let (min, max?) where min <= max: ".\("0".repeated(min))\("#".repeated(max - min))"
        case let (min, nil): ".\("0".repeated(min))+"
        default: ""
    } }

    func skeleton(with roundingIncrement: _polyfill_NumberFormatStyleConfiguration.RoundingIncrement?) -> String {
        guard var stem = roundingIncrement?.skeleton, !stem.isEmpty else { return self.skeleton }
        guard case .integerAndFractionalLength(let minInt, let maxInt, let minFrac, _) = self.option else { return stem }
        if let minFrac {
            if let decimalPoint = stem.lastIndex(of: ".") {
                let frac = stem.suffix(from: stem.index(after: decimalPoint))
                if minFrac > frac.count { stem += "0".repeated(minFrac - frac.count) }
            }
            else { stem += ".\("0".repeated(minFrac))" }
        }
        if minInt != nil || maxInt != nil { stem += " " + Self.integerStem(min: minInt ?? 0, max: maxInt) }
        return stem
    }

    private static func significantDigitsSkeleton(min: Int, max: Int?) -> String {
        "@".repeated(min) + (max.map { "#".repeated($0 - min) } ?? "+")
    }

    private static func integerAndFractionalLengthSkeleton(minInt: Int?, maxInt: Int?, minFrac: Int?, maxFrac: Int?) -> String {
        [
            (minFrac != nil || maxFrac != nil) ? (maxFrac == 0 ? "precision-integer" : self.fractionalStem(min: minFrac ?? 0, max: maxFrac)) : nil,
            (minInt != nil || maxInt != nil) ? self.integerStem(min: minInt ?? 0, max: maxInt) : nil,
        ]
        .compacted().joined(separator: " ")
    }

    var skeleton: String { switch self.option {
        case .significantDigits(let bounds):
            Self.significantDigitsSkeleton(min: bounds.lowerBound, max: bounds.upperBound - 1)
        case .integerAndFractionalLength(let minInt, let maxInt, let minFrac, let maxFrac):
            Self.integerAndFractionalLengthSkeleton(minInt: minInt, maxInt: maxInt, minFrac: minFrac, maxFrac: maxFrac)
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.Grouping {
    var skeleton: String { self.option == .automatic ? "" : "group-off" }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.DecimalSeparatorDisplayStrategy {
    var skeleton: String { self.option == .always ? "decimal-always" : "decimal-auto" }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.Notation {
    var skeleton: String { switch self.option {
        case .scientific: "scientific"
        case .automatic: ""
        case .compactName: "compact-short"
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.RoundingIncrement {
    var skeleton: String { switch self {
        case .integer(let value): value > 0 ? "precision-increment/\(Decimal(value))" : ""
        case .floatingPoint(let value)  : value > 0 ? "precision-increment/\(Decimal(value))" : ""
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.RoundingRule {
    var skeleton: String { switch self {
        case .awayFromZero: "rounding-mode-up"
        case .toNearestOrAwayFromZero: "rounding-mode-half-up"
        case .toNearestOrEven: "rounding-mode-half-even"
        case .up: "rounding-mode-ceiling"
        case .down: "rounding-mode-floor"
        case .towardZero: "rounding-mode-down"
        @unknown default: ""
    } }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.Scale {
    var skeleton: String { "scale/\(Decimal(self))" }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.Precision.Option: Codable {
    private enum CodingKeys: CodingKey {
        case minSignificantDigits, maxSignificantDigits, minIntegerLength, maxIntegerLength, minFractionalLength, maxFractionalLength
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let minSignificantDigits = try container.decodeIfPresent(Int.self, forKey: .minSignificantDigits),
           let maxSignificantDigits = try container.decodeIfPresent(Int.self, forKey: .maxSignificantDigits)
        {
            self = .significantDigits((minSignificantDigits ... maxSignificantDigits).relative(to: Int.min ..< .max))
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
        case .significantDigits(let bounds):
            try container.encode(bounds.lowerBound, forKey: .minSignificantDigits)
            try container.encode(bounds.upperBound, forKey: .maxSignificantDigits)
        case .integerAndFractionalLength(let minInt, let maxInt, let minFraction, let maxFraction):
            try container.encode(minInt, forKey: .minIntegerLength)
            try container.encode(maxInt, forKey: .maxIntegerLength)
            try container.encode(minFraction, forKey: .minFractionalLength)
            try container.encode(maxFraction, forKey: .maxFractionalLength)
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_NumberFormatStyleConfiguration.RoundingIncrement: Codable {
    private enum CodingKeys: CodingKey { case integer, floatingPoint }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(Int.self, forKey: .integer) { self = .integer(value: value) }
        else if let value = try container.decodeIfPresent(Double.self, forKey: .floatingPoint) { self = .floatingPoint(value: value) }
        else { self = .floatingPoint(value: 0.5) }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .integer(let value): try container.encode(value, forKey: .integer)
        case .floatingPoint(let value): try container.encode(value, forKey: .floatingPoint)
        }
    }
}
