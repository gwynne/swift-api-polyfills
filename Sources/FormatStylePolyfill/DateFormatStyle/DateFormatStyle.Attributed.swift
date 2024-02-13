import struct Foundation.AttributeContainer
import enum Foundation.AttributeScopes
import struct Foundation.AttributedString
import struct Foundation.Date
import struct Foundation.Locale

extension _polyfill_DateFormatStyle {
   /// An attributed format style created from the date format style.
    ///
    /// Use a ``FormatStyle`` instance to customize the lexical representation of a date as a string. Use
    /// the format style’s ``FormatStyle/attributed`` property to customize the visual representation of
    /// the date as a string. Attributed strings can represent the subcomponent characters, words, and
    /// phrases of a string with a custom combination of font size, weight, and color.
    ///
    /// For example, the function below uses a date format style to create a custom lexical representation
    /// of a date, then retrieves an attributed string representation of the same date and applies a visual
    /// emphasis to the year component of the date.
    ///
    /// ```swift
    /// // Applies visual emphasis to the year component of a formatted attributed date string.
    /// private func makeAttributedString() -> AttributedString {
    ///     let date = Date()
    ///     let formatStyle = Date.FormatStyle(date: .abbreviated, time: .standard)
    ///     var attributedString = formatStyle.attributed.format(date)
    ///     for run in attributedString.runs {
    ///         if let dateFieldAttribute = run.attributes.foundation.dateField,
    ///            dateFieldAttribute == .year {
    ///             // When you find a year, change its attributes.
    ///             attributedString[run.range].inlinePresentationIntent = [.emphasized, .stronglyEmphasized]
    ///         }
    ///     }
    ///     return attributedString
    /// }
    /// ```
    ///
    /// The expression `formatStyle.attributed.format(date)` above creates an attributed string representation
    /// of the date. This assigns instances of the `AttributeScopes.FoundationAttributes.DateFieldAttribute` to
    /// indicate ranges of the string that represent different date fields. The example then loops over the runs
    /// of the attributed string to find any run with the
    /// `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year` attribute. When it finds one, it
    /// adds the `inlinePresentationIntent` attributes `emphasized` and `stronglyEmphasized`.
    ///
    /// The runs of the resulting attributed string have the following attributes:
    ///
    /// | Run text | Attributes                                                             |
    /// |:---------|:-----------------------------------------------------------------------|
    /// | `Mar`    | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.month`  |
    /// | `15`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.day`    |
    /// | `2022`   | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year`   |
    /// |          | `emphasized`                                                           |
    /// |          | `stronglyEmphasized`                                                   |
    /// | `10`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.hour`   |
    /// | `06`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.minute` |
    /// | `46`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.second` |
    /// | `AM`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.amPM`   |
    ///
    /// If you create a SwiftUI `Text` view with this attributed string, SwiftUI renders the combination
    /// of `emphasized` and `stronglyEmphasized` attributes as bold, italicized text, as seen in the
    /// following screenshot.
    ///
    /// ![A macOS window with a text view showing the current date and time. The year is displayed
    /// in bold, italicized text.][sampleimg]
    ///
    /// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMzk4IiBoZWlnaHQ9IjE1MiIgdmlld0JveD0iMCAwIDM5OCAxNTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NTAwIDI3LjVweCAnU0YgUHJvIFRleHQnLHNhbnMtc2VyaWY7bGV0dGVyLXNwYWNpbmc6MHB4Ij48ZGVmcz48bGluZWFyR3JhZGllbnQgaWQ9ImEiIHgyPSIwIiB5MT0iNTYiIHkyPSI1OCIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPjxzdG9wIHN0b3AtY29sb3I9IiNiZWJlYmUiLz48c3RvcCBzdG9wLWNvbG9yPSIjZTllOWU5IiBvZmZzZXQ9IjEiLz48L2xpbmVhckdyYWRpZW50PjwvZGVmcz48cGF0aCBkPSJtMCw1Ni41aDM5OHptMCwxaDM5OHoiIHN0cm9rZT0idXJsKCNhKSIvPjxnIHN0cm9rZS13aWR0aD0iMiI%2BPHBhdGggZD0ibTIsNTZoMzk0di00MWMwLTcuMi01LjgtMTMtMTMtMTNoLTM2OGMtNy4yLDAtMTMsNS44LTEzLDEzeiIgZmlsbD0iI2ZiZmJmYiIvPjxwYXRoIGQ9Im0yLDU4aDM5NHY4MWMwLDcuMi01LjgsMTMtMTMsMTNoLTM2OGMtNy4yLDAtMTMtNS44LTEzLTEzeiIgZmlsbD0iI2Y0ZjRmNCIvPjxjaXJjbGUgY3g9IjY4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiNmOGFmMjQ7c3Ryb2tlOiNkZmE2NGMiLz48Y2lyY2xlIGN4PSIyOCIgY3k9IjI4IiByPSIxMS41IiBzdHlsZT0iZmlsbDojZjY0NTQ2O3N0cm9rZTojZTE2MjY0Ii8%2BPGNpcmNsZSBjeD0iMTA4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiMyOWMyMzE7c3Ryb2tlOiMyN2FmMzAiLz48cmVjdCB4PSIxIiB5PSIxIiB3aWR0aD0iMzk2IiBoZWlnaHQ9IjE1MCIgcng9IjE0IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojY2JjYmNiIi8%2BPC9nPjx0ZXh0IHg9IjMxIiB5PSIxMTQiPk1hciAxNSw8dHNwYW4gc3R5bGU9ImZvbnQtd2VpZ2h0OjgwMDtmb250LXN0eWxlOml0YWxpYyI%2BIDIwMjI8L3RzcGFuPiwgMTA6MDY6NDYgQU08L3RleHQ%2BPHRleHQgeD0iMTM2IiB5PSIzNyIgZm9udC13ZWlnaHQ9IjcwMCI%2BRGF0ZUZvcm1hdFRvQXR04oCmPC90ZXh0Pjwvc3ZnPg%3D%3D
    public var attributed: _polyfill_DateAttributedStyle {
        .init(style: .formatStyle(self))
    }
}

