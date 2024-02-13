import struct Foundation.Locale
import CLegacyLibICU
import PolyfillCommon

/// A type that formats lists of items with a separator and conjunction appropriate for a given locale.
///
/// A list format style creates human readable text from a `Sequence` of values. Customize the formatting behavior
/// of the list using the `width`, `listType`, and `locale` properties. The system automatically caches unique
/// configurations of `ListFormatStyle` to enhance performance.
///
/// Use either `formatted()` or `formatted(_:)`, both instance methods of `Sequence`, to create a string
/// representation of the items.
///
/// The `formatted()` method applies the default list format style to a sequence of strings. For example:
///
/// ```swift
/// ["Kristin", "Paul", "Ana", "Bill"].formatted()
/// // Kristin, Paul, Ana, and Bill
/// ```
///
/// You can customize a list’s type and width properties.
///
/// - The `listType` property specifies the semantics of the list.
/// - The `width` property determines the size of the returned string.
///
/// The `formatted(_:)` method to applies a custom list format style. You can use the static factory method
/// `list(type:width:)` to create a custom list format style as a parameter to the method.
///
/// This example formats a sequence with a `ListFormatStyle.ListType.and` list type and
/// `ListFormatStyle.Width.short` width:
///
/// ```swift
/// ["Kristin", "Paul", "Ana", "Bill"].formatted(.list(type: .and, width: .short))
/// // Kristin, Paul, Ana, & Bill
/// ```
///
/// You can provide a member format style to transform each list element to a string in applications where the
/// elements aren’t already strings. For example, the following code sample uses an `IntegerFormatStyle` to convert
/// a range of integer values into a list:
///
/// ```swift
/// (5201719 ... 5201722).formatted(.list(memberStyle: IntegerFormatStyle(), type: .or, width: .standard))
/// // For locale: en_US: 5,201,719, 5,201,720, 5,201,721, or 5,201,722
/// // For locale: fr_CA: 5 201 719, 5 201 720, 5 201 721, ou 5 201 722
/// ```
///
/// > Note: The generated string is locale-dependent and incorporates linguistic and cultural conventions of the user.
///
/// You can create and reuse a list format style instance to format similar sequences. For example:
///
/// ```swift
/// let percentStyle = ListFormatStyle<FloatingPointFormatStyle.Percent, StrideThrough<Double>>(memberStyle: .percent)
/// stride(from: 7.5, through: 9.0, by: 0.5).formatted(percentStyle)
/// // 7.5%, 8%, 8.5%, and 9%
/// stride(from: 89.0, through: 95.0, by: 2.0).formatted(percentStyle)
/// // 89%, 91%, 93%, and 95%
/// ```
public struct _polyfill_ListFormatStyle<
    Style: _polyfill_FormatStyle,
    Base: Sequence<Style.FormatInput>
>: _polyfill_FormatStyle
    where Style.FormatOutput == String
{
    /// The type representing the width of a list.
    ///
    /// The possible values of a `width` are `standard`, `short`, and `narrow`.
    public enum Width: Int, Codable, Sendable {
        /// Specifies a standard list style.
        case standard
        
        /// Specifies a short list style.
        case short
        
        /// Specifies a narrow list style, the shortest list style.
        case narrow
    }

    /// A type that describes whether the returned list contains cumulative or alternative elements.
    ///
    /// The possible values of a `listType` are `and` and `or`.
    public enum ListType: Int, Codable, Sendable {
        /// Specifies an _and_ list type.
        case and
        
        /// Specifies an _or_ list type.
        case or
    }

    private let memberStyle: Style
    
    /// The size of the list.
    ///
    /// The `width` property controls the size of the list. The locale determines the formatting and abbreviation
    /// of the string for the given width.
    ///
    /// For example, for English:
    ///
    /// ```swift
    /// ["One", "Two", "Three"].formatted(.list(type: .and, width: .standard))
    /// // “One, Two, and Three”
    ///
    /// ["One", "Two", "Three"].formatted(.list(type: .and, width: .short))
    /// // “One, Two, & Three”
    ///
    /// ["One", "Two", "Three"].formatted(.list(type: .and, width: .narrow))
    /// // “One, Two, Three”
    /// ```
    ///
    /// The default value is `ListFormatStyle.Width.standard`.
    public var width: Width
    
    /// The type of the list.
    ///
    /// The list type determines the semantics used in the returned string.
    ///
    /// For example, for `en_US`:
    ///
    /// ```swift
    /// ["One", "Two", "Three"].formatted(.list(type: .and))
    /// // “One, Two, and Three”
    ///
    /// ["One", "Two", "Three"].formatted(.list(type: .or))
    /// // “One, Two, or Three”
    /// ```
    ///
    /// The default value is `ListFormatStyle.ListType.and`
    public var listType: ListType
    
    /// The locale to use when formatting items in the list.
    ///
    /// A `Locale` instance is typically used to provide, format, and interpret information about and according
    /// to the user’s customs and preferences.
    ///
    /// Examples include ISO region and language codes, currency code, calendar, system of measurement, and
    /// decimal separator.
    ///
    /// The default value is `autoupdatingCurrent`. If you set this property to `nil`, the formatter resets to
    /// using `autoupdatingCurrent`.
    public var locale: Foundation.Locale
    
    /// Creates an instance using the provided format style.
    ///
    /// - Parameter memberStyle: The `FormatStyle` applied to elements of the `Sequence`.
    ///
    /// The input type of `memberStyle` must match the type of an element in the sequence. The output
    /// type is a string.
    ///
    /// The following example uses a `FloatingPointFormatStyle.Descriptive` member style to spell out a list:
    ///
    /// ```swift
    /// [-3.0, 9.0, 11.6].formatted(.list(memberStyle: .descriptive, type: .and))
    /// // minus three, nine, and eleven point six
    /// ```
    public init(memberStyle: Style) {
        self.memberStyle = memberStyle
        self.width = .standard
        self.listType = .and
        self.locale = .autoupdatingCurrent
    }

    /// Creates a locale-aware string representation of the value.
    ///
    /// The `format(_:)` instance method generates a string from the provided sequence. Once you create a
    /// style, you can use it to format similar sequences multiple times. For example:
    ///
    /// ```swift
    /// let percentStyle = ListFormatStyle<IntegerFormatStyle.Percent, [Int]>(memberStyle: .percent)
    /// percentStyle.format([92, 98]) // 92% and 98%
    /// percentStyle.format([67, 72, 99]) // 67%, 72%, and 99%
    /// ```
    ///
    /// - Parameter value: The sequence of elements to format.
    /// - Returns: A string representation of the provided sequence.
    public func format(_ value: Base) -> String {
        ICUListFormatter.formatter(for: self).format(strings: value.map(memberStyle.format(_:)))
    }
    
    /// Modifies the list format style to use the specified locale.
    /// 
    /// - Parameter locale: The locale to use when formatting items in the list.
    /// - Returns: A list format style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        var new = self
        new.locale = locale
        return new
    }
}

