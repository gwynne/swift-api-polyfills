import struct Foundation.Date

extension Foundation.Date._polyfill_FormatStyle {
    public struct Symbol: Hashable, Sendable {
        let symbolType: SymbolType

        public struct Era: Hashable, Sendable { let option: SymbolType.EraOption }
        public struct Year: Hashable, Sendable { let option: SymbolType.YearOption }
        public struct YearForWeekOfYear: Hashable, Sendable { let option: SymbolType.YearForWeekOfYearOption }
        public struct CyclicYear: Hashable, Sendable { let option: SymbolType.CyclicYearOption }
        public struct Quarter: Hashable, Sendable { let option: SymbolType.QuarterOption }
        public struct Month: Hashable, Sendable { let option: SymbolType.MonthOption }
        public struct Week: Hashable, Sendable { let option: SymbolType.WeekOption }
        public struct Day: Hashable, Sendable { let option: SymbolType.DayOption }
        public struct DayOfYear: Hashable, Sendable { let option: SymbolType.DayOfYearOption }
        public struct Weekday: Hashable, Sendable { let option: SymbolType.WeekdayOption }
        public struct DayPeriod: Hashable, Sendable { let option: SymbolType.DayPeriodOption }
        public struct Hour: Hashable, Sendable { let option: SymbolType.HourOption }
        public struct Minute: Hashable, Sendable { let option: SymbolType.MinuteOption }
        public struct Second: Hashable, Sendable { let option: SymbolType.SecondOption }
        public struct SecondFraction: Hashable, Sendable { let option: SymbolType.SecondFractionOption }
        public struct TimeZone: Hashable, Sendable { let option: SymbolType.TimeZoneSymbolOption }

        public struct StandaloneQuarter: Hashable, Sendable { let option: SymbolType.StandaloneQuarterOption }
        public struct StandaloneMonth: Hashable, Sendable { let option: SymbolType.StandaloneMonthOption }
        public struct StandaloneWeekday: Hashable, Sendable { let option: SymbolType.StandaloneWeekdayOption }
        public struct VerbatimHour: Hashable, Sendable { let option: SymbolType.VerbatimHourOption }

        static let maxPadding = 10
        enum SymbolType : Hashable {
            case era(EraOption)
            case year(YearOption)
            case yearForWeekOfYear(YearForWeekOfYearOption)
            case cyclicYear(CyclicYearOption)
            case quarter(QuarterOption)
            case standaloneQuarter(StandaloneQuarterOption)
            case month(MonthOption)
            case standaloneMonth(StandaloneMonthOption)
            case week(WeekOption)
            case day(DayOption)
            case dayOfYear(DayOfYearOption)
            case weekday(WeekdayOption)
            case standaloneWeekday(StandaloneWeekdayOption)
            case dayPeriod(DayPeriodOption)
            case hour(HourOption)
            case minute(MinuteOption)
            case second(SecondOption)
            case secondFraction(SecondFractionOption)
            case timeZone(TimeZoneSymbolOption)

            enum EraOption: String, Codable, Hashable { case abbreviated = "G", wide = "GGGG", narrow = "GGGGG" }

            enum YearOption: RawRepresentable, Codable, Hashable {
                case defaultDigits, twoDigits, padded(Int), relatedGregorian(Int), extended(Int)

                var rawValue: String {
                    switch self {
                    case .defaultDigits:             "y"
                    case .twoDigits:                 "yy"
                    case .padded(let len):           "y".repeated(len.clampedPadding)
                    case .relatedGregorian(let len): "r".repeated(len.clampedPadding)
                    case .extended(let len):         "u".repeated(len.clampedPadding)
                    }
                }

