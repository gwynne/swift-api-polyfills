import struct Foundation.URL
import struct Foundation.URLRequest
import class Foundation.URLResponse
import protocol Foundation.URLSessionTaskDelegate
import class Foundation.URLSession
import class Foundation.URLSessionDataTask

/// AsyncBytes conforms to AsyncSequence for data delivery. The sequence is single pass. Delegate will not be called for response and data delivery.
public struct _polyfill_AsyncURLSessionBytes: AsyncSequence, Sendable {
    /// Underlying data task providing the bytes.
    public var task: URLSessionDataTask {
        fatalError()
    }

    public typealias Element = UInt8

    public struct Iterator: AsyncIteratorProtocol, Sendable {
        public mutating func next() async throws -> UInt8? {
            fatalError()
        }
    }

    public func makeAsyncIterator() -> Self.Iterator {
        .init()
    }
}

extension Foundation.URLSession {
    /// Returns a byte stream that conforms to AsyncSequence protocol.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data stream and response.
    public func _polyfill_bytes(
        for request: Foundation.URLRequest,
        delegate: (any Foundation.URLSessionTaskDelegate)? = nil
    ) async throws -> (_polyfill_AsyncURLSessionBytes, Foundation.URLResponse) {
        fatalError()
    }

    /// Returns a byte stream that conforms to AsyncSequence protocol.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data stream and response.
    public func _polyfill_bytes(
        from url: Foundation.URL,
        delegate: (any Foundation.URLSessionTaskDelegate)? = nil
    ) async throws -> (_polyfill_AsyncURLSessionBytes, Foundation.URLResponse) {
        fatalError()
    }
}
