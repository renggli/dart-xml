import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
final fnDateTime = XPathFunctionItem.fn2(
  const XmlName.qualified('fn:dateTime'),
  (context, arg1Seq, arg2Seq) {
    final arg1 = arg1Seq.atomize().firstOrNull as XPathDate?;
    final arg2 = arg2Seq.atomize().firstOrNull as XPathTime?;
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
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-dateTime
final fnYearFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:year-from-dateTime'),
  (context, arg) =>
      _evalYear(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
final fnMonthFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:month-from-dateTime'),
  (context, arg) =>
      _evalMonth(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalMonth(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.month!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
final fnDayFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:day-from-dateTime'),
  (context, arg) =>
      _evalDay(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalDay(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.day!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
final fnHoursFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:hours-from-dateTime'),
  (context, arg) =>
      _evalHours(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalHours(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.hour!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
final fnMinutesFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:minutes-from-dateTime'),
  (context, arg) =>
      _evalMinutes(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalMinutes(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.minute!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
final fnSecondsFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:seconds-from-dateTime'),
  (context, arg) =>
      _evalSeconds(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalSeconds(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(
        XPathDecimal.fromNum(
          (arg.second ?? 0) +
              (arg.millisecond ?? 0) / 1000.0 +
              (arg.microsecond ?? 0) / 1000000.0,
        ),
      )
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
final fnTimezoneFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-dateTime'),
  (context, arg) =>
      _evalTimezone(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalTimezone(XPathAbstractDateTime? arg) =>
    arg != null && arg.timezoneOffsetMinutes != null
    ? XPathSequence.single(
        XPathDayTimeDuration(arg.timezoneOffsetMinutes! * 60 * 1000000),
      )
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
final fnYearFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:year-from-date'),
  (context, arg) =>
      _evalYear(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

XPathSequence _evalYear(XPathAbstractDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.year!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
final fnMonthFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:month-from-date'),
  (context, arg) =>
      _evalMonth(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
final fnDayFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:day-from-date'),
  (context, arg) =>
      _evalDay(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
final fnTimezoneFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-date'),
  (context, arg) =>
      _evalTimezone(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
final fnHoursFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:hours-from-time'),
  (context, arg) =>
      _evalHours(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
final fnMinutesFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:minutes-from-time'),
  (context, arg) =>
      _evalMinutes(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
final fnSecondsFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:seconds-from-time'),
  (context, arg) =>
      _evalSeconds(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
final fnTimezoneFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-time'),
  (context, arg) =>
      _evalTimezone(arg.atomize().firstOrNull as XPathAbstractDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
final fnAdjustDateTimeToTimezone = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
      (context, arg) => _evalAdjustDateTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
      (context, arg, tz) => _evalAdjustDateTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        tz.atomize().firstOrNull as XPathDayTimeDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustDateTimeToTimezone(
  XPathContext context,
  XPathAbstractDateTime? arg,
  XPathDayTimeDuration? timezone,
) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null ? XPathSequence.single(result) : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
final fnAdjustDateToTimezone = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:adjust-date-to-timezone'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:adjust-date-to-timezone'),
      (context, arg) => _evalAdjustDateToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-date-to-timezone'),
      (context, arg, tz) => _evalAdjustDateToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        tz.atomize().firstOrNull as XPathDayTimeDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustDateToTimezone(
  XPathContext context,
  XPathAbstractDateTime? arg,
  XPathDayTimeDuration? timezone,
) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(
          XPathDate(
            result.year!,
            result.month!,
            result.day!,
            result.timezoneOffsetMinutes,
          ),
        )
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
final fnAdjustTimeToTimezone = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:adjust-time-to-timezone'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:adjust-time-to-timezone'),
      (context, arg) => _evalAdjustTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-time-to-timezone'),
      (context, arg, tz) => _evalAdjustTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathAbstractDateTime?,
        tz.atomize().firstOrNull as XPathDayTimeDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustTimeToTimezone(
  XPathContext context,
  XPathAbstractDateTime? arg,
  XPathDayTimeDuration? timezone,
) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(
          XPathTime(
            result.hour!,
            result.minute!,
            result.second ?? 0,
            result.millisecond ?? 0,
            result.microsecond ?? 0,
            result.timezoneOffsetMinutes,
          ),
        )
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
final fnFormatDateTime = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-dateTime'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:format-dateTime'),
      (context, val, pic) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-dateTime'),
      (context, val, pic, lang) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-dateTime'),
      4,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-dateTime'),
      5,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
  },
);

XPathSequence _evalFormatDateTime(XPathAbstractDateTime? value) => value != null
    ? XPathSequence.single(XPathString(value.stringValue))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
final fnFormatDate = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-date'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:format-date'),
      (context, val, pic) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-date'),
      (context, val, pic, lang) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-date'),
      4,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-date'),
      5,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
final fnFormatTime = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-time'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:format-time'),
      (context, val, pic) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-time'),
      (context, val, pic, lang) => _evalFormatDateTime(
        val.atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-time'),
      4,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-time'),
      5,
      (context, args) => _evalFormatDateTime(
        args[0].atomize().firstOrNull as XPathAbstractDateTime?,
      ),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
final fnParseIetfDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:parse-ietf-date'),
  (context, value) => throw UnimplementedError('fn:parse-ietf-date'),
);

XPathDayTimeDuration _defaultToTimezone(XPathContext context) =>
    XPathDayTimeDuration(context.currentDateTime.timeZoneOffset.inMicroseconds);

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
    final utcInstant = arg.toDateTime(); // This is a UTC DateTime since originalOffsetMinutes != null
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
