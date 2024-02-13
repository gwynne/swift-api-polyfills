/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<UnicodeScalar>`.
public struct _polyfill_AsyncUnicodeScalarSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    // See `AsyncSequence.Element`.
    public typealias Element = UnicodeScalar
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async rethrows -> UnicodeScalar? {
            fatalError()
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init()
    }
}

extension _polyfill_AsyncUnicodeScalarSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncUnicodeScalarSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_unicodeScalars: _polyfill_AsyncUnicodeScalarSequence<Self> {
        .init()
    }
}
