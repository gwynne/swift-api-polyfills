extension _polyfill_DateFormatStyle {
    /// Types that customize formatting templates either by using the date format style’s modifier functions
    /// or by constructing fixed-pattern date format strings.
    public struct Symbol: Hashable, Sendable {}
}

extension _polyfill_DateFormatStyle.Symbol {
    /// A type that specifies a format for the era in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Era` includes static factory variables that create custom
    /// `Date.FormatStyle.Symbol.Era` objects.
    ///
    /// |||
    /// -|-
    /// `abbreviated`|An abbreviated representation of an era. For example, `AD`, `BC`.
    /// `narrow`|A narrow era representation. For example, `A`, `B`.
    /// `wide`|A full representation of an era. For example, `Anno Domini`, `Before Christ`.
    /// |||
    ///
    /// To customize the era format in a string representation of a `Date`, use `era(_:)`. The following
    /// example shows a variety of `Date.FormatStyle.Symbol.Era` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().era(.abbreviated)) // AD
    /// meetingDate.formatted(Date.FormatStyle().era(.narrow)) // A
    /// meetingDate.formatted(Date.FormatStyle().era(.wide)) // Anno Domini
    /// meetingDate.formatted(Date.FormatStyle().era()) // AD
    /// ```
    ///
    /// If no format is specified as a parameter, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle.`
    public struct Era: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the year in a date format style.
    ///
    /// The `Date.FormatStyle.Symbol.Year` type includes static factory variables and methods that
    /// create custom `Date.FormatStyle.Symbol.Year` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that represents the full year. For example, `2`, `20`, `201`, `2017`.
    /// `twoDigits`|The year’s two lowest-order digits, zero-padded or truncated if necessary. For example, `02`, `20`, `01`, `17`, `73`.
    /// `padded(_:)`|Three or more digits, zero-padded if necessary. For example, `002`, `020`, `201`, `2017`.
    /// `relatedGregorian(minimumLength:)`|For non-Gregorian calendars, output corresponds to the extended Gregorian year in which the calendar’s year begins. The default length is the minimum needed to show the full year.
    /// `extended(minimumLength:)`|A single number designating the year of the calendar system, encompassing all supra-year fields. The default length is the minimum needed to show the full year.
    /// |||
    ///
    /// To customize the year format in a string representation of a `Date`, use `year(_:)`. The following
    /// example shows a variety of `Date.FormatStyle.Symbol.Year` formats applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().year(.defaultDigits)) // 2021
    /// meetingDate.formatted(Date.FormatStyle().year(.twoDigits)) // 21
    /// meetingDate.formatted(Date.FormatStyle().year(.extended(minimumLength: 5))) // 02021
    /// meetingDate.formatted(Date.FormatStyle().year(.extended())) // 2021
    /// meetingDate.formatted(Date.FormatStyle().year(.padded(6))) // 002021
    /// meetingDate.formatted(Date.FormatStyle().year(.relatedGregorian())) // 2021
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Year: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for a year in week-of-year calendars when you parse a string
    /// with a date format string.
    public struct YearForWeekOfYear: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for a cyclic year in a date format style.
    ///
    /// Calendars such as the Chinese lunar calendar and Hindu calendars use 60-year cycles of year names. If
    /// the calendar doesn’t provide cyclic year-name data, or if the year value to format is out of the range
    /// of years for which the system provides cyclic name data, then the formatting is numeric, as in
    /// `Date.FormatStyle.Symbol.Year`.
    ///
    /// The `Date.FormatStyle.Symbol.CyclicYear` type includes static factory variables that create custom
    /// `Date.FormatStyle.Symbol.CyclicYear` objects:
    ///
    /// |||
    /// -|-
    /// `abbreviated`|A shortened representation of the cyclic year appropriate for space-constrained applications.
    /// `narrow`|The shortest representation of the cyclic year.
    /// `wide`|The full representation of the cyclic year.
    /// |||
    ///
    /// If no format is specified as a parameter, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see `Date.FormatStyle`.
    public struct CyclicYear: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the quarter in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Quarter` includes static factory variables that create custom
    /// `Date.FormatStyle.Symbol.Quarter` objects:
    ///
    /// |||
    /// -|-
    /// `abbreviated`|Abbreviated quarter name. For example, `Q2`.
    /// `narrow`|Minimum number of digits that represents the numeric quarter. For example, `2`.
    /// `oneDigit`|One-digit numeric quarter. For example, `1`, `4`.
    /// `twoDigits`|Two-digit numeric quarter, zero-padded if necessary. For example, `01`, `04`.
    /// `wide`|Wide quarter name. For example, `2nd quarter`.
    /// |||
    ///
    /// To customize the month format in a string representation of a `Date`, use `quarter(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Quarter` format styles applied
    /// to a date.
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
    /// If no format is specified as a parameter, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Quarter: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the month in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Month` includes static factory variables that create custom
    /// `Date.FormatStyle.Symbol.Month` objects:
    ///
    /// |||
    /// -|-
    /// `abbreviated`|Abbreviated month name. For example, `Sep`.
    /// `defaultDigits`|Minimum number of digits that represents the numeric month. For example, `9`, `12`.
    /// `narrow`|Narrow month name. For example, `S`.
    /// `twoDigits`|Two-digit numeric month, zero-padded if necessary. For example, `09`, `12`.
    /// `wide`|Wide month name. For example, `September`.
    /// |||
    ///
    /// To customize the month format in a string representation of a `Date`, use `month(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Month` format styles applied to a date.
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
    /// If no format is specified as a parameter, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Month: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the week in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Week` includes static factory variables that create
    /// custom `Date.FormatStyle.Symbol.Week` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that represents the full numeric week. For example, `1`, `18`.
    /// `twoDigits`|Two-digit numeric week, zero-padded if necessary. For example, `01`, `18`.
    /// `weekOfMonth`|The numeric week of the month. For example, `1`, `4`.
    /// |||
    ///
    /// To customize the week format in a string representation of a `Date`, use `week(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Week` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // May 3, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().week(.defaultDigits)) // 19
    /// meetingDate.formatted(Date.FormatStyle().week(.twoDigits)) // 19
    /// meetingDate.formatted(Date.FormatStyle().week(.weekOfMonth)) // 2
    /// meetingDate.formatted(Date.FormatStyle().week()) // 19
    /// ```
    ///
    /// An incomplete week at the start of a month is week of the month 1. If no format is specified as
    /// a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Week: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for a day in a date format style.
    ///
    /// The `Date.FormatStyle.Symbol.Day` type includes static factory variables and methods that create
    /// custom `Date.FormatStyle.Symbol.Day` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that shows the numeric day of month. For example, `1`, `18`.
    /// `julianModified(minimumLength:)`|The modified Julian day. The field length specifies the minimum number of digits, zero-padded if necessary. For example, `2451334`.
    /// `ordinalOfDayInMonth`|The ordinal of the day in the month. For example, the second Wednesday in July would yield `2`.
    /// `twoDigits`|The two-digit numeric day of month, zero-padded if necessary. For example, `01`, `18`.
    /// |||
    ///
    /// To customize the day format in a string representation of a `Date`, use `day(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Day` formats applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().day(.defaultDigits)) // 9
    /// meetingDate.formatted(Date.FormatStyle().day(.ordinalOfDayInMonth)) // 2 (second Tuesday of the month)
    /// meetingDate.formatted(Date.FormatStyle().day(.twoDigits)) // 09
    /// meetingDate.formatted(Date.FormatStyle().day(.julianModified(minimumLength: 12))) // 0002459255
    /// meetingDate.formatted(Date.FormatStyle().day()) // 9
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Day: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the day of the year in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.DayOfYear` includes static factory variables that create
    /// custom `Date.FormatStyle.Symbol.DayOfYear` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that represents the full day of the year. For example, `1`, `18`, `317`.
    /// `threeDigits`|Three-digit numeric day of the year, zero-padded if necessary. For example, `001`, `018`, `317`.
    /// `twoDigits`|Two-digit numeric day of the year, zero-padded if necessary. This format has no effect on three-digit values. For example, `01`, `18`, `317`.
    /// |||
    ///
    /// To customize the day format in a string representation of a `Date`, use `dayOfYear(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.DayOfYear` formats applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.defaultDigits)) // 40
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.twoDigits)) // 40
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear(.threeDigits)) // 040
    /// meetingDate.formatted(Date.FormatStyle().dayOfYear()) // 40
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct DayOfYear: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the weekday name in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Weekday` includes static factory variables that create
    /// custom `Date.FormatStyle.Symbol.Weekday` objects:
    ///
    /// |||
    /// -|-
    /// `abbreviated`|Abbreviated weekday name. For example, `Tue`.
    /// `wide`|Wide weekday name. For example, `Tuesday`.
    /// `narrow`|Narrow weekday name. For example, `T`.
    /// `short`|Short weekday name. For example, `Tu`.
    /// `oneDigit`|Local numeric one-digit day of week. The value depends on the local starting day of the week. For example, this is `2` if Sunday is the first day of the week.
    /// `twoDigits`|Local numeric two-digit day of week, zero-padded if necessary. The value depends on the local starting day of the week. For example, this is `02` if Sunday is the first day of the week.
    /// |||
    ///
    /// To customize the weekday name format in a string representation of a `Date`, use `weekday(_:)`. This
    /// example shows a variety of `Date.FormatStyle.Symbol.Weekday` format styles applied to a Thursday,
    /// using locale `en_US`:
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 18, 2021 at 3:00 PM
    /// meetingDate.formatted(Date.FormatStyle().weekday(.abbreviated)) // Thu
    /// meetingDate.formatted(Date.FormatStyle().weekday(.narrow)) // T
    /// meetingDate.formatted(Date.FormatStyle().weekday(.short)) // Th
    /// meetingDate.formatted(Date.FormatStyle().weekday(.wide)) // Thursday
    /// meetingDate.formatted(Date.FormatStyle().weekday(.oneDigit)) // 5
    /// meetingDate.formatted(Date.FormatStyle().weekday(.twoDigits)) // 05
    /// meetingDate.formatted(Date.FormatStyle().weekday()) // Thu
    /// ```
    ///
    /// If no format is specified as a parameter, the `abbreviated` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Weekday: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the time period in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.DayPeriod` includes static factory methods that create
    /// custom `Date.FormatStyle.Symbol.DayPeriod` objects.
    ///
    /// |||
    /// -|-
    /// `conversational(_:)`|Conversational abbreviated period. For example, `at night`, `nachm`, `iltap`. Conversational narrow period. For example, `at night`, `nachmittags`, `iltapäivällä`. Conversational wide period. For example, `at night`, `nachm`, `ip`.
    /// `standard(_:)`|Abbreviated period. For example, `am`. Narrow period. For example, `a`. Wide period. For example, `am`.
    /// `with12s(_:)`|Abbreviated period including designations for noon and midnight. For example, `mid`. Narrow period including designations for noon and midnight. For example, `md`. Wide period including designations for noon and midnight. For example, `midnight`.
    /// |||
    ///
    /// The day period format style may be uppercase or lowercase depending on the locale and other options.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct DayPeriod: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the hour in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Hour` includes static factory variables and methods that create
    /// custom `Date.FormatStyle.Symbol.Hour` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigitsNoAMPM`|The minimum number of digits that represents the full numeric hour. This doesn’t include the day period (a.m. or p.m.). For example, `1`, `11`.
    /// `twoDigitsNoAMPM`|Two-digit numeric hour, zero-padded if necessary. This doesn’t include the day period (a.m. or p.m.). For example, `01`, `11`.
    /// `defaultDigits(amPM:)`|The minimum number of digits that represents the full numeric hour. This may include the day period (a.m. or p.m.), depending on locale. For example, `7a` (narrow), `7AM` (abbreviated), `7A.M.` (wide).
    /// `twoDigits(amPM:)`|Two-digit numeric hour, zero-padded if necessary. This may include the day period (a.m. or p.m.), depending on locale. For example, `07a` (narrow), `07AM` (abbreviated), `07A.M.` (wide).
    /// `conversationalDefaultDigits(amPM:)`|The minimum number of digits that represents the full numeric hour. This may include the day period (a.m. or p.m.), depending on locale, and can include conversational period formats. For example, `7a` (narrow), `7AM` (abbreviated), `7A.M.` (wide).
    /// `conversationalTwoDigits(amPM:)`|Two-digit numeric hour, zero-padded if necessary. This may include the day period (a.m. or p.m.), depending on locale, and can include conversational period formats. For example, `07a` (narrow), `07AM` (abbreviated), `07A.M.` (wide).
    /// |||
    ///
    /// To customize the hour format in a string representation of a `Date`, use `hour(_:)` The
    /// xample below shows a variety of `Date.FormatStyle.Symbol.Hour` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 7:00 PM
    /// meetingDate.formatted(Date.FormatStyle().hour(.defaultDigitsNoAMPM))
    /// // 7
    ///
    /// meetingDate.formatted(Date.FormatStyle().hour(.twoDigitsNoAMPM))
    /// // 07
    ///
    /// meetingDate.formatted(Date.FormatStyle().hour(.defaultDigits(amPM: .narrow)))
    /// // 7p
    ///
    /// meetingDate.formatted(Date.FormatStyle().hour(.twoDigits(amPM: .abbreviated))
    /// // 07 PM
    ///
    /// meetingDate.formatted(Date.FormatStyle().hour(.conversationalDefaultDigits(amPM: .wide))
    /// // 7 P.M.
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Hour: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the minutes in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Minute` includes static factory variables that create
    /// custom `Date.FormatStyle.Symbol.Minute` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that represents the numeric minute. For example, `1`, `18`.
    /// `twoDigits`|Two-digit numeric minute, zero-padded if necessary. For example, `01`, `18`.
    /// |||
    ///
    /// To customize the minute format in a string representation of a `Date`, use `minute(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Minute` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05 PM
    /// meetingDate.formatted(Date.FormatStyle().minute(.defaultDigits)) // 5
    /// meetingDate.formatted(Date.FormatStyle().minute(.twoDigits)) // 05
    /// meetingDate.formatted(Date.FormatStyle().minute()) // 5
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Minute: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the seconds in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.Second` includes static factory variables that create
    /// custom `Date.FormatStyle.Symbol.Second` objects:
    ///
    /// |||
    /// -|-
    /// `defaultDigits`|The minimum number of digits that represents the numeric second. For example, `1`, `18`.
    /// `twoDigits`|Two-digit numeric second, zero-padded if necessary. For example, `01`, `18`.
    /// |||
    ///
    /// To customize the second format in a string representation of a `Date`, use `second(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.Second` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05 PM
    /// meetingDate.formatted(Date.FormatStyle().second(.defaultDigits)) // 5
    /// meetingDate.formatted(Date.FormatStyle().second(.twoDigits)) // 05
    /// meetingDate.formatted(Date.FormatStyle().second()) // 5
    /// ```
    ///
    /// If no format is specified as a parameter, the `defaultDigits` static variable is the default format.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct Second: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for the second fraction in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.SecondFraction` includes static factory methods that create
    /// custom `Date.FormatStyle.Symbol.SecondFraction` objects:
    ///
    /// |||
    /// -|-
    /// `fractional(_:)`|Returns the numerical representation of the fractional component of the second. For example, `8`, `827`.
    /// `milliseconds(_:)`|Returns the number of milliseconds elapsed in the day. For example, `11122827`.
    /// |||
    ///
    /// To customize the second format in a string representation of a `Date`, use `secondFraction(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.SecondFraction` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 3:05:41 PM
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.fractional(3))) // 827
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.fractional(1))) // 8
    /// meetingDate.formatted(Date.FormatStyle().secondFraction(.milliseconds(4))) // 11122827
    /// ```
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct SecondFraction: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the time zone in a date format style.
    ///
    /// The type `Date.FormatStyle.Symbol.TimeZone` includes static factory variables and methods that create
    /// custom `Date.FormatStyle.Symbol.TimeZone` objects:
    ///
    /// |||
    /// -|-
    /// `specificName(_:)`|The specific, non-location representation of a timezone. For example, `CDT` (short), `Central Daylight Time` (long).
    /// `genericName(_:)`|The generic, non-location representation of a timezone. For example, `CT` (short), `Central Time` (long).
    /// `iso8601(_:)`|The ISO 8601 representation of the timezone with hours, minutes, and optional seconds. For example, `-0500` (short), `-05:00` (long).
    /// `localizedGMT(_:)`|The localized GMT format representation of a timezone. For example, `GMT-5` (short), `GMT-05:00` (long).
    /// `identifier(_:)`|The timezone identifier. For example, `uschi` (short), `America/Chicago` (long).
    /// `exemplarLocation`|The exemplar city for a timezone. For example, `Chicago`.
    /// `genericLocation`|The generic location representation of a timezone. For example, `Chicago Time`.
    /// |||
    ///
    /// To customize the hour format in a string representation of a `Date`, use `timeZone(_:)`. The
    /// following example shows a variety of `Date.FormatStyle.Symbol.TimeZone` format styles applied to a date.
    ///
    /// ```swift
    /// let meetingDate = Date() // Feb 9, 2021 at 7:00 PM
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.specificName(.short)))
    /// // CDT
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.specificName(.long)))
    /// // Central Daylight Time
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.genericName(.short)))
    /// // CT
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.genericName(.long)))
    /// // Central Time
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.iso8601(.short)))
    /// // -0500
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.iso8601(.long)))
    /// // -05:00
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.localizedGMT(.short)))
    /// // GMT-5
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.localizedGMT(.long)))
    /// // GMT-05:00
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.identifier(.short)))
    /// // uschi
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.identifier(.long)))
    /// // America/Chicago
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.exemplarLocation))
    /// // Chicago
    ///
    /// meetingDate.formatted(Date.FormatStyle().timeZone(.genericLocation))
    /// // Chicago Time
    /// ```
    ///
    /// If you don’t provide a format, the system formats a timezone using the short `specificName(_:)`
    /// static function with the width `Date.FormatStyle.Symbol.TimeZone.Width.short`.
    ///
    /// For more information about formatting dates, see the `Date.FormatStyle`.
    public struct TimeZone: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for a standalone quarter.
    public struct StandaloneQuarter: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for a standalone month.
    public struct StandaloneMonth: Hashable, Sendable { let option: Option }
    
    /// A type that specifies the format for a standalone weekday.
    public struct StandaloneWeekday: Hashable, Sendable { let option: Option }
    
    /// A type that specifies a format for the hour in a date format style.
    public struct VerbatimHour: Hashable, Sendable { let option: Option }
}

