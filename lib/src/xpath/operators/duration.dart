import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
XPathSequence opDurationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
  return d1 == d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
  return d1 < d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
  return d1 > d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
  return d1 < d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
  return d1 > d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-durations
XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.single as XPathDuration) + (right.single as XPathDuration),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) => opAddDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(XPathSequence left, XPathSequence right) =>
    opAddDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-durations
XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.single as XPathDuration) - (right.single as XPathDuration),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-duration
XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = left.single as XPathDuration;
  final factor = (right.single as XPathNumeric).toDouble();
  if (factor.isNaN) {
    throw XPathEvaluationException(
      XPathErrorCode.FOCA0005,
      'NaN multiplier in duration multiplication',
    );
  }
  if (factor.isInfinite) {
    throw XPathEvaluationException(
      XPathErrorCode.FODT0002,
      'Overflow: duration multiplication by Infinity',
    );
  }
  return XPathSequence.single(duration * factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opMultiplyDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opMultiplyDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-duration
XPathSequence opDivideDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = left.single as XPathDuration;
  final divisor = (right.single as XPathNumeric).toDouble();
  if (divisor.isNaN) {
    throw XPathEvaluationException(
      XPathErrorCode.FOCA0005,
      'NaN divisor in duration division',
    );
  }
  if (divisor.isInfinite) {
    return XPathSequence.single(XPathDuration(type: duration.type));
  }
  final rounded = divisor.round();
  if (rounded == 0) {
    throw XPathEvaluationException(XPathErrorCode.FOAR0001, 'Division by zero');
  }
  return XPathSequence.single(duration ~/ rounded);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-duration-by-duration
XPathSequence opDivideDurationByDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final divisor = right.single as XPathDuration;
  if ((d1.isYearMonth && !divisor.isYearMonth) ||
      (d1.isDayTime && !divisor.isDayTime)) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot divide ${d1.type} by ${divisor.type}',
    );
  }
  if (d1.isYearMonth && divisor.totalMonths == 0) {
    throw XPathEvaluationException(XPathErrorCode.FOAR0001, 'Division by zero');
  }
  if (d1.isDayTime && divisor.totalMicroseconds == 0) {
    throw XPathEvaluationException(XPathErrorCode.FOAR0001, 'Division by zero');
  }
  if (divisor.totalMonths == 0 && divisor.totalMicroseconds == 0) {
    throw XPathEvaluationException(XPathErrorCode.FOAR0001, 'Division by zero');
  }
  return XPathSequence.single(XPathDouble(d1.divideByDuration(divisor)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);
