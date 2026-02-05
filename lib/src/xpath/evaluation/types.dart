import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/string.dart';

import 'definition.dart';

export '../types/function.dart';

/// The standard XPath types.
final Map<String, XPathItemType> types = {
  'xs:anyURI': xsString,
  'xs:base64Binary': xsBase64Binary,
  'xs:boolean': xsBoolean,
  'xs:byte': xsNumber,
  'xs:date': xsDateTime,
  'xs:dateTime': xsDateTime,
  'xs:dateTimeStamp': xsDateTime,
  'xs:dayTimeDuration': xsDuration,
  'xs:decimal': xsNumber,
  'xs:double': xsNumber,
  'xs:duration': xsDuration,
  'xs:ENTITY': xsString,
  'xs:float': xsNumber,
  'xs:gDay': xsDateTime,
  'xs:gMonth': xsDateTime,
  'xs:gMonthDay': xsDateTime,
  'xs:gYear': xsDateTime,
  'xs:gYearMonth': xsDateTime,
  'xs:hexBinary': xsHexBinary,
  'xs:ID': xsString,
  'xs:IDREF': xsString,
  'xs:int': xsNumber,
  'xs:integer': xsNumber,
  'xs:language': xsString,
  'xs:long': xsNumber,
  'xs:Name': xsString,
  'xs:NCName': xsString,
  'xs:negativeInteger': xsNumber,
  'xs:NMTOKEN': xsString,
  'xs:nonNegativeInteger': xsNumber,
  'xs:nonPositiveInteger': xsNumber,
  'xs:normalizedString': xsString,
  'xs:NOTATION': xsString,
  'xs:positiveInteger': xsNumber,
  'xs:QName': xsString,
  'xs:short': xsNumber,
  'xs:string': xsString,
  'xs:time': xsDateTime,
  'xs:token': xsString,
  'xs:unsignedByte': xsNumber,
  'xs:unsignedInt': xsNumber,
  'xs:unsignedLong': xsNumber,
  'xs:unsignedShort': xsNumber,
  'xs:yearMonthDuration': xsDuration,
};