extension _polyfill_DateFormatStyle.Symbol.Era {
    enum Option: String, Codable, Hashable {
        case abbreviated = "G"
        case wide        = "GGGG"
        case narrow      = "GGGGG"
    }

    /// Abbreviated Era name. For example, "AD", "Reiwa", "令和".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide era name. For example, "Anno Domini", "Reiwa", "令和".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow era name.
    ///
    /// For example, "A", "R", "R".
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.Year {
    enum Option: RawRepresentable, Codable, Hashable {
        case padded(Int)
        case relatedGregorian(Int)
        case extended(Int)

        var rawValue: String {
            switch self {
            case .padded(let len):           "y".repeated(len.clampedPadding)
            case .relatedGregorian(let len): "r".repeated(len.clampedPadding)
            case .extended(let len):         "u".repeated(len.clampedPadding)
            }
        }

        init?(rawValue: String) {
            guard let begin = rawValue.first, rawValue.allSatisfy({ $0 == begin }) else { return nil }
            switch begin {
            case "y": self = .padded(rawValue.count)
            case "r": self = .relatedGregorian(rawValue.count)
            case "u": self = .extended(rawValue.count)
            default: return nil
            }
        }
    }

    /// Minimum number of digits that shows the full year.
    ///
    /// For example, `2`, `20`, `201`, `2017`, `20173`.
    public static var defaultDigits: Self { .init(option: .padded(1)) }

    /// Two low-order digits.
    ///
    /// Padded or truncated if necessary. For example, `02`, `20`, `01`, `17`, `73`.
    public static var twoDigits: Self { .init(option: .padded(2)) }

    /// Three or more digits.
    ///
    /// Padded if necessary. For example, `002`, `020`, `201`, `2017`, `20173`.
    public static func padded(_ length: Int) -> Self { .init(option: .padded(length)) }

    /// Related Gregorian year.
    ///
    /// For non-Gregorian calendars, this corresponds to the extended Gregorian year in which the calendar’s
    /// year begins. Related Gregorian years are often displayed, for example, when formatting dates in the
    /// Japanese calendar — e.g. "2012(平成24)年1月15日" — or in the Chinese calendar — e.g. "2012壬辰年腊月初四".
    public static func relatedGregorian(minimumLength: Int = 1) -> Self { .init(option: .relatedGregorian(minimumLength)) }

    /// Extended year.
    ///
    /// This is a single number designating the year of this calendar system, encompassing all supra-year fields.
    /// For example, for the Julian calendar system, year numbers are positive, with an era of BCE or CE. An
    /// extended year value for the Julian calendar system assigns positive values to CE years and negative values
    /// to BCE years, with 1 BCE being year 0.
    public static func extended(minimumLength: Int = 1) -> Self { .init(option: .extended(minimumLength)) }
}

extension _polyfill_DateFormatStyle.Symbol.YearForWeekOfYear {
    enum Option: RawRepresentable, Codable, Hashable {
        case padded(Int)

