import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/string.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

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
  XPathDate? arg1,
  XPathTime? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  final tz1 = arg1.timezoneOffsetMinutes;
  final tz2 = arg2.timezoneOffsetMinutes;
  if (tz1 != null && tz2 != null && tz1 != tz2) {
    throw XPathEvaluationException(
      'Timezone offsets of date and time arguments must match',
    );
  }
  final offset = tz1 ?? tz2;
  return XPathSequence.single(
    XPathDateTime(
      arg1.year,
      arg1.month,
      arg1.day,
      arg2.hour,
      arg2.minute,
      arg2.second,
      arg2.millisecond,
      arg2.microsecond,
      offset,
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

XPathSequence _fnMonth(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null ? XPathSequence.single(arg.month!) : XPathSequence.empty;

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

XPathSequence _fnDay(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null ? XPathSequence.single(arg.day!) : XPathSequence.empty;

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

XPathSequence _fnHours(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null ? XPathSequence.single(arg.hour!) : XPathSequence.empty;

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

XPathSequence _fnMinutes(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null ? XPathSequence.single(arg.minute!) : XPathSequence.empty;

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

XPathSequence _fnSeconds(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null
    ? XPathSequence.single(
        (arg.second ?? 0) +
            (arg.millisecond ?? 0) / 1000.0 +
            (arg.microsecond ?? 0) / 1000000.0,
      )
    : XPathSequence.empty;

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

XPathSequence _fnTimezone(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null && arg.timezoneOffsetMinutes != null
    ? XPathSequence.single(
        XPathDayTimeDuration(arg.timezoneOffsetMinutes! * 60 * 1000000),
      )
    : XPathSequence.empty;

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

XPathSequence _fnYear(XPathContext context, XPathAbstractDateTime? arg) =>
    arg != null ? XPathSequence.single(arg.year!) : XPathSequence.empty;

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

XPathSequence _fnAdjustDateTimeToTimezone(
  XPathContext context,
  XPathAbstractDateTime? arg, [
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
  XPathAbstractDateTime? arg, [
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
  XPathAbstractDateTime? arg, [
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
  XPathAbstractDateTime? value,
  String picture, [
  String? language,
  String? calendar,
  String? place,
]) => value != null
    ? XPathSequence.single(value.toString())
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
    XPathDayTimeDuration.fromDuration(DateTime.now().timeZoneOffset);

XPathAbstractDateTime? _adjustDateTimeHelper(
  XPathAbstractDateTime? arg,
  XPathDayTimeDuration? timezone,
) {
  if (arg == null) return null;
  if (timezone != null) {
    if (timezone.inMicroseconds.abs() > 14 * 3600 * 1000000) {
      throw XPathEvaluationException('Timezone offset out of range: $timezone');
    }
    if (timezone.inMicroseconds % (60 * 1000000) != 0) {
      throw XPathEvaluationException(
        'Timezone offset must be an integral number of minutes: $timezone',
      );
    }
  }

  final originalOffsetMinutes = arg.timezoneOffsetMinutes;
  final targetOffsetMinutes = timezone?.inMinutes;

  final int y, m, d, h, min, s, ms, us;
  if (timezone == null || originalOffsetMinutes == null) {
    y = arg.year ?? 1970;
    m = arg.month ?? 1;
    d = arg.day ?? 1;
    h = arg.hour ?? 0;
    min = arg.minute ?? 0;
    s = arg.second ?? 0;
    ms = arg.millisecond ?? 0;
    us = arg.microsecond ?? 0;
  } else {
    final utcInstant = arg
        .toDateTime(); // This is a UTC DateTime since originalOffsetMinutes != null
    final adjustedUtc = utcInstant.add(Duration(minutes: targetOffsetMinutes!));
    y = adjustedUtc.year;
    m = adjustedUtc.month;
    d = adjustedUtc.day;
    h = adjustedUtc.hour;
    min = adjustedUtc.minute;
    s = adjustedUtc.second;
    ms = adjustedUtc.millisecond;
    us = adjustedUtc.microsecond;
  }

  return switch (arg) {
    XPathDateTimeStamp() =>
      timezone == null
          ? XPathDateTime(y, m, d, h, min, s, ms, us, null)
          : XPathDateTimeStamp(
              y,
              m,
              d,
              h,
              min,
              s,
              ms,
              us,
              targetOffsetMinutes!,
            ),
    XPathDateTime() => XPathDateTime(
      y,
      m,
      d,
      h,
      min,
      s,
      ms,
      us,
      targetOffsetMinutes,
    ),
    XPathDate() => XPathDate(y, m, d, targetOffsetMinutes),
    XPathTime() => XPathTime(h, min, s, ms, us, targetOffsetMinutes),
    XPathYearMonth() => XPathYearMonth(y, m, targetOffsetMinutes),
    XPathYear() => XPathYear(y, targetOffsetMinutes),
    XPathMonthDay() => XPathMonthDay(m, d, targetOffsetMinutes),
    XPathMonth() => XPathMonth(m, targetOffsetMinutes),
    XPathDay() => XPathDay(d, targetOffsetMinutes),
    _ => XPathDateTime(y, m, d, h, min, s, ms, us, targetOffsetMinutes),
  };
}
