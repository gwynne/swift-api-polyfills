import CLegacyLibICU

extension ICU4Swift {
    /// Wrapper for `ufieldpositer`.
    package final class FieldPositer {
        /// A `Sequence` type representing the fields found by a ``ICU4Swift/FieldPositer``.
        package struct Fields: Sequence {
            /// `Element` of ``ICU4Swift/FieldPositer/Fields-swift.struct``
            package struct Element {
                package let field: Int32
                package let begin: Int
                package let end: Int
            }
            
            /// `Iterator` for ``ICU4Swift/FieldPositer/Fields-swift.struct``.
            package struct Iterator: IteratorProtocol {
                fileprivate let positer: FieldPositer
                
                // See `IteratorProtocol.next()`.
                package mutating func next() -> Element? {
                    var begin = 0 as Int32, end = 0 as Int32
                    let field = ufieldpositer_next(self.positer.positer, &begin, &end)
                    
                    return field >= 0 ? .init(field: field, begin: Int(begin), end: Int(end)) : nil
                }
            }
            
            fileprivate let positer: FieldPositer

            // See `Sequence.makeIterator()`.
            package func makeIterator() -> Iterator {
                .init(positer: self.positer)
            }
        }

        package let positer: OpaquePointer
        
        package init() throws {
            self.positer = try ICU4Swift.withCheckedStatus { ufieldpositer_open(&$0) }
        }
        
        deinit {
            ufieldpositer_close(self.positer)
        }
        
        package var fields: Fields {
            .init(positer: self)
        }
    }
}
