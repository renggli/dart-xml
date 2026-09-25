import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

/// Representation of XPath duration values (xs:duration, xs:yearMonthDuration,
/// and xs:dayTimeDuration).
final class XPathDuration extends XPathAtomic {
  /// Creates a new [XPathDuration].
  const new({
    int years = 0,
    int months = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
    int? totalMonths,
    int? totalMicroseconds,
    bool isNegative = false,
    this.type = xsDuration,
  }) : totalMonths =
           totalMonths ?? (years * 12 + months) * (isNegative ? -1 : 1),
       totalMicroseconds =
           totalMicroseconds ??
           (days * Duration.microsecondsPerDay +
                   hours * Duration.microsecondsPerHour +
                   minutes * Duration.microsecondsPerMinute +
                   seconds * Duration.microsecondsPerSecond +
                   milliseconds * Duration.microsecondsPerMillisecond +
                   microseconds) *
               (isNegative ? -1 : 1);

  /// Creates a new [XPathDuration] representing an xs:dayTimeDuration.
  const new dayTime(int totalMicroseconds)
    : this(totalMicroseconds: totalMicroseconds, type: xsDayTimeDuration);

  /// Creates a new [XPathDuration] representing an xs:yearMonthDuration.
  const new yearMonth(int totalMonths)
    : this(totalMonths: totalMonths, type: xsYearMonthDuration);

  /// Creates a new [XPathDuration] from years, months, and microsecond components.
  factory fromValues(
    int totalMonths,
    int totalMicroseconds, [
    XPathType type = xsDuration,
  ]) => XPathDuration(
    totalMonths: totalMonths,
    totalMicroseconds: totalMicroseconds,
    type: type,
  );

  /// Creates a new [XPathDuration] from a Dart [Duration] object.
  factory fromDuration(
    Duration duration, [
    XPathType type = xsDayTimeDuration,
  ]) => XPathDuration(totalMicroseconds: duration.inMicroseconds, type: type);

  /// Total number of months in this duration.
  final int totalMonths;

  /// Total number of microseconds in this duration.
  final int totalMicroseconds;

  @override
  final XPathType type;

  @override
  Object get value => this;

