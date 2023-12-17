import struct Foundation.URL
import struct Foundation.URLComponents
import class Foundation.FileManager

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@_documentation(visibility: internal)
extension URL {
    /// Initializes a newly created file URL referencing the local file or directory at path, relative to a base URL.
    ///
    /// If an empty string is used for the path, then the path is assumed to be ".".
    public init(_polyfill_filePath path: String, directoryHint: _polyfill_DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
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
    public func _polyfill_appending(path: some StringProtocol, directoryHint hint: _polyfill_DirectoryHint = .inferFromPath) -> URL {
        hint == .checkFileSystem ?
            self.appendingPathComponent(.init(path)) :
            self.appendingPathComponent(.init(path), isDirectory: hint.isDirectoryParam(for: path))
    }

    /// Appends a path to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public mutating func _polyfill_append(path: some StringProtocol, directoryHint hint: _polyfill_DirectoryHint = .inferFromPath) {
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
    public func _polyfill_appending(component: some StringProtocol, directoryHint hint: _polyfill_DirectoryHint = .inferFromPath) -> URL {
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
    public mutating func _polyfill_append(component: some StringProtocol, directoryHint hint: _polyfill_DirectoryHint = .inferFromPath) {
        hint == .checkFileSystem ?
            self.appendPathComponent(.init(component)) :
            self.appendPathComponent(.init(component), isDirectory: hint.isDirectoryParam(for: component))
    }

    /// Returns a URL constructed by appending the given varidic list of path components to self.
    ///
    /// - Parameters:
    ///   - components: The list of components to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public func _polyfill_appending<S>(components: S..., directoryHint: _polyfill_DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
        self._polyfill_appending(components: components, directoryHint: directoryHint)
    }
    
    /// Actual implementation of ``\_polyfill_appending(components:directoryHint:)``, required due to old-style variadic usage in API.
    fileprivate func _polyfill_appending<S>(components: [S], directoryHint: _polyfill_DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
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
    public mutating func _polyfill_append<S>(components: S..., directoryHint: _polyfill_DirectoryHint = .inferFromPath) where S: StringProtocol {
        self._polyfill_append(components: components, directoryHint: directoryHint)
    }

    /// Actual implementation of ``\_polyfill_append(components:directoryHint:)``, required due to old-style variadic usage in API.
    fileprivate mutating func _polyfill_append<S>(components: [S], directoryHint: _polyfill_DirectoryHint = .inferFromPath) where S: StringProtocol {
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
    
    /// Options specifying how `URL` determines whether a given path or path component refers to a file or a directory.
    public enum _polyfill_DirectoryHint: Hashable {
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
            case .isDirectory: true
            case .notDirectory: false
            case .checkFileSystem:
                path.starts(with: "/") &&
                    ((try? URL(_polyfill_filePath: String(path), directoryHint: .notDirectory).resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false)
            case .inferFromPath:
                #if os(Windows)
                path.hasSuffix("\\")
                #else
                path.hasSuffix("/")
                #endif
            }
        }
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Foundation.URL {
    public typealias DirectoryHint = _polyfill_DirectoryHint

    /// Initializes a newly created file URL referencing the local file or directory at path, relative to a base URL.
    ///
    /// If an empty string is used for the path, then the path is assumed to be ".".
    public init(filePath path: String, directoryHint: DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
        self.init(_polyfill_filePath: path, directoryHint: directoryHint, relativeTo: base)
    }
    
    /// Returns a URL constructed by appending the given path to self.
    /// - Parameters:
    ///   - path: The path to add
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public func appending(path: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        self._polyfill_appending(path: path, directoryHint: hint)
    }
    
    /// Appends a path to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory
    public mutating func append(path: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) {
        self._polyfill_append(path: path, directoryHint: hint)
    }
    
    /// Returns a URL constructed by appending the given path component to self. The path component
    /// is first percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    /// - Returns: The new URL
    public func appending(component: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        self._polyfill_appending(component: component, directoryHint: hint)
    }
    
    /// Appends a path component to the receiver. The path component is first
    /// percent-encoded before being appended to the receiver.
    ///
    /// - Parameters:
    ///   - component: A path component to append to the receiver.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append(component: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) {
        self._polyfill_append(component: component, directoryHint: DirectoryHint)
    }
    
    /// Returns a URL constructed by appending the given varidic list of path components to self.
    ///
    /// - Parameters:
    ///   - components: The list of components to add.
    ///   - directoryHint: A hint to whether this URL will point to a directory.
    public func appending<S>(components: S..., directoryHint: DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
        self._polyfill_appending(components: components, directoryHint: DirectoryHint)
    }
    
    /// Appends a varidic list of path components to the URL.
    ///
    /// - parameter components: The list of components to add.
    /// - parameter directoryHint: A hint to whether this URL will point to a directory.
    public mutating func append<S>(components: S..., directoryHint: DirectoryHint = .inferFromPath) where S: StringProtocol {
        self._polyfill_append(components: components, directoryHint: DirectoryHint)
    }
}

#endif
