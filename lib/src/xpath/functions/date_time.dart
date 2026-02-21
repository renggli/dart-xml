import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
const fnDateTime = XPathFunctionDefinition(
  name: 'fn:dateTime',
  aliases: ['dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDateTime,
);

XPathSequence _fnDateTime(
  XPathContext context,
  DateTime? arg1,
  DateTime? arg2,
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
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-dateTime
const fnYearFromDateTime = XPathFunctionDefinition(
  name: 'fn:year-from-dateTime',
  aliases: ['year-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearFromDateTime,
);

XPathSequence _fnYearFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
const fnMonthFromDateTime = XPathFunctionDefinition(
  name: 'fn:month-from-dateTime',
  aliases: ['month-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthFromDateTime,
);

XPathSequence _fnMonthFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
const fnDayFromDateTime = XPathFunctionDefinition(
  name: 'fn:day-from-dateTime',
  aliases: ['day-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDayFromDateTime,
);

XPathSequence _fnDayFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
const fnHoursFromDateTime = XPathFunctionDefinition(
  name: 'fn:hours-from-dateTime',
  aliases: ['hours-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromDateTime,
);

XPathSequence _fnHoursFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
const fnMinutesFromDateTime = XPathFunctionDefinition(
  name: 'fn:minutes-from-dateTime',
  aliases: ['minutes-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromDateTime,
);

XPathSequence _fnMinutesFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
const fnSecondsFromDateTime = XPathFunctionDefinition(
  name: 'fn:seconds-from-dateTime',
  aliases: ['seconds-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromDateTime,
);

XPathSequence _fnSecondsFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
const fnTimezoneFromDateTime = XPathFunctionDefinition(
  name: 'fn:timezone-from-dateTime',
  aliases: ['timezone-from-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromDateTime,
);

XPathSequence _fnTimezoneFromDateTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
const fnYearFromDate = XPathFunctionDefinition(
  name: 'fn:year-from-date',
  aliases: ['year-from-date'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearFromDate,
);

XPathSequence _fnYearFromDate(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
const fnMonthFromDate = XPathFunctionDefinition(
  name: 'fn:month-from-date',
  aliases: ['month-from-date'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthFromDate,
);

XPathSequence _fnMonthFromDate(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
const fnDayFromDate = XPathFunctionDefinition(
  name: 'fn:day-from-date',
  aliases: ['day-from-date'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDayFromDate,
);

XPathSequence _fnDayFromDate(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
const fnTimezoneFromDate = XPathFunctionDefinition(
  name: 'fn:timezone-from-date',
  aliases: ['timezone-from-date'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromDate,
);

XPathSequence _fnTimezoneFromDate(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
const fnHoursFromTime = XPathFunctionDefinition(
  name: 'fn:hours-from-time',
  aliases: ['hours-from-time'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromTime,
);

XPathSequence _fnHoursFromTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
const fnMinutesFromTime = XPathFunctionDefinition(
  name: 'fn:minutes-from-time',
  aliases: ['minutes-from-time'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromTime,
);

XPathSequence _fnMinutesFromTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
const fnSecondsFromTime = XPathFunctionDefinition(
  name: 'fn:seconds-from-time',
  aliases: ['seconds-from-time'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromTime,
);

XPathSequence _fnSecondsFromTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
const fnTimezoneFromTime = XPathFunctionDefinition(
  name: 'fn:timezone-from-time',
  aliases: ['timezone-from-time'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezoneFromTime,
);

XPathSequence _fnTimezoneFromTime(XPathContext context, DateTime? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.timeZoneOffset);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
const fnAdjustDateTimeToTimezone = XPathFunctionDefinition(
  name: 'fn:adjust-dateTime-to-timezone',
  aliases: ['adjust-dateTime-to-timezone'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,

      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

XPathSequence _fnAdjustDateTimeToTimezone(
  XPathContext context,
  DateTime? arg, [
  Duration? timezone,
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
    return XPathSequence.single(arg.toUtc());
  }

  final localOffset = DateTime.now().timeZoneOffset;
  if (timezone.inMicroseconds == localOffset.inMicroseconds) {
    return XPathSequence.single(arg.toLocal());
  }

  throw UnsupportedError('Specific timezones not supported.');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
const fnAdjustDateToTimezone = XPathFunctionDefinition(
  name: 'fn:adjust-date-to-timezone',
  aliases: ['adjust-date-to-timezone'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,

      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
const fnAdjustTimeToTimezone = XPathFunctionDefinition(
  name: 'fn:adjust-time-to-timezone',
  aliases: ['adjust-time-to-timezone'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,

      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
const fnFormatDateTime = XPathFunctionDefinition(
  name: 'fn:format-dateTime',
  aliases: ['format-dateTime'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

// Basic implementation: ignore picture and other arguments
XPathSequence _fnFormatDateTime(
  XPathContext context,
  DateTime? value,
  String picture, [
  String? language,
  String? calendar,
  String? place,
]) => value != null
    ? XPathSequence.single(value.toIso8601String())
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
const fnFormatDate = XPathFunctionDefinition(
  name: 'fn:format-date',
  aliases: ['format-date'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
const fnFormatTime = XPathFunctionDefinition(
  name: 'fn:format-time',
  aliases: ['format-time'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'calendar',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'place',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
const fnParseIetfDate = XPathFunctionDefinition(
  name: 'fn:parse-ietf-date',
  aliases: ['parse-ietf-date'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnParseIetfDate,
);

XPathSequence _fnParseIetfDate(XPathContext context, [String? value]) =>
    throw UnimplementedError('fn:parse-ietf-date');

Object _defaultToTimezone(XPathContext context) =>
    DateTime.now().timeZoneOffset;
