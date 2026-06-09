/// An abstract representation of XPath date and time types.
abstract class XPathAbstractDateTime
    implements Comparable<XPathAbstractDateTime> {
  /// The year component, if present.
  int? get year;

  /// The month component, if present.
  int? get month;

  /// The day component, if present.
  int? get day;

  /// The hour component, if present.
  int? get hour;

  /// The minute component, if present.
  int? get minute;

  /// The second component, if present.
  int? get second;

  /// The millisecond component, if present.
  int? get millisecond;

  /// The microsecond component, if present.
  int? get microsecond;

  /// The timezone offset in minutes, if present.
  int? get timezoneOffsetMinutes;

  /// Constant constructor for subclasses.
  const XPathAbstractDateTime();

  /// Converts this object to a standard Dart [DateTime] representation.
  DateTime toDateTime();

  /// Converts this date-time representation to UTC.
  XPathAbstractDateTime toUtc();

  /// Converts this date-time representation to local time.
  XPathAbstractDateTime toLocal();

  /// Whether this date-time has a timezone offset.
  bool get isUtc => timezoneOffsetMinutes != null;

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
      millisecond ?? 0,
      microsecond ?? 0,
    );
    return dt.subtract(offset);
  }

  @override
  bool operator ==(Object other) {
    if (other is! XPathAbstractDateTime) return false;
    try {
      return compareTo(other) == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  int get hashCode {
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
  }

  /// Checks if this instant is before [other].
  bool isBefore(XPathAbstractDateTime other) => compareTo(other) < 0;

  /// Checks if this instant is after [other].
  bool isAfter(XPathAbstractDateTime other) => compareTo(other) > 0;

  /// Checks if this instant is at the same moment as [other].
  bool isAtSameMomentAs(XPathAbstractDateTime other) => compareTo(other) == 0;

  @override
  int compareTo(XPathAbstractDateTime other) =>
      utcInstant.compareTo(other.utcInstant);

  /// Adds a [duration] to this date-time.
  XPathAbstractDateTime add(Duration duration) =>
      _wrapDateTime(toDateTime().add(duration), this);

  /// Subtracts a [duration] from this date-time.
  XPathAbstractDateTime subtract(Duration duration) =>
      _wrapDateTime(toDateTime().subtract(duration), this);

  /// Calculates the difference between this and [other] date-time.
  Duration difference(XPathAbstractDateTime other) =>
      toDateTime().difference(other.toDateTime());

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

  void _writeYear(StringBuffer buffer, int year) {
    if (year < 0) {
      buffer.write('-');
      buffer.write((-year).toString().padLeft(4, '0'));
    } else {
      buffer.write(year.toString().padLeft(4, '0'));
    }
  }
}

XPathAbstractDateTime _wrapDateTime(
  DateTime result,
  XPathAbstractDateTime original,
) {
  final offset = original.timezoneOffsetMinutes;
  return switch (original) {
    XPathDateTimeStamp() => XPathDateTimeStamp.fromDateTime(
      result,
      offset ?? 0,
    ),
    XPathDateTime() => XPathDateTime.fromDateTime(result, offset),
    XPathDate() => XPathDate.fromDateTime(result, offset),
    XPathTime() => XPathTime.fromDateTime(result, offset),
    XPathYearMonth() => XPathYearMonth(result.year, result.month, offset),
    XPathYear() => XPathYear(result.year, offset),
    XPathMonthDay() => XPathMonthDay(result.month, result.day, offset),
    XPathMonth() => XPathMonth(result.month, offset),
    XPathDay() => XPathDay(result.day, offset),
    _ => XPathDateTime.fromDateTime(result, offset),
  };
}

/// Representation of an XPath dateTime value (xs:dateTime).
class XPathDateTime extends XPathAbstractDateTime {
  @override
  final int year;

  @override
  final int month;

  @override
  final int day;

  @override
  final int hour;

  @override
  final int minute;

  @override
  final int second;

  @override
  final int millisecond;

  @override
  final int microsecond;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathDateTime] with the given components.
  const XPathDateTime(
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.second, [
    this.millisecond = 0,
    this.microsecond = 0,
    this.timezoneOffsetMinutes,
  ]);

  /// Creates a new [XPathDateTime] from a Dart [DateTime] object.
  factory XPathDateTime.fromDateTime(
    DateTime dateTime, [
    int? timezoneOffsetMinutes,
  ]) => XPathDateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
    timezoneOffsetMinutes,
  );

  /// Attempts to parse a string representation of a dateTime.
  static XPathDateTime? tryParse(String value) {
    final match = _dateTimeRegExp.firstMatch(value);
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
      );
    }

    return XPathDateTime(yr, mo, dy, hr, mn, sc, ms, us, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  @override
  XPathDateTime toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathDateTime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
      dt.microsecond,
      0,
    );
  }

  @override
  XPathDateTime toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathDateTime(
      localDt.year,
      localDt.month,
      localDt.day,
      localDt.hour,
      localDt.minute,
      localDt.second,
      localDt.millisecond,
      localDt.microsecond,
      localOffsetMinutes,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    _writeYear(buffer, year);
    buffer.write('-');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write('-');
    buffer.write(day.toString().padLeft(2, '0'));
    buffer.write('T');
    buffer.write(hour.toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write(minute.toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write(second.toString().padLeft(2, '0'));
    if (millisecond > 0 || microsecond > 0) {
      final totalUs = millisecond * 1000 + microsecond;
      final usStr = totalUs
          .toString()
          .padLeft(6, '0')
          .replaceAll(RegExp(r'0+$'), '');
      buffer.write('.$usStr');
    }
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath dateTimeStamp value (xs:dateTimeStamp).
class XPathDateTimeStamp extends XPathDateTime {
  /// Creates a new [XPathDateTimeStamp] with the given components.
  const XPathDateTimeStamp(
    super.year,
    super.month,
    super.day,
    super.hour,
    super.minute,
    super.second, [
    super.millisecond,
    super.microsecond,
    int super.timezoneOffsetMinutes = 0,
  ]);

  /// Creates a new [XPathDateTimeStamp] from a Dart [DateTime] object.
  factory XPathDateTimeStamp.fromDateTime(
    DateTime dateTime,
    int timezoneOffsetMinutes,
  ) => XPathDateTimeStamp(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
    timezoneOffsetMinutes,
  );

  /// Attempts to parse a string representation of a dateTimeStamp.
  static XPathDateTimeStamp? tryParse(String value) {
    final match = _dateTimeRegExp.firstMatch(value);
    if (match == null || match.namedGroup('timezone') == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (offset == null) return null;

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
      return XPathDateTimeStamp(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        0,
        0,
        0,
        0,
        0,
        offset,
      );
    }

    return XPathDateTimeStamp(yr, mo, dy, hr, mn, sc, ms, us, offset);
  }

  @override
  XPathDateTimeStamp toUtc() {
    if (timezoneOffsetMinutes == 0) return this;
    final dt = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathDateTimeStamp(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
      dt.microsecond,
      0,
    );
  }

  @override
  XPathDateTimeStamp toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
    final adjusted = utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!));
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathDateTimeStamp(
      localDt.year,
      localDt.month,
      localDt.day,
      localDt.hour,
      localDt.minute,
      localDt.second,
      localDt.millisecond,
      localDt.microsecond,
      localOffsetMinutes,
    );
  }
}

