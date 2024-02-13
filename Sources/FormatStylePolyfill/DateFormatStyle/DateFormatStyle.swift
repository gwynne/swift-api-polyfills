import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale
import struct Foundation.TimeZone
import CLegacyLibICU
import PolyfillCommon

/// A structure that creates a locale-appropriate string representation of a date instance and
/// converts strings of dates and times into date instances.
///
/// A date format style shares the date and time formatting pattern preferred by the user’s locale
/// for formatting and parsing.
///
/// When you want to apply a specific formatting style to a single `Date` instance, use
/// ``FormatStyle``. For other instances, use the following:
///
/// - When working with date representations in ISO 8601 format, use ``ISO8601FormatStyle``.
/// - To represent an interval between two date instances, use ``RelativeFormatStyle``.
/// - To represent two dates as a pair, for example to get output that looks like
///   `10/21/1985 1:45 PM - 9/13/2015 6:33 PM`, use ``IntervalFormatStyle``.
///
/// ## Formatting String Representations of Dates and Times
///
/// ``FormatStyle`` provides a variety of localized presets and configuration options to create
/// user-visible representations of dates and times from instances of `Date`.
///
/// When displaying a date to a user, use the `formatted(date:time:)` instance method. Set the date
/// and time styles of the date format style separately, according to your particular needs.
///
/// For example, to create a string with a full date and no time representation, set the
/// ``FormatStyle/DateStyle`` to ``FormatStyle/DateStyle/complete`` and the ``FormatStyle/TimeStyle``
/// to ``FormatStyle/DateStyle/omitted``. Conversely, to create a string representing only the time
/// for the current locale and time zone, set the date style to ``FormatStyle/DateStyle/omitted`` and
/// the time style to ``FormatStyle/TimeStyle/complete``, as the following code illustrates:
///
/// ```swift
/// let birthday = Date()
///
/// birthday.formatted(date: .complete, time: .omitted) // Sunday, January 17, 2021
/// birthday.formatted(date: .omitted, time: .complete) // 4:03:12 p.m. CST
/// ```
///
/// The results shown are for locale set to `en_US` and time zone set to `CST`.
///
/// You can create string representations of a `Date` instance with various levels of brevity
/// using preset date and time styles. The following example shows date styles of
/// ``FormatStyle/DateStyle/long``, ``FormatStyle/DateStyle/abbreviated``,
/// and ``FormatStyle/DateStyle/numeric``, and time styles of ``FormatStyle/TimeStyle/shortened``,
/// ``FormatStyle/TimeStyle/standard``, and ``FormatStyle/TimeStyle/complete``:
///
/// ```swift
/// let birthday = Date()
///
/// birthday.formatted(date: .long, time: .shortened) // January 17, 2021, 4:03 PM
/// birthday.formatted(date: .abbreviated, time: .standard) // Jan 17, 2021, 4:03:12 PM
/// birthday.formatted(date: .numeric, time: .complete) // 1/17/2021, 4:03:12 PM CST
///
/// birthday.formatted() // Jan 17, 2021, 4:03 PM
/// ```
///
/// The default date style is ``FormatStyle/DateStyle/abbreviated`` and the default time style
/// is ``FormatStyle/TimeStyle/shortened``.
///
/// For full customization of the string representation of a date, use the `formatted(_:)` instance
/// method of `Date` and provide a ``FormatStyle`` instance.
///
/// You can apply more customization of the date and time components and their representation in your
/// app by appying a series of convenience modifiers to your format style. The following example applies
/// a series of modifiers to the format style to precisely define the formatting of the year, month, day,
/// hour, minute, and timezone components of the resulting string. The ordering of the date and time
/// modifiers has no impact on the string produced.
///
/// ```swift
/// // Call the .formatted method on an instance of Date passing in an instance of Date.FormatStyle.
///
/// let birthday = Date()
///
/// birthday.formatted(
///     Date.FormatStyle()
///         .year(.defaultDigits)
///         .month(.abbreviated)
///         .day(.twoDigits)
///         .hour(.defaultDigits(amPM: .abbreviated))
///         .minute(.twoDigits)
///         .timeZone(.identifier(.long))
///         .era(.wide)
///         .dayOfYear(.defaultDigits)
///         .weekday(.abbreviated)
///         .week(.defaultDigits)
/// )
/// // Sun, Jan 17, 2021 Anno Domini (week: 4), 11:18 AM America/Chicago
/// ```
///
/// ``FormatStyle`` provides a convenient factory variable, ``FormatStyle/dateTime``, used to shorten
/// the syntax when applying date and time modifiers to customize the format, as in the following example:
///
/// ```swift
/// let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
/// for localeID in localeArray {
///     print(meetingDate.formatted(.dateTime
///              .day(.twoDigits)
///              .month(.wide)
///              .weekday(.short)
///              .hour(.conversationalTwoDigits(amPM: .wide))
///              .locale(Locale(identifier: localeID))))
/// }
///
/// // Th, November 12, 7 PM
/// // to 12 november 19
/// // Th 12 November, 19
/// // พฤ. 12 พฤศจิกายน 19
/// // je 12 novembre, 19 h
/// ```
///
/// ## Parsing Dates and Times
///
/// To parse a `Date` instance from an input string, use a date parse strategy. For example:
///
/// ```swift
/// let inputString = "Archive for month 8, archived on day 23 - complete."
/// let strategy = Date.ParseStrategy(
///     format: "Archive for month \(month: .defaultDigits), archived on day \(day: .twoDigits) - complete.",
///     locale: Locale(identifier: "en_US"),
///     timeZone: TimeZone(abbreviation: "CDT")!
/// )
/// if let date = try? Date(inputString, strategy: strategy) {
///    print(date.formatted()) // "Aug 23, 2000 at 12:00 AM"
/// }
/// ```
///
/// The time defaults to midnight local time unless explicitly defined.
///
/// The parse instance method attempts to parse a provided string into an instance of date using the
/// source date format style. The function throws an error if it can’t parse the input string into a
/// date instance.
///
/// You can use ``FormatStyle`` for round-trip formatting and parsing in a locale-aware manner. This
/// date format style guides parsing the date instance from an input string, as the following
/// code demonstrates:
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
///
/// The following round-trip date formatting example uses a date format style to create a locale-aware
/// string representation of a date instance. Then, the date format style guides parsing the newly
/// created string into a new date instance.
///
/// ```swift
/// let myFormat = Date.FormatStyle()
///     .year()
///     .day()
///     .month()
///     .locale(Locale(identifier: "en_US"))
///
/// let dateString = Date().formatted(myFormat)
/// // "Feb 17, 2021" for the "en_US" locale
///
/// print(dateString) // Feb 17, 2021
///
/// if let anniversary = try? Date(dateString, strategy: myFormat) {
///     print(anniversary.formatted(myFormat)) // Feb 17, 2021
///     print(anniversary.formatted()) // 2/17/2021, 12:00 AM
/// } else {
///     print("Can't parse string into date with this format.")
/// }
/// ```
///
/// After this code executes, `anniversary` contains a `Date` instance parsed from `dateString`.
///
/// ## Applying Format Styles Repeatedly
///
/// Once you create a date format style, you can use it to format dates multiple times.
///
/// You can use a format style to parse a set of date instances from a set of string representations
/// of dates. Then, use another format style, applied repeatedly, to produce more detailed string
/// representations of those dates for a different locale. For example:
///
/// ```swift
/// func formatIntroDates() {
///    let inputFormat = Date.FormatStyle()
///       .locale(Locale(identifier: "en_GB"))
///       .year()
///       .month()
///       .day()
///     // Parse string inputs into date instances.
///     guard let productIntroDate = try? Date("9 Jan 2007", strategy: inputFormat) else { return }
///     guard let anotherIntroDate = try? Date("27 Jan 2010", strategy: inputFormat) else { return }
///     guard let conferenceDate = try? Date("7 Jun 2021", strategy: inputFormat) else { return }
///
///     let outputFormat = Date.FormatStyle() // Define format style for string output.
///         .locale(Locale(identifier: "en_US"))
///         .year()
///         .month(.wide)
///         .day(.twoDigits)
///         .weekday(.abbreviated)
///
///     // Apply the output format on the three dates below.
///     print(outputFormat.format(conferenceDate)) // Mon, June 07, 2021
///     print(outputFormat.format(anotherIntroDate)) // Wed, January 27, 2010
///     print(outputFormat.format(productIntroDate)) // Tue, January 09, 2007
/// }
/// ```
public struct _polyfill_DateFormatStyle: Sendable, Codable, Hashable, _polyfill_FormatStyle {
    var _symbols = DateFieldCollection()
    
