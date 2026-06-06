import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
const fnDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsTime,
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
  if (arg1.isUtc && arg2.isUtc) {
    return XPathSequence.single(
      DateTime.utc(
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
  name: XmlName.qualified('fn:year-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnYear,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
const fnMonthFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:month-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonth,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
const fnDayFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:day-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDay,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
const fnHoursFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:hours-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHours,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
const fnMinutesFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:minutes-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutes,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
const fnSecondsFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:seconds-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSeconds,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
const fnTimezoneFromDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:timezone-from-dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDateTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
const fnYearFromDate = XPathFunctionDefinition(
  name: XmlName.qualified('fn:year-from-date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnYear,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
const fnMonthFromDate = XPathFunctionDefinition(
  name: XmlName.qualified('fn:month-from-date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonth,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
const fnDayFromDate = XPathFunctionDefinition(
  name: XmlName.qualified('fn:day-from-date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDay,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
const fnTimezoneFromDate = XPathFunctionDefinition(
  name: XmlName.qualified('fn:timezone-from-date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezone,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
const fnHoursFromTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:hours-from-time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHours,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
const fnMinutesFromTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:minutes-from-time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutes,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
const fnSecondsFromTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:seconds-from-time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSeconds,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
const fnTimezoneFromTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:timezone-from-time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnTimezone,
);

XPathSequence _fnYear(XPathContext context, DateTime? arg) =>
    arg != null ? XPathSequence.single(arg.year) : XPathSequence.empty;

XPathSequence _fnMonth(XPathContext context, DateTime? arg) =>
    arg != null ? XPathSequence.single(arg.month) : XPathSequence.empty;

XPathSequence _fnDay(XPathContext context, DateTime? arg) =>
    arg != null ? XPathSequence.single(arg.day) : XPathSequence.empty;

XPathSequence _fnHours(XPathContext context, DateTime? arg) =>
    arg != null ? XPathSequence.single(arg.hour) : XPathSequence.empty;

XPathSequence _fnMinutes(XPathContext context, DateTime? arg) =>
    arg != null ? XPathSequence.single(arg.minute) : XPathSequence.empty;

XPathSequence _fnSeconds(XPathContext context, DateTime? arg) => arg != null
    ? XPathSequence.single(
        arg.second + arg.millisecond / 1000.0 + arg.microsecond / 1000000.0,
      )
    : XPathSequence.empty;

XPathSequence _fnTimezone(XPathContext context, DateTime? arg) => arg != null
    ? XPathSequence.single(XPathDayTimeDuration(arg.timeZoneOffset))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
const fnAdjustDateTimeToTimezone = XPathFunctionDefinition(
  name: XmlName.qualified('fn:adjust-dateTime-to-timezone'),
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
      type: xsDayTimeDuration,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustDateTimeToTimezone,
);

DateTime? _adjustDateTimeHelper(DateTime? arg, XPathDayTimeDuration? timezone) {
  if (arg == null) return null;
  if (timezone != null) {
    if (timezone.inSeconds.abs() > 14 * 3600) {
      throw XPathEvaluationException('Timezone offset out of range: $timezone');
    }
    if (timezone.inSeconds % 60 != 0) {
      throw XPathEvaluationException(
        'Timezone offset must be an integral number of minutes: $timezone',
      );
    }
  }
  final Duration? targetOffset = timezone;

  // Get the original offset (if any)
  final originalOffset = arg is XPathDateTimeWrapper
      ? arg.timezoneOffset
      : (arg.isUtc ? Duration.zero : null);

  final DateTime localComponents;
  if (originalOffset == null || timezone == null) {
    // If original had no timezone, or target timezone is null, local components are unchanged!
    localComponents = arg;
  } else {
    // If original had a timezone and target is not null, preserve the UTC instant!
    final utcInstant = arg is XPathDateTimeWrapper
        ? arg.utcInstant
        : arg.toUtc();
    localComponents = utcInstant.add(targetOffset!);
  }

  // Format localComponents to UTC to be safe
  final utcLocalComponents = DateTime.utc(
    localComponents.year,
    localComponents.month,
    localComponents.day,
    localComponents.hour,
    localComponents.minute,
    localComponents.second,
    localComponents.millisecond,
    localComponents.microsecond,
  );

  // Construct a new instance of the same type
  return switch (arg) {
    XPathDateTimeStamp() => XPathDateTimeStamp(
      utcLocalComponents,
      targetOffset,
    ),
    XPathDateTime() => XPathDateTime(utcLocalComponents, targetOffset),
    XPathDate() => XPathDate(utcLocalComponents, targetOffset),
    XPathTime() => XPathTime(utcLocalComponents, targetOffset),
    XPathGYearMonth() => XPathGYearMonth(utcLocalComponents, targetOffset),
    XPathGYear() => XPathGYear(utcLocalComponents, targetOffset),
    XPathGMonthDay() => XPathGMonthDay(utcLocalComponents, targetOffset),
    XPathGMonth() => XPathGMonth(utcLocalComponents, targetOffset),
    XPathGDay() => XPathGDay(utcLocalComponents, targetOffset),
    _ => XPathDateTime(utcLocalComponents, targetOffset),
  };
}

XPathSequence _fnAdjustDateTimeToTimezone(
  XPathContext context,
  DateTime? arg, [
  XPathDayTimeDuration? timezone,
]) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null ? XPathSequence.single(result) : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
const fnAdjustDateToTimezone = XPathFunctionDefinition(
  name: XmlName.qualified('fn:adjust-date-to-timezone'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDate,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: xsDayTimeDuration,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustDateToTimezone,
);

XPathSequence _fnAdjustDateToTimezone(
  XPathContext context,
  DateTime? arg, [
  XPathDayTimeDuration? timezone,
]) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(xsDate.cast(result))
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
const fnAdjustTimeToTimezone = XPathFunctionDefinition(
  name: XmlName.qualified('fn:adjust-time-to-timezone'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsTime,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'timezone',
      type: xsDayTimeDuration,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToTimezone,
    ),
  ],
  function: _fnAdjustTimeToTimezone,
);

XPathSequence _fnAdjustTimeToTimezone(
  XPathContext context,
  DateTime? arg, [
  XPathDayTimeDuration? timezone,
]) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(xsTime.cast(result))
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
const fnFormatDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:format-dateTime'),
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
  name: XmlName.qualified('fn:format-date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDate,
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
  name: XmlName.qualified('fn:format-time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsTime,
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
  name: XmlName.qualified('fn:parse-ietf-date'),
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
    XPathDayTimeDuration(DateTime.now().timeZoneOffset);