extension _polyfill_ListFormatStyle: Sendable where Style: Sendable {}

/// A type which formats a string by returning it unmodified.
///
/// This is intended for use with `ListFormatStyle`.
public struct _polyfill_StringStyle: _polyfill_FormatStyle, Sendable {
    /// Creates a locale-aware string representation of the value.
    ///
    /// The `format(_:)` instance method returns its input unmodified, regardless of the locale setting.
    ///
    /// - Parameter value: The string to format.
    /// - Returns: `value` unmodified.
    public func format(_ value: String) -> String {
        value
    }
}

extension Swift.Sequence {
    public func _polyfill_formatted<S>(
        _ style: S
    ) -> S.FormatOutput
        where S: _polyfill_FormatStyle, S.FormatInput == Self
    {
        style.format(self)
    }
}

extension Swift.Sequence<String> {
    public func _polyfill_formatted() -> String {
        self._polyfill_formatted(_polyfill_ListFormatStyle(memberStyle: _polyfill_StringStyle()))
    }
}

extension _polyfill_FormatStyle {
    /// Creates a list format style using the provided format style and list style.
    /// 
    /// - Parameters:
    ///   - memberStyle: The `FormatStyle` applied to elements of the `Sequence`.
    ///   - type: The type of the list.
    ///   - width: The width of the list.
    /// - Returns: A list format style using the specified member style, type, and width.
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

    /// Creates a list format style using the provided type and width.
    /// 
    /// - Parameters:
    ///   - type: The type of the list.
    ///   - width: The width of the list.
    /// - Returns: A list format style using the specified type and width.
    public static func list<Base>(
        type: Self.ListType,
        width: Self.Width = .standard
    ) -> Self where Self == _polyfill_ListFormatStyle<_polyfill_StringStyle, Base> {
        .list(memberStyle: .init(), type: type, width: width)
    }
}

final class ICUListFormatter {
    private struct Signature: Hashable {
        let localeIdentifier: String
        let listType: Int
        let width: Int
    }

    private static let cache = FormatterCache<Signature, ICUListFormatter>()

    let uformatter: OpaquePointer

    private init(signature: Signature) {
        self.uformatter = try! ICU4Swift.withCheckedStatus {
            ulistfmt_openForType(
                signature.localeIdentifier,
                [ULISTFMT_TYPE_AND,   ULISTFMT_TYPE_OR,     ULISTFMT_TYPE_UNITS  ][signature.listType],
                [ULISTFMT_WIDTH_WIDE, ULISTFMT_WIDTH_SHORT, ULISTFMT_WIDTH_NARROW][signature.width],
                &$0
            )
        }
    }

    deinit {
        ulistfmt_close(self.uformatter)
    }

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
        defer {
            for pointer in stringPointers {
                pointer?.deallocate()
            }
        }

        return ICU4Swift.withResizingUCharBuffer {
            ulistfmt_format(self.uformatter, stringPointers, stringLengths, Int32(strings.count), $0, $1, &$2)
        } ?? ""
    }

    static func formatter<Style, Base>(for style: _polyfill_ListFormatStyle<Style, Base>) -> ICUListFormatter {
        let signature = Signature(
            localeIdentifier: style.locale.identifier,
            listType: style.listType.rawValue,
            width: style.width.rawValue
        )

        return Self.cache.formatter(for: signature) {
            .init(signature: signature)
        }
    }
}
