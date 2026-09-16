import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION-equal
XPathSequence opNotationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return left.first == right.first
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}
