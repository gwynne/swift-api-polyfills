import struct Foundation.Date
import struct Foundation.TimeZone

/// A type that converts between dates and their ISO-8601 string representations.
///
/// The ``ISO8601FormatStyle`` type generates and parses string representations of dates following
/// the ISO-8601 standard, like `2024-04-01T12:34:56.789Z`. Use this type to create ISO-8601
/// representations of dates and create dates from text strings in ISO 8601 format. For other formatting
/// conventions, like human-readable, localized date formats, use ``FormatStyle``.
///
/// Instance modifier methods applied to an ISO-8601 format style customize the formatted output, as
/// the following example illustrates.
///
/// ```swift
/// let now = Date()
/// print(now.formatted(Date.ISO8601FormatStyle().dateSeparator(.dash)))
/// // 2021-06-21T211015Z
/// ```
///
/// Use the static factory property `iso8601` to create an instance of ``ISO8601FormatStyle``. Then
/// apply instance modifier methods to customize the format, as in the example below.
///
/// ```swift
/// let meetNow = Date()
/// let formatted = meetNow.formatted(.iso8601
///     .year()
///     .month()
///     .day()
///     .timeZone(separator: .omitted)
///     .time(includingFractionalSeconds: true)
///     .timeSeparator(.colon)
/// ) // "2022-06-10T12:34:56.789Z"
/// ```
public struct _polyfill_DateISO8601FormatStyle: Sendable {
    /// A type describing the character separating the time and time zone of a date in an ISO 8601 date format.
    public enum TimeZoneSeparator: String, Codable, Sendable {
        /// Specifies a colon character separating the time and time zone in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `colon` is “`:`”.
        case colon = ":"
        
        /// Specifies no separator between the time and time zone in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `omitted` is an empty string (“”).
        case omitted = ""
    }

    /// A type describing the character separating year, month, and day components of a date in an ISO
    /// 8601 date format.
    public enum DateSeparator: String, Codable, Sendable {
        /// Specifies a dash character separating year, month, and day components in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `dash` is “`-`”.
        case dash = "-"
        
        /// Specifies no separator between the year, month, and day components in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `omitted` is an empty string (“”).
        case omitted = ""
    }
    
    /// Type describing the character separating the time components of a date in an ISO 8601 date format.
    public enum TimeSeparator: String, Codable, Sendable {
        /// Specifies a colon character separating the time components in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `colon` is “`:`”.
        case colon = ":"
        
        /// Specifies no separator between the time components in an ISO 8601 date format style.
        ///
        /// The `rawValue` of `omitted` is an empty string (“”).
        case omitted = ""
    }
    
    /// Type describing the character separating the date and time components of a date in an ISO 8601 date format.
    public enum DateTimeSeparator: String, Codable, Sendable {
        /// Specifies a space character separating date and time components in an ISO 8601 date format style.
        case space = " "
        
        /// Specifies the standard `T` separator between the date and time components in an ISO 8601 date format
        /// style.
        case standard = "'T'"
    }
    
    /// The character used to separate the time components of the ISO 8601 string representation of a date.
    public private(set) var timeSeparator: TimeSeparator
    
    public private(set) var includingFractionalSeconds: Bool
    
    /// The character used to separate the time and time zone components of the ISO 8601 string representation
    /// of a date.
    public private(set) var timeZoneSeparator: TimeZoneSeparator
    
    /// The character used to separate year, month, and day components of the ISO 8601 string representation of a date.
    public private(set) var dateSeparator: DateSeparator
    
    /// The character used to separate the date and time components of the ISO 8601 string representation of a date.
    public private(set) var dateTimeSeparator: DateTimeSeparator

    /// The time zone to use to create and parse date representations.
    ///
    /// The default time zone is Greenwich Mean Time (GMT).
    public var timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!

