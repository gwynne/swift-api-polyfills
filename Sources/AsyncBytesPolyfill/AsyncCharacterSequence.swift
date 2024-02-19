/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<Character>`.
public struct _polyfill_AsyncCharacterSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    let underlying: _polyfill_AsyncUnicodeScalarSequence<Base>
    
    // See `AsyncSequence.Element`.
    public typealias Element = Character
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var remaining: _polyfill_AsyncUnicodeScalarSequence<Base>.AsyncIterator
        var accumulator = ""
        
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async throws -> Character? {
            while let scalar = try await self.remaining.next() {
                self.accumulator.unicodeScalars.append(scalar)
                if self.accumulator.count > 1 {
                    return self.accumulator.removeFirst()
                }
            }
            return !self.accumulator.isEmpty ? self.accumulator.removeFirst() : nil
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init(remaining: self.underlying.makeAsyncIterator())
    }
}

extension _polyfill_AsyncCharacterSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncCharacterSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_characters: _polyfill_AsyncCharacterSequence<Self> {
        .init(underlying: .init(base: self))
    }
}
