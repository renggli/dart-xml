import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/date_time.dart';
import '../types31/duration.dart';
import '../types31/sequence.dart';

// Functions and operators on dates and times

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
XPathSequence fnDateTime(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:dateTime', arguments, 2);
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'fn:dateTime',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'fn:dateTime',
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(
    DateTime(
      arg1.year,
      arg1.month,
      arg1.day,
      arg2.hour,
      arg2.minute,
      arg2.second,
      arg2.millisecond,
      arg2.microsecond,
    ).toXPathDateTime(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-dateTime
XPathSequence fnYearFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:year-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:year-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
XPathSequence fnMonthFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:month-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:month-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
XPathSequence fnDayFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:day-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:day-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
XPathSequence fnHoursFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:hours-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:hours-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
XPathSequence fnMinutesFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:minutes-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:minutes-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
XPathSequence fnSecondsFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:seconds-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:seconds-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

// Operators
XPathSequence opDateTimeEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:dateTime-equal',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-equal',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-equal',
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.isAtSameMomentAs(arg2));
}

XPathSequence opDateTimeLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:dateTime-less-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-less-than',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-less-than',
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.isBefore(arg2));
}

XPathSequence opDateTimeGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:dateTime-greater-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-greater-than',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:dateTime-greater-than',
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.isAfter(arg2));
}

// TODO: Specialized operators for Date and Time if distinct types are introduced.
// For now, reusing DateTime logic as they are likely represented as DateTime.
XPathSequence opDateEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opDateLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeLessThan(context, arguments);

XPathSequence opDateGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeGreaterThan(context, arguments);

XPathSequence opTimeEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opTimeLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeLessThan(context, arguments);

XPathSequence opTimeGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeGreaterThan(context, arguments);

// Arithmetic
XPathSequence opSubtractDateTimes(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:subtract-dateTimes',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-dateTimes',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-dateTimes',
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.difference(arg2).toXPathDuration());
}

XPathSequence opSubtractDates(
  XPathContext context,
  List<XPathSequence> arguments,
) => opSubtractDateTimes(context, arguments);

XPathSequence opSubtractTimes(
  XPathContext context,
  List<XPathSequence> arguments,
) => opSubtractDateTimes(context, arguments);

XPathSequence opAddDurationToDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:add-yearMonthDuration-to-dateTime',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:add-yearMonthDuration-to-dateTime',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:add-yearMonthDuration-to-dateTime',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.add(arg2).toXPathDateTime());
}

XPathSequence opSubtractDurationFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:subtract-yearMonthDuration-from-dateTime',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-yearMonthDuration-from-dateTime',
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:subtract-yearMonthDuration-from-dateTime',
    'arg2',
    arguments[1],
  )?.toXPathDuration();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.subtract(arg2).toXPathDateTime());
}

// Extraction functions

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
XPathSequence fnTimezoneFromDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:timezone-from-dateTime',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:timezone-from-dateTime',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
XPathSequence fnYearFromDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:year-from-date',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:year-from-date',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
XPathSequence fnMonthFromDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:month-from-date',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:month-from-date',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
XPathSequence fnDayFromDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:day-from-date', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:day-from-date',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
XPathSequence fnTimezoneFromDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:timezone-from-date',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:timezone-from-date',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
XPathSequence fnHoursFromTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:hours-from-time',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:hours-from-time',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
XPathSequence fnMinutesFromTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:minutes-from-time',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:minutes-from-time',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
XPathSequence fnSecondsFromTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:seconds-from-time',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:seconds-from-time',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
XPathSequence fnTimezoneFromTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:timezone-from-time',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:timezone-from-time',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

// Missing operators
XPathSequence opGYearMonthEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opGYearEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opGMonthDayEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opGMonthEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

XPathSequence opGDayEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => opDateTimeEqual(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
XPathSequence fnAdjustDateTimeToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-dateTime-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
XPathSequence fnAdjustDateToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-date-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
XPathSequence fnAdjustTimeToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-time-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
XPathSequence fnFormatDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement dateTime formatting
  throw UnimplementedError('fn:format-dateTime');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
XPathSequence fnFormatDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement date formatting
  throw UnimplementedError('fn:format-date');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
XPathSequence fnFormatTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement time formatting
  throw UnimplementedError('fn:format-time');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
XPathSequence fnParseIetfDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  // TODO: Implement parsing
  throw UnimplementedError('fn:parse-ietf-date');
}