                init?(rawValue: String) {
                    guard let begin = rawValue.first else { return nil }
                    if begin == "y" || begin == "r" || begin == "u" && rawValue.allSatisfy({ $0 == begin }) {
                        if begin == "y" {
                            if rawValue.count == 1 { self = .defaultDigits }
                            else if rawValue.count == 2 { self = .twoDigits }
                            else { self = .padded(rawValue.count) }
                        }
                        else if begin == "r" { self = .relatedGregorian(rawValue.count) }
                        else { self = .extended(rawValue.count) }
                    } else { return nil }
                }
            }

            enum YearForWeekOfYearOption: RawRepresentable, Codable, Hashable {
                case defaultDigits, twoDigits, padded(Int)

                var rawValue: String {
                    switch self {
                    case .defaultDigits:   "Y"
                    case .twoDigits:       "YY"
                    case .padded(let len): "Y".repeated(len.clampedPadding)
                    }
                }

                init?(rawValue: String) {
                    if rawValue.allSatisfy({ $0 == "Y" }) {
                        if rawValue.count == 1 { self = .defaultDigits }
                        else if rawValue.count == 2 { self = .twoDigits }
                        else { self = .padded(rawValue.count) }
                    } else { return nil }
                }
            }

            enum CyclicYearOption: String, Codable, Hashable {
                case abbreviated = "U", wide = "UUUU", narrow = "UUUUU"
            }

            enum QuarterOption: String, Codable, Hashable {
                case oneDigit = "Q", twoDigits = "QQ", abbreviated = "QQQ", wide = "QQQQ", narrow = "QQQQQ"
            }

            enum StandaloneQuarterOption: String, Codable, Hashable {
                case oneDigit = "q", twoDigits = "qq", abbreviated = "qqq", wide  = "qqqq", narrow = "qqqqq"
            }

            enum MonthOption: String, Codable, Hashable {
                case defaultDigits = "M", twoDigits = "MM", abbreviated = "MMM", wide = "MMMM", narrow = "MMMMM"
            }

            enum StandaloneMonthOption: String, Codable, Hashable {
                case defaultDigits = "L", twoDigits = "LL", abbreviated = "LLL", wide = "LLLL", narrow = "LLLLL"
            }

            enum WeekOption: String, Codable, Hashable {
                case defaultDigits = "w", twoDigits = "ww", weekOfMonth = "W"
            }

            enum DayOfYearOption: String, Codable, Hashable {
                case defaultDigits = "D", twoDigits = "DD", threeDigits = "DDD"
            }

            enum DayOption: RawRepresentable, Codable, Hashable {
                case defaultDigits, twoDigits, ordinalOfDayInMonth, julianModified(Int)

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
                    default:
                        if rawValue.allSatisfy({ $0 == "g" }) { self = .julianModified(rawValue.count) }
                        else { return nil }
                    }
                }
            }

            enum WeekdayOption: String, Codable, Hashable {
                case abbreviated = "EEE", wide = "EEEE", narrow = "EEEEE", short = "EEEEEE", oneDigit = "e", twoDigits = "ee"
            }

            enum StandaloneWeekdayOption: String, Codable, Hashable {
                case oneDigit = "c", abbreviated = "ccc", wide = "cccc", narrow = "ccccc", short = "cccccc"
            }

            enum DayPeriodOption: String, Codable, Hashable {
                case abbreviated = "a", wide = "aaaa", narrow = "aaaaa", abbreviatedWith12s = "b", wideWith12s = "bbbb",
                     narrowWith12s = "bbbbb", conversationalAbbreviated = "B", conversationalNarrow = "BBBB", conversationalWide = "BBBBB"
            }

            enum HourOption: String, Codable, Hashable {
                case defaultDigitsWithAbbreviatedAMPM = "j", twoDigitsWithAbbreviatedAMPM = "jj", defaultDigitsWithWideAMPM = "jjj",
                     twoDigitsWithWideAMPM = "jjjj", defaultDigitsWithNarrowAMPM = "jjjjj", twoDigitsWithNarrowAMPM = "jjjjjj"
                case defaultDigitsNoAMPM = "J", twoDigitsNoAMPM = "JJ"
                case conversationalDefaultDigitsWithAbbreviatedAMPM = "C", conversationalTwoDigitsWithAbbreviatedAMPM = "CC",
                     conversationalDefaultDigitsWithWideAMPM = "CCC", conversationalTwoDigitsWithWideAMPM = "CCCC",
                     conversationalDefaultDigitsWithNarrowAMPM = "CCCCC", conversationalTwoDigitsWithNarrowAMPM = "CCCCCC"
            }

