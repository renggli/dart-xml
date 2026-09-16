import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../values/binary.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';
import '../values/untyped_atomic.dart';
import 'comparison.dart';

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opAnd(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(left.ebv && right.ebv);

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opOr(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(left.ebv || right.ebv);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, _generalEqual);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralNotEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => !_generalEqual(a, b));

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => compare(a, b) < 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => compare(a, b) > 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareGeneral(left, right, (a, b) => compare(a, b) <= 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareGeneral(left, right, (a, b) => compare(a, b) >= 0);

bool _generalEqual(Object a, Object b) {
  if (a is XmlName || b is XmlName) {
    if (a is XmlName && b is XmlName) return a == b;
    throw XPathEvaluationException('Cannot compare $a and $b');
  }
  if (a is num && b is num) {
    if (a.isNaN || b.isNaN) return false;
    return a == b;
  }
  if (a is XPathAbstractDuration && b is XPathAbstractDuration) {
    return a == b;
  }
  if ((a is XPathBase64Binary && b is XPathBase64Binary) ||
      (a is XPathHexBinary && b is XPathHexBinary)) {
    return a == b;
  }
  return compare(a, b) == 0;
}

XPathSequence _compareGeneral(
  XPathSequence left,
  XPathSequence right,
  bool Function(Object, Object) comparator,
) {
  final seq1 = left.atomize().toList();
  final seq2 = right.atomize().toList();
  if (seq1.isEmpty || seq2.isEmpty) return XPathSequence.falseSequence;

  Object? typeError;
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      try {
        final (c1, c2) = _coerceForGeneralComp(item1, item2);
        if (comparator(c1, c2)) return XPathSequence.trueSequence;
      } catch (error) {
        typeError ??= error;
      }
    }
  }
  if (typeError != null) throw typeError;
  return XPathSequence.falseSequence;
}

(Object, Object) _coerceForGeneralComp(Object a, Object b) {
  if (a is XPathUntypedAtomic && b is XPathUntypedAtomic) {
    return (a.value, b.value);
  }
  if (a is XPathUntypedAtomic) {
    return (_coerceUntyped(a.value, b), b);
  }
  if (b is XPathUntypedAtomic) {
    return (a, _coerceUntyped(b.value, a));
  }
  return _validateComparable(a, b);
}

Object _coerceUntyped(String value, Object target) => switch (target) {
  num() => xsDouble.cast(value),
  bool() => xsBoolean.cast(value),
  String() => value,
  XPathAbstractDuration() => xsDuration.cast(value),
  XPathAbstractDateTime() => xsDateTime.cast(value),
  _ => value,
};

(Object, Object) _validateComparable(Object a, Object b) {
  if ((a is num && b is num) ||
      (a is String && b is String) ||
      (a is bool && b is bool) ||
      (a is XPathAbstractDateTime && b is XPathAbstractDateTime) ||
      (a is XPathAbstractDuration && b is XPathAbstractDuration) ||
      (a is DateTime && b is DateTime) ||
      (a is Duration && b is Duration) ||
      (a is XmlName && b is XmlName) ||
      (a is XPathBase64Binary && b is XPathBase64Binary) ||
      (a is XPathHexBinary && b is XPathHexBinary) ||
      (a is List && b is List)) {
    return (a, b);
  }
  throw XPathEvaluationException(
    'Cannot compare ${a.runtimeType} and ${b.runtimeType}',
  );
}
