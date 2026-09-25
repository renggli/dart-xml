import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

/// Representation of XPath date and time values (xs:dateTime, xs:dateTimeStamp,
/// xs:date, xs:time, xs:gYearMonth, xs:gYear, xs:gMonthDay, xs:gMonth, and xs:gDay).
final class XPathDateTime extends XPathAtomic {
  /// Creates a new [XPathDateTime] with the given components.
  const new(
    this.year, [
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.second,
    this.millisecond = 0,
    this.microsecond = 0,
    this.timezoneOffsetMinutes,
    this.type = xsDateTime,
  ]);

  /// Creates a new [XPathDateTime] with named components filtered for the target [type].
  factory fromParts({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int millisecond = 0,
    int microsecond = 0,
    int? timezoneOffsetMinutes,
    XPathType type = xsDateTime,
  }) {
    final hasYear =
        type != xsTime &&
        type != xsGMonthDay &&
        type != xsGMonth &&
        type != xsGDay;
    final hasMonth = type != xsTime && type != xsGYear && type != xsGDay;
    final hasDay =
        type != xsTime &&
        type != xsGYearMonth &&
        type != xsGYear &&
        type != xsGMonth;
    final hasTime = type.isSubtypeOf(xsDateTime) || type == xsTime;
    return XPathDateTime(
      hasYear ? year : null,
      hasMonth ? month : null,
      hasDay ? day : null,
      hasTime ? hour : null,
      hasTime ? minute : null,
      hasTime ? second : null,
      hasTime ? millisecond : 0,
      hasTime ? microsecond : 0,
      timezoneOffsetMinutes,
      type,
    );
  }

  /// Creates a new [XPathDateTime] representing an xs:date.
  const new date(
    int this.year,
    int this.month,
    int this.day, [
    this.timezoneOffsetMinutes,
  ]) : hour = null,
       minute = null,
       second = null,
       millisecond = 0,
       microsecond = 0,
       type = xsDate;

  /// Creates a new [XPathDateTime] representing an xs:time.
  const new time(
    int this.hour,
    int this.minute,
    int this.second, [
    this.millisecond = 0,
    this.microsecond = 0,
    this.timezoneOffsetMinutes,
  ]) : year = null,
       month = null,
       day = null,
       type = xsTime;

  /// Creates a new [XPathDateTime] representing an xs:gYearMonth.
  const new yearMonth(
    int this.year,
    int this.month, [
    this.timezoneOffsetMinutes,
  ]) : day = null,
       hour = null,
       minute = null,
       second = null,
       millisecond = 0,
       microsecond = 0,
       type = xsGYearMonth;

  /// Creates a new [XPathDateTime] representing an xs:gYear.
  const new year(int this.year, [this.timezoneOffsetMinutes])
    : month = null,
      day = null,
      hour = null,
      minute = null,
      second = null,
      millisecond = 0,
      microsecond = 0,
      type = xsGYear;

  /// Creates a new [XPathDateTime] representing an xs:gMonthDay.
  const new monthDay(int this.month, int this.day, [this.timezoneOffsetMinutes])
    : year = null,
      hour = null,
      minute = null,
      second = null,
      millisecond = 0,
      microsecond = 0,
      type = xsGMonthDay;

  /// Creates a new [XPathDateTime] representing an xs:gMonth.
  const new month(int this.month, [this.timezoneOffsetMinutes])
    : year = null,
      day = null,
      hour = null,
      minute = null,
      second = null,
      millisecond = 0,
      microsecond = 0,
      type = xsGMonth;

  /// Creates a new [XPathDateTime] representing an xs:gDay.
  const new day(int this.day, [this.timezoneOffsetMinutes])
    : year = null,
      month = null,
      hour = null,
      minute = null,
      second = null,
      millisecond = 0,
      microsecond = 0,
      type = xsGDay;

