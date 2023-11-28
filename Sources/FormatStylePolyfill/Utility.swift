import Foundation

extension Swift.FloatingPointRoundingRule {
    /// Convert a `FloatingPointRoundingMode` to the equivalent `NumberFormatter.RoundingMode`.
    internal var toFormatterMode: NumberFormatter.RoundingMode {
        switch self {
        case .toNearestOrAwayFromZero: .halfUp   /// `round(3)`
        case .toNearestOrEven:         .halfEven /// IEEE `roundToIntegralTiesToEven`
        case .up:                      .ceiling  /// `ceil(3)`
        case .down:                    .floor    /// `floor(3)`
        case .towardZero:              .down     /// `trunc(3)`
        case .awayFromZero:            .up       /// Opposite of `towardZero`
        @unknown default:              .halfDown /// Opposite of `toNearestOrAwayFromZero`
        }
    }
}

extension Foundation.NumberFormatter {
    /// Create a `NumberFormatter` preloaded with a desirable configuration.
    ///
    /// The resulting formatter is preconfigured with:
    ///
    /// - The given `Locale`
    /// - The `.decimal` number style
    /// - The given minimum integer width (default 2)
    /// - The given exact (min & max) fractional width (default none)
    /// - The given rounding mode (default `.toNearestOrEven`)
    internal convenience init(
        locale: Locale,
        integerWidth: Int = 2,
        fractionWidth: Int = 0,
        rounding: FloatingPointRoundingRule = .toNearestOrEven
    ) {
        self.init()
        self.locale = locale
        self.numberStyle = .decimal
        self.minimumIntegerDigits = integerWidth
        self.minimumFractionDigits = fractionWidth
        self.maximumFractionDigits = fractionWidth
        self.roundingMode = rounding.toFormatterMode
    }
    
    /// Convenience wrapper for the `NSNumber`-based interface.
    internal func string(from value: Int) -> String? {
        self.string(from: NSNumber(value: value))
    }

    /// Convenience wrapper for the `NSNumber`-based interface.
    internal func string(from value: Int64) -> String? {
        self.string(from: NSNumber(value: value))
    }

    /// Convenience wrapper for the `NSNumber`-based interface.
    internal func string(from value: Double) -> String? {
        self.string(from: NSNumber(value: value))
    }
}

#if !canImport(Darwin)

#if $RetroactiveAttribute
/// Conform `Locale` to `Sendable` retroactively to silence warnings on Linux.
extension Foundation.Locale: @retroactive @unchecked Sendable {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.FloatingPointRoundingRule: @retroactive Codable {}

#else

/// Conform `Locale` to `Sendable` retroactively to silence warnings on Linux.
extension Foundation.Locale: @unchecked Sendable {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.FloatingPointRoundingRule: Codable {}

#endif

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
