import '../exceptions/evaluation_exception.dart';
import '../types/date_time.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

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
  final data = _atomize(seq);
  if (data.isEmpty) return null;
  if (data.length > 1) {
    throw XPathEvaluationException(
      'Sequence contains more than one item: $data',
    );
  }
  return data.first;
}

Iterable<Object> _atomize(XPathSequence seq) => seq.atomize();

XPathSequence _compareValue(
  XPathSequence left,
  XPathSequence right,
  bool Function(int) test,
) {
  final item1 = _atomizeSingle(left);
  final item2 = _atomizeSingle(right);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  return XPathSequence.single(test(compare(item1, item2)));
}

/// Compares two XPath values.
int compare(Object a, Object b) => switch ((a, b)) {
  (final num na, final num nb) => na.compareTo(nb),
  (final String sa, final String sb) => sa.compareTo(sb),
  (final bool ba, final bool bb) =>
    ba == bb
        ? 0
        : ba
        ? 1
        : -1,
  (final DateTime da, final DateTime db)
      when xsDateTime.matches(da) && xsDateTime.matches(db) =>
    da.compareTo(db),
  (final XPathYearMonthDuration yma, final XPathYearMonthDuration ymb) =>
    yma.totalMonths.compareTo(ymb.totalMonths),
  (final XPathDayTimeDuration dta, final XPathDayTimeDuration dtb) =>
    dta.dayTime.compareTo(dtb.dayTime),
  (final XPathDate da, final XPathDate db) => da.compareTo(db),
  (final XPathTime ta, final XPathTime tb) => ta.compareTo(tb),
  _ => a.toString().compareTo(b.toString()),
};
