import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.DateComponents
import struct Foundation.Locale
import typealias Foundation.TimeInterval
import CLegacyLibICU
import PolyfillCommon

typealias CalendarComponentAndValue = (component: Foundation.Calendar.Component, value: Int)

public struct _polyfill_DateRelativeFormatStyle: Codable, Hashable, Sendable, _polyfill_FormatStyle {
    /// A type that represents the style to use when formatting the units of relative dates.
    public struct UnitsStyle: Codable, Hashable, Sendable {
        enum Option: Int, Codable, Hashable {
            case wide
            case spellOut
            case abbreviated
            case narrow
        }
        
        var option: Option

        /// A style that uses full representation of units, such as “2 months ago”.
        public static var wide: Self {
            .init(option: .wide)
        }

        /// A style that spells out units, such as “two months ago”.
        public static var spellOut: Self {
            .init(option: .spellOut)
        }

        /// A style that uses abbreviated units, such as “2 mo. ago”.
        ///
        /// This style may give different results in languages other than English.
        public static var abbreviated: Self {
            .init(option: .abbreviated)
        }

        /// A style that uses the shortest units, such as “2 mo. ago”.
        public static var narrow: Self {
            .init(option: .narrow)
        }
    }

    /// A type that represents the style to use when formatting relative dates, such as “1 week ago” or “last week”.
    ///
    /// Cases include `named` and `numeric`.
    public struct Presentation: Codable, Hashable, Sendable {
        enum Option: Int, Codable, Hashable {
            case numeric
            case named
        }
        
        var option: Option

        /// A style that uses named styles to describe relative dates, such as “yesterday”, “last week”,
        /// or “next week”.
        ///
        /// The format uses the `numeric` style if a name isn’t available.
        public static var numeric: Self {
            .init(option: .numeric)
        }

        /// A style that uses a numeric style to describe relative dates, such as “1 day ago” or “in 3 weeks”.
        public static var named: Self {
            .init(option: .named)
        }
    }

    /// Specifies the style to use when describing a relative date, such as “1 day ago” or “yesterday”.
    ///
    /// Express relative date formats in either `numeric` or `named` styles. For example:
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
    ///     var formatStyle = Date.RelativeFormatStyle()
    ///
    ///     formatStyle.presentation = .numeric
    ///     past.formatted(formatStyle) // "1 week ago"
    ///
    ///     formatStyle.presentation = .named
    ///     past.formatted(formatStyle) // "last week"
    /// }
    /// ```
    public var presentation: Presentation
    