/// Representation of an XPath date value (xs:date).
class XPathDate extends XPathAbstractDateTime {
  @override
  final int year;

  @override
  final int month;

  @override
  final int day;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathDate] with the given components.
  const XPathDate(
    this.year,
    this.month,
    this.day, [
    this.timezoneOffsetMinutes,
  ]);

  /// Creates a new [XPathDate] from a Dart [DateTime] object.
  factory XPathDate.fromDateTime(
    DateTime dateTime, [
    int? timezoneOffsetMinutes,
  ]) => XPathDate(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    timezoneOffsetMinutes,
  );

  /// Attempts to parse a string representation of a date.
  static XPathDate? tryParse(String value) {
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

    return XPathDate(yr, mo, dy, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        year,
        month,
        day,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(year, month, day);
  }

  @override
  XPathDate toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      year,
      month,
      day,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathDate(dt.year, dt.month, dt.day, 0);
  }

  @override
  XPathDate toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(year, month, day);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathDate(
      localDt.year,
      localDt.month,
      localDt.day,
      localOffsetMinutes,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    _writeYear(buffer, year);
    buffer.write('-');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write('-');
    buffer.write(day.toString().padLeft(2, '0'));
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath time value (xs:time).
class XPathTime extends XPathAbstractDateTime {
  @override
  int? get year => null;

  @override
  int? get month => null;

  @override
  int? get day => null;

  @override
  final int hour;

  @override
  final int minute;

  @override
  final int second;

  @override
  final int millisecond;

  @override
  final int microsecond;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathTime] with the given components.
  const XPathTime(
    this.hour,
    this.minute,
    this.second, [
    this.millisecond = 0,
    this.microsecond = 0,
    this.timezoneOffsetMinutes,
  ]);

  /// Creates a new [XPathTime] from a Dart [DateTime] object.
  factory XPathTime.fromDateTime(
    DateTime dateTime, [
    int? timezoneOffsetMinutes,
  ]) => XPathTime(
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
    timezoneOffsetMinutes,
  );

  /// Attempts to parse a string representation of a time.
  static XPathTime? tryParse(String value) {
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
      return XPathTime(0, 0, 0, 0, 0, offset);
    }

    return XPathTime(hr, mn, sc, ms, us, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        1970,
        1,
        1,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(1970, 1, 1, hour, minute, second, millisecond, microsecond);
  }

  @override
  XPathTime toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      1970,
      1,
      1,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathTime(
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
      dt.microsecond,
      0,
    );
  }

  @override
  XPathTime toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(
      1970,
      1,
      1,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathTime(
      localDt.hour,
      localDt.minute,
      localDt.second,
      localDt.millisecond,
      localDt.microsecond,
      localOffsetMinutes,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(hour.toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write(minute.toString().padLeft(2, '0'));
    buffer.write(':');
    buffer.write(second.toString().padLeft(2, '0'));
    if (millisecond > 0 || microsecond > 0) {
      final totalUs = millisecond * 1000 + microsecond;
      final usStr = totalUs
          .toString()
          .padLeft(6, '0')
          .replaceAll(RegExp(r'0+$'), '');
      buffer.write('.$usStr');
    }
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath gYearMonth value (xs:gYearMonth).
class XPathYearMonth extends XPathAbstractDateTime {
  @override
  final int year;

  @override
  final int month;

  @override
  int? get day => null;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathYearMonth] with the given components.
  const XPathYearMonth(this.year, this.month, [this.timezoneOffsetMinutes]);

  /// Attempts to parse a string representation of a gYearMonth.
  static XPathYearMonth? tryParse(String value) {
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

    return XPathYearMonth(yr, mo, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        year,
        month,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(year, month);
  }

  @override
  XPathYearMonth toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      year,
      month,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathYearMonth(dt.year, dt.month, 0);
  }

  @override
  XPathYearMonth toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(year, month);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathYearMonth(localDt.year, localDt.month, localOffsetMinutes);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    _writeYear(buffer, year);
    buffer.write('-');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath gYear value (xs:gYear).
class XPathYear extends XPathAbstractDateTime {
  @override
  final int year;

  @override
  int? get month => null;

  @override
  int? get day => null;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathYear] with the given components.
  const XPathYear(this.year, [this.timezoneOffsetMinutes]);

  /// Attempts to parse a string representation of a gYear.
  static XPathYear? tryParse(String value) {
    final match = _yearRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final yr = int.tryParse(match.namedGroup('year') ?? '');
    if (yr == null) return null;

    return XPathYear(yr, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        year,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(year);
  }

  @override
  XPathYear toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      year,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathYear(dt.year, 0);
  }

  @override
  XPathYear toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(year);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathYear(localDt.year, localOffsetMinutes);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    _writeYear(buffer, year);
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath gMonthDay value (xs:gMonthDay).
class XPathMonthDay extends XPathAbstractDateTime {
  @override
  int? get year => null;

  @override
  final int month;

  @override
  final int day;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathMonthDay] with the given components.
  const XPathMonthDay(this.month, this.day, [this.timezoneOffsetMinutes]);

  /// Attempts to parse a string representation of a gMonthDay.
  static XPathMonthDay? tryParse(String value) {
    final match = _monthDayRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null) return null;

    if (!_validateDateTime(1970, mo, dy, 0, 0, 0.0)) return null;

    return XPathMonthDay(mo, dy, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        1970,
        month,
        day,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(1970, month, day);
  }

  @override
  XPathMonthDay toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      1970,
      month,
      day,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathMonthDay(dt.month, dt.day, 0);
  }

  @override
  XPathMonthDay toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(1970, month, day);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathMonthDay(localDt.month, localDt.day, localOffsetMinutes);
  }

  @override
  String toString() {
    final buffer = StringBuffer('--');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write('-');
    buffer.write(day.toString().padLeft(2, '0'));
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath gMonth value (xs:gMonth).
class XPathMonth extends XPathAbstractDateTime {
  @override
  int? get year => null;

  @override
  final int month;

  @override
  int? get day => null;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathMonth] with the given components.
  const XPathMonth(this.month, [this.timezoneOffsetMinutes]);

  /// Attempts to parse a string representation of a gMonth.
  static XPathMonth? tryParse(String value) {
    final match = _monthRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final mo = int.tryParse(match.namedGroup('month') ?? '');
    if (mo == null) return null;

    if (!_validateDateTime(1970, mo, 1, 0, 0, 0.0)) return null;

    return XPathMonth(mo, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        1970,
        month,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(1970, month);
  }

  @override
  XPathMonth toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      1970,
      month,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathMonth(dt.month, 0);
  }

  @override
  XPathMonth toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(1970, month);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathMonth(localDt.month, localOffsetMinutes);
  }

  @override
  String toString() {
    final buffer = StringBuffer('--');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
}

/// Representation of an XPath gDay value (xs:gDay).
class XPathDay extends XPathAbstractDateTime {
  @override
  int? get year => null;

  @override
  int? get month => null;

  @override
  final int day;

  @override
  int? get hour => null;

  @override
  int? get minute => null;

  @override
  int? get second => null;

  @override
  int? get millisecond => null;

  @override
  int? get microsecond => null;

  @override
  final int? timezoneOffsetMinutes;

  /// Creates a new [XPathDay] with the given components.
  const XPathDay(this.day, [this.timezoneOffsetMinutes]);

  /// Attempts to parse a string representation of a gDay.
  static XPathDay? tryParse(String value) {
    final match = _dayRegExp.firstMatch(value);
    if (match == null) return null;

    final tzStr = match.namedGroup('timezone');
    final offset = _parseTimezoneOffsetMinutes(tzStr);
    if (tzStr != null && offset == null) return null;

    final dy = int.tryParse(match.namedGroup('day') ?? '');
    if (dy == null) return null;

    if (!_validateDateTime(1970, 1, dy, 0, 0, 0.0)) return null;

    return XPathDay(dy, offset);
  }

  @override
  DateTime toDateTime() {
    if (timezoneOffsetMinutes != null) {
      return DateTime.utc(
        1970,
        1,
        day,
      ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    }
    return DateTime(1970, 1, day);
  }

  @override
  XPathDay toUtc() {
    if (timezoneOffsetMinutes == null || timezoneOffsetMinutes == 0) {
      return this;
    }
    final dt = DateTime.utc(
      1970,
      1,
      day,
    ).subtract(Duration(minutes: timezoneOffsetMinutes!));
    return XPathDay(dt.day, 0);
  }

  @override
  XPathDay toLocal() {
    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (timezoneOffsetMinutes == localOffsetMinutes) return this;
    final utcDt = DateTime.utc(1970, 1, day);
    final adjusted = timezoneOffsetMinutes != null
        ? utcDt.subtract(Duration(minutes: timezoneOffsetMinutes!))
        : utcDt;
    final localDt = adjusted.add(Duration(minutes: localOffsetMinutes));
    return XPathDay(localDt.day, localOffsetMinutes);
  }

  @override
  String toString() {
    final buffer = StringBuffer('---');
    buffer.write(day.toString().padLeft(2, '0'));
    buffer.write(_formatTimezone());
    return buffer.toString();
  }
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
