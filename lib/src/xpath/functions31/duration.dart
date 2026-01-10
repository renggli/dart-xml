import '../evaluation/context.dart';

import '../exceptions/evaluation_exception.dart';
import '../types31/duration.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

XPathSequence opDurationEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 < val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 > val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 < val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 > val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 + val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 - val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 * val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 ~/ val2.toInt()).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  if (val2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(val1.inMicroseconds / val2.inMicroseconds);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 + val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 - val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 * val2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 ~/ val2.toInt()).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDuration();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  if (val2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(val1.inMicroseconds / val2.inMicroseconds);
}

XPathSequence fnYearsFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
XPathSequence fnMonthsFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
XPathSequence fnDaysFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.inDays);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
XPathSequence fnHoursFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.inHours % 24);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-duration
XPathSequence fnMinutesFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.inMinutes % 60);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-duration
XPathSequence fnSecondsFromDuration(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDuration();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(
    value.inSeconds % 60 + (value.inMicroseconds % 1000000) / 1000000.0,
  );
}
