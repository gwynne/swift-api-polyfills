/// Adapter mapping `AsyncSequence<UInt8>` to `AsyncSequence<String>` (line by line).
public struct _polyfill_AsyncLineSequence<Base>: AsyncSequence
    where Base: AsyncSequence, Base.Element == UInt8
{
    var base: Base
    let verbatm: Bool
    
    // See `AsyncSequence.Element`.
    public typealias Element = String
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var byteSource: Base.AsyncIterator
        var buffer: [UInt8] = []
        var leftover: UInt8? = nil
        let verbatim: Bool
        
        // See `AsyncIteratorProtocol.next()`.
        public mutating func next() async rethrows -> String? {
            let CR:   UInt8 = 0x0D, LF:   UInt8 = 0x0A
            let NEL1: UInt8 = 0xC2, NEL2: UInt8 = 0x85
            let SEP1: UInt8 = 0xE2, SEP2: UInt8 = 0x80, SEP3L: UInt8 = 0xA8, SEP3P: UInt8 = 0xA9

            func yield() -> String? {
                defer { self.buffer.removeAll(keepingCapacity: true) }
                return self.buffer.isEmpty ? nil : String(decoding: self.buffer, as: UTF8.self)
            }
            func nextByte() async throws -> UInt8? {
                defer { self.leftover = nil }
                if let leftover = self.leftover { return leftover }
                else { return try await self.byteSource.next() }
            }
            
            while let first = try await nextByte() {
                switch first {
                case CR:
                    if let next = try await self.byteSource.next(), next != LF { self.leftover = next }
                    if !self.verbatim { continue }
                case LF:
                    if !self.verbatim { continue }
                case NEL1:
                    guard let next = try await self.byteSource.next() else { self.buffer.append(first); break }
                    guard next == NEL2                                else { self.buffer.append(contentsOf: [first, next]); continue }
                case SEP1:
                    guard let next = try await self.byteSource.next() else { self.buffer.append(first); break }
                    guard next == SEP2                                else { self.buffer.append(contentsOf: [first, next]); continue }
                    guard let fin = try await self.byteSource.next()  else { self.buffer.append(contentsOf: [first, next]); break }
                    guard fin == SEP3L || fin == SEP3P                else { self.buffer.append(contentsOf: [first, next, fin]); continue }
                    if !self.verbatim { continue }
                default: self.buffer.append(first); continue
                }
                return yield() ?? ""
            }
            return yield()
        }

    }

    // See `AsyncSequence.makeAsyncIterator()`.
    public func makeAsyncIterator() -> Self.AsyncIterator {
        .init(byteSource: self.base.makeAsyncIterator(), verbatim: self.verbatm)
    }
}

extension _polyfill_AsyncLineSequence: Sendable where Base: Sendable {}

extension _polyfill_AsyncLineSequence.AsyncIterator: Sendable where Base.AsyncIterator: Sendable {}

extension AsyncSequence where Self.Element == UInt8 {
    public var _polyfill_lines: _polyfill_AsyncLineSequence<Self> {
        .init(base: self, verbatm: false)
    }

    /// Identical to ``lines``, except adjacent sequences of newlines are not collapsed (blank lines are preserved).
    public var _polyfill_noncompactedLines: _polyfill_AsyncLineSequence<Self> {
        .init(base: self, verbatm: true)
    }
}