    /// Creates an instance using the provided date separator, date and time components separator, and time zone.
    ///
    /// - Parameters:
    ///   - dateSeparator: The separator character used between the year, month, and day.
    ///   - dateTimeSeparator: The separator character used between the date and time components.
    ///   - timeZone: The `TimeZone` used to create the string representation of the date.
    ///
    /// Possible values of `dateSeparator` are `dash` and `omitted`. Omitted is the default.
    ///
    /// Possible values of `dateTimeSeparator` are `space` and `standard`. Standard is the default.
    ///
    /// The following example shows the initializer called with a variety of input parameters.
    ///
    /// ```swift
    /// let aDate = Date()
    /// print(aDate) // 2021-06-22 17:21:32 +0000
    /// print(aDate.formatted(Date.ISO8601FormatStyle(dateSeparator: .omitted, dateTimeSeparator: .standard)))
    /// // 20210622T172132Z
    ///
    /// let cstDate = Date()
    /// if let centralStandardTimeZone = TimeZone(identifier: "CST") {
    ///    print(cstDate.formatted(Date.ISO8601FormatStyle(dateSeparator: .dash, dateTimeSeparator: .space, timeZone: centralStandardTimeZone)))
    /// }
    /// // 2021-06-22 122132-0500
    /// ```
    @_disfavoredOverload
    public init(
        dateSeparator: DateSeparator = .dash,
        dateTimeSeparator: DateTimeSeparator = .standard,
        timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!
    ) {
        self.dateSeparator = dateSeparator
        self.dateTimeSeparator = dateTimeSeparator
        self.timeZone = timeZone
        self.timeSeparator = .colon
        self.timeZoneSeparator = .omitted
        self.includingFractionalSeconds = false
    }

    /// Creates an instance using the provided date separator, date and time components separator, time separator,
    /// time and time zone separator, fractional seconds flag, and time zone.
    /// 
    /// Possible values of `dateSeparator` are `dash` and `omitted`. Omitted is the default.
    ///
    /// Possible values of `dateTimeSeparator` are `space` and `standard`. Standard is the default.
    ///
    /// Possible values of `timeSeparator` are `colon` and `omitted`. Colon is the default.
    ///
    /// Possible values of `timeZoneSeparator` are `colon` and `omitted`. Omitted is the default.
    ///
    /// - Parameters:
    ///   - dateSeparator: The separator character used between the year, month, and day.
    ///   - dateTimeSeparator: The separator character used between the date and time components.
    ///   - timeSeparator: The separator character used between the hour, minutes, and second.
    ///   - timeZoneSeparator: The separator character used between the time and time zone components.
    ///   - includingFractionalSeconds: Whether the seconds component is rounded to the nearest second.
    ///   - timeZone: The `TimeZone` used to create the string representation of the date.
    public init(
        dateSeparator: DateSeparator = .dash,
        dateTimeSeparator: DateTimeSeparator = .standard,
        timeSeparator: TimeSeparator = .colon,
        timeZoneSeparator: TimeZoneSeparator = .omitted,
        includingFractionalSeconds: Bool = false,
        timeZone: Foundation.TimeZone = .init(secondsFromGMT: 0)!
    ) {
        self.dateSeparator = dateSeparator
        self.dateTimeSeparator = dateTimeSeparator
        self.timeZone = timeZone
        self.timeSeparator = timeSeparator
        self.timeZoneSeparator = timeZoneSeparator
        self.includingFractionalSeconds = includingFractionalSeconds
    }
    
    enum Field: Int, Codable, Hashable, Comparable {
        case year
        case month
        case weekOfYear
        case day
        case time
        case timeZone

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    private var _formatFields: Set<Field> = []
    
    private var formatFields: Set<Field> {
        !self._formatFields.isEmpty ? self._formatFields : [.year, .month, .day, .time, .timeZone]
    }
    
    private var dayFormat: String {
        self.formatFields.contains(.weekOfYear) ? "ee" : (self.formatFields.contains(.month) ? "dd" : "DDD")
    }
    