extension _polyfill_DateVerbatimFormatStyle {
    /// Returns the corresponding `AttributedStyle` which formats the date with
    ///  `AttributeScopes.FoundationAttributes.DateFormatFieldAttribute`
    public var attributed: _polyfill_DateAttributedStyle {
        .init(style: .verbatimFormatStyle(self))
    }
}

/// A structure that creates a locale-appropriate attributed string representation of a date instance.
///
/// Use a `FormatStyle` instance to customize the lexical representation of a date as a string. Use
/// the format style’s `FormatStyle.attributed` property to customize the visual representation of
/// the date as a string. Attributed strings can represent the subcomponent characters, words, and
/// phrases of a string with a custom combination of font size, weight, and color.
///
/// For example, the function below uses a date format style to create a custom lexical representation
/// of a date, then retrieves an attributed string representation of the same date and applies a visual
/// emphasis to the year component of the date.
///
/// ```swift
/// // Applies visual emphasis to the year component of a formatted attributed date string.
/// private func makeAttributedString() -> AttributedString {
///     let date = Date()
///     let formatStyle = Date.FormatStyle(date: .abbreviated, time: .standard)
///     var attributedString = formatStyle.attributed.format(date)
///     for run in attributedString.runs {
///         if let dateFieldAttribute = run.attributes.foundation.dateField,
///            dateFieldAttribute == .year {
///             // When you find a year, change its attributes.
///             attributedString[run.range].inlinePresentationIntent = [.emphasized, .stronglyEmphasized]
///         }
///     }
///     return attributedString
/// }
/// ```
///
/// The expression `formatStyle.attributed.format(date)` above creates an attributed string representation
/// of the date. This assigns instances of the `AttributeScopes.FoundationAttributes.DateFieldAttribute` to
/// indicate ranges of the string that represent different date fields. The example then loops over the runs
/// of the attributed string to find any run with the
/// `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year` attribute. When it finds one, it
/// adds the `inlinePresentationIntent` attributes `emphasized` and `stronglyEmphasized`.
///
/// The runs of the resulting attributed string have the following attributes:
///
/// | Run text | Attributes                                                             |
/// |:---------|:-----------------------------------------------------------------------|
/// | `Mar`    | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.month`  |
/// | `15`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.day`    |
/// | `2022`   | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.year`   |
/// |          | `emphasized`                                                           |
/// |          | `stronglyEmphasized`                                                   |
/// | `10`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.hour`   |
/// | `06`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.minute` |
/// | `46`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.second` |
/// | `AM`     | `AttributeScopes.FoundationAttributes.DateFieldAttribute.Field.amPM`   |
///
/// If you create a SwiftUI `Text` view with this attributed string, SwiftUI renders the combination
/// of `emphasized` and `stronglyEmphasized` attributes as bold, italicized text, as seen in the
/// following screenshot.
///
/// ![A macOS window with a text view showing the current date and time. The year is displayed
/// in bold, italicized text.][sampleimg]
///
/// [sampleimg]: data:image%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMzk4IiBoZWlnaHQ9IjE1MiIgdmlld0JveD0iMCAwIDM5OCAxNTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3R5bGU9ImZvbnQ6NTAwIDI3LjVweCAnU0YgUHJvIFRleHQnLHNhbnMtc2VyaWY7bGV0dGVyLXNwYWNpbmc6MHB4Ij48ZGVmcz48bGluZWFyR3JhZGllbnQgaWQ9ImEiIHgyPSIwIiB5MT0iNTYiIHkyPSI1OCIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPjxzdG9wIHN0b3AtY29sb3I9IiNiZWJlYmUiLz48c3RvcCBzdG9wLWNvbG9yPSIjZTllOWU5IiBvZmZzZXQ9IjEiLz48L2xpbmVhckdyYWRpZW50PjwvZGVmcz48cGF0aCBkPSJtMCw1Ni41aDM5OHptMCwxaDM5OHoiIHN0cm9rZT0idXJsKCNhKSIvPjxnIHN0cm9rZS13aWR0aD0iMiI%2BPHBhdGggZD0ibTIsNTZoMzk0di00MWMwLTcuMi01LjgtMTMtMTMtMTNoLTM2OGMtNy4yLDAtMTMsNS44LTEzLDEzeiIgZmlsbD0iI2ZiZmJmYiIvPjxwYXRoIGQ9Im0yLDU4aDM5NHY4MWMwLDcuMi01LjgsMTMtMTMsMTNoLTM2OGMtNy4yLDAtMTMtNS44LTEzLTEzeiIgZmlsbD0iI2Y0ZjRmNCIvPjxjaXJjbGUgY3g9IjY4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiNmOGFmMjQ7c3Ryb2tlOiNkZmE2NGMiLz48Y2lyY2xlIGN4PSIyOCIgY3k9IjI4IiByPSIxMS41IiBzdHlsZT0iZmlsbDojZjY0NTQ2O3N0cm9rZTojZTE2MjY0Ii8%2BPGNpcmNsZSBjeD0iMTA4IiBjeT0iMjgiIHI9IjExLjUiIHN0eWxlPSJmaWxsOiMyOWMyMzE7c3Ryb2tlOiMyN2FmMzAiLz48cmVjdCB4PSIxIiB5PSIxIiB3aWR0aD0iMzk2IiBoZWlnaHQ9IjE1MCIgcng9IjE0IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojY2JjYmNiIi8%2BPC9nPjx0ZXh0IHg9IjMxIiB5PSIxMTQiPk1hciAxNSw8dHNwYW4gc3R5bGU9ImZvbnQtd2VpZ2h0OjgwMDtmb250LXN0eWxlOml0YWxpYyI%2BIDIwMjI8L3RzcGFuPiwgMTA6MDY6NDYgQU08L3RleHQ%2BPHRleHQgeD0iMTM2IiB5PSIzNyIgZm9udC13ZWlnaHQ9IjcwMCI%2BRGF0ZUZvcm1hdFRvQXR04oCmPC90ZXh0Pjwvc3ZnPg%3D%3D
public struct _polyfill_DateAttributedStyle: Sendable, _polyfill_FormatStyle {
    enum InnerStyle: Codable, Hashable {
        case formatStyle(_polyfill_DateFormatStyle)
        case verbatimFormatStyle(_polyfill_DateVerbatimFormatStyle)
    }
    
