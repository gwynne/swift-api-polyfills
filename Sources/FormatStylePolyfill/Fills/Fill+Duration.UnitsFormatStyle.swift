#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration {
    /// A ``FormatStyle`` that displays a duration as a list of duration units, such as
    /// "2 hours, 43 minutes, 26 seconds" in English.
    public typealias UnitsFormatStyle = Swift.Duration._polyfill_UnitsFormatStyle
}

extension Swift.Duration.UnitsFormatStyle {
    /// A format style to format a duration as an attributed string. Units in the string are annotated with the
    /// `durationField` and `measurement` attribute keys and the `DurationFieldAttribute` and `MeasurementAttribute`
    /// attribute values.
    ///
    /// You can use `Duration.UnitsFormatStyle` to configure the style, and create an `Attributed` format with
    /// its `public var attributed: Attributed`
    ///
    /// For example, formatting a duration of 2 hours, 43 minutes, 26.25 second in `en_US` locale yields the
    /// following, conceptually:
    ///
    /// ```swift
    /// 2 { durationField: .hours, component: .value }
    /// hours { durationField: .hours, component: .unit }
    /// , { nil }
    /// 43 { durationField: .minutes, component: .value }
    /// minutes { durationField: .minutes, component: .unit }
    /// , { nil }
    /// 26.25 { durationField: .seconds, component: .value }
    /// seconds { durationField: .seconds, component: .unit }
    /// ```
    public typealias Attributed = Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Attributed
    
    /// Units that a duration can be displayed as with `UnitsFormatStyle`.
    public typealias Unit = Swift.Duration._polyfill_UnitsFormatStyle._polyfill_Unit

    /// Specifies the width of the unit and the spacing of the value and the unit.
    public typealias UnitWidth = Swift.Duration._polyfill_UnitsFormatStyle._polyfill_UnitWidth

    /// Specifies how zero value units are handled.
    public typealias ZeroValueUnitsDisplayStrategy = Swift.Duration._polyfill_UnitsFormatStyle._polyfill_ZeroValueUnitsDisplayStrategy

    /// Specifies how a duration is displayed if it cannot be represented exactly with the allowed units.
    ///
    /// For example, you can change this option to show a duration of 1 hour and 15 minutes as "1.25 hr",
    /// "1 hr", or "1.5 hr" with different lengths and rounding rules when hour is the only allowed unit.
    public typealias FractionalPartDisplayStrategy = Swift.Duration._polyfill_UnitsFormatStyle._polyfill_FractionalPartDisplayStrategy
}

#endif