            enum VerbatimHourOption: String, Codable, Hashable {
                case twelveHourDefaultDigitsOneBased = "h", twelveHourTwoDigitsOneBased = "hh"
                case twentyFourHourDefaultDigitsZeroBased = "H", twentyFourHourTwoDigitsZeroBased = "HH"
                case twelveHourDefaultDigitsZeroBased = "K", twelveHourTwoDigitsZeroBased = "KK"
                case twentyFourHourDefaultDigitsOneBased = "k", twentyFourHourTwoDigitsOneBased = "kk"
            }

            enum MinuteOption: String, Codable, Hashable {
                case defaultDigits = "m", twoDigits = "mm"
            }

            enum SecondOption: String, Codable, Hashable {
                case defaultDigits = "s", twoDigits = "ss"
            }

            enum SecondFractionOption: RawRepresentable, Codable, Hashable {
                init?(rawValue: String) {
                    guard let first = rawValue.first, rawValue.allSatisfy({ $0 == first }) else { return nil }
                    switch first {
                    case "S": self = .fractional(rawValue.count)
                    case "A": self = .milliseconds(rawValue.count)
                    default: return nil
                    }
                }

                case fractional(Int), milliseconds(Int)

                public var rawValue: String {
                    let formatString: String, requested: Int, actual: Int, maxCharacters = 9

                    switch self {
                    case .fractional(let n): requested = n; formatString = "S"
                    case .milliseconds(let n): requested = n; formatString = "A"
                    }
                    switch requested {
                    case 1 ... maxCharacters: actual = requested
                    case maxCharacters ... Int.max: actual = maxCharacters
                    default: actual = 1
                    }
                    return formatString.repeated(actual)
                }
            }

            enum TimeZoneSymbolOption: String, Codable, Hashable {
                case shortSpecificName = "z", longSpecificName = "zzzz", iso8601Basic = "Z", longLocalizedGMT = "ZZZZ",
                     iso8601Extended = "ZZZZZ", shortLocalizedGMT = "O", shortGenericName = "v", longGenericName = "vvvv",
                     shortIdentifier = "V", longIdentifier = "VV", exemplarLocation = "VVV", genericLocation = "VVVV"
            }
        }
    }
}

fileprivate extension Int {
    var clampedPadding: Int {
        Swift.min(Foundation.Date._polyfill_FormatStyle.Symbol.maxPadding, Swift.max(1, self))
    }
}


extension Foundation.Date._polyfill_FormatStyle.Symbol.Era {
    /// Abbreviated Era name. For example, "AD", "Reiwa", "令和".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide era name. For example, "Anno Domini", "Reiwa", "令和".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow era name.
    /// For example, For example, "A", "R", "R".
    public static var narrow: Self { .init(option: .narrow) }
}

extension Foundation.Date._polyfill_FormatStyle.Symbol.Year {
    /// Minimum number of digits that shows the full year.
    /// For example, `2`, `20`, `201`, `2017`, `20173`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two low-order digits.
    /// Padded or truncated if necessary. For example, `02`, `20`, `01`, `17`, `73`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Three or more digits.
    /// Padded if necessary. For example, `002`, `020`, `201`, `2017`, `20173`.
    public static func padded(_ length: Int) -> Self { .init(option: .padded(length)) }

