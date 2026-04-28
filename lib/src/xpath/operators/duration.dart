import '../exceptions/evaluation_exception.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
///
/// Two xs:duration values are equal iff their year-month parts are equal AND
/// their day-time parts are equal (XPath 3.1 §10.3.2).
XPathSequence opDurationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(
    d1.months == d2.months && d1.dayTime == d2.dayTime,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left).totalMonths <
        xsYearMonthDuration.cast(right).totalMonths,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left).totalMonths >
        xsYearMonthDuration.cast(right).totalMonths,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) < xsDayTimeDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) > xsDayTimeDuration.cast(right),
  );
}

XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(
    XPathDuration(
      months: d1.months + d2.months,
      dayTime: d1.dayTime + d2.dayTime,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) + xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) + xsDayTimeDuration.cast(right),
  );
}

XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(
    XPathDuration(
      months: d1.months - d2.months,
      dayTime: d1.dayTime - d2.dayTime,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) - xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) - xsDayTimeDuration.cast(right),
  );
}

XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d = xsDuration.cast(left);
  final f = xsNumeric.cast(right);
  return XPathSequence.single(
    XPathDuration(months: (d.months * f).round(), dayTime: d.dayTime * f),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) * xsNumeric.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) * xsNumeric.cast(right),
  );
}

XPathSequence opDivideDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d = xsDuration.cast(left);
  final f = xsNumeric.cast(right).round();
  if (f == 0) throw XPathEvaluationException('Division by zero');
  return XPathSequence.single(
    XPathDuration(months: d.months ~/ f, dayTime: d.dayTime ~/ f),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) ~/ xsNumeric.cast(right).round(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) ~/ xsNumeric.cast(right).round(),
  );
}

XPathSequence opDivideDurationByDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d2 = xsDayTimeDuration.cast(right);
  if (d2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(
    xsDayTimeDuration.cast(left).inMicroseconds / d2.inMicroseconds,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d2 = xsYearMonthDuration.cast(right);
  if (d2.totalMonths == 0) throw XPathEvaluationException('Division by zero');
  return XPathSequence.single(
    xsYearMonthDuration.cast(left).divideByDuration(d2),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);
