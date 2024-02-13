import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale
import struct Foundation.TimeZone

/// Options for parsing string representations of dates to create a `Date` instance.
public struct _polyfill_DateParseStrategy: Hashable, Sendable {
    /// Indicates whether to use heuristics when parsing the representation.
    public var isLenient: Bool

    /// The earliest date that can be denoted by a two-digit year specifier.
    public var twoDigitStartDate: Foundation.Date

    /// The locale to use when parsing date strings with the specified format.
    /// Use system locale if unspecified.
    public var locale: Foundation.Locale?

    /// The time zone to use for creating the date.
    public var timeZone: Foundation.TimeZone

    /// The calendar to use when parsing date strings and creating the date.
    public var calendar: Foundation.Calendar

    /// The string representation of the fixed format conforming to Unicode Technical Standard #35.
    public private(set) var format: String

    /// Creates a new `ParseStrategy` with the given configurations.
    /// - Parameters:
    ///   - format: A fixed format representing the pattern of the date string.
    ///   - locale: The locale of the fixed format.
    ///   - timeZone: The time zone to use for creating the date.
    ///   - isLenient: Whether to use heuristics when parsing the representation.
    ///   - twoDigitStartDate: The earliest date that can be denoted by a two-digit year specifier.
    public init(
        format: _polyfill_DateFormatString,
        locale: Foundation.Locale? = nil,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar = .init(identifier: .gregorian),
        isLenient: Bool = true,
        twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
    ) {
        self.init(
            format: format.rawFormat,
            locale: locale,
            timeZone: timeZone,
            calendar: calendar,
            isLenient: isLenient,
            twoDigitStartDate: twoDigitStartDate
        )
    }

    init(
        format: String,
        locale: Foundation.Locale?,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar,
        isLenient: Bool,
        twoDigitStartDate: Foundation.Date
    ) {
        self.locale = locale
        self.timeZone = timeZone
        self.format = format
        self.calendar = calendar
        self.isLenient = isLenient
        self.twoDigitStartDate = twoDigitStartDate
    }

    private var formatter: ICUDateFormatter {
        .cachedFormatter(for: .init(
            localeIdentifier: self.locale?.identifier,
            timeZoneIdentifier: self.timeZone.identifier,
            calendarIdentifier: self.calendar.identifier,
            firstWeekday: self.calendar.firstWeekday,
            minimumDaysInFirstWeek: self.calendar.minimumDaysInFirstWeek,
            capitalizationContext: .unknown,
            pattern: self.format,
            parseLenient: self.isLenient,
            parseTwoDigitStartDate: self.twoDigitStartDate
        ))
    }

    init(
        formatStyle: _polyfill_DateFormatStyle,
        lenient: Bool,
        twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
    ) {
        self.init(
            format: ICUPatternGenerator.localizedPattern(
                symbols: formatStyle.symbols,
                locale: formatStyle.locale,
                calendar: formatStyle.calendar
            ),
            locale: formatStyle.locale,
            timeZone: formatStyle.timeZone,
            calendar: formatStyle.calendar,
            isLenient: lenient,
            twoDigitStartDate: twoDigitStartDate
        )
    }
}

extension _polyfill_DateParseStrategy: _polyfill_ParseStrategy {
    /// Returns a `Date` of a given string interpreted using the current settings.
    ///
    /// - Parameter value: A string representation of a date.
    /// - Throws: Throws `NSFormattingError` if the string cannot be parsed.
    /// - Returns: A `Date` represented by `value`.
    public func parse(_ value: String) throws -> Foundation.Date {
        guard let date = self.formatter.parse(value) else {
            throw parseError(value, examples: self.formatter.format(.now))
        }
        
        return date
    }
}

extension _polyfill_ParseStrategy {
    /// A fixed-format date parse strategy.
    /// 
    /// - Parameters:
    ///   - format: The string describing the parsing format.
    ///   - timeZone: The `TimeZone` used to create the string representation of the date.
    ///   - locale: The `Locale` used to create the string representation of the date.
    /// - Returns: A strategy for parsing a date.
    public static func fixed(
        format: _polyfill_DateFormatString,
        timeZone: Foundation.TimeZone,
        locale: Foundation.Locale? = nil
    ) -> Self where Self == _polyfill_DateParseStrategy {
        .init(format: format, locale: locale, timeZone: timeZone)
    }
}

