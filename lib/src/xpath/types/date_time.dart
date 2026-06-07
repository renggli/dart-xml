import '../../../xml.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/date_time.dart';
import '../values/sequence.dart';
import 'string.dart';

/// The XPath dateTime type.
const xsDateTime = _XPathDateTimeType();

class _XPathDateTimeType extends XPathType<XPathDateTime> {
  const _XPathDateTimeType();

  @override
  String get name => 'xs:dateTime';

  @override
  bool matches(Object value) =>
      value is XPathDateTime ||
      value is XPathDateTimeStamp ||
      value is DateTime;

  @override
  XPathDateTime cast(Object value) => switch (value) {
    XPathDateTime() => value,
    DateTime() => XPathDateTime.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathDate() => XPathDateTime(
      value.year,
      value.month,
      value.day,
      0,
      0,
      0,
      0,
      0,
      value.timezoneOffsetMinutes,
    ),
    XPathTime() => XPathDateTime(
      1970,
      1,
      1,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
      value.timezoneOffsetMinutes,
    ),
    XPathAbstractDateTime() => XPathDateTime(
      value.year ?? 1970,
      value.month ?? 1,
      value.day ?? 1,
      value.hour ?? 0,
      value.minute ?? 0,
      value.second ?? 0,
      value.millisecond ?? 0,
      value.microsecond ?? 0,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDateTime(value.trim()),
    XmlNode() => _parseDateTime(xsString.cast(value).trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDateTime _parseDateTime(String value) {
    final match = _dateTimeRegExp.firstMatch(value);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final yr = int.parse(match.namedGroup('year')!);
      final mo = int.parse(match.namedGroup('month')!);
      final dy = int.parse(match.namedGroup('day')!);
      final hr = int.parse(match.namedGroup('hour')!);
      final mn = int.parse(match.namedGroup('minute')!);
      final scDouble = double.parse(match.namedGroup('second')!);
      final sc = scDouble.truncate();
      final frac = scDouble - sc;
      final ms = (frac * 1000).truncate();
      final us = ((frac * 1000000) - (ms * 1000)).round();
      _validateDateTime(yr, mo, dy, hr, mn, scDouble);
      return XPathDateTime(yr, mo, dy, hr, mn, sc, ms, us, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  @override
  String castToString(XPathDateTime value) => value.toString();

  static const _timezoneRegExpPart = r'(?<timezone>Z|[+-]\d{2}:\d{2})?';
  static final _dateTimeRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})-(?<month>\d{2})-(?<day>\d{2})'
    'T'
    r'(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)'
    '$_timezoneRegExpPart'
    r'$',
  );
}

/// The XPath dateTimeStamp type.
const xsDateTimeStamp = _XPathDateTimeStampType();

class _XPathDateTimeStampType extends XPathType<XPathDateTimeStamp> {
  const _XPathDateTimeStampType();

  @override
  String get name => 'xs:dateTimeStamp';

  @override
  bool matches(Object value) =>
      value is XPathDateTimeStamp || (value is DateTime && value.isUtc);

  @override
  XPathDateTimeStamp cast(Object value) => switch (value) {
    XPathDateTimeStamp() => value,
    DateTime() when value.isUtc => XPathDateTimeStamp.fromDateTime(value, 0),
    DateTime() => XPathDateTimeStamp.fromDateTime(
      value,
      value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() when value.timezoneOffsetMinutes != null =>
      XPathDateTimeStamp(
        value.year ?? 1970,
        value.month ?? 1,
        value.day ?? 1,
        value.hour ?? 0,
        value.minute ?? 0,
        value.second ?? 0,
        value.millisecond ?? 0,
        value.microsecond ?? 0,
        value.timezoneOffsetMinutes!,
      ),
    String() => _parseDateTimeStamp(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDateTimeStamp _parseDateTimeStamp(String trimmed) {
    final match = _XPathDateTimeType._dateTimeRegExp.firstMatch(trimmed);
    if (match != null && match.namedGroup('timezone') != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr)!;
      final yr = int.parse(match.namedGroup('year')!);
      final mo = int.parse(match.namedGroup('month')!);
      final dy = int.parse(match.namedGroup('day')!);
      final hr = int.parse(match.namedGroup('hour')!);
      final mn = int.parse(match.namedGroup('minute')!);
      final scDouble = double.parse(match.namedGroup('second')!);
      final sc = scDouble.truncate();
      final frac = scDouble - sc;
      final ms = (frac * 1000).truncate();
      final us = ((frac * 1000000) - (ms * 1000)).round();
      _validateDateTime(yr, mo, dy, hr, mn, scDouble);
      return XPathDateTimeStamp(yr, mo, dy, hr, mn, sc, ms, us, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathDateTimeStamp value) => value.toString();
}

/// The XPath date type.
const xsDate = _XPathDateType();

class _XPathDateType extends XPathType<XPathDate> {
  const _XPathDateType();

  @override
  String get name => 'xs:date';

  @override
  bool matches(Object value) => value is XPathDate || value is DateTime;

  @override
  XPathDate cast(Object value) => switch (value) {
    XPathDate() => value,
    DateTime() => XPathDate.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathDate(
      value.year ?? 1970,
      value.month ?? 1,
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDate(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDate _parseDate(String trimmed) {
    final match = _dateRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final yr = int.parse(match.namedGroup('year')!);
      final mo = int.parse(match.namedGroup('month')!);
      final dy = int.parse(match.namedGroup('day')!);
      _validateDateTime(yr, mo, dy, 0, 0, 0.0);
      return XPathDate(yr, mo, dy, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathDate value) => value.toString();

  static final _dateRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})-(?<month>\d{2})-(?<day>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath time type.
const xsTime = _XPathTimeType();

class _XPathTimeType extends XPathType<XPathTime> {
  const _XPathTimeType();

  @override
  String get name => 'xs:time';

  @override
  bool matches(Object value) => value is XPathTime || value is DateTime;

  @override
  XPathTime cast(Object value) => switch (value) {
    XPathTime() => value,
    DateTime() => XPathTime.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathTime(
      value.hour ?? 0,
      value.minute ?? 0,
      value.second ?? 0,
      value.millisecond ?? 0,
      value.microsecond ?? 0,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseTime(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathTime _parseTime(String trimmed) {
    final match = _timeRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final hr = int.parse(match.namedGroup('hour')!);
      final mn = int.parse(match.namedGroup('minute')!);
      final scDouble = double.parse(match.namedGroup('second')!);
      final sc = scDouble.truncate();
      final frac = scDouble - sc;
      final ms = (frac * 1000).truncate();
      final us = ((frac * 1000000) - (ms * 1000)).round();
      _validateDateTime(1970, 1, 1, hr, mn, scDouble);
      return XPathTime(hr, mn, sc, ms, us, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathTime value) => value.toString();

  static final _timeRegExp = RegExp(
    '^'
    r'(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gYearMonth type.
const xsYearMonth = _XPathYearMonthType();

class _XPathYearMonthType extends XPathType<XPathYearMonth> {
  const _XPathYearMonthType();

  @override
  String get name => 'xs:gYearMonth';

  @override
  bool matches(Object value) => value is XPathYearMonth || value is DateTime;

  @override
  XPathYearMonth cast(Object value) => switch (value) {
    XPathYearMonth() => value,
    DateTime() => XPathYearMonth(
      value.year,
      value.month,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathYearMonth(
      value.year ?? 1970,
      value.month ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseYearMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathYearMonth _parseYearMonth(String trimmed) {
    final match = _yearMonthRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final yr = int.parse(match.namedGroup('year')!);
      final mo = int.parse(match.namedGroup('month')!);
      _validateDateTime(yr, mo, 1, 0, 0, 0.0);
      return XPathYearMonth(yr, mo, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathYearMonth value) => value.toString();

  static final _yearMonthRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})-(?<month>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gYear type.
const xsYear = _XPathYearType();

class _XPathYearType extends XPathType<XPathYear> {
  const _XPathYearType();

  @override
  String get name => 'xs:gYear';

  @override
  bool matches(Object value) => value is XPathYear || value is DateTime;

  @override
  XPathYear cast(Object value) => switch (value) {
    XPathYear() => value,
    DateTime() => XPathYear(
      value.year,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathYear(
      value.year ?? 1970,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseYear(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathYear _parseYear(String trimmed) {
    final match = _yearRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final yr = int.parse(match.namedGroup('year')!);
      return XPathYear(yr, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathYear value) => value.toString();

  static final _yearRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gMonthDay type.
const xsMonthDay = _XPathMonthDayType();

class _XPathMonthDayType extends XPathType<XPathMonthDay> {
  const _XPathMonthDayType();

  @override
  String get name => 'xs:gMonthDay';

  @override
  bool matches(Object value) => value is XPathMonthDay || value is DateTime;

  @override
  XPathMonthDay cast(Object value) => switch (value) {
    XPathMonthDay() => value,
    DateTime() => XPathMonthDay(
      value.month,
      value.day,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathMonthDay(
      value.month ?? 1,
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseMonthDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathMonthDay _parseMonthDay(String trimmed) {
    final match = _monthDayRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final mo = int.parse(match.namedGroup('month')!);
      final dy = int.parse(match.namedGroup('day')!);
      _validateDateTime(1970, mo, dy, 0, 0, 0.0);
      return XPathMonthDay(mo, dy, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathMonthDay value) => value.toString();

  static final _monthDayRegExp = RegExp(
    '^'
    r'--(?<month>\d{2})-(?<day>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gMonth type.
const xsMonth = _XPathMonthType();

class _XPathMonthType extends XPathType<XPathMonth> {
  const _XPathMonthType();

  @override
  String get name => 'xs:gMonth';

  @override
  bool matches(Object value) => value is XPathMonth || value is DateTime;

  @override
  XPathMonth cast(Object value) => switch (value) {
    XPathMonth() => value,
    DateTime() => XPathMonth(
      value.month,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathMonth(
      value.month ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathMonth _parseMonth(String trimmed) {
    final match = _monthRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final mo = int.parse(match.namedGroup('month')!);
      _validateDateTime(1970, mo, 1, 0, 0, 0.0);
      return XPathMonth(mo, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathMonth value) => value.toString();

  static final _monthRegExp = RegExp(
    '^'
    r'--(?<month>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gDay type.
const xsDay = _XPathDayType();

class _XPathDayType extends XPathType<XPathDay> {
  const _XPathDayType();

  @override
  String get name => 'xs:gDay';

  @override
  bool matches(Object value) => value is XPathDay || value is DateTime;

  @override
  XPathDay cast(Object value) => switch (value) {
    XPathDay() => value,
    DateTime() => XPathDay(
      value.day,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathDay(
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDay _parseDay(String trimmed) {
    final match = _dayRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffsetMinutes(tzStr);
      final dy = int.parse(match.namedGroup('day')!);
      _validateDateTime(1970, 1, dy, 0, 0, 0.0);
      return XPathDay(dy, offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathDay value) => value.toString();

  static final _dayRegExp = RegExp(
    '^'
    r'---(?<day>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

// Helpers

int? _parseTimezoneOffsetMinutes(String? timezone) {
  if (timezone == null) return null;
  if (timezone == 'Z') return 0;
  final sign = timezone.substring(0, 1) == '-' ? -1 : 1;
  final parts = timezone.substring(1).split(':');
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  return sign * (hours * 60 + minutes);
}

void _validateDateTime(int y, int m, int d, int h, int min, double sec) {
  if (m < 1 || m > 12) throw XPathEvaluationException('Invalid month: $m');
  if (d < 1 || d > 31) throw XPathEvaluationException('Invalid day: $d');
  if (m == 4 || m == 6 || m == 9 || m == 11) {
    if (d > 30) throw XPathEvaluationException('Invalid day: $d');
  } else if (m == 2) {
    final isLeap = (y % 4 == 0) && (y % 100 != 0 || y % 400 == 0);
    if (d > (isLeap ? 29 : 28)) {
      throw XPathEvaluationException('Invalid day: $d');
    }
  }
  if (h > 24 || (h == 24 && (min > 0 || sec > 0))) {
    throw XPathEvaluationException('Invalid hour: $h');
  }
  if (min > 59) throw XPathEvaluationException('Invalid minute: $min');
  if (sec >= 60) throw XPathEvaluationException('Invalid second: $sec');
}
