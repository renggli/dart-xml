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

/// The standard types.
final Map<String, XPathType<Object>> standardTypes = {
  for (var type in basicTypes) ...{
    type.name: type,
    for (var alias in type.aliases) alias: type,
  },
};

/// Internal list of basic types.
const basicTypes = <XPathType<Object>>[
  xsArray,
  xsBase64Binary,
  xsBoolean,
  xsByte,
  xsDateTime,
  xsDouble,
  xsDuration,
  xsEmptySequence,
  xsFunction,
  xsHexBinary,
  xsInt,
  xsInteger,
  xsLong,
  xsMap,
  xsNegativeInteger,
  xsNonNegativeInteger,
  xsNonPositiveInteger,
  xsNumeric,
  xsPositiveInteger,
  xsQName,
  xsSequence,
  xsShort,
  xsString,
  xsUnsignedByte,
  xsUnsignedInt,
  xsUnsignedLong,
  xsUnsignedShort,
];
