#include "unicode/uatimeunitformat.h"
#include "unicode/fieldpos.h"
#include "unicode/localpointer.h"
#include "unicode/numfmt.h"
#include "unicode/measunit.h"
#include "unicode/measure.h"
#include "unicode/measfmt.h"
#include "unicode/unistr.h"
#include "unicode/unum.h"
#include "unicode/urename.h"
#include "unicode/ures.h"
#include "unicode/ustring.h"
#include "unicode/utypes.h"
#include "unicode/udata.h"
#include "unicode/uversion.h"

// From "common/ureslocs.h"
#define U_ICUDATA_UNIT U_ICUDATA_NAME U_TREE_SEPARATOR_STRING "unit"
// From "common/uresimp.h"
U_CAPI UResourceBundle* U_EXPORT2 ures_getByKeyWithFallback(const UResourceBundle *resB, const char* inKey, UResourceBundle *fillIn, UErrorCode *status);
U_CAPI const UChar* U_EXPORT2 ures_getStringByKeyWithFallback(const UResourceBundle *resB, const char* inKey, int32_t* len, UErrorCode *status);
// From "common/ustr_imp.h"
U_CAPI int32_t U_EXPORT2 u_terminateUChars(UChar *dest, int32_t destCapacity, int32_t length, UErrorCode *pErrorCode);
// From "i18n/uatimeunitformat.cpp"
U_CAPI int32_t U_EXPORT2 uatmufmt_getTimePattern(const char* locale, UATimeUnitTimePattern type, UChar* result, int32_t resultCapacity, UErrorCode* status)
{
    if (U_FAILURE(*status)) { return 0; }
    if (result == NULL ? resultCapacity != 0 : resultCapacity < 0) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    const char* key = NULL;
    switch (type) {
        case UATIMEUNITTIMEPAT_HM:  { key = "hm"; break; }
        case UATIMEUNITTIMEPAT_HMS: { key = "hms"; break; }
        case UATIMEUNITTIMEPAT_MS:  { key = "ms"; break; }
        default: { *status = U_ILLEGAL_ARGUMENT_ERROR; return 0; }
    }
    int32_t resLen = 0;
    const UChar* resPtr = NULL;
    UResourceBundle* rb = ures_open(U_ICUDATA_UNIT, locale, status);
    rb = ures_getByKeyWithFallback(rb, "durationUnits", rb, status);
    resPtr = ures_getStringByKeyWithFallback(rb, key, &resLen, status);
    if (U_SUCCESS(*status)) { u_strncpy(result, resPtr, resultCapacity); }
    ures_close(rb);
    return u_terminateUChars(result, resultCapacity, resLen, status);
}
U_CAPI int32_t U_EXPORT2 uatmufmt_getListPattern(const char* locale, UATimeUnitStyle style, UATimeUnitListPattern type, UChar* result, int32_t resultCapacity, UErrorCode* status)
{
    if (U_FAILURE(*status)) { return 0; }
    if (result == NULL ? resultCapacity != 0 : resultCapacity < 0) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    const char* styleKey = NULL;
    switch (style) {
        case UATIMEUNITSTYLE_FULL:          { styleKey = "unit"; break; }
        case UATIMEUNITSTYLE_ABBREVIATED:   { styleKey = "unit-short"; break; }
        case UATIMEUNITSTYLE_NARROW:        { styleKey = "unit-narrow"; break; }
        case UATIMEUNITSTYLE_SHORTER:       { styleKey = "unit-narrow"; break; }
        default: { *status = U_ILLEGAL_ARGUMENT_ERROR; return 0; }
    }
    const char* typeKey = NULL;
    switch (type) {
        case UATIMEUNITLISTPAT_TWO_ONLY:        { typeKey = "2"; break; }
        case UATIMEUNITLISTPAT_END_PIECE:       { typeKey = "end"; break; }
        case UATIMEUNITLISTPAT_MIDDLE_PIECE:    { typeKey = "middle"; break; }
        case UATIMEUNITLISTPAT_START_PIECE:     { typeKey = "start"; break; }
        default: { *status = U_ILLEGAL_ARGUMENT_ERROR; return 0; }
    }
    int32_t resLen = 0;
    const UChar* resPtr = NULL;
    UResourceBundle* rb = ures_open(NULL, locale, status);
    rb = ures_getByKeyWithFallback(rb, "listPattern", rb, status);
    rb = ures_getByKeyWithFallback(rb, styleKey, rb, status);
    resPtr = ures_getStringByKeyWithFallback(rb, typeKey, &resLen, status);
    if (U_SUCCESS(*status)) { u_strncpy(result, resPtr, resultCapacity); }
    ures_close(rb);
    return u_terminateUChars(result, resultCapacity, resLen, status);
}
