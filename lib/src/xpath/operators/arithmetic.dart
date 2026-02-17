import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import 'date_time.dart';
import 'duration.dart';

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

/// Dispatches the `+` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opAdd(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opAddDurations(left, right);
  } else if (xsDateTime.matches(a) && xsDuration.matches(b)) {
    return opAddDurationToDateTime(left, right);
  } else if (xsDuration.matches(a) && xsDateTime.matches(b)) {
    return opAddDurationToDateTime(right, left);
  }
  return opNumericAdd(left, right);
}

/// Dispatches the `-` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opSubtract(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opSubtractDurations(left, right);
  } else if (xsDateTime.matches(a) && xsDuration.matches(b)) {
    return opSubtractDurationFromDateTime(left, right);
  } else if (xsDateTime.matches(a) && xsDateTime.matches(b)) {
    return opSubtractDateTimes(left, right);
  }
  return opNumericSubtract(left, right);
}

/// Dispatches the `*` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opMultiply(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (xsDuration.matches(a) && xsNumeric.matches(b)) {
    return opMultiplyDuration(left, right);
  } else if (xsNumeric.matches(a) && xsDuration.matches(b)) {
    return opMultiplyDuration(right, left);
  }
  return opNumericMultiply(left, right);
}

/// Dispatches the `div` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opDivide(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opDivideDurationByDuration(left, right);
  } else if (xsDuration.matches(a) && xsNumeric.matches(b)) {
    return opDivideDuration(left, right);
  }
  return opNumericDivide(left, right);
}
