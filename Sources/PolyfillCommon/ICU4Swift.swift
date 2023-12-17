import CLegacyLibICU

/// A namespace container for a set of (partial) Swift wrappers around the ICU4C API and named accordingly.
package enum ICU4Swift {
    /// A name to which useful error handling utilities can be attached.
    package typealias ICUError = UErrorCode
}

extension ICU4Swift.ICUError: CustomDebugStringConvertible {
    public var debugDescription: String {
        .init(validatingUTF8: u_errorName(self)) ?? "<ICU error \(self.rawValue)>"
    }
}

extension ICU4Swift.ICUError: @unchecked Sendable {}
extension ICU4Swift.ICUError: Error {}
extension ICU4Swift.ICUError: Hashable {}

extension ICU4Swift.ICUError {
    /// Speaks, hopefully, for itself.
    package var isSuccess: Bool {
        self.rawValue <= U_ZERO_ERROR.rawValue
    }
    
    /// Throws `self` if `!self.isSuccess`.
    package func check() throws {
        guard self.isSuccess else {
            throw self
        }
    }
}

extension ICU4Swift {
    /// Invoke the provided closure with a pointer to a temporary `UErrorCode` (aka ``ICU4Swift/ICUError``) whose
    /// initial value is guaranted to be `U_ZERO_ERROR`, and after the closure returns, check that the status
    /// still has that value. If not, throw it.
    package static func withCheckedStatus<R>(`do` closure: (inout UErrorCode) throws -> R) throws -> R {
        var status = U_ZERO_ERROR
        let result = try closure(&status)
        
        try status.check()
        return result
    }
    
    /// Invoke the provided closure with a pointer to a temporary `UErrorCode` (aka ``ICU4Swift/ICUError``) whose
    /// initial value is guaranted to be `U_ZERO_ERROR`, and after the closure returns, check that the status
    /// has a specific value. If not, throw it.
    ///
    /// Intended for use by APIs that expect to encounter and recover from such errors as `U_BUFFER_OVERLOW_ERROR`.
    package static func withCheckedStatus<R>(_ requiredStatus: UErrorCode, `do` closure: (inout UErrorCode) throws -> R) throws -> R {
        var status = U_ZERO_ERROR
        let result = try closure(&status)
        
        guard status == requiredStatus else {
            throw status
        }
        return result
    }
}