    private var format: String {
        self.formatFields.sorted().flatMap {
            switch $0 {
            case .year:       ["", self.formatFields.contains(.weekOfYear) ? "YYYY" : "yyyy"]
            case .month:      [self.dateSeparator.rawValue, "MM"]
            case .weekOfYear: [self.dateSeparator.rawValue, "'W'ww"]
            case .day:        [self.dateSeparator.rawValue, self.dayFormat]
            case .time:       [
                self.dateTimeSeparator.rawValue,
                ["HH", "mm", "ss"].joined(separator: self.timeSeparator.rawValue),
                self.includingFractionalSeconds ? ".SSS" : ""
            ]
            case .timeZone:   ["", "XXXX\(self.timeZoneSeparator == .colon ? "X" : "")"]
            }
        }.dropFirst().joined()
    }

    private var formatter: ICUDateFormatter {
        .cachedFormatter(for: .init(
            localeIdentifier: "en_US_POSIX",
            timeZoneIdentifier: self.timeZone.identifier,
            calendarIdentifier: .gregorian,
            firstWeekday: 2,
            minimumDaysInFirstWeek: 4,
            capitalizationContext: .unknown,
            pattern: self.format,
            parseLenient: false
        ))
    }
}

extension _polyfill_DateISO8601FormatStyle {
    /// Modifies the ISO 8601 date format style to include the year in the formatted output.
    ///
    /// This example shows an ISO 8601 format with, and without, a year.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 12:51 PM
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    /// )
    /// // 20210623
    ///
    /// meetingDate.formatted(.iso8601
    ///     .month()
    ///     .day()
    /// )
    /// // 0623
    /// ```
    ///
    /// The default `Date.ISO8601FormatStyle` includes the year.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Returns: An ISO 8601 date format style modified to include the year.
    public func year() -> Self {
        var new = self
        new._formatFields.insert(.year)
        return new
    }
    
    /// Modifies the ISO 8601 date format style to include the week of the year in the formatted output.
    ///
    /// The following example shows an ISO 8601 format with, and without, a week of the year.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 12:51 PM
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .weekOfYear()
    /// ) // 202106W25
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .weekOfYear()
    /// ) // 202106W2504
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .day()
    ///     .weekOfYear()
    /// ) // 2021W2504
    /// ```
    ///
    /// When the format style includes the week of year, the output represents the day as the ordinal day of
    /// the week.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Returns: An ISO 8601 date format style modified to include the week of the year.
    public func weekOfYear() -> Self {
        var new = self
        new._formatFields.insert(.weekOfYear)
        return new
    }
    
    /// Modifies the ISO 8601 date format style to include the month in the formatted output.
    ///
    /// The following example shows an ISO 8601 format with, and without, a month.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 12:51 PM
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .day()
    /// )
    /// // 2021174
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    /// )
    /// // 20210623
    /// ```
    ///
    /// If `month()` isn’t included in the format but `day()` is, the format represents the day as the ordinal date.
    ///
    /// The default `Date.ISO8601FormatStyle` includes the month.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Returns: An ISO 8601 date format style modified to include the month.
    public func month() -> Self {
        var new = self
        new._formatFields.insert(.month)
        return new
    }
    
    /// Modifies the ISO 8601 date format style to include the day in the formatted output.
    ///
    /// The following example shows an ISO 8601 format with, and without, a day.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 12:51 PM
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    /// )
    /// // 202106
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .day()
    /// )
    /// // 2021174
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    /// )
    /// // 20210623
    /// ```
    ///
    /// If `month()` isn’t included in the format and `day()` is, the format represents the day as the ordinal date.
    ///
    /// The default `Date.ISO8601FormatStyle` includes the day.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Returns: An ISO 8601 date format style modified to include the day.
    public func day() -> Self {
        var new = self
        new._formatFields.insert(.day)
        return new
    }
    