  @override
  Duration toValue() => toDuration();

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    XPathErrorCode.FORG0006,
    'Cannot compute EBV of duration: $this',
  );

  /// Whether the duration is negative.
  bool get isNegative =>
      totalMonths < 0 || (totalMonths == 0 && totalMicroseconds < 0);

  /// Whether this duration is an `xs:yearMonthDuration`.
  bool get isYearMonth => type.isSubtypeOf(xsYearMonthDuration);

  /// Whether this duration is an `xs:dayTimeDuration`.
  bool get isDayTime => type.isSubtypeOf(xsDayTimeDuration);

  /// The number of years in the duration.
  int get years => totalMonths.abs() ~/ 12;

  /// The number of months in the duration (0-11).
  int get months => totalMonths.abs() % 12;

  /// The number of days in the duration.
  int get days => totalMicroseconds.abs() ~/ Duration.microsecondsPerDay;

  /// The number of hours in the duration (0-23).
  int get hours =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerHour) % 24;

  /// The number of minutes in the duration (0-59).
  int get minutes =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerMinute) % 60;

  /// The number of seconds in the duration (0-59).
  int get seconds =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerSecond) % 60;

  /// The number of milliseconds in the duration (0-999).
  int get milliseconds =>
      (totalMicroseconds.abs() ~/ Duration.microsecondsPerMillisecond) % 1000;

  /// The number of microseconds in the duration (0-999).
  int get microseconds => totalMicroseconds.abs() % 1000;

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

  /// Converts this object to a standard Dart [Duration] representation.
  Duration toDuration() => Duration(microseconds: totalMicroseconds);

  /// Returns the absolute value of this duration.
  XPathDuration abs() => XPathDuration(
    totalMonths: totalMonths.abs(),
    totalMicroseconds: totalMicroseconds.abs(),
    type: type,
  );

  /// Adds another [XPathDuration] to this one.
  XPathDuration operator +(XPathDuration other) => XPathDuration(
    totalMonths: totalMonths + other.totalMonths,
    totalMicroseconds: totalMicroseconds + other.totalMicroseconds,
    type: type == other.type ? type : xsDuration,
  );

  /// Subtracts another [XPathDuration] from this one.
  XPathDuration operator -(XPathDuration other) => XPathDuration(
    totalMonths: totalMonths - other.totalMonths,
    totalMicroseconds: totalMicroseconds - other.totalMicroseconds,
    type: type == other.type ? type : xsDuration,
  );

  /// Multiplies this duration by a factor.
  XPathDuration operator *(num factor) => XPathDuration(
    totalMonths: (totalMonths * factor).round(),
    totalMicroseconds: (totalMicroseconds * factor).round(),
    type: type,
  );

  /// Divides this duration by an integer quotient.
  XPathDuration operator ~/(int quotient) => XPathDuration(
    totalMonths: totalMonths ~/ quotient,
    totalMicroseconds: totalMicroseconds ~/ quotient,
    type: type,
  );

  /// Negates this duration.
  XPathDuration operator -() => XPathDuration(
    totalMonths: -totalMonths,
    totalMicroseconds: -totalMicroseconds,
    type: type,
  );

  /// Compares if this duration is less than another.
  bool operator <(XPathDuration other) => compareTo(other) < 0;

  /// Compares if this duration is less than or equal to another.
  bool operator <=(XPathDuration other) => compareTo(other) <= 0;

  /// Compares if this duration is greater than another.
  bool operator >(XPathDuration other) => compareTo(other) > 0;

  /// Compares if this duration is greater than or equal to another.
  bool operator >=(XPathDuration other) => compareTo(other) >= 0;

  /// Divides this duration by another [XPathDuration] returning a double.
  double divideByDuration(XPathDuration other) {
    if (type.isSubtypeOf(xsYearMonthDuration) &&
        other.type.isSubtypeOf(xsYearMonthDuration)) {
      return totalMonths / other.totalMonths;
    }
    return totalMicroseconds / other.totalMicroseconds;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XPathDuration) return false;
    return totalMonths == other.totalMonths &&
        totalMicroseconds == other.totalMicroseconds;
  }

  @override
  int get hashCode => Object.hash(totalMonths, totalMicroseconds);

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathDuration) {
      if (isYearMonth && other.isYearMonth) {
        return totalMonths.compareTo(other.totalMonths);
      }
      if (isDayTime && other.isDayTime) {
        return totalMicroseconds.compareTo(other.totalMicroseconds);
      }
      final c1 = totalMonths.compareTo(other.totalMonths);
      if (c1 != 0) return c1;
      return totalMicroseconds.compareTo(other.totalMicroseconds);
    }
    return super.compareTo(other);
  }

  @override
  String get stringValue {
    if (type == xsYearMonthDuration) {
      if (totalMonths == 0) return 'P0M';
      final buffer = StringBuffer(totalMonths < 0 ? '-P' : 'P');
      final absYears = years;
      final absMonths = months;
      if (absYears > 0) buffer.write('${absYears}Y');
      if (absMonths > 0 || absYears == 0) buffer.write('${absMonths}M');
      return buffer.toString();
    }
    if (type == xsDayTimeDuration) {
      if (totalMicroseconds == 0) return 'PT0S';
      final buffer = StringBuffer(totalMicroseconds < 0 ? '-P' : 'P');
      _writeDayTimePart(buffer, this);
      return buffer.toString();
    }
    if (totalMonths == 0 && totalMicroseconds == 0) return 'PT0S';
    final buffer = StringBuffer(isNegative ? '-P' : 'P');
    final absYears = years;
    final absMonths = months;
    if (absYears > 0) buffer.write('${absYears}Y');
    if (absMonths > 0) buffer.write('${absMonths}M');
    _writeDayTimePart(buffer, this);
    return buffer.toString();
  }

  @override
  String toString() => stringValue;

  /// Attempts to parse a string representation of a duration.
  static XPathDuration? tryParse(String value, [XPathType type = xsDuration]) {
    if (type == xsYearMonthDuration) {
      return tryParseYearMonth(value);
    }
    if (type == xsDayTimeDuration) {
      return tryParseDayTime(value);
    }
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
    final yr = int.tryParse(match.group(2) ?? '0') ?? 0;
    final mo = int.tryParse(match.group(3) ?? '0') ?? 0;
    final dy = int.tryParse(match.group(4) ?? '0') ?? 0;
    final hr = int.tryParse(match.group(5) ?? '0') ?? 0;
    final min = int.tryParse(match.group(6) ?? '0') ?? 0;
    final scDouble = double.tryParse(match.group(7) ?? '0') ?? 0.0;
    final totalSeconds = scDouble.truncate();
    final frac = scDouble - totalSeconds;
    final ms = (frac * 1000).truncate();
    final us = ((frac * 1000000) - (ms * 1000)).round();

    final sec = totalSeconds % 60;
    final totalMin = min + totalSeconds ~/ 60;
    final m = totalMin % 60;
    final totalHr = hr + totalMin ~/ 60;
    final h = totalHr % 24;
    final d = dy + totalHr ~/ 24;

    return XPathDuration(
      years: yr,
      months: mo,
      days: d,
      hours: h,
      minutes: m,
      seconds: sec,
      milliseconds: ms,
      microseconds: us,
      isNegative: negative,
      type: type,
    );
  }

  /// Attempts to parse a string representation of a dayTimeDuration.
  static XPathDuration? tryParseDayTime(String value) {
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
    return XPathDuration.dayTime(totalUs);
  }

  /// Attempts to parse a string representation of a yearMonthDuration.
  static XPathDuration? tryParseYearMonth(String value) {
    final match = _yearMonthDurationRegExp.firstMatch(value);
    if (match == null) return null;

    if (match.group(2) == null && match.group(3) == null) return null;

    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final total = (years * 12 + months) * (negative ? -1 : 1);
    return XPathDuration.yearMonth(total);
  }
}

void _writeDayTimePart(StringBuffer buffer, XPathDuration value) {
  final d = value.days;
  if (d > 0) buffer.write('${d}D');
  final h = value.hours;
  final m = value.minutes;
  final s = value.seconds;
  final ms = value.milliseconds;
  final us = value.microseconds;
  final hasTime = h > 0 || m > 0 || s > 0 || ms > 0 || us > 0;
  if (hasTime) {
    buffer.write('T');
    if (h > 0) buffer.write('${h}H');
    if (m > 0) buffer.write('${m}M');
    if (s > 0 || ms > 0 || us > 0) {
      buffer.write('$s');
      if (ms > 0 || us > 0) {
        final fraction = (ms * 1000 + us).toString().padLeft(6, '0');
        buffer.write('.${fraction.replaceFirst(RegExp(r'0+$'), '')}');
      }
      buffer.write('S');
    }
  }
}

// Regexes
final _durationRegExp = RegExp(
  r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);

final _dayTimeDurationRegExp = RegExp(
  r'^(-)?P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);

final _yearMonthDurationRegExp = RegExp(r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?$');
