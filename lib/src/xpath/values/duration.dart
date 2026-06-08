import '../types/duration.dart';

/// An abstract representation of XPath duration types.
abstract class XPathAbstractDuration
    implements Comparable<XPathAbstractDuration> {
  /// The number of years in the duration, if applicable.
  int? get years;

  /// The number of months in the duration, if applicable.
  int? get months;

  /// The number of days in the duration, if applicable.
  int? get days;

  /// The number of hours in the duration, if applicable.
  int? get hours;

  /// The number of minutes in the duration, if applicable.
  int? get minutes;

  /// The number of seconds in the duration, if applicable.
  int? get seconds;

  /// The number of milliseconds in the duration, if applicable.
  int? get milliseconds;

  /// The number of microseconds in the duration, if applicable.
  int? get microseconds;

  /// Whether the duration is negative.
  bool get isNegative;

  /// Constant constructor for subclasses.
  const XPathAbstractDuration();

  /// Converts this object to a standard Dart [Duration] representation.
  Duration toDuration() {
    final d = days ?? 0;
    final h = hours ?? 0;
    final m = minutes ?? 0;
    final s = seconds ?? 0;
    final ms = milliseconds ?? 0;
    final us = microseconds ?? 0;
    final duration = Duration(
      days: d,
      hours: h,
      minutes: m,
      seconds: s,
      milliseconds: ms,
      microseconds: us,
    );
    return isNegative ? -duration : duration;
  }

  @override
  int compareTo(XPathAbstractDuration other) {
    if (this is XPathYearMonthDuration && other is XPathYearMonthDuration) {
      return (this as XPathYearMonthDuration).totalMonths.compareTo(
        other.totalMonths,
      );
    }
    if (this is XPathDayTimeDuration && other is XPathDayTimeDuration) {
      return (this as XPathDayTimeDuration).totalMicroseconds.compareTo(
        other.totalMicroseconds,
      );
    }
    return toString().compareTo(other.toString());
  }
}

/// Representation of an XPath duration value (xs:duration).
class XPathDuration extends XPathAbstractDuration {
  @override
  final int years;

  @override
  final int months;

  @override
  final int days;

  @override
  final int hours;

  @override
  final int minutes;

  @override
  final int seconds;

  @override
  final int milliseconds;

  @override
  final int microseconds;

  @override
  final bool isNegative;

  /// Creates a new [XPathDuration] with the given components.
  const XPathDuration({
    this.years = 0,
    this.months = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.milliseconds = 0,
    this.microseconds = 0,
    this.isNegative = false,
  });

  /// Creates a new [XPathDuration] from years, months, and microsecond components.
  factory XPathDuration.fromValues(int totalMonths, int totalMicroseconds) {
    final isNeg =
        totalMonths < 0 || (totalMonths == 0 && totalMicroseconds < 0);
    final absMonths = totalMonths.abs();
    final absUs = totalMicroseconds.abs();
    return XPathDuration(
      years: absMonths ~/ 12,
      months: absMonths % 12,
      days: absUs ~/ Duration.microsecondsPerDay,
      hours: (absUs ~/ Duration.microsecondsPerHour) % 24,
      minutes: (absUs ~/ Duration.microsecondsPerMinute) % 60,
      seconds: (absUs ~/ Duration.microsecondsPerSecond) % 60,
      milliseconds: (absUs ~/ Duration.microsecondsPerMillisecond) % 1000,
      microseconds: absUs % 1000,
      isNegative: isNeg,
    );
  }

  /// Creates a new [XPathDuration] from a Dart [Duration] object.
  factory XPathDuration.fromDuration(Duration duration) {
    final absUs = duration.abs().inMicroseconds;
    return XPathDuration(
      days: absUs ~/ Duration.microsecondsPerDay,
      hours: (absUs ~/ Duration.microsecondsPerHour) % 24,
      minutes: (absUs ~/ Duration.microsecondsPerMinute) % 60,
      seconds: (absUs ~/ Duration.microsecondsPerSecond) % 60,
      milliseconds: (absUs ~/ Duration.microsecondsPerMillisecond) % 1000,
      microseconds: absUs % 1000,
      isNegative: duration.isNegative,
    );
  }

  /// Attempts to parse a string representation of a duration.
  static XPathDuration? tryParse(String value) {
    final match = _durationRegExp.firstMatch(value);
    if (match == null) return null;

    final hasYM = match.group(2) != null || match.group(3) != null;
    final hasDT =
        match.group(4) != null ||
        match.group(5) != null ||
        match.group(6) != null ||
        match.group(7) != null;
    if (!hasYM && !hasDT) return null;

    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final days = int.tryParse(match.group(4) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(5) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(6) ?? '0') ?? 0;
    final secondsDouble = double.tryParse(match.group(7) ?? '0') ?? 0.0;

    final seconds = secondsDouble.truncate();
    final frac = secondsDouble - seconds;
    final ms = (frac * 1000).truncate();
    final us = ((frac * 1000000) - (ms * 1000)).round();

    return XPathDuration(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: ms,
      microseconds: us,
      isNegative: negative,
    );
  }

