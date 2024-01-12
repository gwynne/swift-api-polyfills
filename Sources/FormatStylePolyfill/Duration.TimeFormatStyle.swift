import Foundation

extension Swift.Duration {
    /// Format style to format a `Duration` in a localized positional format.
    /// For example, one hour and ten minutes is displayed as “1:10:00” in
    /// the U.S. English locale, or “1.10.00” in the Finnish locale.
    public struct _polyfill_TimeFormatStyle: Sendable {
        /// Creates an instance using the provided pattern and locale.
        /// - Parameters:
        ///   - pattern: A `Pattern` to specify the units to include in the displayed string and the
        ///     behavior of the units.
        ///   - locale: The `Locale` used to create the string representation of the duration.
        public init(pattern: Swift.Duration._polyfill_TimeFormatStyle.Pattern, locale: Foundation.Locale = .autoupdatingCurrent) {
            self.attributed = .init(locale: locale, pattern: pattern)
        }

        /// The attributed format style corresponding to this style.
        public var attributed: Swift.Duration._polyfill_TimeFormatStyle.Attributed

        /// The locale to use when formatting the duration.
        public var locale: Foundation.Locale {
            get { self.attributed.locale }
            set { self.attributed.locale = newValue }
        }

        /// The pattern to display a Duration with.
        public var pattern: Swift.Duration._polyfill_TimeFormatStyle.Pattern {
            get { self.attributed.pattern }
            set { self.attributed.pattern = newValue }
        }
    }
}

extension _polyfill_FormatStyle where Self == Swift.Duration._polyfill_TimeFormatStyle {
    /// A factory variable to create a time format style to format a duration.
    ///
    /// - Parameter pattern: A `Pattern` to specify the units to include in the displayed string and the
    ///   behavior of the units.
    /// - Returns: A format style to format a duration.
    public static func time(pattern: Swift.Duration._polyfill_TimeFormatStyle.Pattern) -> Self {
        .init(pattern: pattern)
    }
}

extension Swift.Duration._polyfill_TimeFormatStyle: _polyfill_FormatStyle {
    /// The type of data to format.
    public typealias FormatInput = Swift.Duration

    /// The type of the formatted data.
    public typealias FormatOutput = String

    /// Creates a locale-aware string representation from a duration value.
    /// - Parameter value: The value to format.
    /// - Returns: A string representation of the duration.
    public func format(_ value: Swift.Duration) -> String {
        String(self.attributed.format(value).characters[...])
    }

    /// Modifies the format style to use the specified locale.
    /// - Parameter locale: The locale to use when formatting a duration.
    /// - Returns: A format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Swift.Duration._polyfill_TimeFormatStyle {
        var res = self
        res.locale = locale
        return res
    }
}
