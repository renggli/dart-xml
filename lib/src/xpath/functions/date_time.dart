import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
const fnDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDateTime,
);

XPathSequence _fnDateTime(
  XPathContext context,
  XPathDateTime? arg1,
  XPathDateTime? arg2,
) {
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
const fnYearFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'year-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearFromDateTime,
);

XPathSequence _fnYearFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
const fnMonthFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'month-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthFromDateTime,
);

XPathSequence _fnMonthFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
const fnDayFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'day-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDayFromDateTime,
);

XPathSequence _fnDayFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
const fnHoursFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'hours-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromDateTime,
);

XPathSequence _fnHoursFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
const fnMinutesFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'minutes-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromDateTime,
);

XPathSequence _fnMinutesFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
const fnSecondsFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'seconds-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromDateTime,
);

XPathSequence _fnSecondsFromDateTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
const fnTimezoneFromDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'timezone-from-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromDateTime,
);

XPathSequence _fnTimezoneFromDateTime(
  XPathContext context,
  XPathDateTime? arg,
) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
const fnYearFromDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'year-from-date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearFromDate,
);

XPathSequence _fnYearFromDate(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
const fnMonthFromDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'month-from-date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthFromDate,
);

XPathSequence _fnMonthFromDate(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
const fnDayFromDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'day-from-date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDayFromDate,
);

XPathSequence _fnDayFromDate(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
const fnTimezoneFromDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'timezone-from-date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromDate,
);

XPathSequence _fnTimezoneFromDate(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
const fnHoursFromTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'hours-from-time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromTime,
);

XPathSequence _fnHoursFromTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
const fnMinutesFromTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'minutes-from-time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromTime,
);

XPathSequence _fnMinutesFromTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
const fnSecondsFromTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'seconds-from-time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromTime,
);

XPathSequence _fnSecondsFromTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
const fnTimezoneFromTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'timezone-from-time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromTime,
);

XPathSequence _fnTimezoneFromTime(XPathContext context, XPathDateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
Object _defaultTimezone(XPathContext context) => DateTime.now().timeZoneOffset;

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
const fnAdjustDateTimeToTimezone = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'adjust-dateTime-to-timezone',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
      defaultValue: _defaultTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

XPathSequence _fnAdjustDateTimeToTimezone(
  XPathContext context,
  XPathDateTime? arg, [
  XPathDuration? timezone,
]) {
  if (arg == null) return XPathSequence.empty;
  if (timezone == null) {
    // Empty sequence: return value without timezone (or as is).
    // Spec: "If $timezone is the empty sequence, the result is ... without a timezone."
    // Dart DateTime always has timezone.
    return XPathSequence.single(arg);
  }

  // Adjust to specific timezone.
  if (timezone.inMicroseconds == 0) {
    return XPathSequence.single(arg.toUtc().toXPathDateTime());
  }

  final localOffset = DateTime.now().timeZoneOffset;
  if (timezone.inMicroseconds == localOffset.inMicroseconds) {
    return XPathSequence.single(arg.toLocal().toXPathDateTime());
  }

  throw XPathEvaluationException(
    'Implementation restriction: specific timezones not supported by Dart DateTime',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
const fnAdjustDateToTimezone = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'adjust-date-to-timezone',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
      defaultValue: _defaultTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
const fnAdjustTimeToTimezone = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'adjust-time-to-timezone',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
      defaultValue: _defaultTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
const fnFormatDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

// Basic implementation: ignore picture and other arguments
XPathSequence _fnFormatDateTime(
  XPathContext context,
  XPathDateTime? value,
  XPathString picture, [
  XPathString? language,
  XPathString? calendar,
  XPathString? place,
]) => value != null
    ? XPathSequence.single(value.toIso8601String())
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
const fnFormatDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
const fnFormatTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathDateTime,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
const fnParseIetfDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-ietf-date',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnParseIetfDate,
);

XPathSequence _fnParseIetfDate(XPathContext context, [XPathString? value]) =>
    throw UnimplementedError('fn:parse-ietf-date');
