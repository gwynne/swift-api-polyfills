#if $RetroactiveAttribute

extension KeyPath: @retroactive @unchecked Sendable {}

#else

extension KeyPath: @unchecked Sendable {}

#endif
