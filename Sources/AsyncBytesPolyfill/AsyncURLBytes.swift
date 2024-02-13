import struct Foundation.URL

/// `AsyncSequence<UInt8>` over the bytes of a URL's resource.
public struct _polyfill_AsyncURLBytes: AsyncSequence, Sendable {
    // See `AsyncSequence.Element`.
    public typealias Element = UInt8

    public struct AsyncIterator: AsyncIteratorProtocol, Sendable {
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async throws -> UInt8? {
            fatalError()
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init()
    }
}

extension Foundation.URL {
    public var _polyfill_resourceBytes: _polyfill_AsyncURLBytes {
        .init()
    }

    public var _polyfill_lines: _polyfill_AsyncLineSequence<_polyfill_AsyncURLBytes> {
        .init()
    }
}
