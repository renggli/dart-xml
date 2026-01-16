import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/duration.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
XPathSequence opDurationEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) =>
    XPathSequence.single(_compareDuration('op:duration-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDuration('op:yearMonthDuration-less-than', arguments) < 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDuration('op:yearMonthDuration-greater-than', arguments) > 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDuration('op:dayTimeDuration-less-than', arguments) < 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDuration('op:dayTimeDuration-greater-than', arguments) > 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:add-yearMonthDurations',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:add-yearMonthDurations',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:add-yearMonthDurations',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 + arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:subtract-yearMonthDurations',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-yearMonthDurations',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-yearMonthDurations',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 - arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:multiply-yearMonthDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:multiply-yearMonthDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:multiply-yearMonthDuration',
    'arg2',
    arguments[1],
  )?.toXPathNumber();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 * arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:divide-yearMonthDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-yearMonthDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-yearMonthDuration',
    'arg2',
    arguments[1],
  )?.toXPathNumber();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 ~/ arg2.toInt()).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:divide-yearMonthDuration-by-yearMonthDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-yearMonthDuration-by-yearMonthDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-yearMonthDuration-by-yearMonthDuration',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  if (arg2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(arg1.inMicroseconds / arg2.inMicroseconds);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:add-dayTimeDurations',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:add-dayTimeDurations',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:add-dayTimeDurations',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 + arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:subtract-dayTimeDurations',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-dayTimeDurations',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-dayTimeDurations',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 - arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:multiply-dayTimeDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:multiply-dayTimeDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:multiply-dayTimeDuration',
    'arg2',
    arguments[1],
  )?.toXPathNumber();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 * arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:divide-dayTimeDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-dayTimeDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-dayTimeDuration',
    'arg2',
    arguments[1],
  )?.toXPathNumber();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 ~/ arg2.toInt()).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:divide-dayTimeDuration-by-dayTimeDuration',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-dayTimeDuration-by-dayTimeDuration',
    'arg1',
    arguments[0],
  )?.toXPathDuration();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:divide-dayTimeDuration-by-dayTimeDuration',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  if (arg2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(arg1.inMicroseconds / arg2.inMicroseconds);
}

XPathSequence fnYearsFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:years-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:years-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
XPathSequence fnMonthsFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:months-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:months-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
XPathSequence fnDaysFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:days-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:days-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inDays);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
XPathSequence fnHoursFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:hours-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:hours-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inHours % 24);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-duration
XPathSequence fnMinutesFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:minutes-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:minutes-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inMinutes % 60);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-duration
XPathSequence fnSecondsFromDuration(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:seconds-from-duration',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:seconds-from-duration',
    'arg',
    arguments[0],
  )?.toXPathDuration();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.inSeconds % 60 + (arg.inMicroseconds % 1000000) / 1000000.0,
  );
}

int _compareDuration(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg1',
    arguments[0],
  ).toXPathDuration();
  final value2 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg2',
    arguments[1],
  ).toXPathDuration();
  return value1.compareTo(value2);
}
