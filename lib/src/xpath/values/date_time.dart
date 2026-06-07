class XPathDateTime extends XPathDateTimeWrapper {
  XPathDateTime(super.dateTime, [super.timezoneOffset]);

  @override
  XPathDateTime toUtc() {
    if (timezoneOffset == null || timezoneOffset!.inMicroseconds == 0) {
      return this;
    }
    final utcDt = _dateTime.subtract(timezoneOffset!);
    return XPathDateTime(utcDt, const Duration());
  }

  @override
  XPathDateTime toLocal() {
    final localOffset = DateTime.now().timeZoneOffset;
    if (timezoneOffset == localOffset) return this;
    final utcDt = timezoneOffset != null
        ? _dateTime.subtract(timezoneOffset!)
        : _dateTime;
    final localDt = utcDt.add(localOffset);
    return XPathDateTime(localDt, localOffset);
  }
}

class XPathDateTimeStamp extends XPathDateTimeWrapper {
  XPathDateTimeStamp(super.dateTime, [super.timezoneOffset]);

  @override
  XPathDateTimeStamp toUtc() {
    if (timezoneOffset == null || timezoneOffset!.inMicroseconds == 0) {
      return this;
    }
    final utcDt = _dateTime.subtract(timezoneOffset!);
    return XPathDateTimeStamp(utcDt, const Duration());
  }

  @override
  XPathDateTimeStamp toLocal() {
    final localOffset = DateTime.now().timeZoneOffset;
    if (timezoneOffset == localOffset) return this;
    final utcDt = timezoneOffset != null
        ? _dateTime.subtract(timezoneOffset!)
        : _dateTime;
    final localDt = utcDt.add(localOffset);
    return XPathDateTimeStamp(localDt, localOffset);
  }
}

class XPathDate extends XPathDateTimeWrapper {
  XPathDate(super.dateTime, [super.timezoneOffset]);

  @override
  XPathDate toUtc() {
    if (timezoneOffset == null || timezoneOffset!.inMicroseconds == 0) {
      return this;
    }
    final utcDt = _dateTime.subtract(timezoneOffset!);
    return XPathDate(utcDt, const Duration());
  }

  @override
  XPathDate toLocal() {
    final localOffset = DateTime.now().timeZoneOffset;
    if (timezoneOffset == localOffset) return this;
    final utcDt = timezoneOffset != null
        ? _dateTime.subtract(timezoneOffset!)
        : _dateTime;
    final localDt = utcDt.add(localOffset);
    return XPathDate(localDt, localOffset);
  }
}

class XPathTime extends XPathDateTimeWrapper {
  XPathTime(super.dateTime, [super.timezoneOffset]);

  @override
  XPathTime toUtc() {
    if (timezoneOffset == null || timezoneOffset!.inMicroseconds == 0) {
      return this;
    }
    final utcDt = _dateTime.subtract(timezoneOffset!);
    return XPathTime(utcDt, const Duration());
  }

  @override
  XPathTime toLocal() {
    final localOffset = DateTime.now().timeZoneOffset;
    if (timezoneOffset == localOffset) return this;
    final utcDt = timezoneOffset != null
        ? _dateTime.subtract(timezoneOffset!)
        : _dateTime;
    final localDt = utcDt.add(localOffset);
    return XPathTime(localDt, localOffset);
  }
}

class XPathGYearMonth extends XPathDateTimeWrapper {
  XPathGYearMonth(super.dateTime, [super.timezoneOffset]);
}

class XPathGYear extends XPathDateTimeWrapper {
  XPathGYear(super.dateTime, [super.timezoneOffset]);
}

class XPathGMonthDay extends XPathDateTimeWrapper {
  XPathGMonthDay(super.dateTime, [super.timezoneOffset]);
}

class XPathGMonth extends XPathDateTimeWrapper {
  XPathGMonth(super.dateTime, [super.timezoneOffset]);
}

class XPathGDay extends XPathDateTimeWrapper {
  XPathGDay(super.dateTime, [super.timezoneOffset]);
}

abstract class XPathDateTimeWrapper implements DateTime {
  final DateTime _dateTime;
  final Duration? timezoneOffset;

  XPathDateTimeWrapper(this._dateTime, [this.timezoneOffset]);

  DateTime get utcInstant {
    final offset = timezoneOffset ?? _dateTime.toLocal().timeZoneOffset;
    return _dateTime.subtract(offset);
  }

  @override
  bool isAfter(DateTime other) {
    final otherInstant = other is XPathDateTimeWrapper
        ? other.utcInstant
        : other;
    return utcInstant.isAfter(otherInstant);
  }

  @override
  bool isBefore(DateTime other) {
    final otherInstant = other is XPathDateTimeWrapper
        ? other.utcInstant
        : other;
    return utcInstant.isBefore(otherInstant);
  }

  @override
  bool isAtSameMomentAs(DateTime other) {
    final otherInstant = other is XPathDateTimeWrapper
        ? other.utcInstant
        : other;
    return utcInstant.isAtSameMomentAs(otherInstant);
  }

  @override
  int compareTo(DateTime other) {
    final otherInstant = other is XPathDateTimeWrapper
        ? other.utcInstant
        : other;
    return utcInstant.compareTo(otherInstant);
  }

  @override
  DateTime add(Duration duration) => _dateTime.add(duration);

  @override
  DateTime subtract(Duration duration) => _dateTime.subtract(duration);

  @override
  Duration difference(DateTime other) {
    final otherInstant = other is XPathDateTimeWrapper
        ? other.utcInstant
        : other;
    return utcInstant.difference(otherInstant);
  }

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
  bool get isUtc => timezoneOffset != null;

  @override
  String get timeZoneName =>
      timezoneOffset != null ? 'UTC' : _dateTime.timeZoneName;

  @override
  Duration get timeZoneOffset => timezoneOffset ?? _dateTime.timeZoneOffset;

  @override
  int get millisecondsSinceEpoch => utcInstant.millisecondsSinceEpoch;

  @override
  int get microsecondsSinceEpoch => utcInstant.microsecondsSinceEpoch;

  @override
  int get hashCode => utcInstant.hashCode;

  @override
  bool operator ==(Object other) =>
      other is DateTime &&
      (other is XPathDateTimeWrapper
          ? utcInstant.isAtSameMomentAs(other.utcInstant)
          : utcInstant.isAtSameMomentAs(other));

  @override
  String toString() => _dateTime.toString();
}
