import ICU

#if !canImport(Darwin)

import struct Foundation.URL
import struct Foundation.URLComponents
import class Foundation.FileManager

// This file provides the complete set of URL methods added in the macOS 13 (Ventura) SDK, implemented as completely
// as possible. These methods are used only on non-Darwin platforms.

extension URLComponents {
    /// This is an incomplete implementation of the `encodedHost` API provided by Ventura in that it does not
    /// handle IDNA hostnames.
    public var encodedHost: String? {
        get { self.percentEncodedHost }
        set { self.percentEncodedHost = newValue }
    }
}

extension URL {
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the host
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the host should be percent encoded, defaults to `true`.
    /// - Returns: the host component of the URL
    public func host(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self._components()?.encodedHost : self._components()?.host
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the user
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the user should be percent encoded, defaults to `true`.
    /// - Returns: the user component of the URL.
    public func user(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self._components()?.percentEncodedUser : self._components()?.user
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the password
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the password should be percent encoded, defaults to `true`.
    /// - Returns: the password component of the URL.
    public func password(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self._components()?.percentEncodedPassword : self._components()?.password
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path
    /// component of the URL; otherwise it returns an empty string.
    ///
    /// > Note: This function will resolve against the base `URL`.
    ///
    /// - Parameter percentEncoded: whether the path should be percent encoded, defaults to `true`.
    /// - Returns: the path component of the URL.
    public func path(percentEncoded: Bool = true) -> String {
        (percentEncoded ? self._components()?.percentEncodedPath : self._components()?.path) ?? "/"
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the fragment
    /// component of the URL; otherwise it returns nil.
    ///
    /// - Parameter percentEncoded: whether the fragment should be percent encoded, defaults to `true`.
    /// - Returns: the fragment component of the URL.
    public func fragment(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self._components()?.percentEncodedFragment : self._components()?.fragment
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the query
    /// of the URL; otherwise it returns nil.
    /// 
    /// - Parameter percentEncoded: whether the query should be percent encoded, defaults to `true`.
    /// - Returns: the query component of the URL.
    public func query(percentEncoded: Bool = true) -> String? {
        percentEncoded ? self._components()?.percentEncodedQuery : self._components()?.query
    }

    /// Initializes a newly created file URL referencing the local file or directory at path, relative to a base URL.
    ///
    /// If an empty string is used for the path, then the path is assumed to be ".".
    public init(filePath path: String, directoryHint: DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
        if directoryHint == .checkFileSystem {
            self.init(fileURLWithPath: path, relativeTo: base)
        } else {
            self.init(fileURLWithPath: path, isDirectory: directoryHint.isDirectoryParam(for: path), relativeTo: base)
        }
    }

    /// Returns a URL constructed by appending the given path to self.
    /// - Parameters:
    ///   - path: The path to add
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public func appending(path: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        hint == .checkFileSystem ?
            self.appendingPathComponent(.init(path)) :
            self.appendingPathComponent(.init(path), isDirectory: hint.isDirectoryParam(for: path))
    }

    /// Appends a path to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public mutating func append(path: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) {
        hint == .checkFileSystem ?
            self.appendPathComponent(.init(path)) :
            self.appendPathComponent(.init(path), isDirectory: hint.isDirectoryParam(for: path))
    }

    /// Returns a URL constructed by appending the given path component to self. The path component
    /// is first percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    /// - Returns: The new URL
    public func appending(component: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        hint == .checkFileSystem ?
            self.appendingPathComponent(.init(component)) :
            self.appendingPathComponent(.init(component), isDirectory: hint.isDirectoryParam(for: component))
    }

    /// Appends a path component to the receiver. The path component is first
    /// percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append(component: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) {
        hint == .checkFileSystem ?
            self.appendPathComponent(.init(component)) :
            self.appendPathComponent(.init(component), isDirectory: hint.isDirectoryParam(for: component))
    }

    /// Returns a URL constructed by appending the given list of `URLQueryItem` to self.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public func appending(queryItems: [URLQueryItem]) -> URL {
        var components = self._components()! // should not be possible to fail given the URL must be valid
        
        components.queryItems?.append(contentsOf: queryItems)
        return components.url(relativeTo: self.baseURL)! // again, failure isn't supposed to be possible here
    }

    /// Appends a list of `URLQueryItem` to the receiver.
    ///
    /// - Parameter queryItems: A list of `URLQueryItem` to append to the receiver.
    public mutating func append(queryItems: [URLQueryItem]) {
        self = self.appending(queryItems: queryItems)
    }

    /// Returns a URL constructed by appending the given varidic list of path components to self.
    ///
    /// - Parameters:
    ///   - components: The list of components to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public func appending<S>(components: S..., directoryHint: DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
        guard !components.isEmpty else {
            return self
        }
        
        let almost = components.dropLast().reduce(self) {
            $0.appendingPathComponent(.init($1), isDirectory: true)
        }
        
        return directoryHint == .checkFileSystem ?
            almost.appendingPathComponent(.init(components.last!)) :
            almost.appendingPathComponent(.init(components.last!), isDirectory: directoryHint.isDirectoryParam(for: components.last!))
    }

    /// Appends a varidic list of path components to the URL.
    ///
    /// - parameter components: The list of components to add.
    /// - parameter directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append<S>(components: S..., directoryHint: DirectoryHint = .inferFromPath) where S: StringProtocol {
        guard !components.isEmpty else {
            return
        }
        
        _ = components.dropLast().reduce(into: self) {
            $0.appendPathComponent(.init($1), isDirectory: true)
        }
        
        directoryHint == .checkFileSystem ?
            self.appendPathComponent(.init(components.last!)) :
            self.appendPathComponent(.init(components.last!), isDirectory: directoryHint.isDirectoryParam(for: components.last!))
    }