    /// Related Gregorian year.
    /// For non-Gregorian calendars, this corresponds to the extended Gregorian year in which the calendar’s year begins. Related Gregorian years are often displayed, for example, when formatting dates in the Japanese calendar — e.g. "2012(平成24)年1月15日" — or in the Chinese calendar — e.g. "2012壬辰年腊月初四".
    public static func relatedGregorian(minimumLength: Int = 1) -> Self { .init(option: .relatedGregorian(minimumLength)) }

    /// Extended year.
    /// This is a single number designating the year of this calendar system, encompassing all supra-year fields. For example, for the Julian calendar system, year numbers are positive, with an era of BCE or CE. An extended year value for the Julian calendar system assigns positive values to CE years and negative values to BCE years, with 1 BCE being year 0.
    public static func extended(minimumLength: Int = 1) -> Self { .init(option: .extended(minimumLength)) }
}

extension Foundation.Date._polyfill_FormatStyle.Symbol.YearForWeekOfYear {
    /// Minimum number of digits that shows the full year in "Week of Year"-based calendars.
    /// For example, `2`, `20`, `201`, `2017`, `20173`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two low-order digits.  Padded or truncated if necessary.
    /// For example, `02`, `20`, `01`, `17`, `73`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Three or more digits. Padded if necessary.
    /// For example, `002`, `020`, `201`, `2017`, `20173`.
    public static func padded(_ length: Int) -> Self { .init(option: .padded(length) ) }
}

/// Cyclic year symbols.
///
/// Calendars such as the Chinese lunar calendar (and related calendars) and the Hindu calendars use 60-year cycles of year names. If the calendar does not provide cyclic year name data, or if the year value to be formatted is out of the range of years for which cyclic name data is provided, then numeric formatting is used (behaves like `Year`).
///
/// Currently the data only provides abbreviated names, which will be used for all requested name widths.
extension Foundation.Date._polyfill_FormatStyle.Symbol.CyclicYear {
    /// Abbreviated cyclic year name.
    /// For example, "甲子".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide cyclic year name.
    /// For example, "甲子".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow cyclic year name.
    /// For example, "甲子".
    public static var narrow: Self { .init(option: .narrow) }
}

/// Quarter symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Quarter {
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

/// Standalone quarter symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneQuarter {
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

/// Month symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Month {
    /// Minimum number of digits that shows the numeric month. Intended to be used in conjunction with `Day.defaultDigits`.
    /// For example, `9`, `12`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// 2 digits, zero pad if needed. For example, `09`, `12`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Abbreviated month name. For example, "Sep".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide month name. For example, "September".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow month name. For example, "S".
    public static var narrow: Self { .init(option: .narrow) }
}

extension Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneMonth {
    /// Stand-alone minimum digits numeric month. Number/name (intended to be used without `Day`).
    /// For example, `9`, `12`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Stand-alone two-digit numeric month.
    /// Two digits, zero pad if needed. For example, `09`, `12`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Stand-alone abbreviated month.
    /// For example, "Sep".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Stand-alone wide month.
    /// For example, "September".
    public static var wide: Self { .init(option: .wide) }

    /// Stand-alone narrow month.
    /// For example, "S".
    public static var narrow: Self { .init(option: .narrow) }
}

/// Week symbols. Use with `YearForWeekOfYear` for the year field instead of `Year`.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Week {
    /// Numeric week of year. For example, `8`, `27`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two-digit numeric week of year, zero padded as necessary. For example, `08`, `27`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// One-digit numeric week of month, starting from 1. For example, `1`.
    public static var weekOfMonth: Self { .init(option: .weekOfMonth) }
}

/// Day symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Day {
    /// Minimum number of digits that shows the full numeric day of month. For example, `1`, `18`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two-digit, zero-padded if necessary. For example, `01`, `18`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Ordinal of day in month.
    /// For example, the 2nd Wed in July would yield `2`.
    public static var ordinalOfDayInMonth: Self { .init(option: .ordinalOfDayInMonth) }

    /// The field length specifies the minimum number of digits, with zero-padding as necessary.
    /// This is different from the conventional Julian day number in two regards. First, it demarcates days at local zone midnight, rather than noon GMT. Second, it is a local number; that is, it depends on the local time zone. It can be thought of as a single number that encompasses all the date-related fields.
    /// For example, `2451334`.
    public static func julianModified(minimumLength: Int = 1) -> Self { .init(option: .julianModified(minimumLength)) }
}