    var symbols: DateFieldCollection {
        self._symbols.empty ?
            DateFieldCollection().collection(date: .numeric).collection(time: .shortened) :
            self._symbols
    }

    var _dateStyle: DateStyle? // For accessing locale pref's custom date format

    /// The locale to use when formatting date and time values.
    public var locale: Foundation.Locale

    /// The time zone with which to specify date and time values.
    public var timeZone: Foundation.TimeZone

    /// The calendar to use for date values.
    public var calendar: Foundation.Calendar

    /// The capitalization formatting context used when formatting date and time values.
    public var capitalizationContext: _polyfill_FormatStyleCapitalizationContext

    var parseLenient: Bool = true

    /// Creates a new `FormatStyle` with the given configurations.
    ///
    /// - Parameters:
    ///   - date:  The date style for formatting the date.
    ///   - time:  The time style for formatting the date.
    ///   - locale: The locale to use when formatting date and time values.
    ///   - calendar: The calendar to use for date values.
    ///   - timeZone: The time zone with which to specify date and time values.
    ///   - capitalizationContext: The capitalization formatting context used when formatting date and time values.
    /// - Note: Always specify the date style, time style, or the date components to be included in the formatted string with the symbol modifiers. Otherwise, an empty string will be returned when you use the instance to format a `Date`.
    public init(
        date: DateStyle? = nil,
        time: TimeStyle? = nil,
        locale: Foundation.Locale = .autoupdatingCurrent,
        calendar: Foundation.Calendar = .autoupdatingCurrent,
        timeZone: Foundation.TimeZone = .autoupdatingCurrent,
        capitalizationContext: _polyfill_FormatStyleCapitalizationContext = .unknown
    ) {
        if let dateStyle = date {
            self._dateStyle = dateStyle
            self._symbols = self._symbols.collection(date: dateStyle)
        }
        if let timeStyle = time {
            self._symbols = self._symbols.collection(time: timeStyle)
        }
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
        self.capitalizationContext = capitalizationContext
    }

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
    public struct DateStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// A date style with no date-related components represented.
        ///
        /// If both the date style and time style are set to `omitted`, the date is represented using the default
        /// style of `abbreviated`.
        public static let omitted: Self = .init(rawValue: 0)