  /// The total number of months.
  int get totalMonths => (years * 12 + months) * (isNegative ? -1 : 1);

  /// The total number of microseconds.
  int get totalMicroseconds {
    final us =
        days * Duration.microsecondsPerDay +
        hours * Duration.microsecondsPerHour +
        minutes * Duration.microsecondsPerMinute +
        seconds * Duration.microsecondsPerSecond +
        milliseconds * Duration.microsecondsPerMillisecond +
        microseconds;
    return isNegative ? -us : us;
  }

  @override
  bool operator ==(Object other) {
    if (other is XPathDuration) {
      return totalMonths == other.totalMonths &&
          totalMicroseconds == other.totalMicroseconds;
    }
    if (other is XPathYearMonthDuration) {
      return totalMonths == other.totalMonths && totalMicroseconds == 0;
    }
    if (other is XPathDayTimeDuration) {
      return totalMonths == 0 && totalMicroseconds == other.totalMicroseconds;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(totalMonths, totalMicroseconds);

  @override
  int compareTo(XPathAbstractDuration other) {
    if (other is XPathDuration) {
      final c1 = totalMonths.compareTo(other.totalMonths);
      if (c1 != 0) return c1;
      return totalMicroseconds.compareTo(other.totalMicroseconds);
    }
    if (other is XPathYearMonthDuration) {
      final c1 = totalMonths.compareTo(other.totalMonths);
      if (c1 != 0) return c1;
      return totalMicroseconds.compareTo(0);
    }
    if (other is XPathDayTimeDuration) {
      final c1 = totalMonths.compareTo(0);
      if (c1 != 0) return c1;
      return totalMicroseconds.compareTo(other.totalMicroseconds);
    }
    return super.compareTo(other);
  }

  @override
  String toString() => xsDuration.castToString(this);
}

/// Representation of an XPath dayTimeDuration value (xs:dayTimeDuration).
class XPathDayTimeDuration extends XPathAbstractDuration {
  /// The total number of microseconds in this dayTimeDuration.
  final int totalMicroseconds;

  /// Creates a new [XPathDayTimeDuration] with the given total microseconds.
  const XPathDayTimeDuration(this.totalMicroseconds);

  /// Creates a new [XPathDayTimeDuration] from a Dart [Duration] object.
  factory XPathDayTimeDuration.fromDuration(Duration duration) =>
      XPathDayTimeDuration(duration.inMicroseconds);

  /// Attempts to parse a string representation of a dayTimeDuration.
  static XPathDayTimeDuration? tryParse(String value) {
    final match = _dayTimeDurationRegExp.firstMatch(value);
    if (match == null) return null;

    if (match.group(2) == null &&
        match.group(3) == null &&
        match.group(4) == null &&
        match.group(5) == null) {
      return null;
    }

    final negative = match.group(1) == '-';
    final days = int.tryParse(match.group(2) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(3) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(4) ?? '0') ?? 0;
    final secondsDouble = double.tryParse(match.group(5) ?? '0') ?? 0.0;

    final duration = Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      microseconds: (secondsDouble * Duration.microsecondsPerSecond).round(),
    );
    final totalUs = duration.inMicroseconds * (negative ? -1 : 1);
    return XPathDayTimeDuration(totalUs);
  }

  @override
  int? get years => null;

  @override
  int? get months => null;

  @override
  int get days => totalMicroseconds.abs() ~/ Duration.microsecondsPerDay;

  @override
  int get hours =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerHour) % 24;

