/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<String>` (line by line).
public struct _polyfill_AsyncLineSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    // See `AsyncSequence.Element`.
    public typealias Element = String
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async throws -> String? {
            fatalError()
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init()
    }
}

extension _polyfill_AsyncLineSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncLineSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_lines: _polyfill_AsyncLineSequence<Self> {
        .init()
    }
}