        var rawValue: String {
            switch self { case .padded(let l): "Y".repeated(l.clampedPadding) }
        }

        init?(rawValue: String) {
            guard rawValue.allSatisfy({ $0 == "Y" }) else { return nil }
            self = .padded(rawValue.count)
        }
    }

    /// Minimum number of digits that shows the full year in "Week of Year"-based calendars.
    ///
    /// For example, `2`, `20`, `201`, `2017`, `20173`.
    public static var defaultDigits: Self { .init(option: .padded(1)) }

    /// Two low-order digits.  Padded or truncated if necessary.
    ///
    /// For example, `02`, `20`, `01`, `17`, `73`.
    public static var twoDigits: Self { .init(option: .padded(2)) }

    /// Three or more digits. Padded if necessary.
    ///
    /// For example, `002`, `020`, `201`, `2017`, `20173`.
    public static func padded(_ length: Int) -> Self { .init(option: .padded(length) ) }
}

extension _polyfill_DateFormatStyle.Symbol.CyclicYear {
    enum Option: String, Codable, Hashable {
        case abbreviated = "U"
        case wide        = "UUUU"
        case narrow      = "UUUUU"
    }

    /// Abbreviated cyclic year name.
    ///
    /// For example, "甲子".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide cyclic year name.
    ///
    /// For example, "甲子".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow cyclic year name.
    ///
    /// For example, "甲子".
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.Quarter {
    enum Option: String, Codable, Hashable {
        case oneDigit    = "Q"
        case twoDigits   = "QQ"
        case abbreviated = "QQQ"
        case wide        = "QQQQ"
        case narrow      = "QQQQQ"
    }

    /// Numeric: one digit quarter. For example `2`.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// Numeric: two digits with zero padding. For example `02`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Abbreviated quarter. For example `Q2`.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// The quarter spelled out in full, for example `2nd quarter`.
    public static var wide: Self { .init(option: .wide) }

    /// Narrow quarter. For example `2`.
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.StandaloneQuarter {
    enum Option: String, Codable, Hashable {
        case oneDigit    = "q"
        case twoDigits   = "qq"
        case abbreviated = "qqq"
        case wide        = "qqqq"
        case narrow      = "qqqqq"
    }

    /// Standalone one-digit numeric quarter. For example `2`.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// Two-digit standalone numeric quarter with zero padding if necessary, for example `02`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Standalone abbreviated quarter. For example `Q2`.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Standalone wide quarter. For example "2nd quarter".
    public static var wide: Self { .init(option: .wide) }

    /// Standalone narrow quarter. For example "2".
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.Month {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "M"
        case twoDigits     = "MM"
        case abbreviated   = "MMM"
        case wide          = "MMMM"
        case narrow        = "MMMMM"
    }

    /// Custom month format style showing the minimum number of digits that represents the numeric month.
    ///
    /// This style represents the month like `1` or `12`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// The custom month format style that uses two digits to represent the numeric month.
    ///
    /// This style represents the month like `01` or `12`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// The abbreviated representation of a month.
    ///
    /// This custom format style conveys an abbreviated representation of a month, like `Sep`.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// The full representation of a month.
    ///
    /// This custom format style conveys the full representation of a month, like `September`.
    public static var wide: Self { .init(option: .wide) }

    /// The shortest representation of a month.
    ///
    /// This custom format style conveys the shortest representation of a month. For example, it may
    /// represent September as `S`.
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.StandaloneMonth {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "L"
        case twoDigits     = "LL"
        case abbreviated   = "LLL"
        case wide          = "LLLL"
        case narrow        = "LLLLL"
    }

    /// The custom month format style that shows the minimum number of digits to represent a standalone month.
    ///
    /// This style uses representations like `1` for January and `10` for October.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// The two-digit representation of a standalone month.
    ///
    /// This style uses representations like `01` for January and `10` for October.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// The abbreviated representation of a standalone month.
    ///
    /// This custom format style conveys an abbreviated representation of a standable month, like `Oct` for October.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// The full representation of a standalone month.
    ///
    /// This custom format style conveys the complete representation of a month, like `October` for October.
    public static var wide: Self { .init(option: .wide) }

    /// The shortest representation of a standalone month.
    ///
    /// This custom format style conveys the shortest representation of a month, like `O` (the letter) for October.
    public static var narrow: Self { .init(option: .narrow) }
}

extension _polyfill_DateFormatStyle.Symbol.Week {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "w"
        case twoDigits     = "ww"
        case weekOfMonth   = "W"
    }

    /// Custom week format style showing the minimum number of digits that represents the numeric week.
    ///
    /// This style represents weeks like `1` or `18`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Custom format style portraying the two-digit numeric week, zero-padded if necessary.
    ///
    /// This style represents weeks like `01` or `18`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Custom format style portraying the numeric week of the month.
    public static var weekOfMonth: Self { .init(option: .weekOfMonth) }
}

extension _polyfill_DateFormatStyle.Symbol.Day {
    enum Option: RawRepresentable, Codable, Hashable {
        case defaultDigits
        case twoDigits
        case ordinalOfDayInMonth
        case julianModified(Int)

