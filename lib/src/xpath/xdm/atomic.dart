import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import 'item.dart';

export 'atomic/binary.dart';
export 'atomic/boolean.dart';
export 'atomic/date_time.dart';
export 'atomic/duration.dart';
export 'atomic/numeric.dart';
export 'atomic/qname.dart';
export 'atomic/string.dart';

/// Base class for all atomic values in the XDM 3.1 data model.
abstract class XPathAtomic implements XPathItem, Comparable<XPathAtomic> {
  const new();

  /// Underlying Dart value representation.
  Object get value;

  /// Returns `true` if this atomic value is numeric.
  bool get isNumeric => false;

  @override
  XPathAtomic atomize() => this;

  @override
  Object toValue() => value;

  @override
  int compareTo(XPathAtomic other) => throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot compare $type with ${other.type}',
  );

  @override
  String toString() => stringValue;
}
