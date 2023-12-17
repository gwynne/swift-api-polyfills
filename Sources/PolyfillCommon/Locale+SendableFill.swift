import struct Foundation.Locale

#if !canImport(Darwin)

#if $RetroactiveAttribute
/// Conform `Locale` to `Sendable` retroactively to silence warnings on Linux.
extension Foundation.Locale: @retroactive @unchecked Sendable {}

#else

/// Conform `Locale` to `Sendable` retroactively to silence warnings on Linux.
extension Foundation.Locale: @unchecked Sendable {}

#endif

#endif