        var rawValue: String {
            switch self {
            case .defaultDigits:           "d"
            case .twoDigits:               "dd"
            case .ordinalOfDayInMonth:     "F"
            case .julianModified(let len): "g".repeated(len.clampedPadding)
            }
        }

        init?(rawValue: String) {
            switch rawValue {
            case "d":  self = .defaultDigits
            case "dd": self = .twoDigits
            case "F":  self = .ordinalOfDayInMonth
            case let v where v.allSatisfy({ $0 == "g" }) && v.count.clampedPadding == v.count: self = .julianModified(v.count)
            default: return nil
            }
        }
    }

    /// Custom format style portraying the minimum number of digits that represents the numeric day of month.
    ///
    /// This style produces `1` for the first day of the month and `18` for the eighteenth. To force two-digit
    /// display in all cases, use `twoDigits`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Custom format style portraying the two-digit numeric day of month, zero-padded if necessary.
    ///
    /// This style produces `01` for the first day of the month and `18` for the eighteenth. To use single
    /// digits when possible, use `defaultDigits`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Custom format style portraying the ordinal of the day in the month.
    ///
    /// For example, the second Wednesday in July would yield `2.`
    public static var ordinalOfDayInMonth: Self { .init(option: .ordinalOfDayInMonth) }

    /// Creates a custom day format style representing the modified Julian day.
    ///
    /// The length specifies the minimum number of digits, with zero-padding as necessary.
    ///
    /// This is different from the conventional Julian day number in two regards. First, it demarcates days at
    /// local zone midnight, rather than noon GMT. Second, it is a local number; that is, it depends on the local
    /// time zone. It can be thought of as a single number that encompasses all the date-related fields.
    ///
    /// For example, `2451334`.
    public static func julianModified(minimumLength: Int = 1) -> Self { .init(option: .julianModified(minimumLength)) }
}

extension _polyfill_DateFormatStyle.Symbol.DayOfYear {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "D"
        case twoDigits     = "DD"
        case threeDigits   = "DDD"
    }

