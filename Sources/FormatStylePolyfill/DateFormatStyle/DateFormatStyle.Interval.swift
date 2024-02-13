import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.Locale
import struct Foundation.TimeZone
import PolyfillCommon
import CLegacyLibICU

/// A format style that creates string representations of date intervals.
///
/// Use a date interval format style to create user-readable strings in the form of `<start> - <end>` for your
/// app’s interface, where `<start>` and `<end>` are date values that you supply. The format style uses locale
/// and language information, along with custom formatting options, to define the content of the resulting string.
///
/// `Date.IntervalFormatStyle` provides a variety of localized presets and configuration options to create
/// user-visible representations of date intervals. When displaying a date interval to a user, use the
/// `formatted(date:time:)` instance method of `Range<Date>`. Set the date and time styles of the date interval
/// format style separately, according to your particular needs.
///
/// For example, to create a date interval string with a full date and no time representation, set the
/// `Date.IntervalFormatStyle.DateStyle` to `complete` and the `Date.IntervalFormatStyle.TimeStyle` to `omitted`.
/// The following example creates a formatted interval string with this style:
///
/// ```swift
/// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
///     let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
///     // today: June 5, 2023
///     // thirtyDaysBeforeToday: May 6, 2023
///
///     // Create a Range<Date>.
///     let last30days = thirtyDaysBeforeToday..<today
///
///     let formatted = last30days.formatted(date: .complete, time: .omitted)
///     // "Saturday, January 30 – Monday, March 1, 2021"
/// }
/// ```
///
/// You can create string representations of date intervals with various levels of brevity using a variety of preset
/// date and time styles. The following example shows date styles of `long`, `abbreviated`, and `numeric`, and time
/// styles of `shortened`, `standard`, and `complete`:
///
/// ```swifr
/// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
///    let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
///    // today: Mar 1, 2021 at 8:01 PM
///    // thirtyDaysBeforeToday: Jan 30, 2021 at 8:01 PM
///
///    // Create a Range<Date>.
///    let last30days = thirtyDaysBeforeToday..<today
///
///    print(last30days.formatted(date: .long, time: .shortened))
///    // January 30, 2021, 8:01 PM – March 1, 2021, 8:01 PM
///
///    print(last30days.formatted(date: .abbreviated, time: .standard))
///    // Jan 30, 2021, 8:01:49 PM – Mar 1, 2021, 8:01:49 PM
///
///    print(last30days.formatted(date: .numeric, time: .complete))
///    // 1/30/2021, 8:01:49 PM CST – 3/1/2021, 8:01:49 PM CST
///
///    print(last30days.formatted())
///    // 1/30/21, 8:01 PM – 3/1/21, 8:01 PM
/// }
/// ```
///
/// The default date style is `abbreviated` and the default time style is `shortened`.
///
/// For full customization of the string representation of a date interval, use the `formatted(_:)` instance
/// method of `Range<Date>` and provide a `Date.IntervalFormatStyle` instance.
///
/// You can achieve any customization of date and time representation your app requires by appying a series of
/// convenience modifiers to your format style. The following example applies a series of modifiers to the format
/// style to precisely define the formatting of the year, month, day, hour, minute, and time zone components of
/// the resulting string:
///
/// ```swift
/// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
///    let sevenDaysAfterToday = Calendar.current.date(byAdding: .day, value: 7, to: today) {
///
///     // Create a Range<Date>.
///     let weekFromNow = today..<sevenDaysAfterToday
///
///     // Call the .formatted method on a Range<Date> and pass in an instance of Date.IntervalFormatStyle.
///     weekFromNow.formatted(
///         Date.IntervalFormatStyle()
///             .year()
///             .month(.abbreviated)
///             .day()
///             .hour(.defaultDigits(amPM: .narrow))
///             .weekday(.abbreviated)
///     ) //  Wed, Feb 10, 2021, 3 p – Wed, Feb 17, 2021, 3 p
/// }
/// ```
///
/// `Date.IntervalFormatStyle` provides a convenient factory variable, `interval`, to shorten the syntax when
/// applying date and time modifiers to customize the format.
///
/// ```swift
/// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
///
///     // Create a Range<Date>.
///     let weekBefore = sevenDaysBeforeToday..<today
///
///     let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
///     for localeID in localeArray {
///         // Call the .formatted method on a Range<Date> and pass in an instance of Date.IntervalFormatStyle.
///         print(weekBefore.formatted(.interval
///                  .day()
///                  .month(.wide)
///                  .weekday(.short)
///                  .hour(.conversationalTwoDigits(amPM: .wide))
///                  .locale(Locale(identifier: localeID))))
///     }
/// }
/// // We, February 3, 3 PM – We, February 10, 3 PM
/// // on 3 februari 15 – on 10 februari 15
/// // We 3 February, 15 – We 10 February, 15
/// // พ. 3 กุมภาพันธ์ 15 – พ. 10 กุมภาพันธ์ 15
/// // me 3 février, 15 h – me 10 février, 15 h
/// ```
public struct _polyfill_DateIntervalFormatStyle: Codable, Hashable, Sendable, _polyfill_FormatStyle {
    /// The type that defines date interval styles that vary in length or in their included components.
    ///
    /// The exact format depends on the locale. Possible values of date interval style include: `omitted`,
    /// `numeric`, `abbreviated`, `long`, and `complete`.
    ///
    /// The following code sample shows a variety of date interval style format results using the `en_US` locale.
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
    ///    let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
    ///    // today: Apr 11, 2021 at 7:14 AM
    ///    // thirtyDaysBeforeToday: Mar 12, 2021 at 7:14 AM
    ///
    ///    // Create a Range<Date>.
    ///    let last30days = thirtyDaysBeforeToday..<today
    ///
    ///     last30days.formatted(date: .omitted, time: .standard)
    ///     // 3/12/2021, 7:11:16 AM – 4/11/2021, 7:11:16 AM
    ///
    ///     last30days.formatted(date: .numeric, time: .omitted)
    ///     // 3/12/2021 – 4/11/2021
    ///
    ///     last30days.formatted(date: .abbreviated, time: .omitted)
    ///     // Mar 12 – Apr 11, 2021
    ///
    ///     last30days.formatted(date: .long, time: .omitted)
    ///     // March 12 – April 11, 2021"
    ///
    ///     last30days.formatted(date: .complete, time: .omitted)
    ///     // Friday, March 12 – Sunday, April 11, 2021
    ///
    ///     last30days.formatted()
    ///     // 3/12/21, 7:14 AM – 4/11/21, 7:14 AM
    /// }
    /// ```
    ///
    /// The default date style is `numeric`.
    public typealias DateStyle = _polyfill_DateFormatStyle.DateStyle
    