    /// The style to use when formatting the quantity or the name of the unit, such as “1 day ago” or “one day ago”.
    ///
    /// Express relative date format units in either `wide`, `narrow`, `abbreviated`, or `spellOut` styles.
    /// For example:
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: -14, to: Date()) {
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .wide)) // "2 weeks ago"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .narrow)) // "2 wk. ago"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)) // "2 wk. ago"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .spellOut)) // "two weeks ago"
    /// }
    /// ```
    public var unitsStyle: UnitsStyle
    
    /// The capitalization context to use when formatting the relative dates.
    ///
    /// Setting the capitalization context to `beginningOfSentence` sets the first word of the relative date
    /// string to upper-case. A capitalization context set to `middleOfSentence` keeps all words in the string
    /// lower-cased.
    ///
    /// If you set this property to `nil`, the format style resets to using `unknown`.
    public var capitalizationContext: _polyfill_FormatStyleCapitalizationContext
    
    /// The locale to use when formatting the relative date.
    ///
    /// The default value is `autoupdatingCurrent`. If you set this property to `nil`, the format style resets
    /// to using `autoupdatingCurrent`.
    public var locale: Foundation.Locale
    
    /// The calendar to use when formatting relative dates.
    ///
    /// Defaults to `autoupdatingCurrent`. If you set this property to `nil`, the format style resets to using
    /// `autoupdatingCurrent`.
    public var calendar: Foundation.Calendar
    
    /// Creates a relative date format style with the specified presentation, units, locale, calendar,
    /// and capitalization context.
    ///
    /// The following example creates a format style applied to a relative date to create a string representation.
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
    ///     let formatStyle = Date.RelativeFormatStyle(
    ///         presentation: .named,
    ///         unitsStyle: .abbreviated,
    ///         locale: Locale(identifier: "en_US"),
    ///         calendar: Calendar.current,
    ///         capitalizationContext: .beginningOfSentence)
    ///
    ///     print(past.formatted(formatStyle)) // "Last wk."
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - presentation: The style to use when describing a relative date, such as “1 day ago” or “yesterday”.
    ///   - unitsStyle: The style to use when formatting the quantity or the name of the unit, such as “1 day
    ///     ago” or “one day ago”.
    ///   - locale: The locale to use when formatting the relative date.
    ///   - calendar: The calendar to use when formatting the relative date.
    ///   - capitalizationContext: The capitalization context to use when formatting the relative date.
    public init(
        presentation: Presentation = .numeric,
        unitsStyle: UnitsStyle = .wide,
        locale: Foundation.Locale = .autoupdatingCurrent,
        calendar: Foundation.Calendar = .autoupdatingCurrent,
        capitalizationContext: _polyfill_FormatStyleCapitalizationContext = .unknown
    ) {
        self.presentation = presentation
        self.unitsStyle = unitsStyle
        self.capitalizationContext = capitalizationContext
        self.locale = locale
        self.calendar = calendar
    }
    
    /// Creates a locale-aware string representation from a relative date value.
    ///
    /// The `format(_:)` instance method generates a string from the provided relative date. Once you create a
    /// style, you can use it to format dates multiple times.
    ///
    /// The following example applies a format style repeatedly to produce string representations of
    /// relative dates:
    ///
    /// ```swift
    /// if let pastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
    ///     if let pastDay = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
    ///
    ///
    ///         let formatStyle = Date.RelativeFormatStyle(
    ///             presentation: .named,
    ///             unitsStyle: .spellOut,
    ///             locale: Locale(identifier: "en_GB"),
    ///             calendar: Calendar.current,
    ///             capitalizationContext: .beginningOfSentence)
    ///
    ///         formatStyle.format(pastDay) // "Yesterday"
    ///         formatStyle.format(pastWeek) // "Last week"
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter destDate: The date to format.
    /// - Returns: A string representation of the relative date.
    public func format(_ destDate: Foundation.Date) -> String {
        self.formatRel(destDate, refDate: .now)
    }

    /// Modifies the relative date format style to use the specified locale.
    ///
    /// - Parameter locale: The locale to use when formatting relative dates.
    /// - Returns: A relative date format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }

    package func formatRel(_ destDate: Foundation.Date, refDate: Foundation.Date) -> String {
        let (component, value) = self.largestNonZeroComponent(destDate, reference: refDate)
        
        return ICURelativeDateFormatter.formatter(for: self).format(value: value, component: component, presentation: self.presentation)!
    }

    private static func alignedComponentValue(
        component: Foundation.Calendar.Component,
        for destDate: Foundation.Date,
        reference refDate: Foundation.Date,
        calendar: Foundation.Calendar
    ) -> CalendarComponentAndValue? {
        var refDateStart = refDate, interval: TimeInterval = 0
        
        guard calendar.dateInterval(of: component, start: &refDateStart, interval: &interval, for: refDate) else {
            return nil
        }

        return calendar
            .dateComponents(
                Set(ICURelativeDateFormatter.sortedAllowedComponents),
                from: refDateStart.addingTimeInterval(refDate < destDate ? 0 : interval - 1),
                to: destDate
            )
            .nonZeroComponentsAndValue.first
    }

    private static func roundedLargestComponentValue(
        components: Foundation.DateComponents,
        for destDate: Foundation.Date,
        calendar: Foundation.Calendar
    ) -> CalendarComponentAndValue? {
        let compsAndValues = components.nonZeroComponentsAndValue

        if var largest = compsAndValues.first {
            if compsAndValues.count >= 2, let range = calendar.range(of: compsAndValues[1].component, in: largest.component, for: destDate),
               Swift.abs(compsAndValues[1].value) * 2 >= range.count
            {
                largest.value += compsAndValues[1].value > 0 ? 1 : -1
            }
            return largest
        }
        return nil
    }

    private func largestNonZeroComponent(
        _ destDate: Foundation.Date,
        reference refDate: Foundation.Date
    ) -> CalendarComponentAndValue {
        var searchComponents = ICURelativeDateFormatter.sortedAllowedComponents
        searchComponents.append(.nanosecond)
        
        let components = self.calendar.dateComponents(Set(searchComponents), from: refDate, to: destDate)

        let dateComponents = if let nanosecond = components.value(for: .nanosecond),
                                abs(nanosecond) > Int(0.5 * 1.0e+9),
                                let adjustedDestDate = calendar.date(byAdding: .second, value: nanosecond > 0 ? 1 : -1, to: destDate)
        {
            self.calendar.dateComponents(Set(ICURelativeDateFormatter.sortedAllowedComponents), from: refDate, to: adjustedDestDate)
        } else {
            components
        }

        let compAndValue: CalendarComponentAndValue
        if let largest = dateComponents.nonZeroComponentsAndValue.first {
            if largest.component == .hour || largest.component == .minute || largest.component == .second {
                compAndValue = Self.roundedLargestComponentValue(components: dateComponents, for: destDate, calendar: self.calendar) ?? largest
            } else {
                compAndValue = Self.alignedComponentValue(component: largest.component, for: destDate, reference: refDate, calendar: self.calendar) ?? largest
            }
        } else {
            let smallestUnit = ICURelativeDateFormatter.sortedAllowedComponents.last!

            compAndValue = (smallestUnit, dateComponents.value(for: smallestUnit)!)
        }

        return compAndValue
    }
}

