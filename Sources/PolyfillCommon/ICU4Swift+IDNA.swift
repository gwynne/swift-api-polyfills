import protocol Foundation.CustomNSError
import CLegacyLibICU

extension UIDNAInfo {
    /// `UIDNA_INFO_INITIALIZER` for Swift.
    package init() {
        self.init(size: Int16(MemoryLayout<Self>.size), isTransitionalDifferent: 0, reservedB3: 0, errors: 0, reservedI2: 0, reservedI3: 0)
    }
}

extension ICU4Swift {
    /// A simple wrapper around ICU's UTS#46 IDNA C functions.
    ///
    /// > Note: Safe to mark as `Sendable` because ICU's documentation for `uidna_openUTS45()` explicitly states:
    /// >
    /// > The instance is thread-safe, that is, it can be used concurrently.
    package final class IDNA: @unchecked Sendable {
        package struct Options: OptionSet, Hashable, Sendable {
            package let rawValue: Int
            package init(rawValue: Int) { self.rawValue = rawValue }
            
            package static let useSTD3Rules: Self = .init(rawValue: UIDNA_USE_STD3_RULES)
            package static let checkBIDI: Self = .init(rawValue: UIDNA_CHECK_BIDI)
            package static let checkContextJRules: Self = .init(rawValue: UIDNA_CHECK_CONTEXTJ)
            package static let nontransitionalToASCII: Self = .init(rawValue: UIDNA_NONTRANSITIONAL_TO_ASCII)
            package static let nontransitionalToUnicode: Self = .init(rawValue: UIDNA_NONTRANSITIONAL_TO_UNICODE)
        }
        
        private let instance: OpaquePointer
        
        package init(options: Options = []) throws {
            self.instance = try ICU4Swift.withCheckedStatus { uidna_openUTS46(UInt32(options.rawValue), &$0) }
        }
        
        deinit {
            uidna_close(self.instance)
        }
        
        private func transformUTF8(
            _ input: String,
            using call: (
                _ uidna: OpaquePointer?,
                _ input: UnsafePointer<CChar>?,
                _ length: Int32,
                _ dest: UnsafeMutablePointer<CChar>?,
                _ capacity: Int32,
                _ pInfo: UnsafeMutablePointer<UIDNAInfo>?,
                _ status: UnsafeMutablePointer<UErrorCode>?
            ) -> Int32
        ) throws -> String {
            var info = UIDNAInfo()
            let needed = try ICU4Swift.withCheckedStatus(U_BUFFER_OVERFLOW_ERROR) { call(self.instance, input, -1, nil, 0, &info, &$0) }
            
            return try withUnsafeTemporaryAllocation(of: CChar.self, capacity: Int(needed + 1)) { buf in
                _ = try ICU4Swift.withCheckedStatus { call(self.instance, input, -1, buf.baseAddress, Int32(buf.count), &info, &$0) }
                return String(validatingUTF8: buf.baseAddress!)!
            }
        }
        
        /// Encode a complete domain name (having one or more labels) using IDNA.
        ///
        /// The input is returned unmodified if it contains no non-ASCII characters _and_ no otherwise invalid ASCII
        /// characters (i.e. anything not considered valid in a URL authority's hostname field).
        package func encode(name: String) throws -> String {
            try self.transformUTF8(name, using: uidna_nameToASCII_UTF8(_:_:_:_:_:_:_:))
        }
        
        /// Decode a complete domain name potentially encoded with IDNA.
        package func decode(name: String) throws -> String {
            try self.transformUTF8(name, using: uidna_nameToUnicodeUTF8(_:_:_:_:_:_:_:))
        }
        
        /// Encode a single domain label (a single component of a domain name, containing no `.` characters) using IDNA.
        ///
        /// The input is returned unmodified if it contains no non-ASCII characters _and_ no otherwise invalid ASCII
        /// characters (i.e. anything not considered valid in a domain name label).
        package func encode(label: String) throws -> String {
            try self.transformUTF8(label, using: uidna_labelToASCII_UTF8(_:_:_:_:_:_:_:))
        }

        /// Decode a single domain label potentially encoded with IDNA.
        package func decode(label: String) throws -> String {
            try self.transformUTF8(label, using: uidna_labelToUnicodeUTF8(_:_:_:_:_:_:_:))
        }
    }
}
