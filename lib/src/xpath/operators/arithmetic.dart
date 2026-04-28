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
  if (xsYearMonthDuration.matches(a) && xsYearMonthDuration.matches(b)) {
    return opAddYearMonthDurations(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsDayTimeDuration.matches(b)) {
    return opAddDayTimeDurations(left, right);
  } else if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opAddDurations(left, right);
    // xs:dateTime arithmetic
  } else if (xsDateTime.matches(a) && xsYearMonthDuration.matches(b)) {
    return opAddYearMonthDurationToDateTime(left, right);
  } else if (xsYearMonthDuration.matches(a) && xsDateTime.matches(b)) {
    return opAddYearMonthDurationToDateTime(right, left);
  } else if (xsDateTime.matches(a) && xsDayTimeDuration.matches(b)) {
    return opAddDayTimeDurationToDateTime(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsDateTime.matches(b)) {
    return opAddDayTimeDurationToDateTime(right, left);
  } else if (xsDateTime.matches(a) && xsDuration.matches(b)) {
    return opAddDurationToDateTime(left, right);
  } else if (xsDuration.matches(a) && xsDateTime.matches(b)) {
    return opAddDurationToDateTime(right, left);
    // xs:date arithmetic
  } else if (xsDate.matches(a) && xsYearMonthDuration.matches(b)) {
    return opAddYearMonthDurationToDate(left, right);
  } else if (xsYearMonthDuration.matches(a) && xsDate.matches(b)) {
    return opAddYearMonthDurationToDate(right, left);
  } else if (xsDate.matches(a) && xsDayTimeDuration.matches(b)) {
    return opAddDayTimeDurationToDate(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsDate.matches(b)) {
    return opAddDayTimeDurationToDate(right, left);
    // xs:time arithmetic
  } else if (xsTime.matches(a) && xsDayTimeDuration.matches(b)) {
    return opAddDayTimeDurationToTime(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsTime.matches(b)) {
    return opAddDayTimeDurationToTime(right, left);
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
  if (xsYearMonthDuration.matches(a) && xsYearMonthDuration.matches(b)) {
    return opSubtractYearMonthDurations(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsDayTimeDuration.matches(b)) {
    return opSubtractDayTimeDurations(left, right);
  } else if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opSubtractDurations(left, right);
    // xs:dateTime
  } else if (xsDateTime.matches(a) && xsYearMonthDuration.matches(b)) {
    return opSubtractYearMonthDurationFromDateTime(left, right);
  } else if (xsDateTime.matches(a) && xsDayTimeDuration.matches(b)) {
    return opSubtractDayTimeDurationFromDateTime(left, right);
  } else if (xsDateTime.matches(a) && xsDuration.matches(b)) {
    return opSubtractDurationFromDateTime(left, right);
  } else if (xsDateTime.matches(a) && xsDateTime.matches(b)) {
    return opSubtractDateTimes(left, right);
    // xs:date
  } else if (xsDate.matches(a) && xsYearMonthDuration.matches(b)) {
    return opSubtractYearMonthDurationFromDate(left, right);
  } else if (xsDate.matches(a) && xsDayTimeDuration.matches(b)) {
    return opSubtractDayTimeDurationFromDate(left, right);
  } else if (xsDate.matches(a) && xsDate.matches(b)) {
    return opSubtractDates(left, right);
    // xs:time
  } else if (xsTime.matches(a) && xsDayTimeDuration.matches(b)) {
    return opSubtractDayTimeDurationFromTime(left, right);
  } else if (xsTime.matches(a) && xsTime.matches(b)) {
    return opSubtractTimes(left, right);
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
  if (xsYearMonthDuration.matches(a) && xsNumeric.matches(b)) {
    return opMultiplyYearMonthDuration(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsNumeric.matches(b)) {
    return opMultiplyDayTimeDuration(left, right);
  } else if (xsDuration.matches(a) && xsNumeric.matches(b)) {
    return opMultiplyDuration(left, right);
  } else if (xsNumeric.matches(a) && xsYearMonthDuration.matches(b)) {
    return opMultiplyYearMonthDuration(right, left);
  } else if (xsNumeric.matches(a) && xsDayTimeDuration.matches(b)) {
    return opMultiplyDayTimeDuration(right, left);
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
  if (xsYearMonthDuration.matches(a) && xsYearMonthDuration.matches(b)) {
    return opDivideYearMonthDurationByYearMonthDuration(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsDayTimeDuration.matches(b)) {
    return opDivideDayTimeDurationByDayTimeDuration(left, right);
  } else if (xsDuration.matches(a) && xsDuration.matches(b)) {
    return opDivideDurationByDuration(left, right);
  } else if (xsYearMonthDuration.matches(a) && xsNumeric.matches(b)) {
    return opDivideYearMonthDuration(left, right);
  } else if (xsDayTimeDuration.matches(a) && xsNumeric.matches(b)) {
    return opDivideDayTimeDuration(left, right);
  } else if (xsDuration.matches(a) && xsNumeric.matches(b)) {
    return opDivideDuration(left, right);
  }
  return opNumericDivide(left, right);
}