extension Foundation.Date._polyfill_FormatStyle.Symbol.DayOfYear {
    /// Minimum number of digits that shows the full numeric day of year. For example, `7`, `33`, `345`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two-digit day of year, with zero-padding as necessary. For example, `07`, `33`, `345`.
    public static var twoDigits: Self { .init(option: .twoDigits) }

    /// Three-digit day of year, with zero-padding as necessary. For example, `007`, `033`, `345`.
    public static var threeDigits: Self { .init(option: .threeDigits) }
}

/// Week day name symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Weekday {
    /// Abbreviated day of week name. For example, "Tue".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Wide day of week name. For example, "Tuesday".
    public static var wide: Self { .init(option: .wide) }

    /// Narrow day of week name. For example, "T".
    public static var narrow: Self { .init(option: .narrow) }

    /// Short day of week name. For example, "Tu".
    public static var short: Self { .init(option: .short) }

    /// Local day of week number/name. The value depends on the local starting day of the week.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// Local day of week number/name, format style; two digits, zero-padded if necessary.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

extension Foundation.Date._polyfill_FormatStyle.Symbol.StandaloneWeekday {
    /// Standalone local day of week number/name.
    public static var oneDigit: Self { .init(option: .oneDigit) }

    /// Standalone local day of week number/name.
    /// For example, "Tue".
    public static var abbreviated: Self { .init(option: .abbreviated) }

    /// Standalone wide local day of week number/name.
    /// For example, "Tuesday".
    public static var wide: Self { .init(option: .wide) }

    /// Standalone narrow local day of week number/name.
    /// For example, "T".
    public static var narrow: Self { .init(option: .narrow) }

    /// Standalone short local day of week number/name.
    /// For example, "Tu".
    public static var short: Self { .init(option: .short) }
}

/// The time period (for example, "a.m." or "p.m."). May be upper or lower case depending on the locale and other options.
extension Foundation.Date._polyfill_FormatStyle.Symbol.DayPeriod {
    public enum Width: Sendable {
        case abbreviated
        case wide
        case narrow
    }

    /// Standard day period. For example,
    /// Abbreviated: `12 am.`
    /// Wide: `12 am`
    /// Narrow: `12a`.
    public static func standard(_ width: Width) -> Self {
        var option: Foundation.Date._polyfill_FormatStyle.Symbol.SymbolType.DayPeriodOption
        switch width {
        case .abbreviated: option = .abbreviated
        case .wide: option = .wide
        case .narrow: option = .narrow
        }
        return .init(option: option)
    }

    /// Day period including designations for noon and midnight. For example,
    /// Abbreviated: `mid`
    /// Wide: `midnight`
    /// Narrow: `md`.
    public static func with12s(_ width: Width) -> Self {
        var option: Foundation.Date._polyfill_FormatStyle.Symbol.SymbolType.DayPeriodOption
        switch width {
        case .abbreviated: option = .abbreviatedWith12s
        case .wide: option = .wideWith12s
        case .narrow: option = .narrowWith12s
        }
        return .init(option: option)
    }

    /// Conversational day period. For example,
    /// Abbreviated: `at night`, `nachm.`, `ip.`
    /// Wide: `at night`, `nachmittags`, `iltapäivällä`.
    /// Narrow: `at night`, `nachm.`, `iltap`.
    public static func conversational(_ width: Width) -> Self {
        var option: Foundation.Date._polyfill_FormatStyle.Symbol.SymbolType.DayPeriodOption
        switch width {
        case .abbreviated: option = .conversationalAbbreviated
        case .wide: option = .conversationalWide
        case .narrow: option = .conversationalNarrow
        }
        return .init(option: option)
    }
}

