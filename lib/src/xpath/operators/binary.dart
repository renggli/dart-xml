import '../types/binary.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      _compareBinary(left.toXPathHexBinary(), right.toXPathHexBinary()) == 0,
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      _compareBinary(left.toXPathHexBinary(), right.toXPathHexBinary()) < 0,
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      _compareBinary(left.toXPathHexBinary(), right.toXPathHexBinary()) > 0,
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      _compareBinary(left.toXPathBase64Binary(), right.toXPathBase64Binary()) ==
          0,
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      _compareBinary(left.toXPathBase64Binary(), right.toXPathBase64Binary()) <
          0,
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathSequence left,
  XPathSequence right,
) => XPathSequence.single(
  _compareBinary(left.toXPathBase64Binary(), right.toXPathBase64Binary()) > 0,
);

int _compareBinary(List<int> a, List<int> b) {
  final len = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final diff = a[i].compareTo(b[i]);
    if (diff != 0) return diff;
  }
  return a.length.compareTo(b.length);
}
