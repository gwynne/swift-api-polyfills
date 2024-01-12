extension Swift.BinaryInteger {
    /// Format `self` using `IntegerFormatStyle`
    public func _polyfill_formatted() -> String {
        _polyfill_IntegerFormatStyle().format(self)
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, Self == S.FormatInput {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput: BinaryInteger {
        format.format(S.FormatInput(self))
    }

}

extension Swift.BinaryFloatingPoint {
    /// Format `self` with `FloatingPointFormatStyle`.
    public func _polyfill_formatted() -> String {
        _polyfill_FloatingPointFormatStyle().format(self)
    }

    /// Format `self` with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, Self == S.FormatInput {
        format.format(self)
    }

    /// Format `self` with the given format. `self` is first converted to `S.FormatInput` type, then format with the given format.
    public func _polyfill_formatted<S>(_ format: S) -> S.FormatOutput where S: _polyfill_FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(self))
    }
}

extension Swift.BinaryInteger {
    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: _polyfill_ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput: Swift.BinaryInteger {
        let parsed = try strategy.parse(value)
        self = Self(parsed)
    }

    public init<S: _polyfill_ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput == Self {
        self = try strategy.parse(value)
    }

    public init(_ value: String, format: _polyfill_IntegerFormatStyle<Self>, lenient: Bool = true) throws {
        let parsed = try _polyfill_IntegerParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }

    public init(_ value: String, format: _polyfill_IntegerFormatStyle<Self>.Percent, lenient: Bool = true) throws {
        let parsed = try _polyfill_IntegerParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }

    public init(_ value: String, format: _polyfill_IntegerFormatStyle<Self>.Currency, lenient: Bool = true) throws {
        let parsed = try _polyfill_IntegerParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }
}

extension Swift.BinaryFloatingPoint {
    /// Initialize an instance by parsing `value` with the given `strategy`.
    public init<S: _polyfill_ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput: Swift.BinaryFloatingPoint {
        let parsed = try strategy.parse(value)
        self = Self(parsed)
    }

    public init<S: _polyfill_ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput == Self {
        self = try strategy.parse(value)
    }

    /// Initialize an instance by parsing `value` with a `ParseStrategy` created with the given `format` and the `lenient` argument.
    public init(_ value: String, format: _polyfill_FloatingPointFormatStyle<Self>, lenient: Bool = true) throws {
        let parsed = try _polyfill_FloatingPointParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }

    public init(_ value: String, format: _polyfill_FloatingPointFormatStyle<Self>.Percent, lenient: Bool = true) throws {
        let parsed = try _polyfill_FloatingPointParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }

    public init(_ value: String, format: _polyfill_FloatingPointFormatStyle<Self>.Currency, lenient: Bool = true) throws {
        let parsed = try _polyfill_FloatingPointParseStrategy(format: format, lenient: lenient).parse(value)
        self = Self(parsed)
    }
}