        /// A date style with the month, day of month, and year components represented as numeric values.
        ///
        /// A `numeric` date style represents the date components using numeric values. For example,
        /// `10/17/2020`, for locale `en_US`.
        public static let numeric: Self = .init(rawValue: 1)

        /// A date style with some components abbreviated for space-constrained applications.
        ///
        /// A shortened date style that presents an abbreviated month, day of month, and year components of a date.
        /// For example, `Oct 17, 2020`, for locale `en_US`.
        public static let abbreviated: Self = .init(rawValue: 2)

        /// A lengthened date style with the full month, day of month, and year components represented.
        ///
        /// A `long` date style represents the full date without the day of week in the format. For example,
        /// `October 17, 2020`.
        public static let long: Self = .init(rawValue: 3)

        /// A date style with all components represented.
        ///
        /// A `complete` date style represents the day, month, day of month, and year components in the format.
        /// For example, `Saturday, October 17, 2020`, for locale `en_US`.
        public static let complete: Self = .init(rawValue: 4)
    }

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
    public struct TimeStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// A time style with no time-related components represented.
        ///
        /// If both the date style and time style are set to `omitted`, the time is represented using the
        /// default style of `shortened`.
        public static let omitted: Self = .init(rawValue: 0)

        /// A shortened time style with only the hour, minute, and day period components represented.
        ///
        /// A shortened time style represents the hour, minute, and day period components in the format.
        /// For example, `9:54 PM`.
        public static let shortened: Self = .init(rawValue: 1)

        /// A time style with all components except the time zone represented.
        ///
        /// A `standard` time style represents the hour, minute, second, and day period components in the format.
        /// For example, `9:54:29 PM`.
        public static let standard: Self = .init(rawValue: 2)

        /// A time style with all components represented.
        ///
        /// A `complete` time style represents the hour, minute, second, day period, and time zone components in
        /// the format. For example, `9:54:29 PM CDT`, for locale `en_US`.
        public static let complete: Self = .init(rawValue: 3)
    }

    /// Modifies the date format style to use the specified era format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Era` include `abbreviated`, `narrow`, and `wide`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Era` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().era(.abbreviated)) // AD
    /// meetingDate.formatted(Date.FormatStyle().era(.narrow)) // A
    /// meetingDate.formatted(Date.FormatStyle().era(.wide)) // Anno Domini
    /// meetingDate.formatted(Date.FormatStyle().era()) // AD
    /// ```
    ///
    /// If you don’t provide a format, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The era format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified era style.
    public func era(_ format: Symbol.Era = .abbreviated) -> Self {
        var new = self
        new._symbols.era = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified year format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Year` include `twoDigits`, `padded(_:)`,
    /// `relatedGregorian(minimumLength:)`, and `extended(minimumLength:)`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Year` formats applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().year(.defaultDigits)) // 2021
    /// meetingDate.formatted(Date.FormatStyle().year(.twoDigits)) // 21
    /// meetingDate.formatted(Date.FormatStyle().year(.padded(6))) // 002021
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The year format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified year format style.
    public func year(_ format: Symbol.Year = .defaultDigits) -> Self {
        var new = self
        new._symbols.year = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified quarter format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Quarter` include `abbreviated`, `narrow`, `oneDigit`,
    /// `twoDigits`, and `wide`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Quarter` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Oct 7, 2020 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().quarter(.abbreviated)) // Q4
    /// meetingDate.formatted(Date.FormatStyle().quarter(.narrow)) // 4th quarter
    /// meetingDate.formatted(Date.FormatStyle().quarter(.oneDigit)) // 4
    /// meetingDate.formatted(Date.FormatStyle().quarter(.twoDigits)) // 04
    /// meetingDate.formatted(Date.FormatStyle().quarter(.wide)) // 4th quarter
    /// meetingDate.formatted(Date.FormatStyle().quarter()) // Q4
    /// ```
    ///
    /// If you don’t provide a format, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The quarter format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified quarter style.
    public func quarter(_ format: Symbol.Quarter = .abbreviated) -> Self {
        var new = self
        new._symbols.quarter = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified month format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Month` include `abbreviated`, `defaultDigits`, `narrow`,
    /// `twoDigits`, and `wide`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Month` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().month(.abbreviated)) // Feb
    /// meetingDate.formatted(Date.FormatStyle().month(.narrow)) // F
    /// meetingDate.formatted(Date.FormatStyle().month(.defaultDigits)) // 2
    /// meetingDate.formatted(Date.FormatStyle().month(.twoDigits)) // 02
    /// meetingDate.formatted(Date.FormatStyle().month(.wide)) // February
    /// meetingDate.formatted(Date.FormatStyle().month()) // Feb
    /// ```
    ///
    /// If you don’t provide a format, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The month format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified month style.
    public func month(_ format: Symbol.Month = .abbreviated) -> Self {
        var new = self
        new._symbols.month = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified week format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Week` include `defaultDigits`, `twoDigits`, and `weekOfMonth`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Week` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // May 3, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().week(.defaultDigits)) // 19
    /// meetingDate.formatted(Date.FormatStyle().week(.twoDigits)) // 19
    /// meetingDate.formatted(Date.FormatStyle().week(.weekOfMonth)) // 2
    /// meetingDate.formatted(Date.FormatStyle().week()) // 19
    /// ```
    ///
    /// An incomplete week at the start of a month is the first week of the month 1. If you don’t provide a
    /// format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The week format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified week style.
    public func week(_ format: Symbol.Week = .defaultDigits) -> Self {
        var new = self
        new._symbols.week = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified day format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Day` include `defaultDigits`, `ordinalOfDayInMonth`,
    /// and `twoDigits`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Day` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().day(.defaultDigits)) // 9
    /// meetingDate.formatted(Date.FormatStyle().day(.ordinalOfDayInMonth)) // 2 (second Tuesday of the month)
    /// meetingDate.formatted(Date.FormatStyle().day(.twoDigits)) // 09
    /// meetingDate.formatted(Date.FormatStyle().day()) // 9
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The day format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified day style.
    public func day(_ format: Symbol.Day = .defaultDigits) -> Self {
        var new = self
        new._symbols.day = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified day of the year format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.DayOfYear` include `defaultDigits`, `threeDigits`,
    /// and `twoDigits`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.DayOfYear` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.defaultDigits)) // 40
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.twoDigits)) // 40
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.threeDigits)) // 040
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear()) // 40
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The day of the year format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified day of the year style.
    public func dayOfYear(_ format: Symbol.DayOfYear = .defaultDigits) -> Self {
        var new = self
        new._symbols.dayOfYear = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified weekday format style.
    ///
    /// Possible values of `Date.FormatStyle.Symbol.Weekday` include `abbreviated`, `narrow`, `oneDigit`,
    /// `short`, `twoDigits`, and `wide`.
    ///
    /// If you don’t provide a format, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The weekday format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified weekday style.
    public func weekday(_ format: Symbol.Weekday = .abbreviated) -> Self {
        var new = self
        new._symbols.weekday = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified hour format style.
    ///
    /// Values of `Date.FormatStyle.Symbol.Hour` are `defaultDigitsNoAMPM` and `twoDigitsNoAMPM`.
    ///
    /// Static methods that return `Date.FormatStyle.Symbol.Hour` objects include
    /// `conversationalDefaultDigits(amPM:)`, `conversationalTwoDigits(amPM:)`, `defaultDigits(amPM:)`,
    /// and `twoDigitsNoAMPM`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Hour` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 7:00 PM
    /// meetingDate.formatted(Date.FormatStyle().hour(.defaultDigitsNoAMPM))
    /// // 7
    /// meetingDate.formatted(Date.FormatStyle().hour(.twoDigitsNoAMPM))
    /// // 07
    /// meetingDate.formatted(Date.FormatStyle().hour(.defaultDigits(amPM: .narrow)))
    /// // 7p
    /// meetingDate.formatted(Date.FormatStyle().hour(.twoDigits(amPM: .abbreviated))
    /// // 07 PM
    /// meetingDate.formatted(Date.FormatStyle().hour(.conversationalDefaultDigits(amPM: .wide))
    /// // 7 P.M.
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The hour format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified hour style.
    public func hour(_ format: Symbol.Hour = .defaultDigits(amPM: .abbreviated)) -> Self {
        var new = self
        new._symbols.hour = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified minute format style.
    ///
    /// Values of `Date.FormatStyle.Symbol.Minute` are `defaultDigits` and `twoDigits`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Minute` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05 PM
    /// meetingDate.formatted(Date.FormatStyle().minute(.defaultDigits)) // 5
    /// meetingDate.formatted(Date.FormatStyle().minute(.twoDigits)) // 05
    /// meetingDate.formatted(Date.FormatStyle().minute()) // 5
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The minute format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified minute style.
    public func minute(_ format: Symbol.Minute = .defaultDigits) -> Self {
        var new = self
        new._symbols.minute = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified second format style.
    ///
    /// Values of `Date.FormatStyle.Symbol.Second` are `defaultDigits` and `twoDigits`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Second` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05 PM
    /// meetingDate.formatted(Date.FormatStyle().second(.defaultDigits)) // 5
    /// meetingDate.formatted(Date.FormatStyle().second(.twoDigits)) // 05
    /// meetingDate.formatted(Date.FormatStyle().second()) // 5
    /// ```
    ///
    /// If you don’t provide a format, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The second format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified second style.
    public func second(_ format: Symbol.Second = .defaultDigits) -> Self {
        var new = self
        new._symbols.second = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified second fraction format style.
    ///
    /// Static methods that return `Date.FormatStyle.Symbol.SecondFraction` objects include
    /// `fractional(_:)` and `milliseconds(_:)`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.SecondFraction` format styles applied to a date:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05:41.827 PM
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.fractional(3))) // 827
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.fractional(1))) // 8
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.milliseconds(4))) // 11122827
    /// ```
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The second fraction format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified second fraction style.
    public func secondFraction(_ format: Symbol.SecondFraction) -> Self {
        var new = self
        new._symbols.secondFraction = format.option
        return new
    }
    
    /// Modifies the date format style to use the specified time zone format style.
    ///
    /// Values of `Date.FormatStyle.Symbol.TimeZone` are `exemplarLocation` and `genericLocation`.
    ///
    /// Static methods that return `Date.FormatStyle.Symbol.TimeZone` objects include `genericName(_:)`,
    /// `identifier(_:)`, `iso8601(_:)`, `localizedGMT(_:)`, and `specificName(_:)`.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    ///
    /// - Parameter format: The time zone format style applied to the date format style.
    /// - Returns: A date format style modified to include the specified time zone style.
    public func timeZone(_ format: Symbol.TimeZone = .specificName(.short)) -> Self {
        var new = self
        new._symbols.timeZoneSymbol = format.option
        return new
    }

    /// Creates a locale-aware string representation from a date value.
    /// 
    /// - Parameter value: The date to format.
    /// - Returns: A string representation of the date.
    ///
    /// The `format(_:)` instance method generates a string from the provided date. Once you create a style, you can
    /// use it to format dates multiple times.
    ///
    /// The following example creates a format style to guide parsing a set of string representations of dates. It
    /// also creates a second format style, applying it repeatedly to produce more detailed string representations
    /// of those dates for a different locale.
    ///
    /// ```swift
    /// let inputFormat = Date.FormatStyle()
    ///     .locale(Locale(identifier: "en_GB"))
    ///     .year()
    ///     .month()
    ///     .day()
    ///
    /// // Parse dates from strings using the input format defined above.
    /// let iphoneIntroductionDate = try! Date("9 Jan 2007", strategy: inputFormat)
    /// let ipadIntroductionDate = try! Date("27 Jan 2010", strategy: inputFormat)
    /// let wwdc2021Date = try! Date("7 Jun 2021", strategy: inputFormat)
    ///
    /// // Define a format style with the desired date fields.
    /// let outputFormat = Date.FormatStyle()
    ///     .locale(Locale(identifier: "en_US"))
    ///     .year()
    ///     .month(.wide)
    ///     .day(.twoDigits)
    ///     .weekday(.abbreviated)
    ///
    /// // Apply the output format on the three dates below.
    /// print(outputFormat.format(wwdc2021Date))
    /// // Mon, June 07, 2021
    ///
    /// print(outputFormat.format(ipadIntroductionDate))
    /// // Wed, January 27, 2010
    ///
    /// print(outputFormat.format(iphoneIntroductionDate))
    /// // Tue, January 09, 2007
    /// ```
    public func format(_ value: Foundation.Date) -> String {
        ICUDateFormatter.cachedFormatter(for: self).format(value) ?? value.description
    }
    
    /// Modifies the date format style to use the specified locale.
    ///
    /// - Parameter locale: The locale to use when formatting a date.
    /// - Returns: A date format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }

    // See `Decodable.init(from:)`.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._symbols = try container.decode(DateFieldCollection.self, forKey: .symbols)
        self._dateStyle = try container.decodeIfPresent(DateStyle.self, forKey: .dateStyle)
        self.locale = try container.decode(Foundation.Locale.self, forKey: .locale)
        self.timeZone = try container.decode(Foundation.TimeZone.self, forKey: .timeZone)
        self.calendar = try container.decode(Foundation.Calendar.self, forKey: .calendar)
        self.capitalizationContext = try container.decode(_polyfill_FormatStyleCapitalizationContext.self, forKey: .capitalizationContext)
    }

    // See `Encodable.encode(to:)`.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.symbols, forKey: .symbols)
        try container.encode(self.locale, forKey: .locale)
        try container.encode(self.timeZone, forKey: .timeZone)
        try container.encode(self.calendar, forKey: .calendar)
        try container.encode(self.capitalizationContext, forKey: .capitalizationContext)
        try container.encodeIfPresent(self._dateStyle, forKey: .dateStyle)
    }

    private enum CodingKeys: CodingKey {
        case symbols
        case locale
        case timeZone
        case calendar
        case capitalizationContext
        case dateStyle
    }
}

