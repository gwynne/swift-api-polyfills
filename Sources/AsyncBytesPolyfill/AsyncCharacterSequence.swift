/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<Character>`.
public struct _polyfill_AsyncCharacterSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    // See `AsyncSequence.Element`.
    public typealias Element = Character
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async throws -> Character? {
            fatalError()
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init()
    }
}

extension _polyfill_AsyncCharacterSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncCharacterSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_characters: _polyfill_AsyncCharacterSequence<Self> {
        .init()
    }
}
