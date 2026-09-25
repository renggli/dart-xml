import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
final fnDateTime = XPathFunctionItem.fn2(
  const XmlName.qualified('fn:dateTime'),
  (context, arg1Seq, arg2Seq) {
    final arg1 = arg1Seq.atomize().firstOrNull as XPathDateTime?;
    final arg2 = arg2Seq.atomize().firstOrNull as XPathDateTime?;
    if (arg1 == null || arg2 == null) return XPathSequence.empty;
    final tz1 = arg1.timezoneOffsetMinutes;
    final tz2 = arg2.timezoneOffsetMinutes;
    if (tz1 != null && tz2 != null && tz1 != tz2) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0008,
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
  (context, arg) => _evalYear(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
final fnMonthFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:month-from-dateTime'),
  (context, arg) => _evalMonth(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalMonth(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.month!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
final fnDayFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:day-from-dateTime'),
  (context, arg) => _evalDay(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalDay(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.day!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
final fnHoursFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:hours-from-dateTime'),
  (context, arg) => _evalHours(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalHours(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.hour!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
final fnMinutesFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:minutes-from-dateTime'),
  (context, arg) => _evalMinutes(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalMinutes(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.minute!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
final fnSecondsFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:seconds-from-dateTime'),
  (context, arg) => _evalSeconds(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalSeconds(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(
        XPathDecimal.fromNum(
          (arg.second ?? 0) +
              arg.millisecond / 1000.0 +
              arg.microsecond / 1000000.0,
        ),
      )
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
final fnTimezoneFromDateTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-dateTime'),
  (context, arg) => _evalTimezone(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalTimezone(XPathDateTime? arg) =>
    arg != null && arg.timezoneOffsetMinutes != null
    ? XPathSequence.single(
        XPathDuration.dayTime(arg.timezoneOffsetMinutes! * 60 * 1000000),
      )
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
final fnYearFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:year-from-date'),
  (context, arg) => _evalYear(arg.atomize().firstOrNull as XPathDateTime?),
);

XPathSequence _evalYear(XPathDateTime? arg) => arg != null
    ? XPathSequence.single(XPathInteger.fromInt(arg.year!))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
final fnMonthFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:month-from-date'),
  (context, arg) => _evalMonth(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
final fnDayFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:day-from-date'),
  (context, arg) => _evalDay(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
final fnTimezoneFromDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-date'),
  (context, arg) => _evalTimezone(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
final fnHoursFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:hours-from-time'),
  (context, arg) => _evalHours(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
final fnMinutesFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:minutes-from-time'),
  (context, arg) => _evalMinutes(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
final fnSecondsFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:seconds-from-time'),
  (context, arg) => _evalSeconds(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
final fnTimezoneFromTime = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:timezone-from-time'),
  (context, arg) => _evalTimezone(arg.atomize().firstOrNull as XPathDateTime?),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
final fnAdjustDateTimeToTimezone = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
      (context, arg) => _evalAdjustDateTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-dateTime-to-timezone'),
      (context, arg, tz) => _evalAdjustDateTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathDateTime?,
        tz.atomize().firstOrNull as XPathDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustDateTimeToTimezone(
  XPathContext context,
  XPathDateTime? arg,
  XPathDuration? timezone,
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
        arg.atomize().firstOrNull as XPathDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-date-to-timezone'),
      (context, arg, tz) => _evalAdjustDateToTimezone(
        context,
        arg.atomize().firstOrNull as XPathDateTime?,
        tz.atomize().firstOrNull as XPathDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustDateToTimezone(
  XPathContext context,
  XPathDateTime? arg,
  XPathDuration? timezone,
) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(
          XPathDateTime.date(
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
        arg.atomize().firstOrNull as XPathDateTime?,
        _defaultToTimezone(context),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:adjust-time-to-timezone'),
      (context, arg, tz) => _evalAdjustTimeToTimezone(
        context,
        arg.atomize().firstOrNull as XPathDateTime?,
        tz.atomize().firstOrNull as XPathDuration?,
      ),
    ),
  },
);

XPathSequence _evalAdjustTimeToTimezone(
  XPathContext context,
  XPathDateTime? arg,
  XPathDuration? timezone,
) {
  final result = _adjustDateTimeHelper(arg, timezone);
  return result != null
      ? XPathSequence.single(
          XPathDateTime.time(
            result.hour!,
            result.minute!,
            result.second ?? 0,
            result.millisecond,
            result.microsecond,
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
      (context, val, pic) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-dateTime'),
      (context, val, pic, lang) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-dateTime'),
      4,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-dateTime'),
      5,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
  },
);

XPathSequence _evalFormatDateTime(XPathDateTime? value) => value != null
    ? XPathSequence.single(XPathString(value.stringValue))
    : XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
final fnFormatDate = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-date'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:format-date'),
      (context, val, pic) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-date'),
      (context, val, pic, lang) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-date'),
      4,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-date'),
      5,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
final fnFormatTime = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-time'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:format-time'),
      (context, val, pic) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:format-time'),
      (context, val, pic, lang) =>
          _evalFormatDateTime(val.atomize().firstOrNull as XPathDateTime?),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-time'),
      4,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
    5: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:format-time'),
      5,
      (context, args) =>
          _evalFormatDateTime(args[0].atomize().firstOrNull as XPathDateTime?),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
final fnParseIetfDate = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:parse-ietf-date'),
  (context, valueSeq) {
    final atom = valueSeq.atomize().firstOrNull;
    if (atom == null) return XPathSequence.empty;
    final value = atom.stringValue.trim();
    if (value.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Invalid IETF date format: empty string',
      );
    }

    final match = _ietfDateRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Invalid IETF date format: $value',
      );
    }

    final dayStr = match.namedGroup('day') ?? match.namedGroup('day2');
    final monStr = match.namedGroup('mon') ?? match.namedGroup('mon2');
    final yrStr = match.namedGroup('year') ?? match.namedGroup('year2');

    final day = int.tryParse(dayStr ?? '');
    final month = _monthNames[monStr?.toLowerCase()];
    var year = int.tryParse(yrStr ?? '');

    if (day == null || month == null || year == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Invalid date components in IETF date: $value',
      );
    }

    if (year < 100) {
      year += 1900;
    }

    final hr = int.tryParse(match.namedGroup('hour') ?? '');
    final mn = int.tryParse(match.namedGroup('min') ?? '');
    final secStr = match.namedGroup('sec');
    final sec = secStr != null ? int.tryParse(secStr) : 0;
    final fracStr = match.namedGroup('frac');

    if (hr == null || mn == null || sec == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Invalid time components in IETF date: $value',
      );
    }

    var ms = 0;
    var us = 0;
    if (fracStr != null && fracStr.isNotEmpty) {
      final padded = fracStr.padRight(6, '0').substring(0, 6);
      final totalMicros = int.tryParse(padded) ?? 0;
      ms = totalMicros ~/ 1000;
      us = totalMicros % 1000;
    }

    final tzSign = match.namedGroup('tzsign');
    final tzHour = match.namedGroup('tzhour');
    final tzMin = match.namedGroup('tzmin');
    final tzName = match.namedGroup('tzname');
    final tzComment = match.namedGroup('tzcomment');

    var offsetMinutes = 0;
    if (tzSign != null && tzHour != null) {
      final th = int.tryParse(tzHour) ?? 0;
      final tm = tzMin != null && tzMin.isNotEmpty
          ? (int.tryParse(tzMin) ?? 0)
          : 0;
      if (th > 14 || (th == 14 && tm != 0) || tm > 59) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0010,
          'Invalid timezone offset in IETF date: $value',
        );
      }
      if (tzComment != null) {
        final commentTz = tzComment.trim().toUpperCase();
        if (commentTz.isNotEmpty && !_namedTzOffsets.containsKey(commentTz)) {
          throw XPathEvaluationException(
            XPathErrorCode.FORG0010,
            'Unknown timezone name in comment: $tzComment',
          );
        }
      }
      offsetMinutes = (tzSign == '-' ? -1 : 1) * (th * 60 + tm);
    } else if (tzName != null) {
      final off = _namedTzOffsets[tzName.toUpperCase()];
      if (off == null) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0010,
          'Unknown timezone name in IETF date: $tzName',
        );
      }
      offsetMinutes = off;
    }

    // Validate date/time
    final isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
    final daysInMonth = switch (month) {
      1 || 3 || 5 || 7 || 8 || 10 || 12 => 31,
      4 || 6 || 9 || 11 => 30,
      2 => isLeapYear ? 29 : 28,
      _ => 0,
    };
    if (day < 1 || day > daysInMonth) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Day out of range in IETF date: $day',
      );
    }

    if (hr == 24 && mn == 0 && sec == 0 && ms == 0 && us == 0) {
      final dt = DateTime.utc(year, month, day).add(const Duration(days: 1));
      return XPathSequence.single(
        XPathDateTime(
          dt.year,
          dt.month,
          dt.day,
          0,
          0,
          0,
          0,
          0,
          offsetMinutes,
          xsDateTimeStamp,
        ),
      );
    }

    if (hr > 23 || mn > 59 || sec > 59) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0010,
        'Time out of range in IETF date: $hr:$mn:$sec',
      );
    }

    final result = XPathDateTime(
      year,
      month,
      day,
      hr,
      mn,
      sec,
      ms,
      us,
      offsetMinutes,
      xsDateTimeStamp,
    );
    final utc = result.toUtc();
    return XPathSequence.single(
      XPathDateTime(
        utc.year,
        utc.month,
        utc.day,
        utc.hour,
        utc.minute,
        utc.second,
        utc.millisecond,
        utc.microsecond,
        0,
        xsDateTimeStamp,
      ),
    );
  },
);

const _monthNames = <String, int>{
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

const _namedTzOffsets = <String, int>{
  'UTC': 0,
  'UT': 0,
  'GMT': 0,
  'Z': 0,
  'EST': -300,
  'EDT': -240,
  'CST': -360,
  'CDT': -300,
  'MST': -420,
  'MDT': -360,
  'PST': -480,
  'PDT': -420,
};

final _ietfDateRegExp = RegExp(
  r'^(?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)(?:,\s+|\s+))?'
  r'(?:'
  // RFC 2822: day mon year
  r'(?<day>\d{1,2})(?:\s*-\s*|\s+)(?<mon>[A-Za-z]{3})(?:\s*-\s*|\s+)(?<year>\d{2}|\d{4})'
  r'|'
  // asctime / RFC 850 variant: mon day
  r'(?<mon2>[A-Za-z]{3})(?:\s*-\s*|\s+)(?<day2>\d{1,2})'
  r')'
  r'\s+(?<hour>\d{1,2}):(?<min>\d{2})(?::(?<sec>\d{2})(?:\.(?<frac>\d+))?)?'
  r'(?:'
  // Timezone if before year (asctime)
  r'(?:'
  r'(?:\s*|\s+)(?:(?<tzsign>[+-])(?<tzhour>\d{1,2}):?(?<tzmin>\d{2})?|(?<tzname>[A-Za-z]{1,4}))'
  r'(?:\s*\(\s*(?<tzcomment>[A-Za-z]+)\s*\))?'
  r')?'
  r'(?:\s+(?<year2>\d{2}|\d{4}))'
  r'|'
  // Timezone at end
  r'(?:'
  r'(?:\s*|\s+)(?:(?<tzsign>[+-])(?<tzhour>\d{1,2}):?(?<tzmin>\d{2})?|(?<tzname>[A-Za-z]{1,4}))'
  r'(?:\s*\(\s*(?<tzcomment>[A-Za-z]+)\s*\))?'
  r')?'
  r')'
  r'$',
  caseSensitive: false,
);

XPathDuration _defaultToTimezone(XPathContext context) => XPathDuration.dayTime(
  context.currentDateTime.timeZoneOffset.inMicroseconds,
);

XPathDateTime? _adjustDateTimeHelper(
  XPathDateTime? arg,
  XPathDuration? timezone,
) {
  if (arg == null) return null;
  if (timezone != null) {
    if (timezone.inMicroseconds.abs() > 14 * 3600 * 1000000) {
      throw XPathEvaluationException(
        XPathErrorCode.FODT0003,
        'Timezone offset out of range: $timezone',
      );
    }
    if (timezone.inMicroseconds % (60 * 1000000) != 0) {
      throw XPathEvaluationException(
        XPathErrorCode.FODT0003,
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
    ms = arg.millisecond;
    us = arg.microsecond;
  } else {
    final utcInstant = arg.toDateTime();
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

  var resType = arg.type;
  if (arg.type == xsDateTimeStamp && timezone == null) {
    resType = xsDateTime;
  }
  return XPathDateTime.fromParts(
    year: arg.year != null ? y : null,
    month: arg.month != null ? m : null,
    day: arg.day != null ? d : null,
    hour: arg.hour != null ? h : null,
    minute: arg.minute != null ? min : null,
    second: arg.second != null ? s : null,
    millisecond: ms,
    microsecond: us,
    timezoneOffsetMinutes: targetOffsetMinutes,
    type: resType,
  );
}