/// Hour symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Hour {
    public struct AMPMStyle: Codable, Hashable, Sendable {
        let rawValue: UInt

        /// Hides the day period marker (AM/PM).
        /// For example, `8` (for 8 in the morning), `1` (for 1 in the afternoon) if used with `defaultDigits`.
        /// Or `08`, `01` if used with `twoDigits`.
        public static let omitted: AMPMStyle = AMPMStyle(rawValue: 0)

        /// Narrow day period if the locale prefers using day period with hour.
        /// For example, `8`, `8a`, `13`, `1p` if used with `defaultDigits`.
        /// Or `08`, `08a`, `13`, `01p` if used with `twoDigits`.
        public static let narrow: AMPMStyle = AMPMStyle(rawValue: 1)

        /// Abbreviated day period if the locale prefers using day period with hour.
        /// For example, `8`, `8 AM`, `13`, `1 PM` if used with `defaultDigits`.
        /// Or `08`, `08 AM`, `13`, `01 PM` if used with `twoDigits`.
        public static let abbreviated: AMPMStyle = AMPMStyle(rawValue: 2)

        /// Wide day period if the locale prefers using day period with hour.
        /// For example, `8`, `8 A.M.`, `13`, `1 P.M.` if used with `defaultDigits`.
        /// Or, `08`, `08 A.M.`, `13`, `01 P.M.` if used with `twoDigits`.
        public static let wide: AMPMStyle = AMPMStyle(rawValue: 3)
    }

    /// The preferred numeric hour format for the locale with minimum digits. Whether the period symbol (AM/PM) will be shown depends on the locale.
    public static func defaultDigits(amPM: AMPMStyle) -> Self {
        if amPM == .omitted {
            .init(option: .defaultDigitsNoAMPM)
        } else if amPM == .narrow {
            .init(option: .defaultDigitsWithNarrowAMPM)
        } else if amPM == .abbreviated {
            .init(option: .defaultDigitsWithAbbreviatedAMPM)
        } else if amPM == .wide {
            .init(option: .defaultDigitsWithWideAMPM)
        } else {
            fatalError("Specified amPM style is not supported by Hour.defaultDigits")
        }
    }

    /// The preferred two-digit hour format for the locale, zero padded if necessary. Whether the period symbol (AM/PM) will be shown depends on the locale.
    public static func twoDigits(amPM: AMPMStyle) -> Self {
        if amPM == .omitted {
            .init(option: .twoDigitsNoAMPM)
        } else if amPM == .narrow {
            .init(option: .twoDigitsWithNarrowAMPM)
        } else if amPM == .abbreviated {
            .init(option: .twoDigitsWithAbbreviatedAMPM)
        } else if amPM == .wide {
            .init(option: .twoDigitsWithWideAMPM)
        } else {
            fatalError("Specified amPM style is not supported by Hour.twoDigits")
        }
    }

    /// Behaves like `defaultDigits`: the preferred numeric hour format for the locale with minimum digits. May also use conversational period formats.
    public static func conversationalDefaultDigits(amPM: AMPMStyle) -> Self {
        if amPM == .omitted {
            .init(option: .defaultDigitsNoAMPM)
        } else if amPM == .narrow {
            .init(option: .conversationalDefaultDigitsWithNarrowAMPM)
        } else if amPM == .abbreviated {
            .init(option: .conversationalDefaultDigitsWithAbbreviatedAMPM)
        } else if amPM == .wide {
            .init(option: .conversationalDefaultDigitsWithWideAMPM)
        } else {
            fatalError("Specified amPM style is not supported by Hour.conversationalDefaultDigits")
        }
    }

    /// Behaves like `twoDigits`: two-digit hour format for the locale, zero padded if necessary. May also use conversational period formats.
    public static func conversationalTwoDigits(amPM: AMPMStyle) -> Self {
        if amPM == .omitted {
            .init(option: .twoDigitsNoAMPM)
        } else if amPM == .narrow {
            .init(option: .conversationalTwoDigitsWithNarrowAMPM)
        } else if amPM == .abbreviated {
            .init(option: .conversationalTwoDigitsWithAbbreviatedAMPM)
        } else if amPM == .wide {
            .init(option: .conversationalTwoDigitsWithWideAMPM)
        } else {
            fatalError("Specified amPM style is not supported by Hour.conversationalTwoDigits")
        }
    }

    @available(*, deprecated, renamed:"defaultDigits(amPM:)")
    public static var defaultDigitsNoAMPM: Self { .init(option: .defaultDigitsNoAMPM) }

    @available(*, deprecated, renamed:"twoDigits(amPM:)")
    public static var twoDigitsNoAMPM: Self { .init(option: .twoDigitsNoAMPM) }
}