    /// Modifies the ISO 8601 date format style to include the time in the formatted output.
    ///
    /// The following example shows an ISO 8601 format with, and without, a time and fractional seconds.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 24, 2021 at 6:52 AM
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .time(includingFractionalSeconds: false)
    /// )
    /// // 20210624T115209
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .time(includingFractionalSeconds: true)
    /// )
    /// // 2021T115209.274
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .dateSeparator(.dash)
    ///     .time(includingFractionalSeconds: true)
    ///     .timeSeparator(.colon)
    /// )
    /// // 2021-06-24T11:52:09.274
    ///
    /// meetingDate.formatted(.iso8601
    ///     .year()
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .dateSeparator(.dash)
    ///     .time(includingFractionalSeconds: false)
    ///     .timeSeparator(.colon)
    ///     .dateTimeSeparator(.space)
    /// )
    /// // 2021-06-24 11:52:09
    /// ```
    ///
    /// The default `Date.ISO8601FormatStyle` includes the time but not the fractional seconds.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Parameter includingFractionalSeconds: Specifies whether the format style inclues the fractional
    ///   component of the seconds.
    /// - Returns: An ISO 8601 date format style modified to include the time.
    public func time(includingFractionalSeconds: Bool) -> Self {
        var new = self
        new._formatFields.insert(.time)
        new.includingFractionalSeconds = includingFractionalSeconds
        return new
    }
    
    /// Modifies the ISO 8601 date format style to include the time zone in the formatted output.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    ///
    /// - Parameter separator: Character used to separate the time and time zone in a date.
    /// - Returns: An ISO 8601 date format style modified to include the time zone.
    public func timeZone(separator: TimeZoneSeparator) -> Self {
        var new = self
        new._formatFields.insert(.timeZone)
        new.timeZoneSeparator = separator
        return new
    }
    
    /// Modifies the ISO 8601 date format style to use the specified date separator.
    ///
    /// Possible values of `Date.ISO8601FormatStyle.DateSeparator` are `dash` and `omitted`.
    ///
    /// The following example shows a variety of `Date.ISO8601FormatStyle.DateSeparator` formats applied to an
    /// ISO 8601 date format.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 6:13 AM
    /// meetingDate.formatted(.iso8601.dateSeparator(.omitted)) // 20210623T111325Z
    /// meetingDate.formatted(.iso8601.dateSeparator(.dash)) // 2021-06-23T111325Z
    /// meetingDate.formatted(.iso8601) // 20210623T111325Z
    /// ```
    ///
    /// If no format is specified as a parameter, the `omitted` case is the default format.
    ///
    /// For more information about ISO 8601 formatted dates, see the `Date.ISO8601FormatStyle`.
    ///
    /// - Parameter separator: Character used to separate the year, month, and day in a date.
    /// - Returns: An ISO 8601 date format style modified to include the specified date separator style.
    public func dateSeparator(_ separator: DateSeparator) -> Self {
        var new = self
        new.dateSeparator = separator
        return new
    }
    
    /// Sets the character that specifies the date and time components.
    ///
    /// Possible values of `Date.ISO8601FormatStyle.DateTimeSeparator` are `space` and `standard`.
    ///
    /// The following example shows a variety of `Date.ISO8601FormatStyle.DateTimeSeparator` formats applied to
    /// an ISO 8601 date format.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 10:21 AM
    /// meetingDate.formatted(.iso8601.dateSeparator(.omitted)) // 20210623 152135Z
    /// meetingDate.formatted(.iso8601.dateSeparator(.dash)) // 20210623T152135Z
    /// meetingDate.formatted(.iso8601) // 20210623T152135Z
    /// ```
    ///
    /// If no format is specified as a parameter, the `standard` case is the default format.
    ///
    /// For more information about ISO 8601 formatted dates, see the `Date.ISO8601FormatStyle`.
    ///
    /// - Parameter separator: Possible values are `space` and `standard`.
    /// - Returns: An ISO 8601 date format style with the provided date and time component separator.
    public func dateTimeSeparator(_ separator: DateTimeSeparator) -> Self {
        var new = self
        new.dateTimeSeparator = separator
        return new
    }
    
