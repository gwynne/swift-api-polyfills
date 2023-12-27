@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