    /// Custom format style portraying the minimum number of digits that represents the numeric day of the year.
    ///
    /// For example, `1`, `18`, `317`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Custom format style portraying the two-digit numeric day of the year, zero-padded if necessary.
    ///
    /// For example, `01`, `18`, `317`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Custom format style portraying the three-digit numeric day of the year, zero-padded if necessary.
    ///
    /// For example, `001`, `018`, `317`.
    public static var threeDigits: Self { .init(option: .threeDigits) }
}

extension _polyfill_DateFormatStyle.Symbol.Weekday {
    enum Option: String, Codable, Hashable {
        case abbreviated = "EEE"
        case wide        = "EEEE"
        case narrow      = "EEEEE"
        case short       = "EEEEEE"
        case oneDigit    = "e"
        case twoDigits   = "ee"
    }

    /// Abbreviated day of week name. For example, `"Tue"`.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide day of week name. For example, `"Tuesday"`.
    public static var wide: Self { .init(option: .wide) }

    /// Narrow day of week name. For example, `"T"`.
    public static var narrow: Self { .init(option: .narrow) }

    /// Short day of week name. For example, `"Tu"`.
    public static var short: Self { .init(option: .short) }

    /// Local day of week number/name. The value depends on the local starting day of the week.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// Local day of week number/name, format style; two digits, zero-padded if necessary.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

extension _polyfill_DateFormatStyle.Symbol.StandaloneWeekday {
    enum Option: String, Codable, Hashable {
        case oneDigit    = "c"
        case abbreviated = "ccc"
        case wide        = "cccc"
        case narrow      = "ccccc"
        case short       = "cccccc"
    }

    /// The one-digit representation of a standalone weekday.
    ///
    /// This style produces representations like `2` for Monday.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// The abbreviated representation of a standalone weekday.
    ///
    /// This custom format style conveys an abbreviated representation of a standalone weekday, like
    /// `Mon` for Monday.
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// The full representation of a standalone weekday.
    ///
    /// This custom format style conveys the complete representation of a standalone weekday, like `Monday`.
    public static var wide: Self { .init(option: .wide) }

    /// The shortest representation of a standalone weekday.
    ///
    /// This custom format style conveys the shortest representation of a standalone weekday, like `M` for Monday.
    public static var narrow: Self { .init(option: .narrow) }

