import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-QName-equal
XPathSequence opQNameEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return left.first == right.first
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}
