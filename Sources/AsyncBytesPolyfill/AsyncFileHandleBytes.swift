import class Foundation.FileHandle

/// `AsyncSequence<UInt8>` over the bytes of a `FileHandle`.
public struct _polyfill_AsyncFileHandleBytes: AsyncSequence, Sendable {
    // See `AsyncSequence.Element`.
    public typealias Element = UInt8
    
    public struct Iterator: AsyncIteratorProtocol, Sendable {
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async throws -> UInt8? {
            fatalError()
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.Iterator {
        .init()
    }
}

extension Foundation.FileHandle {
    public var _polyfill_bytes: _polyfill_AsyncFileHandleBytes {
        .init()
    }
}
