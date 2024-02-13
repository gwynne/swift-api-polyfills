import CLegacyLibICU
import struct Foundation.Locale

/// A namespace container for a set of (partial) Swift wrappers around the ICU4C API and named accordingly.
package enum ICU4Swift {
    /// A name to which useful error handling utilities can be attached.
    package typealias ICUError = UErrorCode
}

extension ICU4Swift.ICUError: CustomDebugStringConvertible, Error, Hashable, @unchecked Sendable {
    // See `CustomDebugStringConvertible.debugDescription`.
    public var debugDescription: String {
        .init(validatingUTF8: u_errorName(self)) ?? "<ICU error \(self.rawValue)>"
    }

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
    package static func withCheckedStatus<R>(
        `do` closure: (inout UErrorCode) throws -> R
    ) throws -> R {
        var status = U_ZERO_ERROR
        let result = try closure(&status)
        
        try status.check()
        return result
    }
    
    /// Invoke the provided closure with a pointer to a temporary `UErrorCode` (aka ``ICU4Swift/ICUError``) whose
    /// initial value is guaranted to be `U_ZERO_ERROR`, and after the closure returns, check that the status
    /// is either a success indication _or_ has a specific non-success value. If not, throw it.
    ///
    /// Intended for use by APIs that expect to encounter and recover from such errors as `U_BUFFER_OVERLOW_ERROR`
    /// and `U_PARSE_ERROR`.
    package static func withCheckedStatus<R>(
        _ requiredStatus: UErrorCode,
        `do` closure: (inout UErrorCode) throws -> R
    ) throws -> R {
        var status = U_ZERO_ERROR
        let result = try closure(&status)
        
        guard status == requiredStatus || status.isSuccess else {
            throw status
        }
        return result
    }

    package static func withResizingUCharBuffer(
        initialSize: Int32 = 32,
        _ body: (UnsafeMutablePointer<UChar>, Int32, inout UErrorCode) -> Int32?
    ) -> String? {
        withUnsafeTemporaryAllocation(of: UChar.self, capacity: Int(initialSize + 1)) {
            var status = U_ZERO_ERROR
            
            $0.initialize(repeating: 0)
            if let len = body($0.baseAddress!, initialSize, &status) {
                if status == U_BUFFER_OVERFLOW_ERROR {
                    return withUnsafeTemporaryAllocation(of: UChar.self, capacity: Int(len + 1)) {
                        var innerStatus = U_ZERO_ERROR
                        
                        $0.initialize(repeating: 0)
                        if let innerLen = body($0.baseAddress!, len + 1, &innerStatus) {
                            if innerStatus.isSuccess && innerLen > 0 {
                                return String(decodingCString: $0.baseAddress!, as: UTF16.self)
                            }
                        }
                        return nil
                    }
                } else if status.isSuccess, len > 0 {
                    return String(decodingCString: $0.baseAddress!, as: UTF16.self)
                }
            }
            return nil
        }
    }

    package static func localizedParenthesis(locale: Foundation.Locale) -> (String, String) {
        let ulocdata = try! locale.identifier.withCString { localeIdent in
            try ICU4Swift.withCheckedStatus { ulocdata_open(localeIdent, &$0) }
        }
        defer { ulocdata_close(ulocdata) }
        
        let exemplars = try! ICU4Swift.withCheckedStatus {
            ulocdata_getExemplarSet(ulocdata, nil, 0, ULOCDATA_ES_PUNCTUATION, &$0)
        }
        defer { uset_close(exemplars) }
        
        return uset_contains(exemplars!, 0x0000FF08) != 0 ? ("（", "）") : (" (", ")")
    }
}