extension _polyfill_DateParseStrategy: CustomConsumingRegexComponent {
    // See `RegexComponent.RegexOutput`.
    public typealias RegexOutput = Foundation.Date
    
    // See `CustomConsumingRegexComponents.consuming(_:startingAt:in:)`.
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Foundation.Date)? {
        guard index < bounds.upperBound else {
            return nil
        }
        
        return self.formatter.parse(input, in: index ..< bounds.upperBound)
    }
}

extension RegexComponent where Self == _polyfill_DateParseStrategy {
    /// Type that defines date styles varied in length or components included.
    ///
    /// The exact format depends on the locale. Possible values of date style include `omitted`, `numeric`,
    /// `abbreviated`, `long`, and `complete`.
    ///
    /// The following code sample shows a variety of date style format results using the `en_US` locale.
    ///
    /// ```swift
    /// let meetingDate = Date()
    /// meetingDate.formatted(date: .omitted, time: .standard)
    /// // 9:42:14 AM
    ///
    /// meetingDate.formatted(date: .numeric, time: .omitted)
    /// // 10/17/2020
    ///
    /// meetingDate.formatted(date: .abbreviated, time: .omitted)
    /// // Oct 17, 2020
    ///
    /// meetingDate.formatted(date: .long, time: .omitted)
    /// // October 17, 2020
    ///
    /// meetingDate.formatted(date: .complete, time: .omitted)
    /// // Saturday, October 17, 2020
    ///
    /// meetingDate.formatted()
    /// // 10/17/2020, 9:42 AM
    /// ```
    ///
    /// The default date style is `numeric`.
    public typealias _polyfill_DateStyle = _polyfill_DateFormatStyle.DateStyle

    /// Type that defines time styles varied in length or components included.
    ///
    /// The exact format depends on the locale. Possible time styles include `omitted`, `shortened`,
    /// `standard`, and `complete`.
    ///
    /// The following code sample shows a variety of time style format results using the `en_US` locale.
    ///
    /// ```swift
    /// let meetingDate = Date()
    /// meetingDate.formatted(date: .numeric, time: .omitted)
    /// // 10/17/2020
    ///
    /// meetingDate.formatted(date: .numeric, time: .shortened)
    /// // 10/17/2020, 9:54 PM
    ///
    /// meetingDate.formatted(date: .numeric, time: .standard)
    /// // 10/17/2020, 9:54:29 PM
    ///
    /// meetingDate.formatted(date: .numeric, time: .complete)
    /// // 10/17/2020, 9:54:29 PM CDT
    ///
    /// meetingDate.formatted()
    /// // 10/17/2020, 9:54 PM
    /// ```
    ///
    /// The default time style is `shortened`.
    public typealias _polyfill_TimeStyle = _polyfill_DateFormatStyle.TimeStyle

