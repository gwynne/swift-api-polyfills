extension String {
    /// Shorthand for `String(repeating: self, count: n)`.
    package func repeated(_ n: Int) -> String {
        .init(repeating: self, count: n)
    }
    
    /// Returns `self` with all Unicode scalars having the whitespace property trimmed.
    package var trimmed: String {
        let scalars = self.unicodeScalars
        var idx = scalars.startIndex
        while idx < scalars.endIndex && scalars[idx].properties.isWhitespace { scalars.formIndex(after: &idx) }
        guard idx != scalars.endIndex else { return .init(scalars[scalars.endIndex...]) }
        var beforeEnd = scalars.index(before: scalars.endIndex)
        guard idx < beforeEnd else { return .init(scalars[idx...]) }
        while scalars[beforeEnd].properties.isWhitespace { formIndex(before: &beforeEnd) }
        return .init(scalars[idx ... beforeEnd])
    }
}
