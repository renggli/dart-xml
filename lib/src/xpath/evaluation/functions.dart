import '../definitions/functions.dart';
import '../functions/accessor.dart' as accessor;
import '../functions/array.dart' as array;
import '../functions/boolean.dart' as boolean;
import '../functions/context.dart' as context_func;
import '../functions/date_time.dart' as date_time;
import '../functions/duration.dart' as duration;
import '../functions/error.dart' as error;
import '../functions/higher_order.dart' as higher_order;
import '../functions/json.dart' as json;
import '../functions/map.dart' as map;
import '../functions/math.dart' as math;
import '../functions/node.dart' as node;
import '../functions/number.dart' as number;
import '../functions/qname.dart' as qname;
import '../functions/sequence.dart' as sequence;
import '../functions/string.dart' as string;
import '../functions/uri.dart' as uri;
import '../types/function.dart';

/// The standard XPath functions.
final Map<String, XPathFunction> standardFunctions = {
  for (var definition in _definitions) definition.name: definition.call,
};

const _definitions = <XPathFunctionDefinition>[
  // Accessors
  accessor.fnNodeName,
  accessor.fnNilled,
  accessor.fnString,
  accessor.fnData,
  accessor.fnBaseUri,
  accessor.fnDocumentUri,

  // Arrays
  array.fnArraySize,
  array.fnArrayGet,
  array.fnArrayPut,
  array.fnArrayAppend,
  array.fnArraySubarray,
  array.fnArrayRemove,
  array.fnArrayInsertBefore,
  array.fnArrayHead,
  array.fnArrayTail,
  array.fnArrayReverse,
  array.fnArrayJoin,
  array.fnArrayForEach,
  array.fnArrayFilter,
  array.fnArrayFoldLeft,
  array.fnArrayFoldRight,
  array.fnArrayForEachPair,
  array.fnArraySort,
  array.fnArrayFlatten,

  // Boolean
  boolean.fnTrue,
  boolean.fnFalse,
  boolean.fnBoolean,
  boolean.fnNot,
  boolean.fnLang,

  // Context
  context_func.fnPosition,
  context_func.fnLast,
  context_func.fnCurrentDateTime,
  context_func.fnCurrentDate,
  context_func.fnCurrentTime,
  context_func.fnImplicitTimezone,
  context_func.fnDefaultCollation,
  context_func.fnDefaultLanguage,
  context_func.fnStaticBaseUri,

  // Date/Time
  date_time.fnDateTime,
  date_time.fnYearFromDateTime,
  date_time.fnMonthFromDateTime,
  date_time.fnDayFromDateTime,
  date_time.fnHoursFromDateTime,
  date_time.fnMinutesFromDateTime,
  date_time.fnSecondsFromDateTime,
  date_time.fnTimezoneFromDateTime,
  date_time.fnYearFromDate,
  date_time.fnMonthFromDate,
  date_time.fnDayFromDate,
  date_time.fnTimezoneFromDate,
  date_time.fnHoursFromTime,
  date_time.fnMinutesFromTime,
  date_time.fnSecondsFromTime,
  date_time.fnTimezoneFromTime,
  date_time.fnAdjustDateTimeToTimezone,
  date_time.fnAdjustDateToTimezone,
  date_time.fnAdjustTimeToTimezone,
  date_time.fnFormatDateTime,
  date_time.fnFormatDate,
  date_time.fnFormatTime,
  date_time.fnParseIetfDate,

  // Duration
  duration.fnYearsFromDuration,
  duration.fnMonthsFromDuration,
  duration.fnDaysFromDuration,
  duration.fnHoursFromDuration,
  duration.fnMinutesFromDuration,
  duration.fnSecondsFromDuration,

  // Error
  error.fnError,
  error.fnTrace,

  // Higher Order
  higher_order.fnFunctionName,
  higher_order.fnFunctionArity,
  higher_order.fnForEach,
  higher_order.fnFilter,
  higher_order.fnFoldLeft,
  higher_order.fnFoldRight,
  higher_order.fnForEachPair,
  higher_order.fnSort,
  higher_order.fnApply,
  higher_order.fnFunctionLookup,
  higher_order.fnLoadXqueryModule,
  higher_order.fnTransform,

  // JSON
  json.fnParseJson,
  json.fnJsonDoc,
  json.fnJsonToXml,
  json.fnXmlToJson,

  // Maps
  map.fnMapMerge,
  map.fnMapSize,
  map.fnMapKeys,
  map.fnMapContains,
  map.fnMapGet,
  map.fnMapFind,
  map.fnMapPut,
  map.fnMapEntry,
  map.fnMapRemove,
  map.fnMapForEach,

  // Node
  node.fnName,
  node.fnLocalName,
  node.fnNamespaceUri,
  node.fnRoot,
  node.fnPath,
  node.fnHasChildren,
  node.fnInnermost,
  node.fnOutermost,

  // Numeric functions
  number.fnAbs,
  number.fnCeiling,
  number.fnFloor,
  number.fnRound,
  number.fnRoundHalfToEven,
  number.fnNumber,
  // number.fnFormatInteger,
  // number.fnFormatNumber,
  math.mathPi,
  math.mathExp,
  math.mathExp10,
  math.mathLog,
  math.mathLog10,
  math.mathPow,
  math.mathSqrt,
  math.mathSin,
  math.mathCos,
  math.mathTan,
  math.mathAsin,
  math.mathAcos,
  math.mathAtan,
  math.mathAtan2,
  number.fnRandomNumberGenerator,

  // QName
  qname.fnResolveQName,
  qname.fnQName,
  qname.fnPrefixFromQName,
  qname.fnLocalNameFromQName,
  qname.fnNamespaceUriFromQName,
  qname.fnNamespaceUriForPrefix,
  qname.fnInScopePrefixes,

  // Sequence
  sequence.fnEmpty,
  sequence.fnExists,
  sequence.fnHead,
  sequence.fnTail,
  sequence.fnInsertBefore,
  sequence.fnRemove,
  sequence.fnReverse,
  sequence.fnSubsequence,
  sequence.fnUnordered,
  sequence.fnDistinctValues,
  sequence.fnIndexOf,
  sequence.fnDeepEqual,
  sequence.fnZeroOrOne,
  sequence.fnOneOrMore,
  sequence.fnExactlyOne,
  sequence.fnCount,
  sequence.fnAvg,
  sequence.fnMax,
  sequence.fnMin,
  sequence.fnSum,
  node.fnId,
  node.fnElementWithId,
  node.fnIdref,
  node.fnGenerateId,
  uri.fnDoc,
  uri.fnDocAvailable,
  uri.fnCollection,
  uri.fnUriCollection,
  uri.fnUnparsedText,
  uri.fnUnparsedTextLines,
  uri.fnUnparsedTextAvailable,
  uri.fnEnvironmentVariable,
  uri.fnAvailableEnvironmentVariables,
  accessor.fnParseXml,
  accessor.fnParseXmlFragment,
  accessor.fnSerialize,

  // String
  string.fnCodepointsToString,
  string.fnStringToCodepoints,
  string.fnCompare,
  string.fnCodepointEqual,
  string.fnCollationKey,
  string.fnContainsToken,
  string.fnConcat,
  string.fnStringJoin,
  string.fnSubstring,
  string.fnStringLength,
  string.fnNormalizeSpace,
  string.fnNormalizeUnicode,
  string.fnUpperCase,
  string.fnLowerCase,
  string.fnTranslate,
  string.fnContains,
  string.fnStartsWith,
  string.fnEndsWith,
  string.fnSubstringBefore,
  string.fnSubstringAfter,
  string.fnMatches,
  string.fnReplace,
  string.fnTokenize,
  string.fnAnalyzeString,

  // URI
  uri.fnResolveUri,
  uri.fnEncodeForUri,
  uri.fnIriToUri,
  uri.fnEscapeHtmlUri,

  // TODO: Add constructors
];
