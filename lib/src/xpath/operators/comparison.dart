import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/binary.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';
import '../values/untyped_atomic.dart';

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueEqual(XPathSequence left, XPathSequence right) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  if (item1 is XmlName || item2 is XmlName) {
    if (item1 is XmlName && item2 is XmlName) {
      return XPathSequence.single(item1 == item2);
    }
    throw XPathEvaluationException('Cannot compare $item1 and $item2');
  }
  if (item1 is num && item2 is num) {
    if (item1.isNaN || item2.isNaN) return XPathSequence.falseSequence;
    return XPathSequence.single(item1 == item2);
  }
  if (item1 is XPathAbstractDuration && item2 is XPathAbstractDuration) {
    return XPathSequence.single(item1 == item2);
  }
  if ((item1 is XPathBase64Binary && item2 is XPathBase64Binary) ||
      (item1 is XPathHexBinary && item2 is XPathHexBinary)) {
    return XPathSequence.single(item1 == item2);
  }
  return XPathSequence.single(compare(item1, item2) == 0);
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueNotEqual(XPathSequence left, XPathSequence right) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  if (item1 is XmlName || item2 is XmlName) {
    if (item1 is XmlName && item2 is XmlName) {
      return XPathSequence.single(item1 != item2);
    }
    throw XPathEvaluationException('Cannot compare $item1 and $item2');
  }
  if (item1 is num && item2 is num) {
    if (item1.isNaN || item2.isNaN) return XPathSequence.trueSequence;
    return XPathSequence.single(item1 != item2);
  }
  if (item1 is XPathAbstractDuration && item2 is XPathAbstractDuration) {
    return XPathSequence.single(item1 != item2);
  }
  if ((item1 is XPathBase64Binary && item2 is XPathBase64Binary) ||
      (item1 is XPathHexBinary && item2 is XPathHexBinary)) {
    return XPathSequence.single(item1 != item2);
  }
  return XPathSequence.single(compare(item1, item2) != 0);
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c < 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThanOrEqual(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c <= 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c > 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareValue(left, right, (c) => c >= 0);

Object? _atomizeSingle(XPathSequence seq) {
  final data = seq.atomize().toList();
  if (data.isEmpty) return null;
  if (data.length > 1) {
    throw XPathEvaluationException(
      'Sequence contains more than one item: (${data.join(', ')})',
    );
  }
  return data.first;
}

XPathSequence _compareValue(
  XPathSequence left,
  XPathSequence right,
  bool Function(int) test,
) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  if (item1 is num && item2 is num && (item1.isNaN || item2.isNaN)) {
    return XPathSequence.falseSequence;
  }
  return XPathSequence.single(test(compare(item1, item2)));
}

/// Compares two XPath values.
int compare(Object a, Object b) => switch ((a, b)) {
  (final XPathUntypedAtomic ua, final XPathUntypedAtomic ub) =>
    ua.value.compareTo(ub.value),
  (final XPathUntypedAtomic ua, final String sb) => ua.value.compareTo(sb),
  (final String sa, final XPathUntypedAtomic ub) => sa.compareTo(ub.value),
  (final num na, final num nb) => na.compareTo(nb),
  (final String sa, final String sb) => sa.compareTo(sb),
  (final bool ba, final bool bb) =>
    ba == bb
        ? 0
        : ba
        ? 1
        : -1,
  (final XPathAbstractDateTime da, final XPathAbstractDateTime db) =>
    da.compareTo(db),
  (final XPathAbstractDuration da, final XPathAbstractDuration db) =>
    da.compareTo(db),
  (final XPathBase64Binary ba, final XPathBase64Binary bb) => _compareBinary(
    ba,
    bb,
  ),
  (final XPathHexBinary ha, final XPathHexBinary hb) => _compareBinary(ha, hb),
  (final DateTime da, final DateTime db) => da.compareTo(db),
  (final Duration da, final Duration db) => da.compareTo(db),
  (final List<Object?> la, final List<Object?> lb) => _compareList(
    la.cast(),
    lb.cast(),
  ),
  (final XPathSequence sa, final XPathSequence sb) => _compareList(
    sa.toList(),
    sb.toList(),
  ),
  (final List<Object?> la, final XPathSequence sb) => _compareList(
    la.cast(),
    sb.toList(),
  ),
  (final XPathSequence sa, final List<Object?> lb) => _compareList(
    sa.toList(),
    lb.cast(),
  ),
  _ => throw XPathEvaluationException(
    'Cannot compare ${a.runtimeType} and ${b.runtimeType}',
  ),
};

int _compareBinary(List<int> a, List<int> b) {
  final len = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final diff = a[i].compareTo(b[i]);
    if (diff != 0) return diff;
  }
  return a.length.compareTo(b.length);
}

int _compareList(List<Object> a, List<Object> b) {
  final len = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final diff = compare(a[i], b[i]);
    if (diff != 0) return diff;
  }
  return a.length.compareTo(b.length);
}