extension _polyfill_DateFormatStyle {
    struct DateFieldCollection: Codable, Hashable {
        var era: Symbol.Era.Option?
        var year: Symbol.Year.Option?
        var quarter: Symbol.Quarter.Option?
        var month: Symbol.Month.Option?
        var week: Symbol.Week.Option?
        var day: Symbol.Day.Option?
        var dayOfYear: Symbol.DayOfYear.Option?
        var weekday: Symbol.Weekday.Option?
        var dayPeriod: Symbol.DayPeriod.Option?
        var hour: Symbol.Hour.Option?
        var minute: Symbol.Minute.Option?
        var second: Symbol.Second.Option?
        var secondFraction: Symbol.SecondFraction.Option?
        var timeZoneSymbol: Symbol.TimeZone.Option?
    }
}

extension _polyfill_DateFormatStyle.DateFieldCollection {
    func preferredHour(withLocale locale: Foundation.Locale?) -> _polyfill_DateFormatStyle.Symbol.Hour.Option? {
        guard let hour, let locale else {
            return nil
        }
        
        guard locale.hourCycle == .zeroToEleven || locale.hourCycle == .oneToTwelve else {
            return hour
        }
        guard locale.language.languageCode == .chinese, locale.region == .taiwan else {
            return hour
        }
        
        return switch hour {
        case .defaultDigitsWithAbbreviatedAMPM: .conversationalDefaultDigitsWithAbbreviatedAMPM
        case .twoDigitsWithAbbreviatedAMPM:     .conversationalTwoDigitsWithAbbreviatedAMPM
        case .defaultDigitsWithWideAMPM:        .conversationalDefaultDigitsWithWideAMPM
        case .twoDigitsWithWideAMPM:            .conversationalTwoDigitsWithWideAMPM
        case .defaultDigitsWithNarrowAMPM:      .conversationalDefaultDigitsWithNarrowAMPM
        case .twoDigitsWithNarrowAMPM:          .conversationalTwoDigitsWithNarrowAMPM
        default:                                hour
        }
    }

