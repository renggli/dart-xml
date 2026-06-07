abstract class XPathAbstractDateTime
    implements Comparable<XPathAbstractDateTime> {
  int? get year;
  int? get month;
  int? get day;
  int? get hour;
  int? get minute;
  int? get second;
  int? get millisecond;
  int? get microsecond;
  int? get timezoneOffsetMinutes;

  const XPathAbstractDateTime();

  DateTime toDateTime();

  XPathAbstractDateTime toUtc();
  XPathAbstractDateTime toLocal();

  bool get isUtc => timezoneOffsetMinutes != null;

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

  bool isBefore(XPathAbstractDateTime other) => compareTo(other) < 0;
  bool isAfter(XPathAbstractDateTime other) => compareTo(other) > 0;
  bool isAtSameMomentAs(XPathAbstractDateTime other) => compareTo(other) == 0;

  @override
  int compareTo(XPathAbstractDateTime other) =>
      utcInstant.compareTo(other.utcInstant);

  XPathAbstractDateTime add(Duration duration) =>
      _wrapDateTime(toDateTime().add(duration), this);

  XPathAbstractDateTime subtract(Duration duration) =>
      _wrapDateTime(toDateTime().subtract(duration), this);

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

class XPathDateTimeStamp extends XPathDateTime {
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

  const XPathDate(
    this.year,
    this.month,
    this.day, [
    this.timezoneOffsetMinutes,
  ]);

  factory XPathDate.fromDateTime(
    DateTime dateTime, [
    int? timezoneOffsetMinutes,
  ]) => XPathDate(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    timezoneOffsetMinutes,
  );

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

  const XPathTime(
    this.hour,
    this.minute,
    this.second, [
    this.millisecond = 0,
    this.microsecond = 0,
    this.timezoneOffsetMinutes,
  ]);

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

  const XPathYearMonth(this.year, this.month, [this.timezoneOffsetMinutes]);

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

  const XPathYear(this.year, [this.timezoneOffsetMinutes]);

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

  const XPathMonthDay(this.month, this.day, [this.timezoneOffsetMinutes]);

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

  const XPathMonth(this.month, [this.timezoneOffsetMinutes]);

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

  const XPathDay(this.day, [this.timezoneOffsetMinutes]);

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
