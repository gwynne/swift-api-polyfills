import struct Foundation.Locale
import CLegacyLibICU
import PolyfillCommon

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct _polyfill_ListFormatStyle<
    Style: _polyfill_FormatStyle,
    Base: Sequence<Style.FormatInput>
>: _polyfill_FormatStyle
    where Style.FormatOutput == String
{
    public enum Width: Int, Codable, Sendable {
        case standard
        case short
        case narrow
    }

    public enum ListType: Int, Codable, Sendable {
        case and
        case or
    }

    private let memberStyle: Style
    public var width: Width
    public var listType: ListType
    public var locale: Foundation.Locale

    public init(memberStyle: Style) {
        self.memberStyle = memberStyle
        self.width = .standard
        self.listType = .and
        self.locale = .autoupdatingCurrent
    }

    public func format(_ value: Base) -> String {
        ICUListFormatter.formatter(for: self).format(strings: value.map(memberStyle.format(_:)))
    }

    public func locale(_ locale: Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_ListFormatStyle: Sendable where Style: Sendable {}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct _polyfill_StringStyle: _polyfill_FormatStyle, Sendable {
    public func format(_ value: String) -> String { value }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Sequence {
    public func formatted<S: _polyfill_FormatStyle>(_ style: S) -> S.FormatOutput where S.FormatInput == Self {
        style.format(self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Swift.Sequence<String> {
    public func formatted() -> String {
        self.formatted(_polyfill_ListFormatStyle(memberStyle: _polyfill_StringStyle()))
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle {
    public static func list<MemberStyle, Base>(
        memberStyle: MemberStyle,
        type: Self.ListType,
        width: Self.Width = .standard
    ) -> Self where Self == _polyfill_ListFormatStyle<MemberStyle, Base> {
        var style = Self(memberStyle: memberStyle)
        style.width = width
        style.listType = type
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension _polyfill_FormatStyle {
    public static func list<Base>(
        type: Self.ListType,
        width: Self.Width = .standard
    ) -> Self where Self == _polyfill_ListFormatStyle<_polyfill_StringStyle, Base> {
        .list(memberStyle: .init(), type: type, width: width)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class ICUListFormatter {
    let uformatter: OpaquePointer

    private init(localeIdentifier: String, listType: Int, width: Int) {
        self.uformatter = try! ICU4Swift.withCheckedStatus { ulistfmt_openForType(
            localeIdentifier,
            [ULISTFMT_TYPE_AND,   ULISTFMT_TYPE_OR,     ULISTFMT_TYPE_UNITS  ][listType],
            [ULISTFMT_WIDTH_WIDE, ULISTFMT_WIDTH_SHORT, ULISTFMT_WIDTH_NARROW][width],
            &$0
        ) }
    }

    deinit { ulistfmt_close(self.uformatter) }

    func format(strings: [String]) -> String {
        var stringPointers: [UnsafePointer<UChar>?] = [], stringLengths: [Int32] = []

        stringPointers.reserveCapacity(strings.count)
        stringLengths.reserveCapacity(strings.count)

        for string in strings {
            let uchars = Array(string.utf16), ucharsPointer = UnsafeMutablePointer<UChar>.allocate(capacity: uchars.count)
            
            ucharsPointer.initialize(from: uchars, count: uchars.count)
            stringPointers.append(UnsafePointer(ucharsPointer))
            stringLengths.append(Int32(uchars.count))
        }
        defer { for pointer in stringPointers { pointer?.deallocate() } }

        return ICU4Swift._withResizingUCharBuffer {
            ulistfmt_format(self.uformatter, stringPointers, stringLengths, Int32(strings.count), $0, $1, &$2)
        } ?? ""
    }

    static func formatter<Style, Base>(for style: _polyfill_ListFormatStyle<Style, Base>) -> ICUListFormatter {
        .init(localeIdentifier: style.locale.identifier, listType: style.listType.rawValue, width: style.width.rawValue)
    }
}