    /// Modifies the ISO 8601 date format style to use the specified time separator.\
    ///
    /// Possible values of `Date.ISO8601FormatStyle.TimeSeparator` are `colon` and `omitted`.
    ///
    /// This example shows a variety of ISO 8601 time separator formats applied to an ISO 8601 date format:
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 23, 2021 at 1:41 PM
    /// meetingDate.formatted(.iso8601.timeSeparator(.omitted)) // 20210623T184148Z
    /// meetingDate.formatted(.iso8601.timeSeparator(.colon)) // 20210623T18:41:48Z
    /// meetingDate.formatted(.iso8601) // 20210623T184148Z
    /// ```
    ///
    /// If no format is specified as a parameter, the `omitted` case is the default format.
    ///
    /// For more information about ISO 8601 formatted dates, see the `Date.ISO8601FormatStyle`.
    ///
    /// - Parameter separator: Character used to separate the hour and minute in a date.
    /// - Returns: An ISO 8601 date format style modified to include the specified time separator style.
    public func timeSeparator(_ separator: TimeSeparator) -> Self {
        var new = self
        new.timeSeparator = separator
        return new
    }
    
    /// Modifies the ISO 8601 date format style to use the specified time zone separator.
    ///
    /// Possible values of `Date.ISO8601FormatStyle.TimeZoneSeparator` are `colon` and `omitted`.
    ///
    /// For more information about ISO 8601 formatted dates, see the `Date.ISO8601FormatStyle`.
    ///
    /// - Parameter separator: Character used to separate the time and time zone in a date.
    /// - Returns: An ISO 8601 date format style modified to include the specified time zone separator style.
    public func timeZoneSeparator(_ separator: TimeZoneSeparator) -> Self {
        var new = self
        new.timeZoneSeparator = separator
        return new
    }
}

extension _polyfill_DateISO8601FormatStyle: _polyfill_FormatStyle {
    /// Creates a locale-aware ISO 8601 string representation from a date value.
    ///
    /// The `format(_:)` instance method generates a ISO 8601 formatted string from the provided date. Once you
    /// create a style, you can use it to format dates multiple times.
    ///
    /// In the following example, a format style is created to guide parsing a set of string representations of
    /// dates. Another format style is created and applied repeatedly to produce customized ISO 8601 string
    /// representations of those dates for a different locale.
    ///
    /// ```swift
    /// let input8601Format = Date.ISO8601FormatStyle()
    ///     .dateSeparator(.dash)
    ///     .year()
    ///     .month()
    ///     .day()
    ///
    /// // Parse dates from strings using the input format defined above.
    /// let introDate01 = try? Date("2007-01-09", strategy: input8601Format)
    /// let introDate02 = try? Date("2010-01-27", strategy: input8601Format)
    /// let meetingDate2021 = try? Date("2021-06-07", strategy: input8601Format)
    ///
    /// let outputFormat = Date.ISO8601FormatStyle() // define format style for string output
    ///     .locale(Locale(identifier: "en_US"))
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .weekOfYear()
    ///
    /// // Apply the output format to the three dates below.
    /// if let meet2021 = meetingDate2021 {
    ///     print(outputFormat.format(meet2021))
    /// }
    /// // 202106W2301
    /// if let intro02 = introDate02 {
    ///     print(outputFormat.format(intro02))
    /// }
    /// // 201001W0403
    /// if let intro01 = introDate01 {
    ///     print(outputFormat.format(intro01))
    /// }
    /// // 200701W0202
    /// ```
    ///
    /// - Parameter value: The date to format.
    /// - Returns: A string ISO 8601 representation of the date.
    public func format(_ value: Foundation.Date) -> String {
        self.formatter.format(value) ?? value.description
    }
}

extension _polyfill_DateISO8601FormatStyle: _polyfill_ParseStrategy {
    /// Parses a string into a date.
    ///
    /// This method attempts to parse a provided string into an instance of date using the source date
    /// format style. The function throws an error if it can’t parse the input string into a date instance.
    ///
    /// The date format style guides parsing the date instance from an input string, as the following
    /// example illustrates.
    ///
    /// ```swift
    /// let birthdayFormatStyle = Date.ISO8601FormatStyle()
    ///     .dateSeparator(.dash)
    ///     .timeSeparator(.colon)
    ///     .year()
    ///     .month()
    ///     .day()
    ///     .time(includingFractionalSeconds: false)
    ///
    /// // Create a date instance from a string representation of a date.
    /// let yourBirthdayString = "2021-02-17T14:33:25"
    /// let yourBirthday = try? birthdayFormatStyle.parse(yourBirthdayString)
    /// // Feb 17, 2021 at 8:33 AM
    /// ```
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: An instance of `Date` parsed from the input string.
    public func parse(_ value: String) throws -> Foundation.Date {
        guard let date = self.formatter.parse(value) else {
            throw parseError(value, examples: self.formatter.format(.now))
        }
        
        return date
    }
}

extension _polyfill_DateISO8601FormatStyle: _polyfill_ParseableFormatStyle {
    /// The strategy used to parse a string into a date.
    public var parseStrategy: Self {
        self
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DateISO8601FormatStyle {
    /// A convenience factory variable that provides a base format for customizing ISO 8601 date format styles.
    ///
    /// Customize the base date format style using modifier methods to apply specific date and time formats, as
    /// shown in the example below.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 24, 2021 at 7:27 AM
    /// meetingDate.formatted(.iso8601.dateSeparator(.dash).dateTimeSeparator(.space))
    /// // 2021-06-24 122744Z
    ///
    /// meetingDate.formatted(.iso8601
    ///     .month()
    ///     .day()
    ///     .dateSeparator(.omitted)
    ///     .time(includingFractionalSeconds: false)
    ///     .timeSeparator(.colon)
    ///     .dateTimeSeparator(.standard)
    /// )
    /// // 0624T12:27:44
    /// ```
    public static var iso8601: Self {
        .init()
    }
}

extension _polyfill_ParseableFormatStyle where Self == _polyfill_DateISO8601FormatStyle {
    /// A convenience factory variable that provides a base format for customizing ISO 8601 date format styles.
    ///
    /// Customize the base date format style using modifier methods to apply specific date and time formats, as
    /// shown in the example below.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 24, 2021 at 7:27 AM
    /// meetingDate.formatted(.iso8601.dateSeparator(.dash).dateTimeSeparator(.space))
    /// // 2021-06-24 122744Z
    ///
    /// meetingDate.formatted(.iso8601
    ///     .month()
    ///     .day()
    ///     .dateSeparator(.omitted)
    ///     .time(includingFractionalSeconds: false)
    ///     .timeSeparator(.colon)
    ///     .dateTimeSeparator(.standard)
    /// )
    /// // 0624T12:27:44
    /// ```
    public static var iso8601: Self {
        .init()
    }
}

extension _polyfill_ParseStrategy where Self == _polyfill_DateISO8601FormatStyle {
    /// A convenience factory variable that provides a base format for customizing ISO 8601 date format styles.
    ///
    /// Customize the base date format style using modifier methods to apply specific date and time formats, as
    /// shown in the example below.
    ///
    /// ```swift
    /// let meetingDate = Date() // Jun 24, 2021 at 7:27 AM
    /// meetingDate.formatted(.iso8601.dateSeparator(.dash).dateTimeSeparator(.space))
    /// // 2021-06-24 122744Z
    ///
    /// meetingDate.formatted(.iso8601
    ///     .month()
    ///     .day()
    ///     .dateSeparator(.omitted)
    ///     .time(includingFractionalSeconds: false)
    ///     .timeSeparator(.colon)
    ///     .dateTimeSeparator(.standard)
    /// )
    /// // 0624T12:27:44
    /// ```
    @_disfavoredOverload
    public static var iso8601: Self {
        .init()
    }
}

extension Foundation.Date {
    /// Generates a locale-aware string representation of a date using the ISO 8601 date format.
    ///
    /// Calling this method is equivalent to passing a `Date.ISO8601FormatStyle` to a date’s `formatted()` method.
    ///
    /// - Parameter style: A customized `Date.ISO8601FormatStyle` to apply. By default, the method applies an
    ///   unmodified ISO 8601 format style.
    /// - Returns: A string, formatted according to the specified style.
    public func _polyfill_ISO8601Format(_ style: _polyfill_DateISO8601FormatStyle = .init()) -> String {
        style.format(self)
    }
}

extension _polyfill_DateISO8601FormatStyle: CustomConsumingRegexComponent {
    // See `RegexComponent.RegexOutput`.
    public typealias RegexOutput = Foundation.Date
    
    // See `CustomConsumingRegexComponents.consuming(_:startingAt:in:)`.
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Foundation.Date)? {
        guard index < bounds.upperBound else { return nil }
        
        return self.formatter.parse(input, in: index..<bounds.upperBound)
    }
}

extension RegexComponent where Self == _polyfill_DateISO8601FormatStyle {
    /// Creates a regex component to match an ISO 8601 date and time, such as "2015-11-14'T'15:05:03'Z'",
    /// and capture the string as a `Date` using the time zone as specified in the string.
    @_disfavoredOverload
    public static var _polyfill_iso8601: Self {
        .init()
    }

