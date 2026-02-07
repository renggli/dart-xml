import '../definitions/type.dart';
import '../types/array.dart';
import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/number.dart';
import '../types/qname.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// The standard XPath types.
final Map<String, XPathType<Object>> types = {
  for (var type in _types) type.name: type,
};

const _types = <XPathType<Object>>[
  xsArray,
  xsBase64Binary,
  xsBoolean,
  xsDateTime,
  xsDouble,
  xsDuration,
  xsEmptySequence,
  xsFunction,
  xsHexBinary,
  xsInteger,
  xsMap,
  xsQName,
  xsSequence,
  xsString,
];
