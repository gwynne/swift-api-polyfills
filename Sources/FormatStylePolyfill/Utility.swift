extension Swift.RangeExpression {
    func clampedLowerAndUpperBounds(_ boundary: Range<Int>) -> (lower: Int?, upper: Int?) {
        var lower: Int?, upper: Int?
        
        switch self {
        case let self as Range<Int>:
            let clamped = self.clamped(to: boundary)
            (lower, upper) = (clamped.lowerBound, clamped.upperBound)
        case let self as ClosedRange<Int>:
            let clamped = self.clamped(to: ClosedRange(boundary))
            (lower, upper) = (clamped.lowerBound, clamped.upperBound)
        case let self as PartialRangeFrom<Int>:
            (lower, upper) = (Swift.max(self.lowerBound, boundary.lowerBound), nil)
        case let self as PartialRangeThrough<Int>:
            (lower, upper) = (nil, Swift.min(self.upperBound, boundary.upperBound))
        case let self as PartialRangeUpTo<Int>:
            let (val, overflow) = self.upperBound.subtractingReportingOverflow(1)
            (lower, upper) = (nil, Swift.min(overflow ? self.upperBound : val, boundary.upperBound))
        default:
            (lower, upper) = (nil, nil)
        }
        return (lower: lower.map { Swift.min($0, boundary.upperBound) }, upper: upper.map { Swift.max($0, boundary.lowerBound) })
    }
}
