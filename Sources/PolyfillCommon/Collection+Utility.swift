import Foundation
import Algorithms

extension String {
    /// Shorthand for `String(repeating: self, count: n)`.
    package func repeated(_ n: Int) -> String {
        .init(repeating: self, count: n)
    }
    
    /// Returns `self` with all Unicode scalars having the whitespace property trimmed.
    package var trimmed: String {
        .init(self.unicodeScalars.trimming { $0.properties.isWhitespace })
    }
}