/// Hour symbols that does not take users' preferences into account, and is displayed as-is.
extension Foundation.Date._polyfill_FormatStyle.Symbol.VerbatimHour {
    public struct HourCycle: Codable, Hashable, Sendable {
        /// The hour ranges from 0 to 11 in a 12-hour clock. Ranges from 0 to 23 in a 24-hour clock.
        public static let zeroBased = HourCycle(rawValue: 0)

        /// The hour ranges from 1 to 12 in the 12-hour clock. Ranges from 1 to 24 in a 24-hour clock.
        public static let oneBased = HourCycle(rawValue: 1)

        let rawValue: UInt
    }

    public struct Clock: Codable, Hashable, Sendable {
        /// In a 12-hour clock system, the 24-hour day is divided into two periods, a.m. and p.m, and each period consists of 12 hours.
        /// - Note: Does not include the period marker (AM/PM). Specify a `PeriodSymbol` if that's desired.
        public static let twelveHour = Clock(rawValue: 0)

        /// In a 24-hour clock system, the day runs from midnight to midnight, dividing into 24 hours.
        /// - Note: If using `twentyFourHour` together with `PeriodSymbol`, the period is ignored.
        public static let twentyFourHour = Clock(rawValue: 1)

        let rawValue: UInt
    }

    /// Minimum digits to show the numeric hour. For example, `1`, `12`.
    /// Or `23` if using the `twentyFourHour` clock.
    /// - Note: This format does not take user's locale preferences into account. Consider using `defaultDigits` if applicable.
    public static func defaultDigits(clock: Clock, hourCycle: HourCycle) -> Self {
        if clock == .twelveHour {
            if hourCycle == .zeroBased { .init(option: .twelveHourDefaultDigitsZeroBased) }
            else { .init(option: .twelveHourDefaultDigitsOneBased) }
        } else if clock == .twentyFourHour {
            if hourCycle == .zeroBased { .init(option: .twentyFourHourDefaultDigitsZeroBased) }
            else { .init(option: .twentyFourHourDefaultDigitsOneBased) }
        } else {
            fatalError("Specified clock or hourCycle is not supported by VerbatimHour.defaultDigits")
        }
    }

    /// Numeric two-digit hour, zero padded if necessary.
    /// For example, `01`, `12`.
    /// Or `23` if using the `twentyFourHour` clock.
    /// - Note: This format does not take user's locale preferences into account. Consider using `defaultDigits` if applicable.
    public static func twoDigits(clock: Clock, hourCycle: HourCycle) -> Self {
        if clock == .twelveHour {
            if hourCycle == .zeroBased { .init(option: .twelveHourTwoDigitsZeroBased) }
            else { .init(option: .twelveHourTwoDigitsOneBased) }
        } else if clock == .twentyFourHour {
            if hourCycle == .zeroBased { .init(option: .twentyFourHourTwoDigitsZeroBased) }
            else { .init(option: .twentyFourHourTwoDigitsOneBased) }
        } else {
            fatalError("Specified clock or hourCycle is not supported by VerbatimHour.twoDigits")
        }
    }
}

