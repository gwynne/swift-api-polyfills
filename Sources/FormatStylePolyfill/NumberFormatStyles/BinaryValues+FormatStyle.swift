import struct Foundation.Decimal

extension BinaryInteger {
    /// Format `self` using `IntegerFormatStyle`
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_IntegerFormatStyle())
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(
        _ format: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, Self == S.FormatInput
    {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then
    /// formatted with the given format.
    public func _polyfill_formatted<S>(
        _ format: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, S.FormatInput: BinaryInteger
    {
        format.format(S.FormatInput(self))
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S>(
        _ value: S.ParseInput,
        _polyfill_strategy: S
    ) throws
        where S: _polyfill_ParseStrategy, S.ParseOutput: BinaryInteger
    {
        self = .init(try _polyfill_strategy.parse(value))
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S>(
        _ value: S.ParseInput,
        _polyfill_strategy: S
    ) throws
        where S: _polyfill_ParseStrategy, S.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(value)
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_IntegerFormatStyle<Self>,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_IntegerParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_IntegerFormatStyle<Self>.Percent,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_IntegerParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_IntegerFormatStyle<Self>.Currency,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_IntegerParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }
}

extension BinaryFloatingPoint {
    /// Format `self` with `FloatingPointFormatStyle`.
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_FloatingPointFormatStyle())
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(
        _ format: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, Self == S.FormatInput
    {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then
    /// formatted with the given format.
    public func _polyfill_formatted<S>(
        _ format: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, S.FormatInput: BinaryFloatingPoint
    {
        format.format(S.FormatInput(self))
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S>(
        _ value: S.ParseInput,
        _polyfill_strategy: S
    ) throws
        where S: _polyfill_ParseStrategy, S.ParseOutput: BinaryFloatingPoint
    {
        self = .init(try _polyfill_strategy.parse(value))
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S>(
        _ value: S.ParseInput,
        _polyfill_strategy: S
    ) throws
        where S: _polyfill_ParseStrategy, S.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(value)
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_FloatingPointFormatStyle<Self>,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_FloatingPointParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_FloatingPointFormatStyle<Self>.Percent,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_FloatingPointParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_FloatingPointFormatStyle<Self>.Currency,
        lenient: Bool = true
    ) throws {
        self = .init(try _polyfill_FloatingPointParseStrategy(format: _polyfill_format, lenient: lenient).parse(value))
    }
}

extension Foundation.Decimal {
    /// Formats the decimal using a default localized format style.
    ///
    /// - Returns: A string representation of the decimal, formatted according to the default format style.
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_DecimalFormatStyle())
    }
    
    /// Formats the decimal using the provided format style.
    ///
    /// Use this method when you want to format a single decimal value with a specific format style
    /// or multiple format styles. The following example shows the results of formatting a given
    /// decimal value with format styles for the `en_US` and `fr_FR` locales:
    ///
    /// ```swift
    /// let decimal: Decimal = 123456.789
    /// let usStyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
    /// let frStyle = Decimal.FormatStyle(locale: Locale(identifier: "fr_FR"))
    /// let formattedUS = decimal.formatted(usStyle) // 123,456.789
    /// let formattedFR = decimal.formatted(frStyle) // 123 456,789
    /// ```
    ///
    /// - Parameter format: The format style to apply when formatting the decimal.
    /// - Returns: A localized, formatted string representation of the decimal.
    public func _polyfill_formatted<S>(
        _ format: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, S.FormatInput == Self
    {
        format.format(self)
    }

    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S>(
        _ value: S.ParseInput,
        _polyfill_strategy: S
    ) throws
        where S: _polyfill_ParseStrategy, S.ParseOutput == Self
    {
        self = try _polyfill_strategy.parse(value)
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_DecimalFormatStyle,
        lenient: Bool = true
    ) throws {
        self = try .init(value, _polyfill_strategy: _polyfill_DecimalParseStrategy(formatStyle: _polyfill_format, lenient: lenient))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_DecimalFormatStyle.Percent,
        lenient: Bool = true
    ) throws {
        self = try .init(value, _polyfill_strategy: _polyfill_DecimalParseStrategy(formatStyle: _polyfill_format, lenient: lenient))
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format`
    /// and the `lenient` argument.
    public init(
        _ value: String,
        _polyfill_format: _polyfill_DecimalFormatStyle.Currency,
        lenient: Bool = true
    ) throws {
        self = try .init(value, _polyfill_strategy: _polyfill_DecimalParseStrategy(formatStyle: _polyfill_format, lenient: lenient))
    }
}
 
