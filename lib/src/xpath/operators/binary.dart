import '../xdm/atomic/binary.dart';
import '../xdm/sequence.dart';

XPathSequence _opBinaryEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBinary) == (right.single as XPathBinary)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _opBinaryLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBinary).compareTo(right.single as XPathBinary) < 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _opBinaryGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBinary).compareTo(right.single as XPathBinary) > 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(XPathSequence left, XPathSequence right) =>
    _opBinaryEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(XPathSequence left, XPathSequence right) =>
    _opBinaryLessThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(XPathSequence left, XPathSequence right) =>
    _opBinaryGreaterThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(XPathSequence left, XPathSequence right) =>
    _opBinaryEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(XPathSequence left, XPathSequence right) =>
    _opBinaryLessThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathSequence left,
  XPathSequence right,
) => _opBinaryGreaterThan(left, right);