    /// The type that defines time styles that vary in length or in their included components.
    ///
    /// The exact format depends on the locale. Possible time styles include: `omitted`, `shortened`,
    /// `standard`, and `complete`.
    ///
    /// The following code sample shows a variety of time style format results using the `en_US` locale.
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -120, to: Date()),
    ///    let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -30, to: today) {
    ///    // today: Apr 11, 2021 at 7:14 AM
    ///    // thirtyDaysBeforeToday: Mar 12, 2021 at 7:14 AM
    ///
    ///    // Create a Range<Date>.
    ///    let last30days = thirtyDaysBeforeToday..<today
    ///
    ///     last30days.formatted(date: .omitted, time: .standard)
    ///     // 3/12/2021, 7:11:16 AM – 4/11/2021, 7:11:16 AM
    ///
    ///     last30days.formatted(date: .numeric, time: .omitted)
    ///     // 3/12/2021 – 4/11/2021
    ///
    ///     last30days.formatted(date: .abbreviated, time: .omitted)
    ///     // Mar 12 – Apr 11, 2021
    ///
    ///     last30days.formatted(date: .long, time: .omitted)
    ///     // March 12 – April 11, 2021"
    ///
    ///     last30days.formatted(date: .complete, time: .omitted)
    ///     // Friday, March 12 – Sunday, April 11, 2021
    ///
    ///     last30days.formatted()
    ///     // 3/12/21, 7:14 AM – 4/11/21, 7:14 AM
    /// }
    public typealias TimeStyle = _polyfill_DateFormatStyle.TimeStyle

    /// The locale for formatting the date and time interval components.
    ///
    /// The default value is `autoupdatingCurrent`. If you set this property to `nil`, the formatter resets
    /// to use `autoupdatingCurrent`.
    public var locale: Foundation.Locale
    
    /// The time zone for formatting the date interval components.
    public var timeZone: Foundation.TimeZone
    
    /// The calendar for formatting the date interval.
    public var calendar: Foundation.Calendar

    var symbols = _polyfill_DateFormatStyle.DateFieldCollection()

    /// Creates a new `FormatStyle` with the given configurations.
    ///
    /// - Parameters:
    ///   - date: The style for formatting the date part of the given date pairs. Note that if
    ///     `.omitted` is specified, but the date interval spans more than one day, a locale-specific
    ///     fallback will be used.
    ///   - time: The style for formatting the time part of the given date pairs.
    ///   - locale: The locale to use when formatting date and time values.
    ///   - calendar: The calendar to use for date values.
    ///   - timeZone: The time zone with which to specify date and time values.
    ///
    /// > Important: Always specify the date length, time length, or the date components to be included
    /// > in the formatted string with the symbol modifiers. Otherwise, an empty string will be returned
    /// > when you use the instance to format an object.
    ///
    /// > Note: If specifying the date fields, and the `DateInterval` range is larger than the specified
    /// > units, a locale-specific fallback will be used.
    /// >   > Example: for the range 2010-03-04 07:56 - 2010-03-08 16:11 (4 days, 8 hours, 15 minutes),
    /// >   > specifying `.hour().minute()` will produce
    /// >   >   - for `en_US`, "3/4/2010 7:56 AM - 3/8/2010 4:11 PM"
    /// >   >   - for `en_GB`, "4/3/2010 7:56 - 8/3/2010 16:11"
    public init(
        date: DateStyle? = nil,
        time: TimeStyle? = nil,
        locale: Foundation.Locale = .autoupdatingCurrent,
        calendar: Foundation.Calendar = .autoupdatingCurrent,
        timeZone: Foundation.TimeZone = .autoupdatingCurrent
    ) {
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
        if let date {
            self.symbols = self.symbols.collection(date: date)
        }
        if let time {
            self.symbols = self.symbols.collection(time: time)
        }
    }

    /// Creates a locale-aware string representation from a range of dates
    ///
    /// The `format(_:)` instance method generates a string from the provided range of dates. After you create
    /// a style, you can use it to format dates multiple times.
    ///
    /// - Parameter v: The date range to format.
    /// - Returns: A string representation of the date range.
    public func format(_ v: Range<Foundation.Date>) -> String {
        ICUDateIntervalFormatter.formatter(for: self).string(from: v)
    }

    /// Modifies the date interval format style to use the specified locale.
    ///
    /// - Parameter locale: The locale for formatting a date interval.
    /// - Returns: A date inteverval format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_DateIntervalFormatStyle {
    /// The type that supports customizing formatting templates using the date format style’s modifier
    /// functions, and constructing fixed-pattern date format strings.
    public typealias Symbol = _polyfill_DateFormatStyle.Symbol
    
    /// Modifies the date interval format style to include the year.
    ///
    /// Use a combination of modifier instance methods to customize the format of the date interval. The following
    /// example shows several combinations of year, month, and day components in the date interval:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval))
    ///     print(weekBefore.formatted(.interval.day()))
    ///     print(weekBefore.formatted(.interval.day().month(.defaultDigits)))
    ///     print(weekBefore.formatted(.interval.day().month(.wide).year()))
    /// }
    /// // 2/5/21, 6:37 AM – 2/12/21, 6:37 AM
    /// // 5 – 12
    /// // 2/5 – 2/12
    /// // February 5 – 12, 202
    /// ```
    ///
    /// - Returns: A date interval format style that includes the year.
    public func year() -> Self {
        var new = self
        new.symbols.year = .padded(1)
        return new
    }

    /// Modifies the date interval format style to include the month.
    ///
    /// Use a combination of modifier instance methods to customize the format of the date interval. The following
    /// example shows several combinations of year, month, and day components in the date interval:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval))
    ///     print(weekBefore.formatted(.interval.day()))
    ///     print(weekBefore.formatted(.interval.day().month(.defaultDigits)))
    ///     print(weekBefore.formatted(.interval.day().month(.wide).year()))
    /// }
    /// // 2/5/21, 6:37 AM – 2/12/21, 6:37 AM
    /// // 5 – 12
    /// // 2/5 – 2/12
    /// // February 5 – 12, 2021
    /// ```
    ///
    /// - Parameter format: The month format style to apply to the date interval format style.
    /// - Returns: A date interval format style that includes the specified month style.
    public func month(_ format: Symbol.Month = .abbreviated) -> Self {
        var new = self
        new.symbols.month = format.option
        return new
    }

    /// Modifies the date interval format style to include the day.
    ///
    /// Use a combination of modifier instance methods to customize the format of the date interval. The following
    /// example shows several combinations of year, month, and day components in the date interval:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval))
    ///     print(weekBefore.formatted(.interval.day()))
    ///     print(weekBefore.formatted(.interval.day().month(.defaultDigits)))
    ///     print(weekBefore.formatted(.interval.day().month(.wide).year()))
    /// }
    /// // 2/5/21, 6:37 AM – 2/12/21, 6:37 AM
    /// // 5 – 12
    /// // 2/5 – 2/12
    /// // February 5 – 12, 202
    /// ```
    ///
    /// - Returns: A date interval format style that includes the day.
    public func day() -> Self {
        var new = self
        new.symbols.day = .defaultDigits
        return new
    }

    /// Modifies the date interval format style to include the specified weekday style.
    ///
    /// Use a combination of modifier instance methods to customize the format of the date interval. The following
    /// example shows a combination date interval format styles that include the weekday:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval.day().month(.wide).year().weekday(.wide)))
    ///     print(weekBefore.formatted(.interval.day().weekday(.abbreviated)))
    ///     print(weekBefore.formatted(.interval.day().month(.wide).weekday(.narrow)))
    /// }
    /// // Friday, February 5 – Friday, February 12, 2021
    /// // 5 Fri – 12 Fri
    /// // F, February 5 – F, February 12
    /// ```
    ///
    /// - Parameter format: The weekday format style to apply to the date interval format style.
    /// - Returns: A date interval format style that includes the specified weekday style.
    public func weekday(_ format: Symbol.Weekday = .abbreviated) -> Self {
        var new = self
        new.symbols.weekday = format.option
        return new
    }
    
    /// Modifies the date interval format style to use the specified hour format style.
    ///
    /// The values of `Date.FormatStyle.Symbol.Hour` are `defaultDigitsNoAMPM` and `twoDigitsNoAMPM`.
    ///
    /// The static methods that return `Date.FormatStyle.Symbol.Hour` objects include
    /// `conversationalDefaultDigits(amPM:)`, `conversationalTwoDigits(amPM:)`, and `defaultDigits(amPM:)`.
    ///
    /// This example shows a variety of `Date.FormatStyle.Symbol.Hour` format styles for a date interval:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval.minute()))
    ///     print(weekBefore.formatted(.interval.day().minute().hour()))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.defaultDigitsNoAMPM)))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.conversationalDefaultDigits(amPM: .wide))))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.conversationalDefaultDigits(amPM: .narrow))))
    /// }
    /// // 2/5/2021, 9 – 2/12/2021, 9
    /// // 5, 7:09 AM – 12, 7:09 AM
    /// // Feb 5, 07:09 – Feb 12, 07:09
    /// // Feb 5, 7:09 AM – Feb 12, 7:09 AM
    /// // Feb 5, 7:09 a – Feb 12, 7:09 a
    /// ```
    ///
    /// - Parameter format: The hour format style to apply to the date interval format style.
    /// - Returns: A date interval format style that includes the specified hour style.
    public func hour(_ format: Symbol.Hour = .defaultDigits(amPM: .abbreviated)) -> Self {
        var new = self
        new.symbols.hour = format.option
        return new
    }

    /// Modifies the date interval format style to include the minutes.
    ///
    /// This example shows a combination of date interval format styles that includes the hour and minutes:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval.minute()))
    ///     print(weekBefore.formatted(.interval.day().minute().hour()))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.defaultDigitsNoAMPM)))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.conversationalDefaultDigits(amPM: .wide))))
    ///     print(weekBefore.formatted(.interval.day().month().minute().hour(.conversationalDefaultDigits(amPM: .narrow))))
    /// }
    /// // 2/5/2021, 9 – 2/12/2021, 9
    /// // 5, 7:09 AM – 12, 7:09 AM
    /// // Feb 5, 07:09 – Feb 12, 07:09
    /// // Feb 5, 7:09 AM – Feb 12, 7:09 AM
    /// // Feb 5, 7:09 a – Feb 12, 7:09 a
    /// ```
    ///
    /// - Returns: A date interval format style that includes the minutes.
    public func minute() -> Self {
        var new = self
        new.symbols.minute = .defaultDigits
        return new
    }
    
    /// Modifies the date interval format style to include the seconds.
    ///
    /// This example shows a combination of date interval format styles that include the hour, minutes, and seconds:
    ///
    /// ```swift
    /// if let today = Calendar.current.date(byAdding: .day, value: -140, to: Date()),
    ///    let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     print(weekBefore.formatted(.interval.minute()))
    ///     print(weekBefore.formatted(.interval.day().minute().hour().second()))
    /// }
    /// // 2/5/2021, 17 – 2/12/2021, 17
    /// // 5, 8:17:19 AM – 12, 8:17:19 AM
    /// ```
    ///
    /// - Returns: A date interval format style that includes the seconds.
    public func second() -> Self {
        var new = self
        new.symbols.second = .defaultDigits
        return new
    }
    
    /// Modifies the date interval format style to use the specified time zone format.
    ///
    /// - Parameter format: The time zone format style for formatting a date interval.
    /// - Returns: A date interval format style with the provided time zone format.
    public func timeZone(_ format: Symbol.TimeZone = .genericName(.short)) -> Self {
        var new = self
        new.symbols.timeZoneSymbol = format.option
        return new
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DateIntervalFormatStyle {
    /// A convenience factory variable to use as a base for custom date interval format styles.
    ///
    /// Customize the date interval format style using modifier syntax to apply specific date and time formats,
    /// as in the following example:
    ///
    /// ```swift
    /// let today = Date.now
    /// if let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///
    ///     let localeArray = ["en_US", "sv_SE", "en_GB", "th_TH", "fr_BE"]
    ///     for localeID in localeArray {
    ///         // Call the .formatted method on a Range<Date> and pass in an instance of Date.IntervalFormatStyle.
    ///         print(weekBefore.formatted(.interval
    ///                  .day()
    ///                  .month(.wide)
    ///                  .weekday(.short)
    ///                  .hour(.conversationalTwoDigits(amPM: .wide))
    ///                  .locale(Locale(identifier: localeID))))
    ///     }
    /// }
    /// // We, February 3, 3 PM – We, February 10, 3 PM
    /// // on 3 februari 15 – on 10 februari 15
    /// // We 3 February, 15 – We 10 February, 15
    /// // พ. 3 กุมภาพันธ์ 15 – พ. 10 กุมภาพันธ์ 15
    /// // me 3 février, 15 h – me 10 février, 15 h
    /// ```
    ///
    /// The default format styles are `numeric` date format and `shortened` time format, as in the
    /// following example:
    ///
    /// ```swift
    /// let today = Date.now
    /// if let sevenDaysBeforeToday = Calendar.current.date(byAdding: .day, value: -7, to: today) {
    ///     // Create a Range<Date>.
    ///     let weekBefore = sevenDaysBeforeToday..<today
    ///     print(weekBefore.formatted(.interval))
    /// }
    /// // 2/25/21, 12:58 PM – 3/4/21, 12:58 PM
    /// ```
    public static var interval: Self {
        .init()
    }
}

extension Range where Bound == Foundation.Date {
    /// Formats the date range as an interval.
    public func _polyfill_formatted() -> String {
        _polyfill_DateIntervalFormatStyle().format(self)
    }
    
    /// Formats the date range using the specified date and time format styles.
    public func _polyfill_formatted(
        date: _polyfill_DateIntervalFormatStyle.DateStyle,
        time: _polyfill_DateIntervalFormatStyle.TimeStyle
    ) -> String {
        _polyfill_DateIntervalFormatStyle(date: date, time: time).format(self)
    }
    
    /// Formats the date range using the specified style.
    public func _polyfill_formatted<S>(
        _ style: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, S.FormatInput == Range<Foundation.Date>
    {
        style.format(self)
    }
}

final class ICUDateIntervalFormatter {
    struct Signature: Hashable {
        let localeComponents: Foundation.Locale.Components
        let calendarIdentifier: Foundation.Calendar.Identifier
        let timeZoneIdentifier: String
        let dateTemplate: String
    }
    
    private static let cache = FormatterCache<Signature, ICUDateIntervalFormatter>()

    let uformatter: OpaquePointer

    private init(signature: Signature) {
        var comps = signature.localeComponents
        comps.calendar = signature.calendarIdentifier

        self.uformatter = try! Array(signature.timeZoneIdentifier.utf16).withUnsafeBufferPointer { tz in
            try Array(signature.dateTemplate.utf16).withUnsafeBufferPointer { template in
                try ICU4Swift.withCheckedStatus {
                    udtitvfmt_open(comps.icuIdentifier, template.baseAddress, Int32(template.count), tz.baseAddress, Int32(tz.count), &$0)
                }
            }
        }
        try! ICU4Swift.withCheckedStatus {
            udtitvfmt_setAttribute(self.uformatter, UDTITVFMT_MINIMIZE_TYPE, UDTITVFMT_MINIMIZE_NONE, &$0)
        }
    }

    deinit {
        udtitvfmt_close(self.uformatter)
    }

    func string(from: Range<Foundation.Date>) -> String {
        ICU4Swift.withResizingUCharBuffer {
            udtitvfmt_format(uformatter, from.lowerBound.timeIntervalSince1970 * 1000, from.upperBound.timeIntervalSince1970 * 1000, $0, $1, nil, &$2)
        } ?? ""
    }

    static func formatter(for style: _polyfill_DateIntervalFormatStyle) -> ICUDateIntervalFormatter {
        var template = style.symbols.formatterTemplate(overridingDayPeriodWithLocale: style.locale)

        if template.isEmpty {
            template = _polyfill_DateFormatStyle.DateFieldCollection()
                .collection(date: .numeric)
                .collection(time: .shortened)
                .formatterTemplate(overridingDayPeriodWithLocale: style.locale)
        }

        let signature = Signature(
            localeComponents: .init(locale: style.locale),
            calendarIdentifier: style.calendar.identifier,
            timeZoneIdentifier: style.timeZone.identifier,
            dateTemplate: template
        )
        
        return Self.cache.formatter(for: signature) {
            ICUDateIntervalFormatter(signature: signature)
        }
    }
}
