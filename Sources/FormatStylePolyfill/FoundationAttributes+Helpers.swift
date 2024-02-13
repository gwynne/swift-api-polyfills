import CLegacyLibICU
import enum Foundation.AttributeScopes

extension Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.SymbolAttribute.Symbol {
    init?(unumberFormatField: UNumberFormatFields) {
        switch unumberFormatField {
        case UNUM_DECIMAL_SEPARATOR_FIELD:  self = .decimalSeparator
        case UNUM_GROUPING_SEPARATOR_FIELD: self = .groupingSeparator
        case UNUM_CURRENCY_FIELD:           self = .currency
        case UNUM_PERCENT_FIELD:            self = .percent
        case UNUM_SIGN_FIELD:               self = .sign
        default: return nil
        }
    }
}

extension Foundation.AttributeScopes.FoundationAttributes.NumberFormatAttributes.NumberPartAttribute.NumberPart {
    init?(unumberFormatField: UNumberFormatFields) {
        switch unumberFormatField {
        case UNUM_INTEGER_FIELD:  self = .integer
        case UNUM_FRACTION_FIELD: self = .fraction
        default: return nil
        }
    }
}

extension Foundation.AttributeScopes.FoundationAttributes.MeasurementAttribute.Component {
    init?(unumberFormatField: UNumberFormatFields) {
        switch unumberFormatField {
        case UNUM_INTEGER_FIELD:            self = .value
        case UNUM_FRACTION_FIELD:           self = .value
        case UNUM_DECIMAL_SEPARATOR_FIELD:  self = .value
        case UNUM_GROUPING_SEPARATOR_FIELD: self = .value
        case UNUM_SIGN_FIELD:               self = .value
        case UNUM_MEASURE_UNIT_FIELD:       self = .unit
        default: return nil
        }
    }
}

extension Foundation.AttributeScopes.FoundationAttributes.DateFieldAttribute.Field {
    init?(udateFormatField: UDateFormatField) {
        switch udateFormatField {
        case UDAT_ERA_FIELD:                  self = .era
        case UDAT_YEAR_FIELD:                 self = .year
        case UDAT_MONTH_FIELD:                self = .month
        case UDAT_DATE_FIELD:                 self = .day
        case UDAT_HOUR_OF_DAY1_FIELD:         self = .hour // "k"
        case UDAT_HOUR_OF_DAY0_FIELD:         self = .hour // "H"
        case UDAT_MINUTE_FIELD:               self = .minute
        case UDAT_SECOND_FIELD:               self = .second
        case UDAT_FRACTIONAL_SECOND_FIELD:    self = .secondFraction
        case UDAT_DAY_OF_WEEK_FIELD:          self = .weekday // "E"
        case UDAT_DAY_OF_YEAR_FIELD:          self = .dayOfYear // "D"
        case UDAT_DAY_OF_WEEK_IN_MONTH_FIELD: self = .weekdayOrdinal // "F"
        case UDAT_WEEK_OF_YEAR_FIELD:         self = .weekOfYear
        case UDAT_WEEK_OF_MONTH_FIELD:        self = .weekOfMonth
        case UDAT_AM_PM_FIELD:                self = .amPM
        case UDAT_HOUR1_FIELD:                self = .hour
        case UDAT_HOUR0_FIELD:                self = .hour
        case UDAT_TIMEZONE_FIELD:             self = .timeZone
        case UDAT_YEAR_WOY_FIELD:             self = .year
        case UDAT_DOW_LOCAL_FIELD:            self = .weekday // "e"
        case UDAT_EXTENDED_YEAR_FIELD:        self = .year
        case UDAT_JULIAN_DAY_FIELD:           self = .day
        case UDAT_MILLISECONDS_IN_DAY_FIELD:  self = .second
        case UDAT_TIMEZONE_RFC_FIELD:         self = .timeZone
        case UDAT_TIMEZONE_GENERIC_FIELD:     self = .timeZone
        case UDAT_STANDALONE_DAY_FIELD:       self = .weekday // "c": day of week number/name
        case UDAT_STANDALONE_MONTH_FIELD:     self = .month
        case UDAT_STANDALONE_QUARTER_FIELD:   self = .quarter
        case UDAT_QUARTER_FIELD:              self = .quarter
        case UDAT_TIMEZONE_SPECIAL_FIELD:     self = .timeZone
        case UDAT_YEAR_NAME_FIELD:            self = .year
        case UDAT_TIMEZONE_LOCALIZED_GMT_OFFSET_FIELD:
                                              self = .timeZone
        case UDAT_TIMEZONE_ISO_FIELD:         self = .timeZone
        case UDAT_TIMEZONE_ISO_LOCAL_FIELD:   self = .timeZone
        case UDAT_AM_PM_MIDNIGHT_NOON_FIELD:  self = .amPM
        case UDAT_FLEXIBLE_DAY_PERIOD_FIELD:  self = .amPM
        default:                              return nil
        }
    }
}

