struct FormatterCache<Format: Hashable & Sendable, FormattingType> {
    private static var cacheLimit: Int {
        100
    }
    
    private let lock = LockedState<[Format: FormattingType]>(initialState: [:])
    
    func formatter(for config: Format, creator: () -> FormattingType) -> FormattingType {
        if let existed = self.lock.withLock({ $0[config] }) {
            return existed
        }

        let df = creator()

        self.lock.withLockExtendingLifetimeOfState {
            if $0.count > Self.cacheLimit {
                $0.removeAll()
            }
            $0[config] = df
        }
        return df
    }
    
    func removeAllObjects() {
        self.lock.withLockExtendingLifetimeOfState { $0.removeAll() }
    }
    
    subscript(key: Format) -> FormattingType? {
        self.lock.withLock { $0[key] }
    }
}


#if canImport(os)
import os.lock
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WinSDK)
import WinSDK
#endif

private struct LockedState<State> {
    private struct Lock {
        #if canImport(os)
        typealias Primitive = UnsafeMutablePointer<os_unfair_lock>
        fileprivate static func initialize(_ lock: Primitive)   { lock.initialize(to: os_unfair_lock()) }
        fileprivate static func deinitialize(_ lock: Primitive) { lock.deinitialize(count: 1) }
        fileprivate static func lock(_ lock: Primitive)         { os_unfair_lock_lock(lock) }
        fileprivate static func unlock(_ lock: Primitive)       { os_unfair_lock_unlock(lock) }
        #elseif canImport(Glibc) || canImport(Musl)
        typealias Primitive = UnsafeMutablePointer<pthread_mutex_t>
        fileprivate static func initialize(_ lock: Primitive)   { pthread_mutex_init(lock, nil) }
        fileprivate static func deinitialize(_ lock: Primitive) { pthread_mutex_destroy(lock); lock.deinitialize(count: 1) }
        fileprivate static func lock(_ lock: Primitive)         { pthread_mutex_lock(lock) }
        fileprivate static func unlock(_ lock: Primitive)       { pthread_mutex_unlock(lock) }
        #elseif canImport(WinSDK)
        typealias Primitive = UnsafeMutablePointer<SRWLOCK>
        fileprivate static func initialize(_ lock: Primitive)   { InitializeSRWLock(lock) }
        fileprivate static func deinitialize(_ lock: Primitive) { lock.deinitialize(count: 1) }
        fileprivate static func lock(_ lock: Primitive)         { AcquireSRWLockExclusive(lock) }
        fileprivate static func unlock(_ lock: Primitive)       { ReleaseSRWLockExclusive(lock) }
        #endif
    }
    
    private class Buffer: ManagedBuffer<State, Lock.Primitive.Pointee> {
        deinit {
            self.withUnsafeMutablePointerToElements { Lock.deinitialize($0) }
        }
    }

    private let buffer: ManagedBuffer<State, Lock.Primitive.Pointee>

    init(initialState: State) {
        self.buffer = Buffer.create(minimumCapacity: 1, makingHeaderWith: { buf in
            buf.withUnsafeMutablePointerToElements { Lock.initialize($0) }
            return initialState
        })
    }

    func withLock<T>(_ body: @Sendable (inout State) throws -> T) rethrows -> T {
        try self.withLockUnchecked(body)
    }
    
    func withLockUnchecked<T>(_ body: (inout State) throws -> T) rethrows -> T {
        try self.buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            defer { Lock.unlock(lock) }
            return try body(&state.pointee)
        }
    }

    func withLockExtendingLifetimeOfState<T>(_ body: (inout State) throws -> T) rethrows -> T {
        try self.buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            return try withExtendedLifetime(state.pointee) {
                defer { Lock.unlock(lock) }
                return try body(&state.pointee)
            }
        }
    }
}