  /// Creates a new [XPathDateTime] from a Dart [DateTime] object.
  factory fromDateTime(
    DateTime dateTime, [
    int? timezoneOffsetMinutes,
    XPathType type = xsDateTime,
  ]) {
    if (type == xsDate) {
      return XPathDateTime.date(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        timezoneOffsetMinutes,
      );
    }
    if (type == xsTime) {
      return XPathDateTime.time(
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.millisecond,
        dateTime.microsecond,
        timezoneOffsetMinutes,
      );
    }
    return XPathDateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
      timezoneOffsetMinutes,
      type,
    );
  }

  /// The year component, if present.
  final int? year;

  /// The month component, if present.
  final int? month;

  /// The day component, if present.
  final int? day;

  /// The hour component, if present.
  final int? hour;

  /// The minute component, if present.
  final int? minute;

  /// The second component, if present.
  final int? second;

  /// The millisecond component.
  final int millisecond;

  /// The microsecond component.
  final int microsecond;

  /// The timezone offset in minutes, if present.
  final int? timezoneOffsetMinutes;

  @override
  final XPathType type;

  @override
  Object get value => this;

  @override
  DateTime toValue() => toDateTime();

  @override
  String get stringValue => toString();

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    XPathErrorCode.FORG0006,
    'EBV not defined for temporal values: $this',
  );

  /// Whether this date-time has a timezone offset.
  bool get isUtc => timezoneOffsetMinutes != null;

  /// Converts this object to a standard Dart [DateTime] representation.
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        year ?? 1970,
        month ?? 1,
        day ?? 1,
        hour ?? 0,
        minute ?? 0,
        second ?? 0,
        millisecond,
        microsecond,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(
      year ?? 1970,
      month ?? 1,
      day ?? 1,
      hour ?? 0,
      minute ?? 0,
      second ?? 0,
      millisecond,
      microsecond,
    );
  }

  /// Returns the UTC instant for comparison.
  DateTime get utcInstant {
    final offset = timezoneOffsetMinutes != null
        ? Duration(minutes: timezoneOffsetMinutes!)
        : DateTime.now().timeZoneOffset;
    final dt = DateTime.utc(
      year ?? 1970,
      month ?? 1,
      day ?? 1,
      hour ?? 0,
      minute ?? 0,
      second ?? 0,
      millisecond,
      microsecond,
    );
    return dt.subtract(offset);
  }

  /// Converts this date-time representation to UTC.
  XPathDateTime toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = toDateTime();
    return XPathDateTime.fromParts(
      year: year != null ? dt.year : null,
      month: month != null ? dt.month : null,
      day: day != null ? dt.day : null,
      hour: hour != null ? dt.hour : null,
      minute: minute != null ? dt.minute : null,
      second: second != null ? dt.second : null,
      millisecond: millisecond,
      microsecond: microsecond,
      timezoneOffsetMinutes: 0,
      type: type,
    );
  }

  /// Converts this date-time representation to local time.
  XPathDateTime toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(
      year ?? 1970,
      month ?? 1,
      day ?? 1,
      hour ?? 0,
      minute ?? 0,
      second ?? 0,
      millisecond,
      microsecond,
    );
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathDateTime.fromParts(
      year: year != null ? localDt.year : null,
      month: month != null ? localDt.month : null,
      day: day != null ? localDt.day : null,
      hour: hour != null ? localDt.hour : null,
      minute: minute != null ? localDt.minute : null,
      second: second != null ? localDt.second : null,
      millisecond: millisecond,
      microsecond: microsecond,
      timezoneOffsetMinutes: localOffsetMinutes,
      type: type,
    );
  }

  /// Checks if this instant is before [other].
  bool isBefore(XPathDateTime other) => compareTo(other) < 0;

  /// Checks if this instant is after [other].
  bool isAfter(XPathDateTime other) => compareTo(other) > 0;

  /// Checks if this instant is at the same moment as [other].
  bool isAtSameMomentAs(XPathDateTime other) => compareTo(other) == 0;

  /// Adds a [duration] to this date-time.
  XPathDateTime add(Duration duration) =>
      _wrapDateTime(toDateTime().add(duration), this);

  /// Subtracts a [duration] from this date-time.
  XPathDateTime subtract(Duration duration) =>
      _wrapDateTime(toDateTime().subtract(duration), this);

  /// Calculates the difference between this and [other] date-time.
  Duration difference(XPathDateTime other) =>
      toDateTime().difference(other.toDateTime());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XPathDateTime) return false;
    if (type != other.type &&
        !(type.isSubtypeOf(xsDateTime) && other.type.isSubtypeOf(xsDateTime))) {
      return false;
    }
    try {
      return compareTo(other) == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  int get hashCode {
    try {
      final dt = toDateTime().toUtc();
      return Object.hash(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
        dt.millisecond,
        dt.microsecond,
        timezoneOffsetMinutes,
      );
    } catch (_) {
      return Object.hash(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
        timezoneOffsetMinutes,
      );
    }
  }

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathDateTime) {
      if (type == other.type ||
          (type.isSubtypeOf(xsDateTime) &&
              other.type.isSubtypeOf(xsDateTime))) {
        return utcInstant.compareTo(other.utcInstant);
      }
    }
    return super.compareTo(other);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (type == xsDate) {
      _writeYear(buffer, year ?? 1970);
      buffer.write('-');
      buffer.write((month ?? 1).toString().padLeft(2, '0'));
      buffer.write('-');
      buffer.write((day ?? 1).toString().padLeft(2, '0'));
    } else if (type == xsTime) {
      _writeTime(buffer);
    } else if (type == xsGYearMonth) {
      _writeYear(buffer, year ?? 1970);
      buffer.write('-');
      buffer.write((month ?? 1).toString().padLeft(2, '0'));
    } else if (type == xsGYear) {
      _writeYear(buffer, year ?? 1970);
    } else if (type == xsGMonthDay) {
      buffer.write('--');
      buffer.write((month ?? 1).toString().padLeft(2, '0'));
      buffer.write('-');
      buffer.write((day ?? 1).toString().padLeft(2, '0'));
    } else if (type == xsGMonth) {
      buffer.write('--');
      buffer.write((month ?? 1).toString().padLeft(2, '0'));
    } else if (type == xsGDay) {
      buffer.write('---');
      buffer.write((day ?? 1).toString().padLeft(2, '0'));
    } else {
      // xsDateTime, xsDateTimeStamp
      _writeYear(buffer, year ?? 1970);
      buffer.write('-');
      buffer.write((month ?? 1).toString().padLeft(2, '0'));
      buffer.write('-');
      buffer.write((day ?? 1).toString().padLeft(2, '0'));
      buffer.write('T');
      _writeTime(buffer);
    }
    buffer.write(_formatTimezone());
    return buffer.toString();
  }

  void _writeTime(StringBuffer buffer) {
    buffer.write((hour ?? 0).toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write((minute ?? 0).toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write((second ?? 0).toString().padLeft(2, '0'));
    if (millisecond > 0 || microsecond > 0) {
      final totalUs = millisecond * 1000 + microsecond;
      final usStr = totalUs
          .toString()
          .padLeft(6, '0')
          .replaceAll(RegExp(r'0+$'), '');
      buffer.write('.$usStr');
    }
  }

  String _formatTimezone() {
    final offset = timezoneOffsetMinutes;
    if (offset == null) return '';
    if (offset == 0) return 'Z';
    final sign = offset < 0 ? '-' : '+';
    final absOffset = offset.abs();
    final hours = absOffset ~/ 60;
    final minutes = absOffset % 60;
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _writeYear(StringBuffer buffer, int yr) {
    if (yr < 0) {
      buffer.write('-');
      buffer.write((-yr).toString().padLeft(4, '0'));
    } else {
      buffer.write(yr.toString().padLeft(4, '0'));
    }
  }

  /// Attempts to parse a string representation of a date/time.
  static XPathDateTime? tryParse(String value, [XPathType type = xsDateTime]) {
    if (type == xsDate) return tryParseDate(value);
    if (type == xsTime) return tryParseTime(value);
    if (type == xsGYearMonth) return tryParseYearMonth(value);
    if (type == xsGYear) return tryParseYear(value);
    if (type == xsGMonthDay) return tryParseMonthDay(value);
    if (type == xsGMonth) return tryParseMonth(value);
    if (type == xsGDay) return tryParseDay(value);

    final match = _dateTimeRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;
    if (type == xsDateTimeStamp && offset == null) return null;

    final yr = int.tryParse(match.namedGroup('year') ?? '');
    if (yr == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null) return null;

    final hr = int.tryParse(match.namedGroup('hour') ?? '');
    if (hr == null) return null;

    final mn = int.tryParse(match.namedGroup('minute') ?? '');
    if (mn == null) return null;

    final scDouble = double.tryParse(match.namedGroup('second') ?? '');
    if (scDouble == null) return null;

    final sc = scDouble.truncate();
    final frac = scDouble - sc;
    final ms = (frac * 1000).truncate();
    final us = ((frac * 1000000) - (ms * 1000)).round();

    if (!_validateDateTime(yr, mo, dy, hr, mn, scDouble)) return null;

    if (hr == 24) {
      final normalizedDate = DateTime.utc(
        yr,
        mo,
        dy,
      ).add(const Duration(days: 1));
      return XPathDateTime(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        0,
        0,
        0,
        0,
        0,
        offset,
        type,
      );
    }

    return XPathDateTime(yr, mo, dy, hr, mn, sc, ms, us, offset, type);
  }

  /// Attempts to parse a string representation of an xs:dateTimeStamp.
  static XPathDateTime? tryParseDateTimeStamp(String value) =>
      tryParse(value, xsDateTimeStamp);

  /// Attempts to parse a string representation of a date.
  static XPathDateTime? tryParseDate(String value) {
    final match = _dateRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final yr = int.tryParse(match.namedGroup('year') ?? '');
    if (yr == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null) return null;

    if (!_validateDateTime(yr, mo, dy, 0, 0, 0.0)) return null;

    return XPathDateTime.date(yr, mo, dy, offset);
  }

  /// Attempts to parse a string representation of a time.
  static XPathDateTime? tryParseTime(String value) {
    final match = _timeRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final hr = int.tryParse(match.namedGroup('hour') ?? '');
    if (hr == null) return null;

    final mn = int.tryParse(match.namedGroup('minute') ?? '');
    if (mn == null) return null;

    final scDouble = double.tryParse(match.namedGroup('second') ?? '');
    if (scDouble == null) return null;

    final sc = scDouble.truncate();
    final frac = scDouble - sc;
    final ms = (frac * 1000).truncate();
    final us = ((frac * 1000000) - (ms * 1000)).round();

    if (!_validateDateTime(1970, 1, 1, hr, mn, scDouble)) return null;

    if (hr == 24) {
      return const XPathDateTime.time(0, 0, 0, 0, 0, null);
    }

    return XPathDateTime.time(hr, mn, sc, ms, us, offset);
  }

  /// Attempts to parse a string representation of a gYearMonth.
  static XPathDateTime? tryParseYearMonth(String value) {
    final match = _yearMonthRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final yr = int.tryParse(match.namedGroup('year') ?? '');
    if (yr == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    if (!_validateDateTime(yr, mo, 1, 0, 0, 0.0)) return null;

    return XPathDateTime.yearMonth(yr, mo, offset);
  }

  /// Attempts to parse a string representation of a gYear.
  static XPathDateTime? tryParseYear(String value) {
    final match = _yearRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final yr = int.tryParse(match.namedGroup('year') ?? '');
    if (yr == null) return null;

    if (!_validateDateTime(yr, 1, 1, 0, 0, 0.0)) return null;

    return XPathDateTime.year(yr, offset);
  }

  /// Attempts to parse a string representation of a gMonthDay.
  static XPathDateTime? tryParseMonthDay(String value) {
    final match = _monthDayRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null) return null;

    if (!_validateDateTime(1972, mo, dy, 0, 0, 0.0)) return null;

    return XPathDateTime.monthDay(mo, dy, offset);
  }

  /// Attempts to parse a string representation of a gMonth.
  static XPathDateTime? tryParseMonth(String value) {
    final match = _monthRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null || mo < 1 || mo > 12) return null;

    return XPathDateTime.month(mo, offset);
  }

  /// Attempts to parse a string representation of a gDay.
  static XPathDateTime? tryParseDay(String value) {
    final match = _dayRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null || dy < 1 || dy > 31) return null;

    return XPathDateTime.day(dy, offset);
  }
}

