import '../../../xml.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

/// The XPath dateTime type.
const xsDateTime = _XPathDateTimeType();

class _XPathDateTimeType extends XPathType<DateTime> {
  const _XPathDateTimeType();

  @override
  String get name => 'xs:dateTime';

  @override
  bool matches(Object value) =>
      (value is DateTime && value is! _XPathDateTimeWrapper) ||
      value is XPathDateTimeStamp;

  @override
  DateTime cast(Object value) {
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      return _parseDateTime(value.trim());
    } else if (value is XmlNode) {
      return _parseDateTime(xsString.cast(value).trim());
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  DateTime _parseDateTime(String value) {
    final match = _dateTimeRegExp.firstMatch(value);
    if (match != null) {
      return _createDateTime(
        year: match.namedGroup('year')!,
        month: match.namedGroup('month')!,
        day: match.namedGroup('day')!,
        hour: match.namedGroup('hour')!,
        minute: match.namedGroup('minute')!,
        second: match.namedGroup('second')!,
        timezone: match.namedGroup('timezone'),
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
  bool matches(Object value) => value is XPathDateTimeStamp;

  @override
  XPathDateTimeStamp cast(Object value) {
    if (value is XPathDateTimeStamp) {
      return value;
    } else if (value is DateTime) {
      if (value.isUtc) return XPathDateTimeStamp(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _XPathDateTimeType._dateTimeRegExp.firstMatch(trimmed);
      if (match != null && match.namedGroup('timezone') != null) {
        return XPathDateTimeStamp(
          _createDateTime(
            year: match.namedGroup('year')!,
            month: match.namedGroup('month')!,
            day: match.namedGroup('day')!,
            hour: match.namedGroup('hour')!,
            minute: match.namedGroup('minute')!,
            second: match.namedGroup('second')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  @override
  String castToString(XPathDateTimeStamp value) => value.toIso8601String();
}

class XPathDateTimeStamp extends _XPathDateTimeWrapper {
  XPathDateTimeStamp(super.dateTime);
}

/// The XPath date type.
const xsDate = _XPathDateType();

class _XPathDateType extends XPathType<XPathDate> {
  const _XPathDateType();

  @override
  String get name => 'xs:date';

  @override
  bool matches(Object value) => value is XPathDate;

  @override
  XPathDate cast(Object value) {
    if (value is XPathDate) {
      return value;
    } else if (value is DateTime) {
      return XPathDate(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _dateRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathDate(
          _createDateTime(
            year: match.namedGroup('year')!,
            month: match.namedGroup('month')!,
            day: match.namedGroup('day')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathDate extends _XPathDateTimeWrapper {
  XPathDate(super.dateTime);
}

/// The XPath time type.
const xsTime = _XPathTimeType();

class _XPathTimeType extends XPathType<XPathTime> {
  const _XPathTimeType();

  @override
  String get name => 'xs:time';

  @override
  bool matches(Object value) => value is XPathTime;

  @override
  XPathTime cast(Object value) {
    if (value is XPathTime) {
      return value;
    } else if (value is DateTime) {
      return XPathTime(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _timeRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathTime(
          _createDateTime(
            hour: match.namedGroup('hour')!,
            minute: match.namedGroup('minute')!,
            second: match.namedGroup('second')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathTime extends _XPathDateTimeWrapper {
  XPathTime(super.dateTime);
}

/// The XPath gYearMonth type.
const xsGYearMonth = _XPathGYearMonthType();

class _XPathGYearMonthType extends XPathType<XPathGYearMonth> {
  const _XPathGYearMonthType();

  @override
  String get name => 'xs:gYearMonth';

  @override
  bool matches(Object value) => value is XPathGYearMonth;

  @override
  XPathGYearMonth cast(Object value) {
    if (value is XPathGYearMonth) {
      return value;
    } else if (value is DateTime) {
      return XPathGYearMonth(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _yearMonthRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathGYearMonth(
          _createDateTime(
            year: match.namedGroup('year')!,
            month: match.namedGroup('month')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathGYearMonth extends _XPathDateTimeWrapper {
  XPathGYearMonth(super.dateTime);
}

/// The XPath gYear type.
const xsGYear = _XPathGYearType();

class _XPathGYearType extends XPathType<XPathGYear> {
  const _XPathGYearType();

  @override
  String get name => 'xs:gYear';

  @override
  bool matches(Object value) => value is XPathGYear;

  @override
  XPathGYear cast(Object value) {
    if (value is XPathGYear) {
      return value;
    } else if (value is DateTime) {
      return XPathGYear(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _yearRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathGYear(
          _createDateTime(
            year: match.namedGroup('year')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathGYear extends _XPathDateTimeWrapper {
  XPathGYear(super.dateTime);
}

/// The XPath gMonthDay type.
const xsGMonthDay = _XPathGMonthDayType();

class _XPathGMonthDayType extends XPathType<XPathGMonthDay> {
  const _XPathGMonthDayType();

  @override
  String get name => 'xs:gMonthDay';

  @override
  bool matches(Object value) => value is XPathGMonthDay;

  @override
  XPathGMonthDay cast(Object value) {
    if (value is XPathGMonthDay) {
      return value;
    } else if (value is DateTime) {
      return XPathGMonthDay(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _monthDayRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathGMonthDay(
          _createDateTime(
            month: match.namedGroup('month')!,
            day: match.namedGroup('day')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathGMonthDay extends _XPathDateTimeWrapper {
  XPathGMonthDay(super.dateTime);
}

/// The XPath gMonth type.
const xsGMonth = _XPathGMonthType();

class _XPathGMonthType extends XPathType<XPathGMonth> {
  const _XPathGMonthType();

  @override
  String get name => 'xs:gMonth';

  @override
  bool matches(Object value) => value is XPathGMonth;

  @override
  XPathGMonth cast(Object value) {
    if (value is XPathGMonth) {
      return value;
    } else if (value is DateTime) {
      return XPathGMonth(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _monthRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathGMonth(
          _createDateTime(
            month: match.namedGroup('month')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathGMonth extends _XPathDateTimeWrapper {
  XPathGMonth(super.dateTime);
}

/// The XPath gDay type.
const xsGDay = _XPathGDayType();

class _XPathGDayType extends XPathType<XPathGDay> {
  const _XPathGDayType();

  @override
  String get name => 'xs:gDay';

  @override
  bool matches(Object value) => value is XPathGDay;

  @override
  XPathGDay cast(Object value) {
    if (value is XPathGDay) {
      return value;
    } else if (value is DateTime) {
      return XPathGDay(value);
    } else if (value is String) {
      final trimmed = value.trim();
      final match = _dayRegExp.firstMatch(trimmed);
      if (match != null) {
        return XPathGDay(
          _createDateTime(
            day: match.namedGroup('day')!,
            timezone: match.namedGroup('timezone'),
          ),
        );
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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

class XPathGDay extends _XPathDateTimeWrapper {
  XPathGDay(super.dateTime);
}

// Internal

abstract class _XPathDateTimeWrapper implements DateTime {
  final DateTime _dateTime;

  _XPathDateTimeWrapper(this._dateTime);

  @override
  bool isAfter(DateTime other) => _dateTime.isAfter(other);

  @override
  bool isBefore(DateTime other) => _dateTime.isBefore(other);

  @override
  bool isAtSameMomentAs(DateTime other) => _dateTime.isAtSameMomentAs(other);

  @override
  int compareTo(DateTime other) => _dateTime.compareTo(other);

  @override
  DateTime add(Duration duration) => _dateTime.add(duration);

  @override
  DateTime subtract(Duration duration) => _dateTime.subtract(duration);

  @override
  Duration difference(DateTime other) => _dateTime.difference(other);

  @override
  DateTime toUtc() => _dateTime.toUtc();

  @override
  DateTime toLocal() => _dateTime.toLocal();

  @override
  String toIso8601String() => _dateTime.toIso8601String();

  @override
  int get year => _dateTime.year;

  @override
  int get month => _dateTime.month;

  @override
  int get day => _dateTime.day;

  @override
  int get hour => _dateTime.hour;

  @override
  int get minute => _dateTime.minute;

  @override
  int get second => _dateTime.second;

  @override
  int get millisecond => _dateTime.millisecond;

  @override
  int get microsecond => _dateTime.microsecond;

  @override
  int get weekday => _dateTime.weekday;

  @override
  bool get isUtc => _dateTime.isUtc;

  @override
  String get timeZoneName => _dateTime.timeZoneName;

  @override
  Duration get timeZoneOffset => _dateTime.timeZoneOffset;

  @override
  int get millisecondsSinceEpoch => _dateTime.millisecondsSinceEpoch;

  @override
  int get microsecondsSinceEpoch => _dateTime.microsecondsSinceEpoch;

  @override
  int get hashCode => _dateTime.hashCode;

  @override
  bool operator ==(Object other) =>
      other is DateTime &&
      (other is _XPathDateTimeWrapper
          ? _dateTime == other._dateTime
          : _dateTime == other);

  @override
  String toString() => _dateTime.toString();
}

DateTime _createDateTime({
  String year = '1970',
  String month = '01',
  String day = '01',
  String hour = '00',
  String minute = '00',
  String second = '00',
  String? timezone,
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
  if (timezone != null) buffer.write(timezone);
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
  if (value.isUtc) {
    buffer.write('Z');
  }
}
