import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/date_time.dart';
import '../types31/duration.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

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

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-equal
XPathSequence opDateTimeEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) =>
    XPathSequence.single(_compareDateTime('op:dateTime-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-less-than
XPathSequence opDateTimeLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:dateTime-less-than', arguments) == -1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-greater-than
XPathSequence opDateTimeGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:dateTime-greater-than', arguments) == 1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-date-equal
XPathSequence opDateEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareDateTime('op:date-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-date-less-than
XPathSequence opDateLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:date-less-than', arguments) == -1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-date-greater-than
XPathSequence opDateGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:date-greater-than', arguments) == 1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-equal
XPathSequence opTimeEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareDateTime('op:time-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-less-than
XPathSequence opTimeLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:time-less-than', arguments) == -1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-greater-than
XPathSequence opTimeGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:time-greater-than', arguments) == 1,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth-equal
XPathSequence opGYearMonthEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:gYearMonth-equal', arguments) == 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear-equal
XPathSequence opGYearEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareDateTime('op:gYear-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay-equal
XPathSequence opGMonthDayEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareDateTime('op:gMonthDay-equal', arguments) == 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth-equal
XPathSequence opGMonthEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareDateTime('op:gMonth-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay-equal
XPathSequence opGDayEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareDateTime('op:gDay-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dateTimes
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

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dates
XPathSequence opSubtractDates(
  XPathContext context,
  List<XPathSequence> arguments,
) => opSubtractDateTimes(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-times
XPathSequence opSubtractTimes(
  XPathContext context,
  List<XPathSequence> arguments,
) => opSubtractDateTimes(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-dateTime
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

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
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

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
XPathSequence fnAdjustDateTimeToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:adjust-dateTime-to-timezone',
    arguments,
    1,
    2,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:adjust-dateTime-to-timezone',
    'arg',
    arguments[0],
  )?.toXPathDateTime();
  if (arg == null) return XPathSequence.empty;
  if (arguments.length == 1) {
    // No timezone argument: adjust to implicit timezone (Local)
    return XPathSequence.single(arg.toLocal().toXPathDateTime());
  }
  final timezone = XPathEvaluationException.extractZeroOrOne(
    'fn:adjust-dateTime-to-timezone',
    'timezone',
    arguments[1],
  )?.toXPathDuration();
  if (timezone == null) {
    // Empty sequence: return value without timezone.
    // Dart DateTime always has a timezone (UTC or Local).
    // This is an approximation.
    return XPathSequence.single(arg);
  }
  if (timezone.inMicroseconds == 0) {
    return XPathSequence.single(arg.toUtc().toXPathDateTime());
  }
  // Implementation restriction: Dart DateTime only supports UTC and Local.
  // We cannot represent arbitrary timezones.
  // If the offset matches Local, we convert to Local.
  final localOffset = arg.toLocal().timeZoneOffset;
  if (timezone.inMicroseconds == localOffset.inMicroseconds) {
    return XPathSequence.single(arg.toLocal().toXPathDateTime());
  }
  throw XPathEvaluationException(
    'Implementation restriction: specific timezones not supported by Dart DateTime',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
XPathSequence fnAdjustDateToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) => fnAdjustDateTimeToTimezone(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
XPathSequence fnAdjustTimeToTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) => fnAdjustDateTimeToTimezone(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
XPathSequence fnFormatDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:format-dateTime',
    arguments,
    2,
    5,
  );
  final value = XPathEvaluationException.extractZeroOrOne(
    'fn:format-dateTime',
    'value',
    arguments[0],
  )?.toXPathDateTime();
  // Basic implementation: ignore picture and other arguments
  return value != null
      ? XPathSequence.single(XPathString(value.toIso8601String()))
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
XPathSequence fnFormatDate(
  XPathContext context,
  List<XPathSequence> arguments,
) => fnFormatDateTime(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
XPathSequence fnFormatTime(
  XPathContext context,
  List<XPathSequence> arguments,
) => fnFormatDateTime(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
XPathSequence fnParseIetfDate(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:parse-ietf-date');
int? _compareDateTime(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractZeroOrOne(
    name,
    'arg1',
    arguments[0],
  )?.toXPathDateTime();
  final value2 = XPathEvaluationException.extractZeroOrOne(
    name,
    'arg2',
    arguments[1],
  )?.toXPathDateTime();
  if (value1 == null || value2 == null) return null;
  return value1.compareTo(value2);
}
