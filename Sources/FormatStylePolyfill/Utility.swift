import Foundation
import CLegacyLibICU
import PolyfillCommon

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
        self.roundingMode = rounding.toNumberFormatterMode
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