extension _polyfill_FormatStyle where Self == _polyfill_DateRelativeFormatStyle {
    /// Returns a relative date format style based on the provided presentation and unit style.
    ///
    /// Use this convenient static factory method to shorten the syntax when applying presentation and units
    /// style modifiers to customize the format. For example:
    ///
    /// ```swift
    /// if let past = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
    ///     past.formatted(.relative(presentation: .numeric)) // "1 week ago"
    ///     past.formatted(.relative(presentation: .named)) // "last week"
    ///
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .wide)) // "last week"
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .narrow)) // "last wk."
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)) // "last wk."
    ///     past.formatted(.relative(presentation: .named, unitsStyle: .spellOut)) // "last week"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .wide)) // "1 week ago"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)) // "1 wk. ago"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)) // "1 wk. ago"
    ///     past.formatted(.relative(presentation: .numeric, unitsStyle: .spellOut)) // "one week ago"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - presentation: The style to use when describing a relative date, for example “1 day ago” or “yesterday”.
    ///   - unitsStyle: The style to use when formatting the quantity or the name of the unit, such as “1 day ago”
    ///     or “one day ago”.
    /// - Returns: A relative date format style customized with the specified presentation and unit styles.
    public static func relative(
        presentation: _polyfill_DateRelativeFormatStyle.Presentation,
        unitsStyle: _polyfill_DateRelativeFormatStyle.UnitsStyle = .wide
    ) -> Self {
        .init(presentation: presentation, unitsStyle: unitsStyle)
    }
}

final class ICURelativeDateFormatter {
    struct Signature: Hashable {
        let localeIdentifier: String
        let numberFormatStyle: UNumberFormatStyle.RawValue?
        let relativeDateStyle: UDateRelativeDateTimeFormatterStyle.RawValue
        let context: UDisplayContext.RawValue
    }
    
    static let sortedAllowedComponents: [Foundation.Calendar.Component] = [
        .year,
        .month,
        .weekOfMonth,
        .day,
        .hour,
        .minute,
        .second,
    ]
    
    static let componentsToURelativeDateUnit: [Foundation.Calendar.Component: URelativeDateTimeUnit] = [
               .year: UDAT_REL_UNIT_YEAR,
              .month: UDAT_REL_UNIT_MONTH,
        .weekOfMonth: UDAT_REL_UNIT_WEEK,
                .day: UDAT_REL_UNIT_DAY,
               .hour: UDAT_REL_UNIT_HOUR,
             .minute: UDAT_REL_UNIT_MINUTE,
             .second: UDAT_REL_UNIT_SECOND,
    ]

    let uformatter: OpaquePointer

    private init?(signature: Signature) {
        guard let result = try? ICU4Swift.withCheckedStatus(do: { ureldatefmt_open(
            signature.localeIdentifier,
            signature.numberFormatStyle.flatMap { s in
                try? ICU4Swift.withCheckedStatus { unum_open(.init(rawValue: s), nil, 0, signature.localeIdentifier, nil, &$0) }
            },
            .init(rawValue: signature.relativeDateStyle),
            .init(rawValue: signature.context),
            &$0
        ) }) else {
            return nil
        }
        self.uformatter = result
    }

    deinit {
        ureldatefmt_close(self.uformatter)
    }

    func format(
        value: Int,
        component: Foundation.Calendar.Component,
        presentation: _polyfill_DateRelativeFormatStyle.Presentation
    ) -> String? {
        Self.componentsToURelativeDateUnit[component].flatMap { urelUnit in
            ICU4Swift.withResizingUCharBuffer {
                switch presentation.option {
                case .named:   ureldatefmt_format(self.uformatter, Double(value), urelUnit, $0, $1, &$2)
                case .numeric: ureldatefmt_formatNumeric(self.uformatter, Double(value), urelUnit, $0, $1, &$2)
                }
            }
        }
    }

    private static let cache = FormatterCache<Signature, ICURelativeDateFormatter?>()

    static func formatter(for style: _polyfill_DateRelativeFormatStyle) -> ICURelativeDateFormatter {
        let numberFormatStyle = style.unitsStyle.option == .spellOut ? UNUM_SPELLOUT : nil
        let relativeDateStyle = switch style.unitsStyle.option {
            case .spellOut, .wide: UDAT_STYLE_LONG
            case .abbreviated: UDAT_STYLE_SHORT
            case .narrow: UDAT_STYLE_NARROW
            }
        let signature = Signature(
            localeIdentifier: style.locale.identifier,
            numberFormatStyle: numberFormatStyle?.rawValue,
            relativeDateStyle: relativeDateStyle.rawValue,
            context: style.capitalizationContext.icuContext.rawValue
        )
        
        return Self.cache.formatter(for: signature) {
            .init(signature: signature)
        }!
    }
}

extension Foundation.DateComponents {
    fileprivate var nonZeroComponentsAndValue: [CalendarComponentAndValue] {
        ICURelativeDateFormatter.sortedAllowedComponents.filter {
            self.value(for: $0) != 0
        }.map {
            ($0, self.value(for: $0)!)
        }
    }
}
