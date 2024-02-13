import struct Foundation.Date
import struct Foundation.Locale
import struct Foundation.TimeZone
import struct Foundation.Calendar

/// A style that formats a date with an explicitly-specified style.
public struct _polyfill_DateVerbatimFormatStyle: Sendable, _polyfill_FormatStyle {
    /// The time zone with which to specify date and time values.
    public var timeZone: Foundation.TimeZone

    /// The calendar to use for date values.
    public var calendar: Foundation.Calendar

    /// Use system locale if nil or unspecified.
    public var locale: Foundation.Locale?

    var formatPattern: String
    
    /// Creates a new `FormatStyle` with the given configurations.
    ///
    /// - Parameters:
    ///   - format: A `Date.FormatString` that provides the explicit components and their respective styles to
    ///     use when formatting a date.
    ///   - locale: The locale to use when formatting. Defaults to `nil`.
    ///   - timeZone: The time zone to use when formatting.
    ///   - calendar: The calendar to use when formatting.
    public init(
        format: _polyfill_DateFormatString,
        locale: Foundation.Locale? = nil,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar
    ) {
        self.formatPattern = format.rawFormat
        self.calendar = calendar
        self.locale = locale
        self.timeZone = timeZone
    }

    /// Creates a locale-aware string representation from a date value for a verbatim date format.
    ///
    /// - Parameter value: The date to format.
    /// - Returns: A string representation of the date.
    ///
    /// The `format(_:)` instance method generates a string from the provided date. Once you create a style, you can
    /// use it to format dates multiple times.
    public func format(_ value: Foundation.Date) -> String {
        ICUDateFormatter.cachedFormatter(for: self).format(value) ?? value.description
    }

    /// Modifies the date verbatim style to use the specified locale.
    ///
    /// - Parameter locale: The locale to use when formatting a date.
    /// - Returns: A date attributed style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DateVerbatimFormatStyle {
    /// Returns a style for formatting a date with an explicitly-specified style.
    ///
    /// - Parameters:
    ///   - format: A `Date.FormatString` that provides the explicit components and their respective styles to
    ///     use when formatting a date.
    ///   - locale: The locale to use when formatting. Defaults to `nil`.
    ///   - timeZone: The time zone to use when formatting.
    ///   - calendar: The calendar to use when formatting.
    /// - Returns: A date format style that uses the provided format string and timekeeping parameters.
    ///
    /// Use this format style only when you need to produce or parse an exact format, such as when working with
    /// programmatically-produced date strings. For formatting dates that people read, use dateTime to get a
    /// localized `Date.FormatStyle` instead. To use the ISO-8601 standard, use `iso8601` to get a
    /// `Date.ISO8601FormatStyle`.
    ///
    /// Use the dot-notation form of this type method when the call point allows the use of
    /// `Date.VerbatimFormatStyle`. You typically do this when calling the `formatted(_:)` method of `Date`.
    ///
    /// The following example formats the current date with a verbatim format that uses a two-digit month,
    /// two-digit day, and default-digits year, separated by slashes. The format style zero-pads the month and day
    /// components. This style isn’t localized — while this format string mimicks `en_US` conventions, it uses this
    /// format in any locale, ignoring locale-appropriate conventions.
    ///
    /// ```swift
    /// let date = Date()
    /// let formatted = date.formatted(
    ///     .verbatim("\(month: .twoDigits)/\(day: .twoDigits)/\(year: .defaultDigits)" as Date.FormatString,
    ///               locale: .autoupdatingCurrent,
    ///               timeZone: .current,
    ///               calendar: .current)) // 12/05/2022
    /// ```
    public static func verbatim(
        _ format: _polyfill_DateFormatString,
        locale: Foundation.Locale? = nil,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar
    ) -> _polyfill_DateVerbatimFormatStyle {
        .init(
            format: format,
            locale: locale,
            timeZone: timeZone,
            calendar: calendar
        )
    }
}

extension _polyfill_DateVerbatimFormatStyle: _polyfill_ParseableFormatStyle {
    /// The strategy used to parse a string into a date.
    public var parseStrategy: _polyfill_DateParseStrategy {
        .init(
            format: self.formatPattern,
            locale: self.locale,
            timeZone: self.timeZone,
            calendar: self.calendar,
            isLenient: false,
            twoDigitStartDate: .init(timeIntervalSince1970: 0)
        )
    }
}

extension _polyfill_DateVerbatimFormatStyle: CustomConsumingRegexComponent {
    // See `RegexComponent.RegexOutput`.
    public typealias RegexOutput = Foundation.Date
    
    // See `CustomConsumingRegexComponents.consuming(_:startingAt:in:)`.
     public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Foundation.Date)? {
        try self.parseStrategy.consuming(input, startingAt: index, in: bounds)
    }
}
