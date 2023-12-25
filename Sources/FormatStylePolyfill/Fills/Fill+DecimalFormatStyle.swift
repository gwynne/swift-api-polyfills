#if !canImport(Darwin)

import struct Foundation.Decimal

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.Decimal {
    public typealias FormatStyle = Foundation.Decimal._polyfill_FormatStyle
}

#endif
