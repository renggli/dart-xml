import '../xdm/atomic/binary.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathHexBinary) == (right.single as XPathHexBinary)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathHexBinary).compareTo(
            right.single as XPathHexBinary,
          ) <
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathHexBinary).compareTo(
            right.single as XPathHexBinary,
          ) >
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBase64Binary) ==
          (right.single as XPathBase64Binary)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBase64Binary).compareTo(
            right.single as XPathBase64Binary,
          ) <
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathBase64Binary).compareTo(
            right.single as XPathBase64Binary,
          ) >
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}
