import '../definitions/type.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/node.dart';
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
  xsAny,
  xsArray,
  xsAttribute,
  xsBase64Binary,
  xsBoolean,
  xsByte,
  xsComment,
  xsDateTime,
  xsDecimal,
  xsDocument,
  xsDouble,
  xsDuration,
  xsElement,
  xsEmptySequence,
  xsFunction,
  xsHexBinary,
  xsInt,
  xsInteger,
  xsLong,
  xsMap,
  xsNamespace,
  xsNegativeInteger,
  xsNode,
  xsNonNegativeInteger,
  xsNonPositiveInteger,
  xsNumeric,
  xsPositiveInteger,
  xsProcessingInstruction,
  xsQName,
  xsSequence,
  xsShort,
  xsString,
  xsText,
  xsUnsignedByte,
  xsUnsignedInt,
  xsUnsignedLong,
  xsUnsignedShort,
];