    /// Creates a regex component to match an ISO 8601 date and time string, including time zone, and
    /// capture the string as a `Date` using the time zone as specified in the string.
    ///
    /// - Parameters:
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    ///   - timeZoneSeparator: The separator between time parts in the time zone.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string, including time zone.
    public static func _polyfill_iso8601WithTimeZone(
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon,
        timeZoneSeparator: Self.TimeZoneSeparator = .omitted
    ) -> Self {
        .init(
            dateSeparator: dateSeparator,
            dateTimeSeparator: dateTimeSeparator,
            timeSeparator: timeSeparator,
            timeZoneSeparator: timeZoneSeparator,
            includingFractionalSeconds: includingFractionalSeconds
        )
    }

    /// Creates a regex component to match an ISO 8601 date and time string without time zone, and
    /// capture the string as a `Date` using the specified `timeZone`. If the string contains time
    /// zone designators, matches up until the start of time zone designators.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - includingFractionalSeconds: Specifies if the string contains fractional seconds.
    ///   - dateSeparator: The separator between date components.
    ///   - dateTimeSeparator: The separator between date and time parts.
    ///   - timeSeparator: The separator between time components.
    /// - Returns: A `RegexComponent` to match an ISO 8601 string.
    public static func _polyfill_iso8601(
        timeZone: Foundation.TimeZone,
        includingFractionalSeconds: Bool = false,
        dateSeparator: Self.DateSeparator = .dash,
        dateTimeSeparator: Self.DateTimeSeparator = .standard,
        timeSeparator: Self.TimeSeparator = .colon
    ) -> Self {
        .init(timeZone: timeZone)
            .year()
            .month()
            .day()
            .time(includingFractionalSeconds: includingFractionalSeconds)
            .timeSeparator(timeSeparator)
            .dateSeparator(dateSeparator)
            .dateTimeSeparator(dateTimeSeparator)
    }

    /// Creates a regex component to match an ISO 8601 date string, such as "2015-11-14", and
    /// capture the string as a `Date`. The captured `Date` would be at midnight in the specified `timeZone`.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to create the captured `Date` with.
    ///   - dateSeparator: The separator between date components.
    /// - Returns:  A `RegexComponent` to match an ISO 8601 date string, including time zone.
    public static func _polyfill_iso8601Date(
        timeZone: Foundation.TimeZone,
        dateSeparator: Self.DateSeparator = .dash
    ) -> Self {
        .init(dateSeparator: dateSeparator, timeZone: timeZone).year().month().day()
    }
}