    func formatterTemplate(overridingDayPeriodWithLocale locale: Locale?) -> String {
        ([
            self.era,       self.year,           self.quarter,        self.month,
            self.week,      self.day,            self.dayOfYear,      self.weekday,
            self.dayPeriod, self.preferredHour(withLocale: locale),   self.minute,
            self.second,    self.secondFraction, self.timeZoneSymbol,
        ] as [(any RawRepresentable<String>)?])
            .compactMap { $0?.rawValue }.joined()
    }

    var empty: Bool {
        self == Self()
    }

    func collection(date len: _polyfill_DateFormatStyle.DateStyle) -> Self {
        var new = self
        
        new.day = .defaultDigits
        new.year = .padded(1)
        switch len {
        case .numeric:     new.month = .defaultDigits
        case .abbreviated: new.month = .abbreviated
        case .complete:    new.weekday = .wide; fallthrough
        case .long:        new.month = .wide
        case .omitted, _: return self
        }
        return new
    }

    func collection(time len: _polyfill_DateFormatStyle.TimeStyle) -> Self {
        var new = self
        
        if len == .omitted {
            return new
        }
        new.hour = .defaultDigitsWithAbbreviatedAMPM
        new.minute = .twoDigits
        if len == .standard {
            new.second = .twoDigits
        } else if len == .complete {
            new.second = .twoDigits
            new.timeZoneSymbol = .shortSpecificName
        }
        return new
    }
}

