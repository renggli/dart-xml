import '../functions/accessor.dart' as accessor;
import '../functions/array.dart' as array;
import '../functions/binary.dart' as binary;
import '../functions/boolean.dart' as boolean;
import '../functions/context.dart' as context_func;
import '../functions/date_time.dart' as date_time;
import '../functions/duration.dart' as duration;
import '../functions/error.dart' as error;
import '../functions/higher_order.dart' as higher_order;
import '../functions/json.dart' as json;
import '../functions/map.dart' as map;
import '../functions/node.dart' as node;
import '../functions/notation.dart' as notation;
import '../functions/number.dart' as number;
import '../functions/qname.dart' as qname;
import '../functions/sequence.dart' as sequence;
import '../functions/string.dart' as string;
import '../functions/uri.dart' as uri;

export '../types/function.dart';

/// The standard XPath functions.
const Map<String, Object> standardFunctions = {
  // Accessors
  'node-name': accessor.fnNodeName,
  'nilled': accessor.fnNilled,
  'string': accessor.fnString,
  'data': accessor.fnData,
  'base-uri': accessor.fnBaseUri,
  'document-uri': accessor.fnDocumentUri,

  // Arrays
  'array:size': array.arraySize,
  'array:get': array.arrayGet,
  'array:put': array.arrayPut,
  'array:append': array.arrayAppend,
  'array:subarray': array.arraySubarray,
  'array:remove': array.arrayRemove,
  'array:insert-before': array.arrayInsertBefore,
  'array:head': array.arrayHead,
  'array:tail': array.arrayTail,
  'array:reverse': array.arrayReverse,
  'array:join': array.arrayJoin,
  'array:for-each': array.arrayForEach,
  'array:filter': array.arrayFilter,
  'array:fold-left': array.arrayFoldLeft,
  'array:fold-right': array.arrayFoldRight,
  'array:for-each-pair': array.arrayForEachPair,
  'array:sort': array.arraySort,
  'array:flatten': array.arrayFlatten,

  // Binary
  'op:hexBinary-equal': binary.opHexBinaryEqual,
  'op:hexBinary-less-than': binary.opHexBinaryLessThan,
  'op:hexBinary-greater-than': binary.opHexBinaryGreaterThan,
  'op:base64Binary-equal': binary.opBase64BinaryEqual,
  'op:base64Binary-less-than': binary.opBase64BinaryLessThan,
  'op:base64Binary-greater-than': binary.opBase64BinaryGreaterThan,

  // Boolean
  'true': boolean.fnTrue,
  'false': boolean.fnFalse,
  'boolean': boolean.fnBoolean,
  'not': boolean.fnNot,
  'lang': boolean.fnLang,
  'op:boolean-equal': boolean.opBooleanEqual,
  'op:boolean-less-than': boolean.opBooleanLessThan,
  'op:boolean-greater-than': boolean.opBooleanGreaterThan,

  // Context
  'position': context_func.fnPosition,
  'last': context_func.fnLast,
  'current-dateTime': context_func.fnCurrentDateTime,
  'current-date': context_func.fnCurrentDate,
  'current-time': context_func.fnCurrentTime,
  'implicit-timezone': context_func.fnImplicitTimezone,
  'default-collation': context_func.fnDefaultCollation,
  'default-language': context_func.fnDefaultLanguage,
  'static-base-uri': context_func.fnStaticBaseUri,

  // Date/Time
  'dateTime': date_time.fnDateTime,
  'year-from-dateTime': date_time.fnYearFromDateTime,
  'month-from-dateTime': date_time.fnMonthFromDateTime,
  'day-from-dateTime': date_time.fnDayFromDateTime,
  'hours-from-dateTime': date_time.fnHoursFromDateTime,
  'minutes-from-dateTime': date_time.fnMinutesFromDateTime,
  'seconds-from-dateTime': date_time.fnSecondsFromDateTime,
  'timezone-from-dateTime': date_time.fnTimezoneFromDateTime,
  'year-from-date': date_time.fnYearFromDate,
  'month-from-date': date_time.fnMonthFromDate,
  'day-from-date': date_time.fnDayFromDate,
  'timezone-from-date': date_time.fnTimezoneFromDate,
  'hours-from-time': date_time.fnHoursFromTime,
  'minutes-from-time': date_time.fnMinutesFromTime,
  'seconds-from-time': date_time.fnSecondsFromTime,
  'timezone-from-time': date_time.fnTimezoneFromTime,
  'adjust-dateTime-to-timezone': date_time.fnAdjustDateTimeToTimezone,
  'adjust-date-to-timezone': date_time.fnAdjustDateToTimezone,
  'adjust-time-to-timezone': date_time.fnAdjustTimeToTimezone,
  'format-dateTime': date_time.fnFormatDateTime,
  'format-date': date_time.fnFormatDate,
  'format-time': date_time.fnFormatTime,
  'parse-ietf-date': date_time.fnParseIetfDate,
  'op:dateTime-equal': date_time.opDateTimeEqual,
  'op:dateTime-less-than': date_time.opDateTimeLessThan,
  'op:dateTime-greater-than': date_time.opDateTimeGreaterThan,
  'op:date-equal': date_time.opDateEqual,
  'op:date-less-than': date_time.opDateLessThan,
  'op:date-greater-than': date_time.opDateGreaterThan,
  'op:time-equal': date_time.opTimeEqual,
  'op:time-less-than': date_time.opTimeLessThan,
  'op:time-greater-than': date_time.opTimeGreaterThan,
  'op:subtract-dateTimes': date_time.opSubtractDateTimes,
  'op:subtract-dates': date_time.opSubtractDates,
  'op:subtract-times': date_time.opSubtractTimes,
  'op:add-yearMonthDuration-to-dateTime': date_time.opAddDurationToDateTime,
  'op:add-dayTimeDuration-to-dateTime': date_time.opAddDurationToDateTime,
  'op:subtract-yearMonthDuration-from-dateTime':
      date_time.opSubtractDurationFromDateTime,
  'op:subtract-dayTimeDuration-from-dateTime':
      date_time.opSubtractDurationFromDateTime,
  'op:add-yearMonthDuration-to-date': date_time.opAddDurationToDateTime,
  'op:add-dayTimeDuration-to-date': date_time.opAddDurationToDateTime,
  'op:subtract-yearMonthDuration-from-date':
      date_time.opSubtractDurationFromDateTime,
  'op:subtract-dayTimeDuration-from-date':
      date_time.opSubtractDurationFromDateTime,
  'op:add-dayTimeDuration-to-time': date_time.opAddDurationToDateTime,
  'op:subtract-dayTimeDuration-from-time':
      date_time.opSubtractDurationFromDateTime,

  // Duration
  'years-from-duration': duration.fnYearsFromDuration,
  'months-from-duration': duration.fnMonthsFromDuration,
  'days-from-duration': duration.fnDaysFromDuration,
  'hours-from-duration': duration.fnHoursFromDuration,
  'minutes-from-duration': duration.fnMinutesFromDuration,
  'seconds-from-duration': duration.fnSecondsFromDuration,
  'op:yearMonthDuration-less-than': duration.opYearMonthDurationLessThan,
  'op:yearMonthDuration-greater-than': duration.opYearMonthDurationGreaterThan,
  'op:dayTimeDuration-less-than': duration.opDayTimeDurationLessThan,
  'op:dayTimeDuration-greater-than': duration.opDayTimeDurationGreaterThan,
  'op:duration-equal': duration.opDurationEqual,
  'op:add-yearMonthDurations': duration.opAddYearMonthDurations,
  'op:subtract-yearMonthDurations': duration.opSubtractYearMonthDurations,
  'op:multiply-yearMonthDuration': duration.opMultiplyYearMonthDuration,
  'op:divide-yearMonthDuration': duration.opDivideYearMonthDuration,
  'op:divide-yearMonthDuration-by-yearMonthDuration':
      duration.opDivideYearMonthDurationByYearMonthDuration,
  'op:add-dayTimeDurations': duration.opAddDayTimeDurations,
  'op:subtract-dayTimeDurations': duration.opSubtractDayTimeDurations,
  'op:multiply-dayTimeDuration': duration.opMultiplyDayTimeDuration,
  'op:divide-dayTimeDuration': duration.opDivideDayTimeDuration,
  'op:divide-dayTimeDuration-by-dayTimeDuration':
      duration.opDivideDayTimeDurationByDayTimeDuration,

  // Error
  'error': error.fnError,
  'trace': error.fnTrace,

  // Higher Order
  'function-name': higher_order.fnFunctionName,
  'function-arity': higher_order.fnFunctionArity,
  'for-each': higher_order.fnForEach,
  'filter': higher_order.fnFilter,
  'fold-left': higher_order.fnFoldLeft,
  'fold-right': higher_order.fnFoldRight,
  'for-each-pair': higher_order.fnForEachPair,
  'sort': higher_order.fnSort,
  'apply': higher_order.fnApply,
  'function-lookup': higher_order.fnFunctionLookup,
  'load-xquery-module': higher_order.fnLoadXqueryModule,
  'transform': higher_order.fnTransform,

  // JSON
  'parse-json': json.fnParseJson,
  'json-doc': json.fnJsonDoc,
  'json-to-xml': json.fnJsonToXml,
  'xml-to-json': json.fnXmlToJson,

  // Maps
  'op:same-key': map.opSameKey,
  'map:merge': map.mapMerge,
  'map:size': map.mapSize,
  'map:keys': map.mapKeys,
  'map:contains': map.mapContains,
  'map:get': map.mapGet,
  'map:find': map.mapFind,
  'map:put': map.mapPut,
  'map:entry': map.mapEntry,
  'map:remove': map.mapRemove,
  'map:for-each': map.mapForEach,

  // Node
  'name': node.fnName,
  'local-name': node.fnLocalName,
  'namespace-uri': node.fnNamespaceUri,
  'root': node.fnRoot,
  'path': node.fnPath,
  'has-children': node.fnHasChildren,
  'innermost': node.fnInnermost,
  'outermost': node.fnOutermost,
  'op:union': node.opUnion,
  'op:intersect': node.opIntersect,
  'op:except': node.opExcept,

  // Notation
  'op:NOTATION-equal': notation.opNotationEqual,

  // Number
  'op:numeric-add': number.opNumericAdd,
  'op:numeric-subtract': number.opNumericSubtract,
  'op:numeric-multiply': number.opNumericMultiply,
  'op:numeric-divide': number.opNumericDivide,
  'op:numeric-integer-divide': number.opNumericIntegerDivide,
  'op:numeric-mod': number.opNumericMod,
  'op:numeric-unary-plus': number.opNumericUnaryPlus,
  'op:numeric-unary-minus': number.opNumericUnaryMinus,
  'op:numeric-equal': number.opNumericEqual,
  'op:numeric-less-than': number.opNumericLessThan,
  'op:numeric-greater-than': number.opNumericGreaterThan,
  'abs': number.fnAbs,
  'ceiling': number.fnCeiling,
  'floor': number.fnFloor,
  'round': number.fnRound,
  'round-half-to-even': number.fnRoundHalfToEven,
  'number': number.fnNumber,
  'format-integer': number.fnFormatInteger,
  'format-number': number.fnFormatNumber,
  'math:pi': number.mathPi,
  'math:exp': number.mathExp,
  'math:exp10': number.mathExp10,
  'math:log': number.mathLog,
  'math:log10': number.mathLog10,
  'math:pow': number.mathPow,
  'math:sqrt': number.mathSqrt,
  'math:sin': number.mathSin,
  'math:cos': number.mathCos,
  'math:tan': number.mathTan,
  'math:asin': number.mathAsin,
  'math:acos': number.mathAcos,
  'math:atan': number.mathAtan,
  'math:atan2': number.mathAtan2,
  'fn:random-number-generator': number.fnRandomNumberGenerator,

  // QName
  'resolve-QName': qname.fnResolveQName,
  'QName': qname.fnQName,
  'op:QName-equal': qname.opQNameEqual,
  'prefix-from-QName': qname.fnPrefixFromQName,
  'local-name-from-QName': qname.fnLocalNameFromQName,
  'namespace-uri-from-QName': qname.fnNamespaceUriFromQName,
  'namespace-uri-for-prefix': qname.fnNamespaceUriForPrefix,
  'in-scope-prefixes': qname.fnInScopePrefixes,

  // Sequence
  'empty': sequence.fnEmpty,
  'exists': sequence.fnExists,
  'head': sequence.fnHead,
  'tail': sequence.fnTail,
  'insert-before': sequence.fnInsertBefore,
  'remove': sequence.fnRemove,
  'reverse': sequence.fnReverse,
  'subsequence': sequence.fnSubsequence,
  'unordered': sequence.fnUnordered,
  'distinct-values': sequence.fnDistinctValues,
  'index-of': sequence.fnIndexOf,
  'deep-equal': sequence.fnDeepEqual,
  'zero-or-one': sequence.fnZeroOrOne,
  'one-or-more': sequence.fnOneOrMore,
  'exactly-one': sequence.fnExactlyOne,
  'count': sequence.fnCount,
  'avg': sequence.fnAvg,
  'max': sequence.fnMax,
  'min': sequence.fnMin,
  'sum': sequence.fnSum,
  'id': sequence.fnId,
  'element-with-id': sequence.fnElementWithId,
  'idref': sequence.fnIdref,
  'generate-id': sequence.fnGenerateId,
  'doc': sequence.fnDoc,
  'doc-available': sequence.fnDocAvailable,
  'collection': sequence.fnCollection,
  'uri-collection': sequence.fnUriCollection,
  'unparsed-text': sequence.fnUnparsedText,
  'unparsed-text-lines': sequence.fnUnparsedTextLines,
  'unparsed-text-available': sequence.fnUnparsedTextAvailable,
  'environment-variable': sequence.fnEnvironmentVariable,
  'available-environment-variables': sequence.fnAvailableEnvironmentVariables,
  'parse-xml': sequence.fnParseXml,
  'parse-xml-fragment': sequence.fnParseXmlFragment,
  'serialize': sequence.fnSerialize,

  // String
  'codepoints-to-string': string.fnCodepointsToString,
  'string-to-codepoints': string.fnStringToCodepoints,
  'compare': string.fnCompare,
  'codepoint-equal': string.fnCodepointEqual,
  'collation-key': string.fnCollationKey,
  'contains-token': string.fnContainsToken,
  'concat': string.fnConcat,
  'string-join': string.fnStringJoin,
  'substring': string.fnSubstring,
  'string-length': string.fnStringLength,
  'normalize-space': string.fnNormalizeSpace,
  'normalize-unicode': string.fnNormalizeUnicode,
  'upper-case': string.fnUpperCase,
  'lower-case': string.fnLowerCase,
  'translate': string.fnTranslate,
  'contains': string.fnContains,
  'starts-with': string.fnStartsWith,
  'ends-with': string.fnEndsWith,
  'substring-before': string.fnSubstringBefore,
  'substring-after': string.fnSubstringAfter,
  'matches': string.fnMatches,
  'replace': string.fnReplace,
  'tokenize': string.fnTokenize,
  'analyze-string': string.fnAnalyzeString,

  // URI
  'resolve-uri': uri.fnResolveUri,
  'encode-for-uri': uri.fnEncodeForUri,
  'iri-to-uri': uri.fnIriToUri,
  'escape-html-uri': uri.fnEscapeHtmlUri,
};
