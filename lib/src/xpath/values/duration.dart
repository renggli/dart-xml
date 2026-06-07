import '../types/duration.dart';

abstract class XPathAbstractDuration
    implements Comparable<XPathAbstractDuration> {
  int? get years;
  int? get months;
  int? get days;
  int? get hours;
  int? get minutes;
  int? get seconds;
  int? get milliseconds;
  int? get microseconds;
  bool get isNegative;

  const XPathAbstractDuration();

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
    if (this is XPathDuration && other is XPathDuration) {
      return (this as XPathDuration).compareTo(other);
    }
    return toString().compareTo(other.toString());
  }
}

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

  int get totalMonths => (years * 12 + months) * (isNegative ? -1 : 1);
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

class XPathDayTimeDuration extends XPathAbstractDuration {
  final int totalMicroseconds;

  const XPathDayTimeDuration(this.totalMicroseconds);

  factory XPathDayTimeDuration.fromDuration(Duration duration) =>
      XPathDayTimeDuration(duration.inMicroseconds);

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

  int get inDays => totalMicroseconds ~/ Duration.microsecondsPerDay;
  int get inHours => totalMicroseconds ~/ Duration.microsecondsPerHour;
  int get inMinutes => totalMicroseconds ~/ Duration.microsecondsPerMinute;
  int get inSeconds => totalMicroseconds ~/ Duration.microsecondsPerSecond;
  int get inMilliseconds =>
      totalMicroseconds ~/ Duration.microsecondsPerMillisecond;
  int get inMicroseconds => totalMicroseconds;

  XPathDayTimeDuration abs() => XPathDayTimeDuration(totalMicroseconds.abs());

  XPathDayTimeDuration operator +(XPathDayTimeDuration other) =>
      XPathDayTimeDuration(totalMicroseconds + other.totalMicroseconds);

  XPathDayTimeDuration operator -(XPathDayTimeDuration other) =>
      XPathDayTimeDuration(totalMicroseconds - other.totalMicroseconds);

  XPathDayTimeDuration operator *(num factor) =>
      XPathDayTimeDuration((totalMicroseconds * factor).round());

  XPathDayTimeDuration operator ~/(int quotient) =>
      XPathDayTimeDuration(totalMicroseconds ~/ quotient);

  XPathDayTimeDuration operator -() => XPathDayTimeDuration(-totalMicroseconds);

  bool operator <(XPathDayTimeDuration other) =>
      totalMicroseconds < other.totalMicroseconds;
  bool operator <=(XPathDayTimeDuration other) =>
      totalMicroseconds <= other.totalMicroseconds;
  bool operator >(XPathDayTimeDuration other) =>
      totalMicroseconds > other.totalMicroseconds;
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

class XPathYearMonthDuration extends XPathAbstractDuration {
  final int totalMonths;

  const XPathYearMonthDuration(this.totalMonths);

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

  XPathYearMonthDuration operator +(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(totalMonths + other.totalMonths);

  XPathYearMonthDuration operator -(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(totalMonths - other.totalMonths);

  XPathYearMonthDuration operator *(num factor) =>
      XPathYearMonthDuration((totalMonths * factor).round());

  XPathYearMonthDuration operator ~/(int quotient) =>
      XPathYearMonthDuration(totalMonths ~/ quotient);

  XPathYearMonthDuration operator -() => XPathYearMonthDuration(-totalMonths);

  bool operator <(XPathYearMonthDuration other) =>
      totalMonths < other.totalMonths;
  bool operator <=(XPathYearMonthDuration other) =>
      totalMonths <= other.totalMonths;
  bool operator >(XPathYearMonthDuration other) =>
      totalMonths > other.totalMonths;
  bool operator >=(XPathYearMonthDuration other) =>
      totalMonths >= other.totalMonths;

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
