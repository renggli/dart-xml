import '../types/boolean.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
XPathSequence opBooleanEqual(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(left.toXPathBoolean() == right.toXPathBoolean());

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
XPathSequence opBooleanLessThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      (left.toXPathBoolean() ? 1 : 0) < (right.toXPathBoolean() ? 1 : 0),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
XPathSequence opBooleanGreaterThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      (left.toXPathBoolean() ? 1 : 0) > (right.toXPathBoolean() ? 1 : 0),
    );