/// Minute symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Minute {
    /// Minimum digits to show the numeric minute. Truncated, not rounded. For example, `8`, `59`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two-digit numeric, zero padded if needed. For example, `08`, `59`.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

/// Second symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.Second {
    /// Minimum digits to show the numeric second. Truncated, not rounded. For example, `8`, `12`.
    public static var defaultDigits: Self { .init(option: .defaultDigits) }

    /// Two digits numeric, zero padded if needed, not rounded. For example, `08`, `12`.
    public static var twoDigits: Self { .init(option: .twoDigits) }
}

/// Fractions of a second  symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.SecondFraction {
    /// Fractional second (numeric).
    /// Truncates, like other numeric time fields, but in this case to the number of digits specified by the associated `Int`.
    /// For example, specifying `4` for seconds value `12.34567` yields `12.3456`.
    public static func fractional(_ val: Int) -> Self { .init(option: .fractional(val)) }

    /// Milliseconds in day (numeric).
    /// The associated `Int` specifies the minimum number of digits, with zero-padding as necessary. The maximum number of digits is 9.
    /// This field behaves exactly like a composite of all time-related fields, not including the zone fields. As such, it also reflects discontinuities of those fields on DST transition days. On a day of DST onset, it will jump forward. On a day of DST cessation, it will jump backward. This reflects the fact that is must be combined with the offset field to obtain a unique local time value.
    public static func milliseconds(_ val: Int) -> Self { .init(option: .milliseconds(val)) }
}

/// Time zone symbols.
extension Foundation.Date._polyfill_FormatStyle.Symbol.TimeZone {
    public enum Width: Sendable {
        case short
        case long
    }

    /// Specific non-location format. Falls back to `shortLocalizedGMT` if unavailable. For example,
    /// short: "PDT"
    /// long: "Pacific Daylight Time".
    public static func specificName(_ width: Width) -> Self {
        switch width {
        case .short: .init(option: .shortSpecificName)
        case .long: .init(option: .longSpecificName)
        }
    }

    /// Generic non-location format. Falls back to `genericLocation` if unavailable. For example,
    /// short: "PT". Fallback again to `localizedGMT(.short)` if `genericLocation(.short)` is unavailable.
    /// long: "Pacific Time"
    public static func genericName(_ width: Width) -> Self {
        switch width {
        case .short: .init(option: .shortGenericName)
        case .long: .init(option: .longGenericName)
        }
    }

    /// The ISO8601 format with hours, minutes and optional seconds fields. For example,
    /// short: "-0800"
    /// long: "-08:00" or "-07:52:58".
     public static func iso8601(_ width: Width) -> Self {
         switch width {
         case .short: .init(option: .iso8601Basic)
         case .long: .init(option: .iso8601Extended)
         }
    }

    /// Short localized GMT format. For example,
    /// short: "GMT-8"
    /// long: "GMT-8:00"
     public static func localizedGMT(_ width: Width) -> Self {
         switch width {
         case .short: .init(option: .shortLocalizedGMT)
         case .long: .init(option: .longLocalizedGMT)
         }
     }

    /// The time zone ID. For example,
    /// short: "uslax"
    /// long: "America/Los_Angeles".
    public static func identifier(_ width: Width) -> Self {
        switch width {
        case .short: .init(option: .shortIdentifier)
        case .long: .init(option: .longIdentifier)
        }
    }

    /// The exemplar city (location) for the time zone. The localized exemplar city name for the special zone or unknown is used as the fallback if it is unavailable.
    /// For example, "Los Angeles".
    public static var exemplarLocation: Self { .init(option: .exemplarLocation) }

    /// The generic location format. Falls back to `longLocalizedGMT` if unavailable. Recommends for presenting possible time zone choices for user selection.
    /// For example, "Los Angeles Time".
    public static var genericLocation: Self { .init(option: .genericLocation) }
}
