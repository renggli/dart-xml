import '../types/boolean.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
XPathSequence opBooleanEqual(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(xsBoolean.cast(left) == xsBoolean.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
XPathSequence opBooleanLessThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      (xsBoolean.cast(left) ? 1 : 0) < (xsBoolean.cast(right) ? 1 : 0),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
XPathSequence opBooleanGreaterThan(XPathSequence left, XPathSequence right) =>
    XPathSequence.single(
      (xsBoolean.cast(left) ? 1 : 0) > (xsBoolean.cast(right) ? 1 : 0),
    );
