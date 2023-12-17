import struct Foundation.URL
import struct Foundation.URLComponents
import class Foundation.FileManager

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension URL {
    /// The working directory of the current process.
    /// Calling this property will issue a `getcwd` syscall.
    public static func _polyfill_currentDirectory() -> URL {
        self.init(_polyfill_filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
    }
    
    /// The home directory for the current user (`~/`).
    /// Complexity: O(1)
    public static var _polyfill_homeDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
    }

    /// The temporary directory for the current user.
    /// Complexity: O(1)
    public static var _polyfill_temporaryDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    /// Discardable cache files directory for the
    /// current user. (~/Library/Caches).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_cachesDirectory: URL {
        try! self.init(_polyfill_for: .cachesDirectory, in: .userDomainMask, create: true)
    }

    /// Supported applications (/Applications).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_applicationDirectory: URL {
        try! self.init(_polyfill_for: .applicationDirectory, in: .localDomainMask, create: true)
    }

    /// Various user-visible documentation, support, and configuration
    /// files for the current user (~/Library).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_libraryDirectory: URL {
        try! self.init(_polyfill_for: .libraryDirectory, in: .userDomainMask, create: true)
    }

    /// User home directories (/Users).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_userDirectory: URL {
        try! self.init(_polyfill_for: .userDirectory, in: .localDomainMask, create: true)
    }

    /// Documents directory for the current user (~/Documents)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_documentsDirectory: URL {
        try! self.init(_polyfill_for: .documentDirectory, in: .userDomainMask, create: true)
    }

    /// Desktop directory for the current user (~/Desktop)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_desktopDirectory: URL {
        try! self.init(_polyfill_for: .desktopDirectory, in: .userDomainMask, create: true)
    }

    /// Application support files for the current
    /// user (~/Library/Application Support)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_applicationSupportDirectory: URL {
        try! self.init(_polyfill_for: .applicationSupportDirectory, in: .userDomainMask, create: true)
    }

    /// Downloads directory for the current user (~/Downloads)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_downloadsDirectory: URL {
        try! self.init(_polyfill_for: .downloadsDirectory, in: .userDomainMask, create: true)
    }

    /// Movies directory for the current user (~/Movies)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_moviesDirectory: URL {
        try! self.init(_polyfill_for: .moviesDirectory, in: .userDomainMask, create: true)
    }

    /// Music directory for the current user (~/Music)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_musicDirectory: URL {
        try! self.init(_polyfill_for: .musicDirectory, in: .userDomainMask, create: true)
    }

    /// Pictures directory for the current user (~/Pictures)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_picturesDirectory: URL {
        try! self.init(_polyfill_for: .picturesDirectory, in: .userDomainMask, create: true)
    }

    /// The user’s Public sharing directory (~/Public)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_sharedPublicDirectory: URL {
        try! self.init(_polyfill_for: .sharedPublicDirectory, in: .userDomainMask, create: true)
    }

    /// Trash directory for the current user (~/.Trash)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var _polyfill_trashDirectory: URL {
        try! self.init(_polyfill_for: .trashDirectory, in: .userDomainMask, create: true)
    }

    /// Returns the home directory for the specified user.
    public static func _polyfill_homeDirectory(forUser user: String) -> URL? {
        FileManager.default.homeDirectory(forUser: user)
    }
    
    /// Initializes a new URL from a search path directory and domain, creating the directory if
    /// specified, necessary, and possible.
    public init(
        _polyfill_for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL? = nil,
        create shouldCreate: Bool = false
    ) throws {
        self = try FileManager.default.url(
            for: directory,
            in: domain,
            appropriateFor: url,
            create: shouldCreate
        )
    }
}

#if !canImport(Darwin)

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Foundation.URL {
    /// The working directory of the current process.
    /// Calling this property will issue a `getcwd` syscall.
    public static func currentDirectory() -> URL {
        self._polyfill_currentDirectory
    }
    
    /// The home directory for the current user (`~/`).
    /// Complexity: O(1)
    public static var homeDirectory: URL {
        self._polyfill_homeDirectory
    }

    /// The temporary directory for the current user.
    /// Complexity: O(1)
    public static var temporaryDirectory: URL {
        self._polyfill_temporaryDirectory
    }

    /// Discardable cache files directory for the
    /// current user. (~/Library/Caches).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var cachesDirectory: URL {
        self._polyfill_cachesDirectory
    }

    /// Supported applications (/Applications).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var applicationDirectory: URL {
        self._polyfill_applicationDirectory
    }

    /// Various user-visible documentation, support, and configuration
    /// files for the current user (~/Library).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var libraryDirectory: URL {
        self._polyfill_libraryDirectory
    }

    /// User home directories (/Users).
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var userDirectory: URL {
        self._polyfill_userDirectory
    }

    /// Documents directory for the current user (~/Documents)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var documentsDirectory: URL {
        self._polyfill_documentsDirectory
    }

    /// Desktop directory for the current user (~/Desktop)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var desktopDirectory: URL {
        self._polyfill_desktopDirectory
    }

    /// Application support files for the current
    /// user (~/Library/Application Support)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var applicationSupportDirectory: URL {
        self._polyfill_applicationSupportDirectory
    }

    /// Downloads directory for the current user (~/Downloads)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var downloadsDirectory: URL {
        self._polyfill_downloadsDirectory
    }

    /// Movies directory for the current user (~/Movies)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var moviesDirectory: URL {
        self._polyfill_moviesDirectory
    }

    /// Music directory for the current user (~/Music)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var musicDirectory: URL {
        self._polyfill_musicDirectory
    }

    /// Pictures directory for the current user (~/Pictures)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var picturesDirectory: URL {
        self._polyfill_picturesDirectory
    }

    /// The user’s Public sharing directory (~/Public)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var sharedPublicDirectory: URL {
        self._polyfill_sharedPublicDirectory
    }

    /// Trash directory for the current user (~/.Trash)
    /// Complexity: O(n) where n is the number of significant directories
    /// specified by `FileManager.SearchPathDirectory`
    public static var trashDirectory: URL {
        self._polyfill_trashDirectory
    }

    /// Returns the home directory for the specified user.
    public static func homeDirectory(forUser user: String) -> URL? {
        self._polyfill_homeDirectory(forUser: user)
    }

    /// Initializes a new URL from a search path directory and domain, creating the directory if
    /// specified, necessary, and possible.
    public init(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL? = nil,
        create shouldCreate: Bool = false
    ) throws {
        self.init(_polyfill_for: directory, in: domain, appropriateFor: url, create: shouldCreate)
    }
}

#endif
