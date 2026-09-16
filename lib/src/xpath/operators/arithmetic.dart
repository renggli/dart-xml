import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'date_time.dart';
import 'duration.dart';

XPathNumeric _toNumeric(XPathItem item) {
  if (item is XPathNumeric) return item;
  if (item is XPathUntypedAtomic) {
    final d = XPathDouble.tryParse(item.stringValue);
    if (d != null) return d;
    throw XPathEvaluationException(
      'Cannot convert untypedAtomic "${item.stringValue}" to xs:double [err:FORG0001]',
    );
  }
  throw XPathEvaluationException(
    'Expected numeric value, got $item [err:XPTY0004]',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) + _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) - _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) * _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) / _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    _toNumeric(left.single).idiv(_toNumeric(right.single)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) % _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(arg.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(-_toNumeric(arg.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) == 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) < 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) > 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// Dispatches the `+` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opAdd(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (a is XPathYearMonthDuration && b is XPathYearMonthDuration) {
    return opAddYearMonthDurations(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathDayTimeDuration) {
    return opAddDayTimeDurations(left, right);
  } else if (a is XPathDuration && b is XPathDuration) {
    return opAddDurations(left, right);
    // xs:dateTime arithmetic
  } else if (a is XPathDateTime && b is XPathYearMonthDuration) {
    return opAddYearMonthDurationToDateTime(left, right);
  } else if (a is XPathYearMonthDuration && b is XPathDateTime) {
    return opAddYearMonthDurationToDateTime(right, left);
  } else if (a is XPathDateTime && b is XPathDayTimeDuration) {
    return opAddDayTimeDurationToDateTime(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathDateTime) {
    return opAddDayTimeDurationToDateTime(right, left);
  } else if (a is XPathDateTime && b is XPathDuration) {
    return opAddDurationToDateTime(left, right);
  } else if (a is XPathDuration && b is XPathDateTime) {
    return opAddDurationToDateTime(right, left);
    // xs:date arithmetic
  } else if (a is XPathDate && b is XPathYearMonthDuration) {
    return opAddYearMonthDurationToDate(left, right);
  } else if (a is XPathYearMonthDuration && b is XPathDate) {
    return opAddYearMonthDurationToDate(right, left);
  } else if (a is XPathDate && b is XPathDayTimeDuration) {
    return opAddDayTimeDurationToDate(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathDate) {
    return opAddDayTimeDurationToDate(right, left);
    // xs:time arithmetic
  } else if (a is XPathTime && b is XPathDayTimeDuration) {
    return opAddDayTimeDurationToTime(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathTime) {
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
  if (a is XPathYearMonthDuration && b is XPathYearMonthDuration) {
    return opSubtractYearMonthDurations(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathDayTimeDuration) {
    return opSubtractDayTimeDurations(left, right);
  } else if (a is XPathDuration && b is XPathDuration) {
    return opSubtractDurations(left, right);
    // xs:dateTime
  } else if (a is XPathDateTime && b is XPathYearMonthDuration) {
    return opSubtractYearMonthDurationFromDateTime(left, right);
  } else if (a is XPathDateTime && b is XPathDayTimeDuration) {
    return opSubtractDayTimeDurationFromDateTime(left, right);
  } else if (a is XPathDateTime && b is XPathDuration) {
    return opSubtractDurationFromDateTime(left, right);
  } else if (a is XPathDateTime && b is XPathDateTime) {
    return opSubtractDateTimes(left, right);
    // xs:date
  } else if (a is XPathDate && b is XPathYearMonthDuration) {
    return opSubtractYearMonthDurationFromDate(left, right);
  } else if (a is XPathDate && b is XPathDayTimeDuration) {
    return opSubtractDayTimeDurationFromDate(left, right);
  } else if (a is XPathDate && b is XPathDate) {
    return opSubtractDates(left, right);
    // xs:time
  } else if (a is XPathTime && b is XPathDayTimeDuration) {
    return opSubtractDayTimeDurationFromTime(left, right);
  } else if (a is XPathTime && b is XPathTime) {
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
  final aIsNum = a is XPathNumeric || a is XPathUntypedAtomic;
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathYearMonthDuration && bIsNum) {
    return opMultiplyYearMonthDuration(
      left,
      XPathSequence.single(_toNumeric(b)),
    );
  } else if (a is XPathDayTimeDuration && bIsNum) {
    return opMultiplyDayTimeDuration(left, XPathSequence.single(_toNumeric(b)));
  } else if (a is XPathDuration && bIsNum) {
    return opMultiplyDuration(left, XPathSequence.single(_toNumeric(b)));
  } else if (aIsNum && b is XPathYearMonthDuration) {
    return opMultiplyYearMonthDuration(
      right,
      XPathSequence.single(_toNumeric(a)),
    );
  } else if (aIsNum && b is XPathDayTimeDuration) {
    return opMultiplyDayTimeDuration(
      right,
      XPathSequence.single(_toNumeric(a)),
    );
  } else if (aIsNum && b is XPathDuration) {
    return opMultiplyDuration(right, XPathSequence.single(_toNumeric(a)));
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
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathYearMonthDuration && b is XPathYearMonthDuration) {
    return opDivideYearMonthDurationByYearMonthDuration(left, right);
  } else if (a is XPathDayTimeDuration && b is XPathDayTimeDuration) {
    return opDivideDayTimeDurationByDayTimeDuration(left, right);
  } else if (a is XPathDuration && b is XPathDuration) {
    return opDivideDurationByDuration(left, right);
  } else if (a is XPathYearMonthDuration && bIsNum) {
    return opDivideYearMonthDuration(left, XPathSequence.single(_toNumeric(b)));
  } else if (a is XPathDayTimeDuration && bIsNum) {
    return opDivideDayTimeDuration(left, XPathSequence.single(_toNumeric(b)));
  } else if (a is XPathDuration && bIsNum) {
    return opDivideDuration(left, XPathSequence.single(_toNumeric(b)));
  }
  return opNumericDivide(left, right);
}
