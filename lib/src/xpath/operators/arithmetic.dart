import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(left) + xsNumeric.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(left) - xsNumeric.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(left) * xsNumeric.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(left) / xsNumeric.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(
        (xsNumeric.cast(left) / xsNumeric.cast(right)).truncate(),
      );

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(left) % xsNumeric.cast(right));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(xsNumeric.cast(arg));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(-xsNumeric.cast(arg));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(
        xsNumeric.cast(left).compareTo(xsNumeric.cast(right)) == 0,
      );

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(
        xsNumeric.cast(left).compareTo(xsNumeric.cast(right)) < 0,
      );

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(
        xsNumeric.cast(left).compareTo(xsNumeric.cast(right)) > 0,
      );
