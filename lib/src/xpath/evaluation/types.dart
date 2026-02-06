import '../../xml/nodes/node.dart';
import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/string.dart';
import 'definition.dart';

export '../types/array.dart';
export '../types/binary.dart';
export '../types/boolean.dart';
export '../types/date_time.dart';
export '../types/duration.dart';
export '../types/function.dart';
export '../types/item.dart';
export '../types/map.dart';
export '../types/node.dart';
export '../types/number.dart';
export '../types/sequence.dart';
export '../types/string.dart';
export 'definition.dart';

typedef XPathString = String;
typedef XPathNode = XmlNode;

/// The standard XPath types.
final Map<String, XPathType> types = {
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
  'xs:anyAtomicType': xsAny, // mapping to item() for now
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