    /// The short representation of a standalone weekday.
    ///
    /// This custom format style conveys a short representation of a standalone weekday like `Mo` for Monday.
    /// For an even shorter representation, see `narrow`.
    public static var short: Self { .init(option: .short) }
}

extension _polyfill_DateFormatStyle.Symbol.DayPeriod {
    enum Option: String, Codable, Hashable {
        case abbreviated               = "a"
        case wide                      = "aaaa"
        case narrow                    = "aaaaa"
        case abbreviatedWith12s        = "b"
        case wideWith12s               = "bbbb"
        case narrowWith12s             = "bbbbb"
        case conversationalAbbreviated = "B"
        case conversationalNarrow      = "BBBB"
        case conversationalWide        = "BBBBB"
    }

    /// A type representing the width of a day period in a format style.
    public enum Width: Sendable {
        /// A shortened day period width representation.
        case abbreviated
        
        /// A full day period width representation.
        case wide
        
        /// The shortest day period width representation.
        case narrow
    }

    /// Standard day period.
    ///
    /// For example,
    /// Abbreviated: `12 am.`
    /// Wide: `12 am`
    /// Narrow: `12a`.
    public static func standard(_ width: Width) -> Self {
        switch width {
        case .abbreviated: .init(option: .abbreviated)
        case .wide:        .init(option: .wide)
        case .narrow:      .init(option: .narrow)
        }
    }

    /// Day period including designations for noon and midnight.
    ///
    /// For example,
    /// Abbreviated: `mid`
    /// Wide: `midnight`
    /// Narrow: `md`.
    public static func with12s(_ width: Width) -> Self {
        switch width {
        case .abbreviated: .init(option: .abbreviatedWith12s)
        case .wide:        .init(option: .wideWith12s)
        case .narrow:      .init(option: .narrowWith12s)
        }
    }

    /// Conversational day period.
    ///
    /// For example,
    /// Abbreviated: `at night`, `nachm.`, `ip.`
    /// Wide: `at night`, `nachmittags`, `iltapäivällä`.
    /// Narrow: `at night`, `nachm.`, `iltap`.
    public static func conversational(_ width: Width) -> Self {
        switch width {
        case .abbreviated: .init(option: .conversationalAbbreviated)
        case .wide:        .init(option: .conversationalWide)
        case .narrow:      .init(option: .conversationalNarrow)
        }
    }
}

extension _polyfill_DateFormatStyle.Symbol.Hour {
    enum Option: String, Codable, Hashable {
        case defaultDigitsNoAMPM                            = "J",     twoDigitsNoAMPM                            = "JJ"
        case defaultDigitsWithAbbreviatedAMPM               = "j",     twoDigitsWithAbbreviatedAMPM               = "jj"
        case defaultDigitsWithWideAMPM                      = "jjj",   twoDigitsWithWideAMPM                      = "jjjj"
        case defaultDigitsWithNarrowAMPM                    = "jjjjj", twoDigitsWithNarrowAMPM                    = "jjjjjj"
        case conversationalDefaultDigitsWithAbbreviatedAMPM = "C",     conversationalTwoDigitsWithAbbreviatedAMPM = "CC"
        case conversationalDefaultDigitsWithWideAMPM        = "CCC",   conversationalTwoDigitsWithWideAMPM        = "CCCC"
        case conversationalDefaultDigitsWithNarrowAMPM      = "CCCCC", conversationalTwoDigitsWithNarrowAMPM      = "CCCCCC"
    }

    /// The format style of the string representation of the day period, before or after noon, in a date.
    ///
    /// Possible values for this style are: `omitted`, `narrow`, `abbreviated`, and `wide`.
    public struct AMPMStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// A type that hides the day period marker.
        ///
        /// This type represents the hour period numerically only. For example, `8` (for 8 a.m.) or `1`
        /// (for 1 p.m.) if used with `defaultDigits`, and `08` or `01` if used with `twoDigits`.
        public static let omitted: AMPMStyle = AMPMStyle(rawValue: 0)

        /// A type that specifies the narrow day period if the locale prefers using day period with hour.
        ///
        /// This type represents the hour period in a narrow format where appropriate. For example, when used
        /// with `defaultDigits`, this style may represent 8 a.m. as `8` or `8a`, and 1 p.m. as `13`, or `1p`.
        /// With `twoDigits`, this style produces `08` or `08a`, and `13` or `01p`, respectively.
        public static let narrow: AMPMStyle = AMPMStyle(rawValue: 1)

        /// A type that specifies the abbreviated day period for when the locale prefers using day period with hour.
        ///
        /// This type represents the hour period in an abbreviated format where appropriate. For example, when
        /// used with `defaultDigits`, this style may represent 8 a.m. as `8`, or `8 AM`, and 1 p.m. as `13`, or
        /// `1 PM`. With `twoDigits`, this style produces `08` or `08 AM`, and `13`, `01 PM`, respectively.
        public static let abbreviated: AMPMStyle = AMPMStyle(rawValue: 2)

        /// A type that represents the wide day period if the locale prefers using day period with hour.
        ///
        /// This type represents the hour period in a wide format where appropriate. For example, when used with
        /// `defaultDigits`, this style may represent 8 a.m. as `8` or `8 A.M.`, and 1 p.m. as `13` or `1 P.M.`
        /// With `twoDigits`, this style produce `08` or `08 A.M.` and `13` or `01 P.M.`
        public static let wide: AMPMStyle = AMPMStyle(rawValue: 3)
    }

    /// Custom format style portraying the minimum number of digits that represents the hour and locale-dependent
    /// day period formats.
    ///
    /// - Parameter amPM: Specifies the format of the day period representation.
    /// - Returns: An hour format style customized according to the specified day period format style and the
    ///   given locale.
    ///
    /// This style may include the day period symbol (a.m. or p.m.), depending on locale. For example, `7a`
    /// (`narrow`), `7AM` (`abbreviated`), `7A.M.` (`wide`).
    public static func defaultDigits(amPM: AMPMStyle) -> Self {
        switch amPM {
        case .omitted:     .init(option: .defaultDigitsNoAMPM)
        case .narrow:      .init(option: .defaultDigitsWithNarrowAMPM)
        case .abbreviated: .init(option: .defaultDigitsWithAbbreviatedAMPM)
        case .wide:        .init(option: .defaultDigitsWithWideAMPM)
        default:           fatalError("Specified amPM style is not supported by Hour.defaultDigits")
        }
    }