extension Foundation.Date {
    /// Converts `self` to its textual representation.
    ///
    /// - Parameter format: The format for formatting `self`.
    /// - Returns: A representation of `self` using the given `format`. The type of the representation is specified by `FormatStyle.FormatOutput`.
    public func _polyfill_formatted<F>(
        _ format: F
    ) -> F.FormatOutput
        where F: _polyfill_FormatStyle, F.FormatInput == Foundation.Date
    {
        format.format(self)
    }

    /// Generates a locale-aware string representation of a date using specified date and time format styles.
    ///
    /// - Parameters:
    ///   - date: The date format style to apply to the date.
    ///   - time: The time format style to apply to the date.
    /// - Returns: A string, formatted according to the specified date and time styles.
    ///
    /// When displaying a date to a user, use the convenient `formatted(date:time:)` instance method to customize
    /// the string representation of the date. Set the date and time styles of the date format style separately,
    /// according to your particular needs.
    ///
    /// For example, to create a string with a full date and no time representation, set the
    /// `Date.FormatStyle.DateStyle` to `complete` and the `Date.FormatStyle.TimeStyle` to `omitted`. Conversely,
    /// to create a string representing only the time, set the date style to `omitted` and the time style to
    /// `complete`.
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .complete, time: .omitted) // Sunday, January 17, 2021
    /// birthday.formatted(date: .omitted, time: .complete) // 4:03:12 PM CST
    /// ```
    ///
    /// You can create string representations of a `Date` instance with several levels of brevity using a variety
    /// of preset date and time styles. This example shows date styles of `long`, `abbreviated`, and `numeric`, and
    /// time styles of `shortened`, `standard`, and `complete`.
    ///
    /// ```swift
    /// let birthday = Date()
    ///
    /// birthday.formatted(date: .long, time: .shortened) // January 17, 2021, 4:03 PM
    /// birthday.formatted(date: .abbreviated, time: .standard) // Jan 17, 2021, 4:03:12 PM
    /// birthday.formatted(date: .numeric, time: .complete) // 1/17/2021, 4:03:12 PM CST
    ///
    /// birthday.formatted() // Jan 17, 2021, 4:03 PM
    /// ```
    ///
    /// The default date style is `abbreviated` and the default time style is `shortened`.
    ///
    /// For the default date formatting, use the `formatted()` method. To customize the formatted date string,
    /// use the `formatted(_:)` method and include a `Date.FormatStyle`.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public func _polyfill_formatted(
        date: _polyfill_DateFormatStyle.DateStyle,
        time: _polyfill_DateFormatStyle.TimeStyle
    ) -> String {
        _polyfill_DateFormatStyle(date: date, time: time).format(self)
    }

    /// Generates a locale-aware string representation of a date using the default date format style.
    ///
    /// - Returns: A string, formatted according to the default style.
    ///
    /// Use the `formatted()` method to apply the default format style to a date, as in the following example:
    ///
    /// ```swift
    /// let birthday = Date()
    /// print(birthday.formatted())
    /// // 6/4/2021, 2:24 PM
    /// ```
    ///
    /// The default date format style uses the `numeric` date style and the `shortened` time style.
    ///
    /// To customize the formatted measurement string, use either the `formatted(_:)` method and include a
    /// `Date.FormatStyle` or the `formatted(date:time:)` and include a date and time style.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_DateFormatStyle(date: .numeric, time: .shortened))
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DateFormatStyle {
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

extension _polyfill_DateFormatStyle: CustomConsumingRegexComponent {
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
        
        return ICUDateFormatter.cachedFormatter(for: self).parse(input, in: index ..< bounds.upperBound)
    }
}