    /// Creates a regex component to match a localized date string following the specified format
    /// and capture the string as a `Date`.
    ///
    /// - Parameters:
    ///   - format: The date format that describes the localized date string. For example,
    ///     `"\(month: .twoDigits)_\(day: .twoDigits)_\(year: .twoDigits)"` matches `"05_04_22"`
    ///     as May 4th, 2022 in the Gregorian calendar.
    ///   - locale: The locale of the date string to be matched.
    ///   - timeZone: The time zone to create the matched date with.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar
    ///     of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func _polyfill_date(
        format: _polyfill_DateFormatString,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil,
        twoDigitStartDate: Foundation.Date = .init(timeIntervalSince1970: 0)
    ) -> Self {
        .init(
            format: format.rawFormat,
            locale: locale,
            timeZone: timeZone,
            calendar: calendar ?? locale.calendar,
            isLenient: false,
            twoDigitStartDate: twoDigitStartDate
        )
    }

    /// Creates a regex component to match a localized date and time string and capture the string as
    /// a `Date`. The date string is expected to follow the format of what
    /// `Date.FormatStyle(date:time:locale:calendar:)` produces.
    ///
    /// - Parameters:
    ///   - date: The style that describes the date part of the string. For example, `.numeric` matches
    ///     `"10/21/2015"`, and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US`
    ///     locale.
    ///   - time: The style that describes the time part of the string.
    ///   - locale: The locale of the string to be matched.
    ///   - timeZone: The time zone to create the matched date with. Ignored if the string contains a time
    ///     zone and matches the specified style.
    ///   - calendar: The calendar with which to interpret the date string. If set to nil, the default
    ///     calendar of the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    ///
    /// > Note: If the string contains a time zone and matches the specified style, then the `timeZone`
    /// > argument is ignored. For example, "Oct 21, 2015 4:29:24 PM PDT" matches
    /// > `.dateTime(date: .abbreviated, time: .complete, ...)` and is captured as
    /// > `October 13, 2022, 20:29:24 PDT` regardless of the `timeZone` value.
    public static func _polyfill_dateTime(
        date: _polyfill_DateFormatStyle.DateStyle,
        time: _polyfill_DateFormatStyle.TimeStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Self {
        .init(formatStyle: .init(
            date: date,
            time: time,
            locale: locale,
            calendar: calendar ?? locale.calendar,
            timeZone: timeZone
        ), lenient: false)
    }

    /// Creates a regex component to match a localized date string and capture the string as a `Date`.
    /// The string is expected to follow the format of what `Date.FormatStyle(date:locale:calendar:)`
    /// produces. `Date` created by this regex component would be at `00:00:00` in the specified time zone.
    ///
    /// - Parameters:
    ///   - style: The style that describes the date string. For example, `.numeric` matches `"10/21/2015"`,
    ///     and `.abbreviated` matches `"Oct 21, 2015"` as October 21, 2015 in the `en_US` locale.
    ///     `.omitted` is invalid.
    ///   - locale: The locale of the string to be matched. Generally speaking, the language of the locale
    ///     is used to parse the date parts if the string contains localized numbers or words, and the region
    ///     of the locale specifies the order of the date parts. For example, `"3/5/2015"` represents
    ///     March 5th, 2015 in `en_US`, but represents May 3rd, 2015 in `en_GB`.
    ///   - timeZone: The time zone to create the matched date with. For example, parsing `"Oct 21, 2015"`
    ///     with the `PDT` time zone returns a date representing October 21, 2015 at 00:00:00 PDT.
    ///   - calendar: The calendar with which to interpret the date string. If nil, the default calendar of
    ///     the specified `locale` is used.
    /// - Returns: A `RegexComponent` to match a localized date string.
    public static func _polyfill_date(
        _ style: _polyfill_DateFormatStyle.DateStyle,
        locale: Foundation.Locale,
        timeZone: Foundation.TimeZone,
        calendar: Foundation.Calendar? = nil
    ) -> Self {
        .init(formatStyle: .init(
            date: style,
            locale: locale,
            calendar: calendar ?? locale.calendar,
            timeZone: timeZone
        ), lenient: false)
    }
}

extension _polyfill_DateFormatStyle: _polyfill_ParseStrategy {
    /// Parses a string into a date.
    /// 
    /// - Parameter value: The string to parse.
    /// - Returns: An instance of `Date` parsed from the input string.
    ///
    /// The `parse(_:)` instance method attempts to parse a provided string into an instance of date using the
    /// source date format style. The function throws an error if it can’t parse the input string into a
    /// date instance.
    ///
    /// The date format style guides parsing the date instance from an input string, as the example below
    /// illustrates.
    ///
    /// ```swift
    /// let birthdayFormatStyle = Date.FormatStyle()
    ///     .year(.defaultDigits)
    ///     .month(.abbreviated)
    ///     .day(.twoDigits)
    ///     .hour(.defaultDigits(amPM: .abbreviated))
    ///     .minute(.twoDigits)
    ///     .timeZone(.identifier(.long))
    ///     .era(.abbreviated)
    ///     .weekday(.abbreviated)
    ///
    /// let yourBirthdayString = "Mon, Feb 17, 1997 AD, 1:27 AM America/Chicago"
    ///
    /// // Create a date instance from a string representation of a date.
    /// let yourBirthday = try? birthdayFormatStyle.parse(yourBirthdayString)
    /// // Feb 17, 1997 at 1:27 AM
    /// ```
    public func parse(_ value: String) throws -> Foundation.Date {
        guard let date = ICUDateFormatter.cachedFormatter(for: self).parse(value) else {
            throw parseError(value, examples: ICUDateFormatter.cachedFormatter(for: self).format(.now))
        }
        return date
    }
}