    /// Custom format style portraying two digits that represent the hour and locale-dependent day period formats.
    /// 
    /// - Parameter amPM: Specifies the format of the day period representation.
    /// - Returns: An hour format style customized according to the specified day period format style and the
    ///   given locale.
    ///
    /// This style pads the hour with a leading zero if necessary. This style may include the day period symbol
    /// (a.m. or p.m.), depending on locale. For example, `07a` (`narrow`), `07AM` (`abbreviated`), `07A.M.` (`wide`).
    public static func twoDigits(amPM: AMPMStyle) -> Self {
        switch amPM {
        case .omitted:     .init(option: .twoDigitsNoAMPM)
        case .narrow:      .init(option: .twoDigitsWithNarrowAMPM)
        case .abbreviated: .init(option: .twoDigitsWithAbbreviatedAMPM)
        case .wide:        .init(option: .twoDigitsWithWideAMPM)
        default:           fatalError("Specified amPM style is not supported by Hour.twoDigits")
        }
    }

    /// Custom format style portraying the minimum number of digits that represents the hour and
    /// locale-dependent conversational day period formats.
    ///
    /// - Parameter amPM: Specifies the format of the day period representation.
    /// - Returns: An hour format style customized according to the specified day period format style and
    ///   the given locale.
    ///
    /// This format may include the day period symbol (a.m. or p.m.), depending on locale, and can include
    /// conversational period formats. For example, `7a` (`narrow`), `7AM` (`abbreviated`), `7A.M.` (`wide`).
    public static func conversationalDefaultDigits(amPM: AMPMStyle) -> Self {
        switch amPM {
        case .omitted:     .init(option: .defaultDigitsNoAMPM)
        case .narrow:      .init(option: .conversationalDefaultDigitsWithNarrowAMPM)
        case .abbreviated: .init(option: .conversationalDefaultDigitsWithAbbreviatedAMPM)
        case .wide:        .init(option: .conversationalDefaultDigitsWithWideAMPM)
        default:           fatalError("Specified amPM style is not supported by Hour.conversationalDefaultDigits")
        }
    }

    /// Custom format style portraying two digits that represent the hour and locale-dependent conversational
    /// day period formats.
    /// 
    /// - Parameter amPM: Specifies the format of the day period representation.
    /// - Returns: An hour format style customized according to the specified day period format style and
    ///   the given locale.
    ///
    /// This style pads the hour with a leading zero if necessary. This style may include the day period symbol
    /// (a.m. or p.m.), depending on locale, and can include conversational period formats. For example, `07a`
    /// (`narrow`), `07AM` (`abbreviated`), `07A.M.` (`wide`).
    public static func conversationalTwoDigits(amPM: AMPMStyle) -> Self {
        switch amPM {
        case .omitted:     .init(option: .twoDigitsNoAMPM)
        case .narrow:      .init(option: .conversationalTwoDigitsWithNarrowAMPM)
        case .abbreviated: .init(option: .conversationalTwoDigitsWithAbbreviatedAMPM)
        case .wide:        .init(option: .conversationalTwoDigitsWithWideAMPM)
        default:           fatalError("Specified amPM style is not supported by Hour.conversationalTwoDigits")
        }
    }
}

extension _polyfill_DateFormatStyle.Symbol.VerbatimHour {
    enum Option: String, Codable, Hashable {
        case twelveHourDefaultDigitsZeroBased     = "K", twelveHourTwoDigitsZeroBased     = "KK"
        case twelveHourDefaultDigitsOneBased      = "h", twelveHourTwoDigitsOneBased      = "hh"
        case twentyFourHourDefaultDigitsOneBased  = "k", twentyFourHourTwoDigitsOneBased  = "kk"
        case twentyFourHourDefaultDigitsZeroBased = "H", twentyFourHourTwoDigitsZeroBased = "HH"
    }

    /// A type that specifies the start of a clock representation for the format of a hour.
    public struct HourCycle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// The hour ranges from 0 to 11 in a 12-hour clock. Ranges from 0 to 23 in a 24-hour clock.
        public static let zeroBased = Self(rawValue: 0)

        /// The hour ranges from 1 to 12 in the 12-hour clock. Ranges from 1 to 24 in a 24-hour clock.
        public static let oneBased = Self(rawValue: 1)
    }

    /// A type that specifies a clock representation for the format of an hour.
    public struct Clock: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// In a 12-hour clock system, the 24-hour day is divided into two periods, a.m. and p.m, and each
        /// period consists of 12 hours.
        ///
        /// > Note: Does not include the period marker (AM/PM). Specify a `PeriodSymbol` if that's desired.
        public static let twelveHour = Self(rawValue: 0)

        /// In a 24-hour clock system, the day runs from midnight to midnight, dividing into 24 hours.
        ///
        /// > Note: If using `twentyFourHour` together with `PeriodSymbol`, the period is ignored.
        public static let twentyFourHour = Self(rawValue: 1)
    }

    /// Minimum digits to show the numeric hour.
    ///
    /// For example, `1`, `12`. Or `23` if using the `twentyFourHour` clock.
    ///
    /// > Note: This format does not take user's locale preferences into account. Consider using
    /// > `defaultDigits` if applicable.
    public static func defaultDigits(clock: Clock, hourCycle: HourCycle) -> Self {
        switch (clock, hourCycle) {
        case (.twelveHour,     .zeroBased): .init(option: .twelveHourDefaultDigitsZeroBased)
        case (.twelveHour,     .oneBased):  .init(option: .twelveHourDefaultDigitsOneBased)
        case (.twentyFourHour, .zeroBased): .init(option: .twentyFourHourDefaultDigitsZeroBased)
        case (.twentyFourHour, .oneBased):  .init(option: .twentyFourHourDefaultDigitsOneBased)
        default: fatalError("Specified clock or hourCycle is not supported by VerbatimHour.defaultDigits")
        }
    }

    /// Numeric two-digit hour, zero padded if necessary.
    ///
    /// For example, `01`, `12`. Or `23` if using the `twentyFourHour` clock.
    ///
    /// > Note: This format does not take user's locale preferences into account. Consider using
    /// > `defaultDigits` if applicable.
    public static func twoDigits(clock: Clock, hourCycle: HourCycle) -> Self {
        switch (clock, hourCycle) {
        case (.twelveHour,     .zeroBased): .init(option: .twelveHourTwoDigitsZeroBased)
        case (.twelveHour,     .oneBased):  .init(option: .twelveHourTwoDigitsOneBased)
        case (.twentyFourHour, .zeroBased): .init(option: .twentyFourHourTwoDigitsZeroBased)
        case (.twentyFourHour, .oneBased):  .init(option: .twentyFourHourTwoDigitsOneBased)
        default: fatalError("Specified clock or hourCycle is not supported by VerbatimHour.twoDigits")
        }
    }
}

