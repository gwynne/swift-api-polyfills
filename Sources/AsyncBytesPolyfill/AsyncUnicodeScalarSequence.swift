/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<UnicodeScalar>`.
public struct _polyfill_AsyncUnicodeScalarSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    var base: Base
    
    // See `AsyncSequence.Element`.
    public typealias Element = UnicodeScalar
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var base: Base.AsyncIterator
        var leftover: UInt8? = nil
        
        private func expectedContinuationCountForByte(_ byte: UInt8) -> Int? {
            if byte & 0b11100000 == 0b11000000      { 1 }
            else if byte & 0b11110000 == 0b11100000 { 2 }
            else if byte & 0b11111000 == 0b11110000 { 3 }
            else if byte & 0b10000000 == 0b00000000 { 0 }
            else                                    { nil }
        }
        
        private mutating func nextComplexScalar(_ first: UInt8) async rethrows -> UnicodeScalar? {
            guard let expectedContinuationCount = self.expectedContinuationCountForByte(first) else {
                return "\u{FFFD}"
            }
            
            var bytes: (UInt8, UInt8, UInt8, UInt8) = (first, 0, 0, 0), numContinuations = 0
            
            while numContinuations < expectedContinuationCount, let next = try await self.base.next() {
                guard UTF8.isContinuation(next) else {
                    self.leftover = next
                    break
                }
                numContinuations += 1
                withUnsafeMutableBytes(of: &bytes) { $0[numContinuations] = next }
            }
            return withUnsafeBytes(of: &bytes) { String(decoding: $0, as: UTF8.self).unicodeScalars.first }
        }
        
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async rethrows -> UnicodeScalar? {
            if let leftover = self.leftover {
                self.leftover = nil
                return try await self.nextComplexScalar(leftover)
            } else if let byte = try await self.base.next() {
                if UTF8.isASCII(byte) {
                    return UnicodeScalar(byte)
                } else {
                    return try await self.nextComplexScalar(byte)
                }
            } else {
                return nil
            }
        }
    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init(base: base.makeAsyncIterator())
    }
}

extension _polyfill_AsyncUnicodeScalarSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncUnicodeScalarSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_unicodeScalars: _polyfill_AsyncUnicodeScalarSequence<Self> {
        .init(base: self)
    }
}
