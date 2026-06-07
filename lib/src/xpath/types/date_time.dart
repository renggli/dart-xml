import '../../../xml.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/date_time.dart';
import '../values/sequence.dart';
import 'string.dart';

/// The XPath dateTime type.
const xsDateTime = _XPathDateTimeType();

class _XPathDateTimeType extends XPathType<DateTime> {
  const _XPathDateTimeType();

  @override
  String get name => 'xs:dateTime';

  @override
  bool matches(Object value) =>
      value is XPathDateTime ||
      value is XPathDateTimeStamp ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  DateTime cast(Object value) => switch (value) {
    DateTime() => value,
    String() => _parseDateTime(value.trim()),
    XmlNode() => _parseDateTime(xsString.cast(value).trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  DateTime _parseDateTime(String value) {
    final match = _dateTimeRegExp.firstMatch(value);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathDateTime(
        _createDateTime(
          year: match.namedGroup('year')!,
          month: match.namedGroup('month')!,
          day: match.namedGroup('day')!,
          hour: match.namedGroup('hour')!,
          minute: match.namedGroup('minute')!,
          second: match.namedGroup('second')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  @override
  String castToString(DateTime value) {
    final buffer = StringBuffer();
    _writeYear(buffer, value.year);
    buffer.write('-');
    _writePad2(buffer, value.month);
    buffer.write('-');
    _writePad2(buffer, value.day);
    buffer.write('T');
    _writePad2(buffer, value.hour);
    buffer.write(':');
    _writePad2(buffer, value.minute);
    buffer.write(':');
    _writeSeconds(buffer, value);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

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
      value is XPathDateTimeStamp ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathDateTimeStamp cast(Object value) => switch (value) {
    XPathDateTimeStamp() => value,
    DateTime() when value.isUtc => XPathDateTimeStamp(value, const Duration()),
    DateTime() => XPathDateTimeStamp(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseDateTimeStamp(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDateTimeStamp _parseDateTimeStamp(String trimmed) {
    final match = _XPathDateTimeType._dateTimeRegExp.firstMatch(trimmed);
    if (match != null && match.namedGroup('timezone') != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathDateTimeStamp(
        _createDateTime(
          year: match.namedGroup('year')!,
          month: match.namedGroup('month')!,
          day: match.namedGroup('day')!,
          hour: match.namedGroup('hour')!,
          minute: match.namedGroup('minute')!,
          second: match.namedGroup('second')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathDateTimeStamp value) => value.toIso8601String();
}

/// The XPath date type.
const xsDate = _XPathDateType();

class _XPathDateType extends XPathType<XPathDate> {
  const _XPathDateType();

  @override
  String get name => 'xs:date';

  @override
  bool matches(Object value) =>
      value is XPathDate ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathDate cast(Object value) => switch (value) {
    XPathDate() => value,
    DateTime() => XPathDate(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseDate(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDate _parseDate(String trimmed) {
    final match = _dateRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathDate(
        _createDateTime(
          year: match.namedGroup('year')!,
          month: match.namedGroup('month')!,
          day: match.namedGroup('day')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathDate value) {
    final buffer = StringBuffer();
    _writeYear(buffer, value.year);
    buffer.write('-');
    _writePad2(buffer, value.month);
    buffer.write('-');
    _writePad2(buffer, value.day);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

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
  bool matches(Object value) =>
      value is XPathTime ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathTime cast(Object value) => switch (value) {
    XPathTime() => value,
    DateTime() => XPathTime(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseTime(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathTime _parseTime(String trimmed) {
    final match = _timeRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathTime(
        _createDateTime(
          hour: match.namedGroup('hour')!,
          minute: match.namedGroup('minute')!,
          second: match.namedGroup('second')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathTime value) {
    final buffer = StringBuffer();
    _writePad2(buffer, value.hour);
    buffer.write(':');
    _writePad2(buffer, value.minute);
    buffer.write(':');
    _writeSeconds(buffer, value);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _timeRegExp = RegExp(
    '^'
    r'(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gYearMonth type.
const xsGYearMonth = _XPathGYearMonthType();

class _XPathGYearMonthType extends XPathType<XPathGYearMonth> {
  const _XPathGYearMonthType();

  @override
  String get name => 'xs:gYearMonth';

  @override
  bool matches(Object value) =>
      value is XPathGYearMonth ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathGYearMonth cast(Object value) => switch (value) {
    XPathGYearMonth() => value,
    DateTime() => XPathGYearMonth(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseGYearMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathGYearMonth _parseGYearMonth(String trimmed) {
    final match = _yearMonthRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathGYearMonth(
        _createDateTime(
          year: match.namedGroup('year')!,
          month: match.namedGroup('month')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathGYearMonth value) {
    final buffer = StringBuffer();
    _writeYear(buffer, value.year);
    buffer.write('-');
    _writePad2(buffer, value.month);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _yearMonthRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})-(?<month>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gYear type.
const xsGYear = _XPathGYearType();

class _XPathGYearType extends XPathType<XPathGYear> {
  const _XPathGYearType();

  @override
  String get name => 'xs:gYear';

  @override
  bool matches(Object value) =>
      value is XPathGYear ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathGYear cast(Object value) => switch (value) {
    XPathGYear() => value,
    DateTime() => XPathGYear(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseGYear(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathGYear _parseGYear(String trimmed) {
    final match = _yearRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathGYear(
        _createDateTime(year: match.namedGroup('year')!),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathGYear value) {
    final buffer = StringBuffer();
    _writeYear(buffer, value.year);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _yearRegExp = RegExp(
    '^'
    r'(?<year>-?\d{4,})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gMonthDay type.
const xsGMonthDay = _XPathGMonthDayType();

class _XPathGMonthDayType extends XPathType<XPathGMonthDay> {
  const _XPathGMonthDayType();

  @override
  String get name => 'xs:gMonthDay';

  @override
  bool matches(Object value) =>
      value is XPathGMonthDay ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathGMonthDay cast(Object value) => switch (value) {
    XPathGMonthDay() => value,
    DateTime() => XPathGMonthDay(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseGMonthDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathGMonthDay _parseGMonthDay(String trimmed) {
    final match = _monthDayRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathGMonthDay(
        _createDateTime(
          month: match.namedGroup('month')!,
          day: match.namedGroup('day')!,
        ),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathGMonthDay value) {
    final buffer = StringBuffer('--');
    _writePad2(buffer, value.month);
    buffer.write('-');
    _writePad2(buffer, value.day);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _monthDayRegExp = RegExp(
    '^'
    r'--(?<month>\d{2})-(?<day>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gMonth type.
const xsGMonth = _XPathGMonthType();

class _XPathGMonthType extends XPathType<XPathGMonth> {
  const _XPathGMonthType();

  @override
  String get name => 'xs:gMonth';

  @override
  bool matches(Object value) =>
      value is XPathGMonth ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathGMonth cast(Object value) => switch (value) {
    XPathGMonth() => value,
    DateTime() => XPathGMonth(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseGMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathGMonth _parseGMonth(String trimmed) {
    final match = _monthRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathGMonth(
        _createDateTime(month: match.namedGroup('month')!),
        offset,
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathGMonth value) {
    final buffer = StringBuffer('--');
    _writePad2(buffer, value.month);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _monthRegExp = RegExp(
    '^'
    r'--(?<month>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

/// The XPath gDay type.
const xsGDay = _XPathGDayType();

class _XPathGDayType extends XPathType<XPathGDay> {
  const _XPathGDayType();

  @override
  String get name => 'xs:gDay';

  @override
  bool matches(Object value) =>
      value is XPathGDay ||
      (value is DateTime && value is! XPathDateTimeWrapper);

  @override
  XPathGDay cast(Object value) => switch (value) {
    XPathGDay() => value,
    DateTime() => XPathGDay(
      value,
      value is XPathDateTimeWrapper ? value.timezoneOffset : null,
    ),
    String() => _parseGDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathGDay _parseGDay(String trimmed) {
    final match = _dayRegExp.firstMatch(trimmed);
    if (match != null) {
      final tzStr = match.namedGroup('timezone');
      final offset = _parseTimezoneOffset(tzStr);
      return XPathGDay(_createDateTime(day: match.namedGroup('day')!), offset);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(XPathGDay value) {
    final buffer = StringBuffer('---');
    _writePad2(buffer, value.day);
    _writeTimezone(buffer, value);
    return buffer.toString();
  }

  static final _dayRegExp = RegExp(
    '^'
    r'---(?<day>\d{2})'
    '${_XPathDateTimeType._timezoneRegExpPart}'
    r'$',
  );
}

// Internal helpers

Duration? _parseTimezoneOffset(String? timezone) {
  if (timezone == null) return null;
  if (timezone == 'Z') return const Duration();
  final sign = timezone.substring(0, 1) == '-' ? -1 : 1;
  final parts = timezone.substring(1).split(':');
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  return Duration(hours: sign * hours, minutes: sign * minutes);
}

DateTime _createDateTime({
  String year = '1970',
  String month = '01',
  String day = '01',
  String hour = '00',
  String minute = '00',
  String second = '00',
}) {
  final y = int.parse(year);
  final m = int.parse(month);
  final d = int.parse(day);
  final h = int.parse(hour);
  final min = int.parse(minute);
  final sec = double.parse(second);
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
  final buffer = StringBuffer();
  _writeYear(buffer, y);
  buffer.write('-');
  _writePad2(buffer, m);
  buffer.write('-');
  _writePad2(buffer, d);
  buffer.write('T');
  _writePad2(buffer, h);
  buffer.write(':');
  _writePad2(buffer, min);
  buffer.write(':');
  buffer.write(second);
  buffer.write('Z'); // Always parse as UTC to preserve local components
  final result = DateTime.tryParse(buffer.toString());
  if (result == null) {
    throw XPathEvaluationException('Invalid date/time: ${buffer.toString()}');
  }
  return result;
}

void _writeYear(StringBuffer buffer, int year) {
  if (year < 0) {
    buffer.write('-');
    buffer.write((-year).toString().padLeft(4, '0'));
  } else {
    buffer.write(year.toString().padLeft(4, '0'));
  }
}

void _writePad2(StringBuffer buffer, int value) =>
    buffer.write(value.toString().padLeft(2, '0'));

void _writeSeconds(StringBuffer buffer, DateTime value) {
  _writePad2(buffer, value.second);
  if (value.millisecond > 0 || value.microsecond > 0) {
    final seconds = value.millisecond / 1000.0 + value.microsecond / 1000000.0;
    final string = seconds.toString();
    buffer.write(string.substring(1)); // skip the leading 0
  }
}

void _writeTimezone(StringBuffer buffer, DateTime value) {
  if (value is XPathDateTimeWrapper) {
    final offset = value.timezoneOffset;
    if (offset != null) {
      if (offset.inMicroseconds == 0) {
        buffer.write('Z');
      } else {
        final sign = offset.isNegative ? '-' : '+';
        final absOffset = offset.abs();
        final hours = absOffset.inHours;
        final minutes = absOffset.inMinutes % 60;
        buffer.write(sign);
        buffer.write(hours.toString().padLeft(2, '0'));
        buffer.write(':');
        buffer.write(minutes.toString().padLeft(2, '0'));
      }
    }
  } else if (value.isUtc) {
    buffer.write('Z');
  }
}