XPathDateTime _wrapDateTime(DateTime result, XPathDateTime original) {
  final offset = original.timezoneOffsetMinutes;
  return XPathDateTime.fromParts(
    year: original.year != null ? result.year : null,
    month: original.month != null ? result.month : null,
    day: original.day != null ? result.day : null,
    hour: original.hour != null ? result.hour : null,
    minute: original.minute != null ? result.minute : null,
    second: original.second != null ? result.second : null,
    millisecond: result.millisecond,
    microsecond: result.microsecond,
    timezoneOffsetMinutes: offset,
    type: original.type,
  );
}

// Regexes and Parsing Helpers

const _timezoneRegExpPart = r'(?<timezone>Z|[+-]\d{2}:\d{2})?';

final _dateTimeRegExp = RegExp(
  '^'
  r'(?<year>-?\d{4,})-(?<month>\d{2})-(?<day>\d{2})'
  'T'
  r'(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)'
  '$_timezoneRegExpPart'
  r'$',
);

final _dateRegExp = RegExp(
  '^'
  r'(?<year>-?\d{4,})-(?<month>\d{2})-(?<day>\d{2})'
  '$_timezoneRegExpPart'
  r'$',
);

final _timeRegExp = RegExp(
  '^'
  r'(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)'
  '$_timezoneRegExpPart'
  r'$',
);

