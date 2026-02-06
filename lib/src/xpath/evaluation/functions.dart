import '../functions/accessor.dart' as accessor;
import '../functions/array.dart' as array;
import '../functions/boolean.dart' as boolean;
import '../functions/constructors.dart' as constructors;
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
import '../namespaces.dart';
import '../types/function.dart';

export '../types/function.dart';

/// The standard XPath functions.
final Map<String, XPathFunction> standardFunctions = {
  // Accessors
  'Q{$xpathFnNamespace}node-name': accessor.fnNodeName.call,
  'Q{$xpathFnNamespace}nilled': accessor.fnNilled.call,
  'Q{$xpathFnNamespace}string': accessor.fnString.call,
  'Q{$xpathFnNamespace}data': accessor.fnData.call,
  'Q{$xpathFnNamespace}base-uri': accessor.fnBaseUri.call,
  'Q{$xpathFnNamespace}document-uri': accessor.fnDocumentUri.call,

  // Arrays
  'Q{$xpathArrayNamespace}size': array.fnArraySize.call,
  'Q{$xpathArrayNamespace}get': array.fnArrayGet.call,
  'Q{$xpathArrayNamespace}put': array.fnArrayPut.call,
  'Q{$xpathArrayNamespace}append': array.fnArrayAppend.call,
  'Q{$xpathArrayNamespace}subarray': array.fnArraySubarray.call,
  'Q{$xpathArrayNamespace}remove': array.fnArrayRemove.call,
  'Q{$xpathArrayNamespace}insert-before': array.fnArrayInsertBefore.call,
  'Q{$xpathArrayNamespace}head': array.fnArrayHead.call,
  'Q{$xpathArrayNamespace}tail': array.fnArrayTail.call,
  'Q{$xpathArrayNamespace}reverse': array.fnArrayReverse.call,
  'Q{$xpathArrayNamespace}join': array.fnArrayJoin.call,
  'Q{$xpathArrayNamespace}for-each': array.fnArrayForEach.call,
  'Q{$xpathArrayNamespace}filter': array.fnArrayFilter.call,
  'Q{$xpathArrayNamespace}fold-left': array.fnArrayFoldLeft.call,
  'Q{$xpathArrayNamespace}fold-right': array.fnArrayFoldRight.call,
  'Q{$xpathArrayNamespace}for-each-pair': array.fnArrayForEachPair.call,
  'Q{$xpathArrayNamespace}sort': array.fnArraySort.call,
  'Q{$xpathArrayNamespace}flatten': array.fnArrayFlatten.call,

  // Boolean
  'Q{$xpathFnNamespace}true': boolean.fnTrue.call,
  'Q{$xpathFnNamespace}false': boolean.fnFalse.call,
  'Q{$xpathFnNamespace}boolean': boolean.fnBoolean.call,
  'Q{$xpathFnNamespace}not': boolean.fnNot.call,
  'Q{$xpathFnNamespace}lang': boolean.fnLang.call,

  // Context
  'Q{$xpathFnNamespace}position': context_func.fnPosition.call,
  'Q{$xpathFnNamespace}last': context_func.fnLast.call,
  'Q{$xpathFnNamespace}current-dateTime': context_func.fnCurrentDateTime.call,
  'Q{$xpathFnNamespace}current-date': context_func.fnCurrentDate.call,
  'Q{$xpathFnNamespace}current-time': context_func.fnCurrentTime.call,
  'Q{$xpathFnNamespace}implicit-timezone': context_func.fnImplicitTimezone.call,
  'Q{$xpathFnNamespace}default-collation': context_func.fnDefaultCollation.call,
  'Q{$xpathFnNamespace}default-language': context_func.fnDefaultLanguage.call,
  'Q{$xpathFnNamespace}static-base-uri': context_func.fnStaticBaseUri.call,

  // Date/Time
  'Q{$xpathFnNamespace}dateTime': date_time.fnDateTime.call,
  'Q{$xpathFnNamespace}year-from-dateTime': date_time.fnYearFromDateTime.call,
  'Q{$xpathFnNamespace}month-from-dateTime': date_time.fnMonthFromDateTime.call,
  'Q{$xpathFnNamespace}day-from-dateTime': date_time.fnDayFromDateTime.call,
  'Q{$xpathFnNamespace}hours-from-dateTime': date_time.fnHoursFromDateTime.call,
  'Q{$xpathFnNamespace}minutes-from-dateTime':
      date_time.fnMinutesFromDateTime.call,
  'Q{$xpathFnNamespace}seconds-from-dateTime':
      date_time.fnSecondsFromDateTime.call,
  'Q{$xpathFnNamespace}timezone-from-dateTime':
      date_time.fnTimezoneFromDateTime.call,
  'Q{$xpathFnNamespace}year-from-date': date_time.fnYearFromDate.call,
  'Q{$xpathFnNamespace}month-from-date': date_time.fnMonthFromDate.call,
  'Q{$xpathFnNamespace}day-from-date': date_time.fnDayFromDate.call,
  'Q{$xpathFnNamespace}timezone-from-date': date_time.fnTimezoneFromDate.call,
  'Q{$xpathFnNamespace}hours-from-time': date_time.fnHoursFromTime.call,
  'Q{$xpathFnNamespace}minutes-from-time': date_time.fnMinutesFromTime.call,
  'Q{$xpathFnNamespace}seconds-from-time': date_time.fnSecondsFromTime.call,
  'Q{$xpathFnNamespace}timezone-from-time': date_time.fnTimezoneFromTime.call,
  'Q{$xpathFnNamespace}adjust-dateTime-to-timezone':
      date_time.fnAdjustDateTimeToTimezone.call,
  'Q{$xpathFnNamespace}adjust-date-to-timezone':
      date_time.fnAdjustDateToTimezone.call,
  'Q{$xpathFnNamespace}adjust-time-to-timezone':
      date_time.fnAdjustTimeToTimezone.call,
  'Q{$xpathFnNamespace}format-dateTime': date_time.fnFormatDateTime.call,
  'Q{$xpathFnNamespace}format-date': date_time.fnFormatDate.call,
  'Q{$xpathFnNamespace}format-time': date_time.fnFormatTime.call,
  'Q{$xpathFnNamespace}parse-ietf-date': date_time.fnParseIetfDate.call,

  // Duration
  'Q{$xpathFnNamespace}years-from-duration': duration.fnYearsFromDuration.call,
  'Q{$xpathFnNamespace}months-from-duration':
      duration.fnMonthsFromDuration.call,
  'Q{$xpathFnNamespace}days-from-duration': duration.fnDaysFromDuration.call,
  'Q{$xpathFnNamespace}hours-from-duration': duration.fnHoursFromDuration.call,
  'Q{$xpathFnNamespace}minutes-from-duration':
      duration.fnMinutesFromDuration.call,
  'Q{$xpathFnNamespace}seconds-from-duration':
      duration.fnSecondsFromDuration.call,

  // Error
  'Q{$xpathFnNamespace}error': error.fnError.call,
  'Q{$xpathFnNamespace}trace': error.fnTrace.call,

  // Higher Order
  'Q{$xpathFnNamespace}function-name': higher_order.fnFunctionName.call,
  'Q{$xpathFnNamespace}function-arity': higher_order.fnFunctionArity.call,
  'Q{$xpathFnNamespace}for-each': higher_order.fnForEach.call,
  'Q{$xpathFnNamespace}filter': higher_order.fnFilter.call,
  'Q{$xpathFnNamespace}fold-left': higher_order.fnFoldLeft.call,
  'Q{$xpathFnNamespace}fold-right': higher_order.fnFoldRight.call,
  'Q{$xpathFnNamespace}for-each-pair': higher_order.fnForEachPair.call,
  'Q{$xpathFnNamespace}sort': higher_order.fnSort.call,
  'Q{$xpathFnNamespace}apply': higher_order.fnApply.call,
  'Q{$xpathFnNamespace}function-lookup': higher_order.fnFunctionLookup.call,
  'Q{$xpathFnNamespace}load-xquery-module':
      higher_order.fnLoadXqueryModule.call,
  'Q{$xpathFnNamespace}transform': higher_order.fnTransform.call,

  // JSON
  'Q{$xpathFnNamespace}parse-json': json.fnParseJson.call,
  'Q{$xpathFnNamespace}json-doc': json.fnJsonDoc.call,
  'Q{$xpathFnNamespace}json-to-xml': json.fnJsonToXml.call,
  'Q{$xpathFnNamespace}xml-to-json': json.fnXmlToJson.call,

  // Maps
  'Q{$xpathMapNamespace}merge': map.fnMapMerge.call,
  'Q{$xpathMapNamespace}size': map.fnMapSize.call,
  'Q{$xpathMapNamespace}keys': map.fnMapKeys.call,
  'Q{$xpathMapNamespace}contains': map.fnMapContains.call,
  'Q{$xpathMapNamespace}get': map.fnMapGet.call,
  'Q{$xpathMapNamespace}find': map.fnMapFind.call,
  'Q{$xpathMapNamespace}put': map.fnMapPut.call,
  'Q{$xpathMapNamespace}entry': map.fnMapEntry.call,
  'Q{$xpathMapNamespace}remove': map.fnMapRemove.call,
  'Q{$xpathMapNamespace}for-each': map.fnMapForEach.call,

  // Node
  'Q{$xpathFnNamespace}name': node.fnName.call,
  'Q{$xpathFnNamespace}local-name': node.fnLocalName.call,
  'Q{$xpathFnNamespace}namespace-uri': node.fnNamespaceUri.call,
  'Q{$xpathFnNamespace}root': node.fnRoot.call,
  'Q{$xpathFnNamespace}path': node.fnPath.call,
  'Q{$xpathFnNamespace}has-children': node.fnHasChildren.call,
  'Q{$xpathFnNamespace}innermost': node.fnInnermost.call,
  'Q{$xpathFnNamespace}outermost': node.fnOutermost.call,

  // Numeric functions
  'Q{$xpathFnNamespace}abs': number.fnAbs.call,
  'Q{$xpathFnNamespace}ceiling': number.fnCeiling.call,
  'Q{$xpathFnNamespace}floor': number.fnFloor.call,
  'Q{$xpathFnNamespace}round': number.fnRound.call,
  'Q{$xpathFnNamespace}round-half-to-even': number.fnRoundHalfToEven.call,
  'Q{$xpathFnNamespace}number': number.fnNumber.call,
  // 'Q{$xpathFnNamespace}format-integer': number.fnFormatInteger.call,
  // 'Q{$xpathFnNamespace}format-number': number.fnFormatNumber.call,
  'Q{$xpathMathNamespace}pi': math.mathPi.call,
  'Q{$xpathMathNamespace}exp': math.mathExp.call,
  'Q{$xpathMathNamespace}exp10': math.mathExp10.call,
  'Q{$xpathMathNamespace}log': math.mathLog.call,
  'Q{$xpathMathNamespace}log10': math.mathLog10.call,
  'Q{$xpathMathNamespace}pow': math.mathPow.call,
  'Q{$xpathMathNamespace}sqrt': math.mathSqrt.call,
  'Q{$xpathMathNamespace}sin': math.mathSin.call,
  'Q{$xpathMathNamespace}cos': math.mathCos.call,
  'Q{$xpathMathNamespace}tan': math.mathTan.call,
  'Q{$xpathMathNamespace}asin': math.mathAsin.call,
  'Q{$xpathMathNamespace}acos': math.mathAcos.call,
  'Q{$xpathMathNamespace}atan': math.mathAtan.call,
  'Q{$xpathMathNamespace}atan2': math.mathAtan2.call,
  'Q{$xpathFnNamespace}random-number-generator':
      number.fnRandomNumberGenerator.call,

  // QName
  'Q{$xpathFnNamespace}resolve-QName': qname.fnResolveQName.call,
  'Q{$xpathFnNamespace}QName': qname.fnQName.call,

  'Q{$xpathFnNamespace}prefix-from-QName': qname.fnPrefixFromQName.call,
  'Q{$xpathFnNamespace}local-name-from-QName': qname.fnLocalNameFromQName.call,
  'Q{$xpathFnNamespace}namespace-uri-from-QName':
      qname.fnNamespaceUriFromQName.call,
  'Q{$xpathFnNamespace}namespace-uri-for-prefix':
      qname.fnNamespaceUriForPrefix.call,
  'Q{$xpathFnNamespace}in-scope-prefixes': qname.fnInScopePrefixes.call,

  // Sequence
  'Q{$xpathFnNamespace}empty': sequence.fnEmpty.call,
  'Q{$xpathFnNamespace}exists': sequence.fnExists.call,
  'Q{$xpathFnNamespace}head': sequence.fnHead.call,
  'Q{$xpathFnNamespace}tail': sequence.fnTail.call,
  'Q{$xpathFnNamespace}insert-before': sequence.fnInsertBefore.call,
  'Q{$xpathFnNamespace}remove': sequence.fnRemove.call,
  'Q{$xpathFnNamespace}reverse': sequence.fnReverse.call,
  'Q{$xpathFnNamespace}subsequence': sequence.fnSubsequence.call,
  'Q{$xpathFnNamespace}unordered': sequence.fnUnordered.call,
  'Q{$xpathFnNamespace}distinct-values': sequence.fnDistinctValues.call,
  'Q{$xpathFnNamespace}index-of': sequence.fnIndexOf.call,
  'Q{$xpathFnNamespace}deep-equal': sequence.fnDeepEqual.call,
  'Q{$xpathFnNamespace}zero-or-one': sequence.fnZeroOrOne.call,
  'Q{$xpathFnNamespace}one-or-more': sequence.fnOneOrMore.call,
  'Q{$xpathFnNamespace}exactly-one': sequence.fnExactlyOne.call,
  'Q{$xpathFnNamespace}count': sequence.fnCount.call,
  'Q{$xpathFnNamespace}avg': sequence.fnAvg.call,
  'Q{$xpathFnNamespace}max': sequence.fnMax.call,
  'Q{$xpathFnNamespace}min': sequence.fnMin.call,
  'Q{$xpathFnNamespace}sum': sequence.fnSum.call,
  'Q{$xpathFnNamespace}id': node.fnId.call,
  'Q{$xpathFnNamespace}element-with-id': node.fnElementWithId.call,
  'Q{$xpathFnNamespace}idref': node.fnIdref.call,
  'Q{$xpathFnNamespace}generate-id': node.fnGenerateId.call,
  'Q{$xpathFnNamespace}doc': uri.fnDoc.call,
  'Q{$xpathFnNamespace}doc-available': uri.fnDocAvailable.call,
  'Q{$xpathFnNamespace}collection': uri.fnCollection.call,
  'Q{$xpathFnNamespace}uri-collection': uri.fnUriCollection.call,
  'Q{$xpathFnNamespace}unparsed-text': uri.fnUnparsedText.call,
  'Q{$xpathFnNamespace}unparsed-text-lines': uri.fnUnparsedTextLines.call,
  'Q{$xpathFnNamespace}unparsed-text-available':
      uri.fnUnparsedTextAvailable.call,
  'Q{$xpathFnNamespace}environment-variable': uri.fnEnvironmentVariable.call,
  'Q{$xpathFnNamespace}available-environment-variables':
      uri.fnAvailableEnvironmentVariables.call,
  'Q{$xpathFnNamespace}parse-xml': accessor.fnParseXml.call,
  'Q{$xpathFnNamespace}parse-xml-fragment': accessor.fnParseXmlFragment.call,
  'Q{$xpathFnNamespace}serialize': accessor.fnSerialize.call,

  // String
  'Q{$xpathFnNamespace}codepoints-to-string': string.fnCodepointsToString.call,
  'Q{$xpathFnNamespace}string-to-codepoints': string.fnStringToCodepoints.call,
  'Q{$xpathFnNamespace}compare': string.fnCompare.call,
  'Q{$xpathFnNamespace}codepoint-equal': string.fnCodepointEqual.call,
  'Q{$xpathFnNamespace}collation-key': string.fnCollationKey.call,
  'Q{$xpathFnNamespace}contains-token': string.fnContainsToken.call,
  'Q{$xpathFnNamespace}concat': string.fnConcat.call,
  'Q{$xpathFnNamespace}string-join': string.fnStringJoin.call,
  'Q{$xpathFnNamespace}substring': string.fnSubstring.call,
  'Q{$xpathFnNamespace}string-length': string.fnStringLength.call,
  'Q{$xpathFnNamespace}normalize-space': string.fnNormalizeSpace.call,
  'Q{$xpathFnNamespace}normalize-unicode': string.fnNormalizeUnicode.call,
  'Q{$xpathFnNamespace}upper-case': string.fnUpperCase.call,
  'Q{$xpathFnNamespace}lower-case': string.fnLowerCase.call,
  'Q{$xpathFnNamespace}translate': string.fnTranslate.call,
  'Q{$xpathFnNamespace}contains': string.fnContains.call,
  'Q{$xpathFnNamespace}starts-with': string.fnStartsWith.call,
  'Q{$xpathFnNamespace}ends-with': string.fnEndsWith.call,
  'Q{$xpathFnNamespace}substring-before': string.fnSubstringBefore.call,
  'Q{$xpathFnNamespace}substring-after': string.fnSubstringAfter.call,
  'Q{$xpathFnNamespace}matches': string.fnMatches.call,
  'Q{$xpathFnNamespace}replace': string.fnReplace.call,
  'Q{$xpathFnNamespace}tokenize': string.fnTokenize.call,
  'Q{$xpathFnNamespace}analyze-string': string.fnAnalyzeString.call,

  // URI
  'Q{$xpathFnNamespace}resolve-uri': uri.fnResolveUri.call,
  'Q{$xpathFnNamespace}encode-for-uri': uri.fnEncodeForUri.call,
  'Q{$xpathFnNamespace}iri-to-uri': uri.fnIriToUri.call,
  'Q{$xpathFnNamespace}escape-html-uri': uri.fnEscapeHtmlUri.call,

  // Constructors
  'Q{$xpathXsNamespace}string': constructors.xsString.call,
  'Q{$xpathXsNamespace}boolean': constructors.xsBoolean.call,
  'Q{$xpathXsNamespace}decimal': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}float': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}double': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}integer': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}nonPositiveInteger': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}negativeInteger': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}long': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}int': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}short': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}byte': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}nonNegativeInteger': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}unsignedLong': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}unsignedInt': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}unsignedShort': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}unsignedByte': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}positiveInteger': constructors.xsNumber.call,
  'Q{$xpathXsNamespace}yearMonthDuration': constructors.xsDuration.call,
  'Q{$xpathXsNamespace}dayTimeDuration': constructors.xsDuration.call,
  'Q{$xpathXsNamespace}duration': constructors.xsDuration.call,
  'Q{$xpathXsNamespace}dateTime': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}date': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}time': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}gYear': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}gYearMonth': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}gMonth': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}gMonthDay': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}gDay': constructors.xsDateTime.call,
  'Q{$xpathXsNamespace}anyURI': constructors.xsString.call,
  'Q{$xpathXsNamespace}QName': constructors.xsString.call,
  'Q{$xpathXsNamespace}NOTATION': constructors.xsString.call,
  'Q{$xpathXsNamespace}uniqueID': constructors.xsString.call,
  'Q{$xpathXsNamespace}ID': constructors.xsString.call,
  'Q{$xpathXsNamespace}IDREF': constructors.xsString.call,
  'Q{$xpathXsNamespace}ENTITY': constructors.xsString.call,
  'Q{$xpathXsNamespace}NMTOKEN': constructors.xsString.call,
  'Q{$xpathXsNamespace}Name': constructors.xsString.call,
  'Q{$xpathXsNamespace}NCName': constructors.xsString.call,
  'Q{$xpathXsNamespace}token': constructors.xsString.call,
  'Q{$xpathXsNamespace}normalizedString': constructors.xsString.call,
  'Q{$xpathXsNamespace}hexBinary': constructors.xsString.call,
  'Q{$xpathXsNamespace}base64Binary': constructors.xsString.call,
};
