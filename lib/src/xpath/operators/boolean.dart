import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opAnd(XPathSequence left, XPathSequence right) =>
    left.ebv && right.ebv
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opOr(XPathSequence left, XPathSequence right) =>
    left.ebv || right.ebv
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
XPathSequence opBooleanEqual(XPathSequence left, XPathSequence right) =>
    left.ebv == right.ebv
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
XPathSequence opBooleanLessThan(XPathSequence left, XPathSequence right) =>
    (left.ebv ? 1 : 0) < (right.ebv ? 1 : 0)
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
XPathSequence opBooleanGreaterThan(XPathSequence left, XPathSequence right) =>
    (left.ebv ? 1 : 0) > (right.ebv ? 1 : 0)
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;
