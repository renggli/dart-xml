import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/boolean.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueEqual(XPathSequence left, XPathSequence right) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  return XPathSequence.single(item1 == item2);
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueNotEqual(XPathSequence left, XPathSequence right) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  return XPathSequence.single(item1 != item2);
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (a, b) => a < b, (a, b) => a.compareTo(b) < 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThanOrEqual(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (a, b) => a <= b, (a, b) => a.compareTo(b) <= 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (a, b) => a > b, (a, b) => a.compareTo(b) > 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) =>
    _compareValue(left, right, (a, b) => a >= b, (a, b) => a.compareTo(b) >= 0);

Object? _atomizeSingle(XPathSequence seq) {
  final data = _atomize(seq);
  if (data.isEmpty) return null;
  if (data.length > 1) {
    throw XPathEvaluationException(
      'Sequence contains more than one item: $data',
    );
  }
  return data.first;
}

Iterable<Object> _atomize(XPathSequence seq) => seq.expand((item) {
  if (item is XmlNode) {
    return [xsString.cast(item)];
  } else {
    return [item];
  }
});

XPathSequence _compareValue(
  XPathSequence left,
  XPathSequence right,
  bool Function(num, num) numComparator,
  bool Function(String, String) stringComparator,
) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;

  if (item1 is num && item2 is num) {
    return XPathSequence.single(numComparator(item1, item2));
  } else if (item1 is String && item2 is String) {
    return XPathSequence.single(stringComparator(item1, item2));
  } else {
    throw XPathEvaluationException('Cannot compare $item1 and $item2');
  }
}

/// Compares two XPath values.
int compare(Object a, Object b) {
  if (xsNumeric.matches(a) && xsNumeric.matches(b)) {
    return xsNumeric.cast(a).compareTo(xsNumeric.cast(b));
  } else if (xsString.matches(a) && xsString.matches(b)) {
    return xsString.cast(a).compareTo(xsString.cast(b));
  } else if (xsBoolean.matches(a) && xsBoolean.matches(b)) {
    final ba = xsBoolean.cast(a);
    final bb = xsBoolean.cast(b);
    return ba == bb
        ? 0
        : ba
        ? 1
        : -1;
  } else {
    return a.toString().compareTo(b.toString());
  }
}