    /// The working directory of the current process.
    /// Calling this property will issue a `getcwd` syscall.
    public static func currentDirectory() -> URL       { self.init(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true) }
    
    /// The home directory for the current user (`~/`).
    /// Complexity: O(1)
    public static var homeDirectory: URL               { FileManager.default.homeDirectoryForCurrentUser }

    /// The temporary directory for the current user.
    /// Complexity: O(1)
    public static var temporaryDirectory: URL          { FileManager.default.temporaryDirectory }

    /// Discardable cache files directory for the
    /// current user. (~/Library/Caches).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var cachesDirectory: URL             { try! self.init(for: .cachesDirectory, in: .userDomainMask, create: true) }

    /// Supported applications (/Applications).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var applicationDirectory: URL        { try! self.init(for: .applicationDirectory, in: .localDomainMask, create: true) }

    /// Various user-visible documentation, support, and configuration
    /// files for the current user (~/Library).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var libraryDirectory: URL            { try! self.init(for: .libraryDirectory, in: .userDomainMask, create: true) }

    /// User home directories (/Users).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var userDirectory: URL               { try! self.init(for: .userDirectory, in: .localDomainMask, create: true) }

    /// Documents directory for the current user (~/Documents)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var documentsDirectory: URL          { try! self.init(for: .documentDirectory, in: .userDomainMask, create: true) }

    /// Desktop directory for the current user (~/Desktop)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var desktopDirectory: URL            { try! self.init(for: .desktopDirectory, in: .userDomainMask, create: true) }

    /// Application support files for the current
    /// user (~/Library/Application Support)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var applicationSupportDirectory: URL { try! self.init(for: .applicationSupportDirectory, in: .userDomainMask, create: true) }

    /// Downloads directory for the current user (~/Downloads)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var downloadsDirectory: URL          { try! self.init(for: .downloadsDirectory, in: .userDomainMask, create: true) }

    /// Movies directory for the current user (~/Movies)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var moviesDirectory: URL             { try! self.init(for: .moviesDirectory, in: .userDomainMask, create: true) }

    /// Music directory for the current user (~/Music)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var musicDirectory: URL              { try! self.init(for: .musicDirectory, in: .userDomainMask, create: true) }

    /// Pictures directory for the current user (~/Pictures)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var picturesDirectory: URL           { try! self.init(for: .picturesDirectory, in: .userDomainMask, create: true) }

    /// The user’s Public sharing directory (~/Public)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var sharedPublicDirectory: URL       { try! self.init(for: .sharedPublicDirectory, in: .userDomainMask, create: true) }

    /// Trash directory for the current user (~/.Trash)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var trashDirectory: URL              { try! self.init(for: .trashDirectory, in: .userDomainMask, create: true) }

    /// Returns the home directory for the specified user.
    public static func homeDirectory(forUser user: String) -> URL? { FileManager.default.homeDirectory(forUser: user) }
    
    public init(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL? = nil,
        create shouldCreate: Bool = false
    ) throws {
        self = try FileManager.default.url(for: directory, in: domain, appropriateFor: url, create: shouldCreate)
    }
    
    public enum DirectoryHint {
        /// Specifies that the `URL` does reference a directory
        case isDirectory

        /// Specifies that the `URL` does **not** reference a directory
        case notDirectory

        /// Specifies that `URL` should check with the file system to determine whether it references a directory
        case checkFileSystem

        /// Specifies that `URL` should infer whether is references a directory based on whether it has a trialing slash
        case inferFromPath

        fileprivate func isDirectoryParam(for path: some StringProtocol) -> Bool {
            switch self {
            case .isDirectory: return true
            case .notDirectory: return false
            case .checkFileSystem: return false
            case .inferFromPath:
                #if os(Windows)
                return path.hasSuffix("\\")
                #else
                return path.hasSuffix("/")
                #endif
            }
        }
    }

    private func _components() -> URLComponents? {
        .init(url: self, resolvingAgainstBaseURL: false)
    }
}

#endif