extension _polyfill_DateFormatStyle.Symbol.Minute {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "m"
        case twoDigits     = "mm"
    }

    /// Minimum digits to show the numeric minute. Truncated, not rounded. For example, `8`, `59`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two-digit numeric, zero padded if needed. For example, `08`, `59`.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

extension _polyfill_DateFormatStyle.Symbol.Second {
    enum Option: String, Codable, Hashable {
        case defaultDigits = "s"
        case twoDigits     = "ss"
    }

    /// Minimum digits to show the numeric second. Truncated, not rounded. For example, `8`, `12`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two digits numeric, zero padded if needed, not rounded. For example, `08`, `12`.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

extension _polyfill_DateFormatStyle.Symbol.SecondFraction {
    enum Option: RawRepresentable, Codable, Hashable {
        case fractional(Int)
        case milliseconds(Int)

        init?(rawValue: String) {
            guard let first = rawValue.first, rawValue.allSatisfy({ $0 == first }) else { return nil }
            switch first {
            case "S": self = .fractional(rawValue.count)
            case "A": self = .milliseconds(rawValue.count)
            default: return nil
            }
        }

        public var rawValue: String {
            switch self {
            case .fractional(let n): "S".repeated(n.clampedPadding)
            case .milliseconds(let n): "A".repeated(n.clampedPadding)
            }
        }
    }

    /// Fractional second (numeric).
    ///
    /// Truncates, like other numeric time fields, but in this case to the number of digits specified
    /// by the associated `Int`.
    ///
    /// For example, specifying `4` for seconds value `12.34567` yields `12.3456`.
    public static func fractional(_ val: Int) -> Self { .init(option: .fractional(val)) }

    /// Milliseconds in day (numeric).
    ///
    /// The associated `Int` specifies the minimum number of digits, with zero-padding as necessary. The maximum
    /// number of digits is 9.
    ///
    /// This field behaves exactly like a composite of all time-related fields, not including the zone fields. As
    /// such, it also reflects discontinuities of those fields on DST transition days. On a day of DST onset, it
    /// will jump forward. On a day of DST cessation, it will jump backward. This reflects the fact that it must
    /// be combined with the offset field to obtain a unique local time value.
    public static func milliseconds(_ val: Int) -> Self { .init(option: .milliseconds(val)) }
}

extension _polyfill_DateFormatStyle.Symbol.TimeZone {
    enum Option: String, Codable, Hashable {
        case shortSpecificName = "z", longSpecificName = "zzzz"
        case      iso8601Basic = "Z",  iso8601Extended = "ZZZZZ"
        case shortLocalizedGMT = "O", longLocalizedGMT = "ZZZZ"
        case  shortGenericName = "v",  longGenericName = "vvvv"
        case  shortIdentifier = "V",    longIdentifier = "VV"
        case exemplarLocation = "VVV", genericLocation = "VVVV"
    }

    /// A type representing the width of a timezone in a format style.
    ///
    /// The possible values of a width are `short` and `long`.
    public enum Width: Sendable {
        /// A short timezone representation.
        case short
        
        /// A long timezone representation.
        case long
    }

    /// Specific non-location format. Falls back to `shortLocalizedGMT` if unavailable.
    ///
    /// For example,
    /// short: `"PDT"`
    /// long: `"Pacific Daylight Time"`.
    public static func specificName(_ width: Width) -> Self { .init(option: width == .short ? .shortSpecificName : .longSpecificName) }

    /// Generic non-location format. Falls back to `genericLocation` if unavailable.
    ///
    /// For example,
    /// short: `"PT"`. Fallback again to `localizedGMT(.short)` if `genericLocation(.short)` is unavailable.
    /// long: `"Pacific Time"`
    public static func genericName(_ width: Width) -> Self { .init(option: width == .short ? .shortGenericName : .longGenericName) }

    /// The ISO8601 format with hours, minutes and optional seconds fields.
    ///
    /// For example,
    /// short: `"-0800"`
    /// long: `"-08:00"` or `"-07:52:58"`.
    public static func iso8601(_ width: Width) -> Self { .init(option: width == .short ? .iso8601Basic : .iso8601Extended) }

    /// Short localized GMT format.
    ///
    /// For example,
    /// short: `"GMT-8"`
    /// long: `"GMT-8:00"`
     public static func localizedGMT(_ width: Width) -> Self { .init(option: width == .short ? .shortLocalizedGMT : .longLocalizedGMT) }

    /// The time zone ID.
    ///
    /// For example,
    /// short: `"uslax"`
    /// long: `"America/Los_Angeles"`.
    public static func identifier(_ width: Width) -> Self { .init(option: width == .short ? .shortIdentifier : .longIdentifier) }

    /// The exemplar city (location) for the time zone. The localized exemplar city name for the special zone
    /// or unknown is used as the fallback if it is unavailable.
    ///
    /// For example, `"Los Angeles"`.
    public static var exemplarLocation: Self { .init(option: .exemplarLocation) }

    /// The generic location format. Falls back to `longLocalizedGMT` if unavailable. Recommends for presenting
    /// possible time zone choices for user selection.
    ///
    /// For example, `"Los Angeles Time"`.
    public static var genericLocation: Self { .init(option: .genericLocation) }
}

fileprivate extension Int {
    var clampedPadding: Int { Swift.min(10, Swift.max(1, self)) }
}
