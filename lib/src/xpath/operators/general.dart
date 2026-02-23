import '../../xml/nodes/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opAnd(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(left.ebv && right.ebv);

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opOr(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(left.ebv || right.ebv);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => a == b);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralNotEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => a != b);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => (a as Comparable).compareTo(b) < 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) => (a as Comparable).compareTo(b) > 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) =>
    _compareGeneral(left, right, (a, b) => (a as Comparable).compareTo(b) <= 0);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) =>
    _compareGeneral(left, right, (a, b) => (a as Comparable).compareTo(b) >= 0);

XPathSequence _compareGeneral(
  XPathSequence left,
  XPathSequence right,
  bool Function(Object, Object) comparator,
) {
  final seq1 = _atomize(left);
  final seq2 = _atomize(right);
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      if (item1 is num && item2 is num) {
        if (comparator(item1, item2)) return XPathSequence.trueSequence;
      }
      if (item1.toString() == item2.toString() &&
          comparator(item1.toString(), item2.toString())) {
        return XPathSequence.trueSequence;
      }
    }
  }
  return XPathSequence.falseSequence;
}

Iterable<Object> _atomize(XPathSequence seq) => seq.expand((item) {
  if (item is XmlNode) {
    return [xsString.cast(item)];
  } else {
    return [item];
  }
});