  @override
  int get minutes =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerMinute) % 60;

  @override
  int get seconds =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerSecond) % 60;

  @override
  int get milliseconds =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerMillisecond) % 1000;

  @override
  int get microseconds => totalMicroseconds.abs() % 1000;

  @override
  bool get isNegative => totalMicroseconds < 0;

  /// Returns the duration in days.
  int get inDays => totalMicroseconds ~/ Duration.microsecondsPerDay;

  /// Returns the duration in hours.
  int get inHours => totalMicroseconds ~/ Duration.microsecondsPerHour;

  /// Returns the duration in minutes.
  int get inMinutes => totalMicroseconds ~/ Duration.microsecondsPerMinute;

  /// Returns the duration in seconds.
  int get inSeconds => totalMicroseconds ~/ Duration.microsecondsPerSecond;

  /// Returns the duration in milliseconds.
  int get inMilliseconds =>
      totalMicroseconds ~/ Duration.microsecondsPerMillisecond;

  /// Returns the duration in microseconds.
  int get inMicroseconds => totalMicroseconds;

  /// Returns the absolute value of this duration.
  XPathDayTimeDuration abs() => XPathDayTimeDuration(totalMicroseconds.abs());

  /// Adds another [XPathDayTimeDuration] to this one.
  XPathDayTimeDuration operator +(XPathDayTimeDuration other) =>
      XPathDayTimeDuration(totalMicroseconds + other.totalMicroseconds);

  /// Subtracts another [XPathDayTimeDuration] from this one.
  XPathDayTimeDuration operator -(XPathDayTimeDuration other) =>
      XPathDayTimeDuration(totalMicroseconds - other.totalMicroseconds);

  /// Multiplies this duration by a factor.
  XPathDayTimeDuration operator *(num factor) =>
      XPathDayTimeDuration((totalMicroseconds * factor).round());

  /// Divides this duration by an integer quotient.
  XPathDayTimeDuration operator ~/(int quotient) =>
      XPathDayTimeDuration(totalMicroseconds ~/ quotient);

  /// Negates this duration.
  XPathDayTimeDuration operator -() => XPathDayTimeDuration(-totalMicroseconds);

  /// Compares if this duration is less than another.
  bool operator <(XPathDayTimeDuration other) =>
      totalMicroseconds < other.totalMicroseconds;

  /// Compares if this duration is less than or equal to another.
  bool operator <=(XPathDayTimeDuration other) =>
      totalMicroseconds <= other.totalMicroseconds;

  /// Compares if this duration is greater than another.
  bool operator >(XPathDayTimeDuration other) =>
      totalMicroseconds > other.totalMicroseconds;

  /// Compares if this duration is greater than or equal to another.
  bool operator >=(XPathDayTimeDuration other) =>
      totalMicroseconds >= other.totalMicroseconds;

  @override
  bool operator ==(Object other) {
    if (other is XPathDayTimeDuration) {
      return totalMicroseconds == other.totalMicroseconds;
    }
    if (other is XPathDuration) {
      return other.totalMonths == 0 &&
          totalMicroseconds == other.totalMicroseconds;
    }
    return false;
  }

  @override
  int get hashCode => totalMicroseconds.hashCode;

  @override
  String toString() => xsDayTimeDuration.castToString(this);
}

/// Representation of an XPath yearMonthDuration value (xs:yearMonthDuration).
class XPathYearMonthDuration extends XPathAbstractDuration {
  /// The total number of months in this yearMonthDuration.
  final int totalMonths;

  /// Creates a new [XPathYearMonthDuration] with the given total months.
  const XPathYearMonthDuration(this.totalMonths);

  /// Attempts to parse a string representation of a yearMonthDuration.
  static XPathYearMonthDuration? tryParse(String value) {
    final match = _yearMonthDurationRegExp.firstMatch(value);
    if (match == null) return null;

    if (match.group(2) == null && match.group(3) == null) return null;

    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final total = (years * 12 + months) * (negative ? -1 : 1);
    return XPathYearMonthDuration(total);
  }

  @override
  int get years => totalMonths.abs() ~/ 12;

  @override
  int get months => totalMonths.abs() % 12;

  @override
  int? get days => null;

  @override
  int? get hours => null;

  @override
  int? get minutes => null;

  @override
  int? get seconds => null;

  @override
  int? get milliseconds => null;

  @override
  int? get microseconds => null;

  @override
  bool get isNegative => totalMonths < 0;

  /// Adds another [XPathYearMonthDuration] to this one.
  XPathYearMonthDuration operator +(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(totalMonths + other.totalMonths);

  /// Subtracts another [XPathYearMonthDuration] from this one.
  XPathYearMonthDuration operator -(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(totalMonths - other.totalMonths);

  /// Multiplies this duration by a factor.
  XPathYearMonthDuration operator *(num factor) =>
      XPathYearMonthDuration((totalMonths * factor).round());

  /// Divides this duration by an integer quotient.
  XPathYearMonthDuration operator ~/(int quotient) =>
      XPathYearMonthDuration(totalMonths ~/ quotient);

  /// Negates this duration.
  XPathYearMonthDuration operator -() => XPathYearMonthDuration(-totalMonths);

  /// Compares if this duration is less than another.
  bool operator <(XPathYearMonthDuration other) =>
      totalMonths < other.totalMonths;

  /// Compares if this duration is less than or equal to another.
  bool operator <=(XPathYearMonthDuration other) =>
      totalMonths <= other.totalMonths;

  /// Compares if this duration is greater than another.
  bool operator >(XPathYearMonthDuration other) =>
      totalMonths > other.totalMonths;

  /// Compares if this duration is greater than or equal to another.
  bool operator >=(XPathYearMonthDuration other) =>
      totalMonths >= other.totalMonths;

  /// Divides this duration by another [XPathYearMonthDuration] returning a double.
  double divideByDuration(XPathYearMonthDuration other) =>
      totalMonths / other.totalMonths;

  @override
  bool operator ==(Object other) {
    if (other is XPathYearMonthDuration) {
      return totalMonths == other.totalMonths;
    }
    if (other is XPathDuration) {
      return totalMonths == other.totalMonths && other.totalMicroseconds == 0;
    }
    return false;
  }

  @override
  int get hashCode => totalMonths.hashCode;

  @override
  String toString() => xsYearMonthDuration.castToString(this);
}

// Regexes and Parsing Helpers

final _durationRegExp = RegExp(
  r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);

final _dayTimeDurationRegExp = RegExp(
  r'^(-)?P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);

final _yearMonthDurationRegExp = RegExp(r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?$');