final _yearMonthRegExp = RegExp(
  '^'
  r'(?<year>-?\d{4,})-(?<month>\d{2})'
  '$_timezoneRegExpPart'
  r'$',
);

final _yearRegExp = RegExp(
  '^'
  r'(?<year>-?\d{4,})'
  '$_timezoneRegExpPart'
  r'$',
);

final _monthDayRegExp = RegExp(
  '^'
  r'--(?<month>\d{2})-(?<day>\d{2})'
  '$_timezoneRegExpPart'
  r'$',
);

final _monthRegExp = RegExp(
  '^'
  r'--(?<month>\d{2})'
  '$_timezoneRegExpPart'
  r'$',
);

final _dayRegExp = RegExp(
  '^'
  r'---(?<day>\d{2})'
  '$_timezoneRegExpPart'
  r'$',
);

int? _parseTimezoneOffsetMinutes(String? timezone) {
  if (timezone == null) return null;
  if (timezone == 'Z') return 0;
  final sign = timezone.substring(0, 1) == '-' ? -1 : 1;
  final parts = timezone.substring(1).split(':');
  if (parts.length != 2) return null;
  final hours = int.tryParse(parts[0]);
  if (hours == null || hours < 0 || hours > 14) return null;
  final minutes = int.tryParse(parts[1]);
  if (minutes == null || minutes < 0 || minutes > 59) return null;
  if (hours == 14 && minutes != 0) return null;
  return sign * (hours * 60 + minutes);
}

bool _validateDateTime(int y, int m, int d, int h, int min, double sec) {
  if (y < -271821 || y > 275759) return false;
  if (m < 1 || m > 12) return false;
  if (d < 1 || d > 31) return false;
  if (m == 4 || m == 6 || m == 9 || m == 11) {
    if (d > 30) return false;
  } else if (m == 2) {
    final isLeap = (y % 4 == 0) && (y % 100 != 0 || y % 400 == 0);
    if (d > (isLeap ? 29 : 28)) {
      return false;
    }
  }
  if (h > 24 || (h == 24 && (min > 0 || sec > 0))) {
    return false;
  }
  if (min > 59) return false;
  if (sec >= 60) return false;
  return true;
}