extension _polyfill_DateFormatStyle: _polyfill_ParseableFormatStyle {
    /// The strategy used to parse a string into a date.
    public var parseStrategy: _polyfill_DateFormatStyle {
        self
    }
}

extension _polyfill_ParseableFormatStyle where Self == _polyfill_DateFormatStyle {
    /// A factory variable used as a base for custom date format styles.
    ///
    /// Customize the date format style using modifier syntax to apply specific date and time formats. For example:
    ///
    /// ```swift
    /// let meetingDate = Date()
    /// let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
    /// for localeID in localeArray {
    ///     print(meetingDate.formatted(.dateTime
    ///         .day(.twoDigits).month(.wide).weekday(.short)
    ///         .hour(.conversationalTwoDigits(amPM: .wide))
    ///         .locale(Locale(identifier: localeID)))
    ///     )
    /// }
    /// // Tu, October 27, 5 PM
    /// // ti 27 oktober 17
    /// // Tu 27 October, 17
    /// // อ. 27 ตุลาคม 17
    /// // ma 27 octobre à 17 h
    /// ```
    ///
    /// The default format styles provided are `numeric` date format and `shortened` time format. For example:
    ///
    /// ```swift
    /// Date().formatted(.dateTime)) // 10/28/2020, 12:13 AM
    /// ```
    public static var dateTime: Self {
        .init()
    }
}

extension _polyfill_ParseStrategy where Self == _polyfill_DateFormatStyle {
    /// A factory variable used as a base for custom date format styles.
    ///
    /// Customize the date format style using modifier syntax to apply specific date and time formats. For example:
    ///
    /// ```swift
    /// let meetingDate = Date()
    /// let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
    /// for localeID in localeArray {
    ///     print(meetingDate.formatted(.dateTime
    ///         .day(.twoDigits).month(.wide).weekday(.short)
    ///         .hour(.conversationalTwoDigits(amPM: .wide))
    ///         .locale(Locale(identifier: localeID)))
    ///     )
    /// }
    /// // Tu, October 27, 5 PM
    /// // ti 27 oktober 17
    /// // Tu 27 October, 17
    /// // อ. 27 ตุลาคม 17
    /// // ma 27 octobre à 17 h
    /// ```
    ///
    /// The default format styles provided are `numeric` date format and `shortened` time format. For example:
    ///
    /// ```swift
    /// Date().formatted(.dateTime)) // 10/28/2020, 12:13 AM
    /// ```
    @_disfavoredOverload
    public static var dateTime: Self {
        .init()
    }
}

extension Foundation.Date {
    /// Creates a new `Date` by parsing the given representation.
    ///
    /// - Parameters:
    ///   - value: A representation of a date. The type of the representation is specified by
    ///     `ParseStrategy.ParseInput`.
    ///   - strategy: The parse strategy to parse `value` whose `ParseOutput` is `Date`.
    public init<T: _polyfill_ParseStrategy>(
        _ value: T.ParseInput,
        _polyfill_strategy: T
    ) throws
        where T: _polyfill_ParseStrategy, T.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(value)
    }

    /// Creates a new `Date` by parsing the given string representation.
    ///
    /// - Parameters:
    ///   - value: A representation of a date. The type of the representation is `StringProtocol`.
    ///   - strategy: The parse strategy to parse `value` whose `ParseOutput` is `Date`.
    @_disfavoredOverload
    public init<T>(
        _ value: some StringProtocol,
        _polyfill_strategy: T
    ) throws
        where T: _polyfill_ParseStrategy, T.ParseInput == String, T.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(String(value))
    }
}
