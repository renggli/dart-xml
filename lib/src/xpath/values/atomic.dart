import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';

/// Base class for all XDM 3.1 atomic values.
abstract class XPathAtomic implements Comparable<XPathAtomic> {
  const new();

  /// The XML Schema / XDM type of this atomic value.
  XPathType get type;

  /// The underlying Dart value representation.
  Object get value;

  /// The canonical string value of this atomic value.
  String get stringValue;

  /// The effective boolean value (EBV) of this atomic value.
  bool get effectiveBooleanValue;

  /// Returns `true` if this atomic value is numeric.
  bool get isNumeric => false;

  @override
  int compareTo(XPathAtomic other) =>
      throw XPathEvaluationException('Cannot compare $type with ${other.type}');

  @override
  String toString() => stringValue;
}