    var innerStyle: InnerStyle

    init(style: InnerStyle) {
        self.innerStyle = style
    }

    /// Creates a locale-aware attributed string representation from a date value.
    ///
    /// The `format(_:)` instance method generates an attributed string from the provided date. Once you create
    /// a style, you can use it to format dates multiple times.
    ///
    /// For an example of formatting multiple dates into plain strings, see `format(_:)`.
    ///
    /// - Parameter value: The date to format.
    /// - Returns: An attributed string representation of the date.
    public func format(_ value: Foundation.Date) -> Foundation.AttributedString {
        let fm: ICUDateFormatter = switch innerStyle {
        case .formatStyle(let formatStyle):         ICUDateFormatter.cachedFormatter(for: formatStyle)
        case .verbatimFormatStyle(let formatStyle): ICUDateFormatter.cachedFormatter(for: formatStyle)
        }

        return if let (str, attributes) = fm.attributedFormat(value) {
            Self.attributedStringFromPositions(attributes, string: str)
        } else {
            .init(value.description)
        }
    }

    /// Modifies the date attributed style to use the specified locale.
    ///
    /// - Parameter locale: The locale to use when formatting a date.
    /// - Returns: A date attributed style with the provided locale.
    public func locale(_ locale: Foundation.Locale) -> Self {
        let newInnerStyle: InnerStyle = switch self.innerStyle {
        case .formatStyle(let style):         .formatStyle(style.locale(locale))
        case .verbatimFormatStyle(let style): .verbatimFormatStyle(style.locale(locale))
        }

        var new = self
        new.innerStyle = newInnerStyle
        return new
    }

    static func attributedStringFromPositions(
        _ positions: [ICUDateFormatter.AttributePosition],
        string: String
    ) -> Foundation.AttributedString {
        typealias DateFieldAttribute = Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field

        var attrstr = Foundation.AttributedString(string)

        for attr in positions {
            let strRange = String.Index(utf16Offset: attr.begin, in: string) ..< String.Index(utf16Offset: attr.end, in: string)
            let range = Range<Foundation.AttributedString.Index>(strRange, in: attrstr)!
            let field = attr.field
            var container = Foundation.AttributeContainer()

            if let dateField = DateFieldAttribute(udateFormatField: field) {
                container.dateField = dateField
            }
            attrstr[range].mergeAttributes(container)
        }
        return attrstr
    }
}
