import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath duration type (xs:duration) combining a year-month and day-time part.
const xsDuration = _XPathDurationType();

class _XPathDurationType extends XPathType<XPathDuration> {
  const _XPathDurationType();

  @override
  String get name => 'xs:duration';

  @override
  bool matches(Object value) =>
      value is XPathDuration &&
      value is! XPathYearMonthDuration &&
      value is! XPathDayTimeDuration;

  @override
  XPathDuration cast(Object value) {
    if (value is XPathDuration) return value;
    if (value is String) return _parseDuration(value.trim());
    if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _durationRegExp = RegExp(
    r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
  );

  static XPathDuration _parseDuration(String value) {
    final match = _durationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(xsDuration, value);
    }
    final hasYM = match.group(2) != null || match.group(3) != null;
    final hasDT =
        match.group(4) != null ||
        match.group(5) != null ||
        match.group(6) != null ||
        match.group(7) != null;
    if (!hasYM && !hasDT) {
      throw XPathEvaluationException.unsupportedCast(xsDuration, value);
    }
    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final days = int.tryParse(match.group(4) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(5) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(6) ?? '0') ?? 0;
    final seconds = double.tryParse(match.group(7) ?? '0') ?? 0.0;
    final totalMonths = (years * 12 + months) * (negative ? -1 : 1);
    var dayTime = Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      microseconds: (seconds * Duration.microsecondsPerSecond).round(),
    );
    if (negative) dayTime = -dayTime;
    return XPathDuration(months: totalMonths, dayTime: dayTime);
  }

  @override
  String castToString(XPathDuration value) {
    if (value.months == 0 && value.dayTime == Duration.zero) return 'PT0S';
    // A combined xs:duration is negative if both parts are non-positive and at least one is negative.
    final negative = value.isNegative;
    final buffer = StringBuffer(negative ? '-P' : 'P');
    final absMonths = value.months.abs();
    final absDayTime = value.dayTime.abs();
    final years = absMonths ~/ 12;
    final remainingMonths = absMonths.remainder(12);
    if (years > 0) buffer.write('${years}Y');
    if (remainingMonths > 0) buffer.write('${remainingMonths}M');
    _writeDayTimePart(buffer, absDayTime);
    return buffer.toString();
  }
}

/// Shared helper to write the dayTime portion (D, T, H, M, S).
void _writeDayTimePart(StringBuffer buffer, Duration duration) {
  final days = duration.inDays;
  if (days > 0) buffer.write('${days}D');
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  final wholeSeconds = duration.inSeconds.remainder(60);
  final microRemainder = duration.inMicroseconds.remainder(
    Duration.microsecondsPerSecond,
  );
  final hasTime =
      hours > 0 || minutes > 0 || wholeSeconds > 0 || microRemainder != 0;
  if (hasTime) {
    buffer.write('T');
    if (hours > 0) buffer.write('${hours}H');
    if (minutes > 0) buffer.write('${minutes}M');
    if (wholeSeconds > 0 || microRemainder != 0) {
      buffer.write(wholeSeconds);
      if (microRemainder != 0) {
        // Write fractional seconds without trailing zeros.
        final frac = (microRemainder.abs() / Duration.microsecondsPerSecond)
            .toStringAsFixed(6);
        buffer.write(frac.substring(1).replaceAll(RegExp(r'0+$'), ''));
      }
      buffer.write('S');
    }
  }
}

/// An XPath xs:duration value holding separate year-month and day-time parts.
///
/// XPath requires that `xs:duration` equality compares the two parts independently:
/// `P1Y == P12M` (both have yearMonth=12 months, dayTime=zero), and
/// `P1Y != P365D` (one has yearMonth=12M, the other has yearMonth=0, dayTime=365d).
class XPathDuration {
  /// Total months for the year-month component (signed).
  final int months;

  /// Day-time component (signed).
  final Duration dayTime;

  const XPathDuration({required this.months, required this.dayTime});

  /// Whether this duration is negative.
  bool get isNegative => months < 0 || (months == 0 && dayTime.isNegative);

  @override
  bool operator ==(Object other) =>
      other is XPathDuration &&
      months == other.months &&
      dayTime == other.dayTime;

  @override
  int get hashCode => Object.hash(months, dayTime);

  @override
  String toString() => xsDuration.castToString(this);
}

// ---------------------------------------------------------------------------
// xs:dayTimeDuration
// ---------------------------------------------------------------------------

/// The XPath dayTimeDuration type.
const xsDayTimeDuration = _XPathDayTimeDurationType();

class _XPathDayTimeDurationType extends XPathType<XPathDayTimeDuration> {
  const _XPathDayTimeDurationType();

  @override
  String get name => 'xs:dayTimeDuration';

  @override
  bool matches(Object value) => value is XPathDayTimeDuration;

  @override
  XPathDayTimeDuration cast(Object value) {
    if (value is XPathDayTimeDuration) return value;
    if (value is XPathYearMonthDuration) {
      return XPathDayTimeDuration(Duration.zero);
    }
    if (value is XPathDuration) return XPathDayTimeDuration(value.dayTime);
    if (value is Duration) return XPathDayTimeDuration(value);
    if (value is String) return _parseDayTimeDuration(value.trim());
    if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _dayTimeDurationRegExp = RegExp(
    r'^(-)?P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
  );

  static XPathDayTimeDuration _parseDayTimeDuration(String value) {
    final match = _dayTimeDurationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(xsDayTimeDuration, value);
    }
    if (match.group(2) == null &&
        match.group(3) == null &&
        match.group(4) == null &&
        match.group(5) == null) {
      throw XPathEvaluationException.unsupportedCast(xsDayTimeDuration, value);
    }
    final negative = match.group(1) == '-';
    final days = int.tryParse(match.group(2) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(3) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(4) ?? '0') ?? 0;
    final seconds = double.tryParse(match.group(5) ?? '0') ?? 0.0;
    final duration = Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      microseconds: (seconds * Duration.microsecondsPerSecond).round(),
    );
    return XPathDayTimeDuration(negative ? -duration : duration);
  }

  @override
  String castToString(XPathDayTimeDuration value) {
    if (value.inMicroseconds == 0) return 'PT0S';
    final negative = value.isNegative;
    final buffer = StringBuffer(negative ? '-P' : 'P');
    _writeDayTimePart(buffer, value.dayTime.abs());
    return buffer.toString();
  }
}

/// An XPath xs:dayTimeDuration value.
///
/// Implements [Duration] so it can be passed to [DateTime.add] etc.
class XPathDayTimeDuration extends XPathDuration implements Duration {
  XPathDayTimeDuration(Duration dayTime) : super(months: 0, dayTime: dayTime);

  @override
  int get inDays => dayTime.inDays;
  @override
  int get inHours => dayTime.inHours;
  @override
  int get inMinutes => dayTime.inMinutes;
  @override
  int get inSeconds => dayTime.inSeconds;
  @override
  int get inMilliseconds => dayTime.inMilliseconds;
  @override
  int get inMicroseconds => dayTime.inMicroseconds;
  @override
  bool get isNegative => dayTime.isNegative;
  @override
  int compareTo(Duration other) => dayTime.compareTo(other);
  @override
  Duration abs() => XPathDayTimeDuration(
    Duration(microseconds: dayTime.inMicroseconds.abs()),
  );
  @override
  Duration operator +(Duration other) => XPathDayTimeDuration(
    Duration(microseconds: dayTime.inMicroseconds + other.inMicroseconds),
  );
  @override
  Duration operator -(Duration other) => XPathDayTimeDuration(
    Duration(microseconds: dayTime.inMicroseconds - other.inMicroseconds),
  );
  @override
  Duration operator *(num factor) => XPathDayTimeDuration(
    Duration(microseconds: (dayTime.inMicroseconds * factor).round()),
  );
  @override
  Duration operator ~/(int quotient) => XPathDayTimeDuration(
    Duration(microseconds: dayTime.inMicroseconds ~/ quotient),
  );
  @override
  Duration operator -() =>
      XPathDayTimeDuration(Duration(microseconds: -dayTime.inMicroseconds));
  @override
  bool operator <(Duration other) =>
      dayTime.inMicroseconds < other.inMicroseconds;
  @override
  bool operator <=(Duration other) =>
      dayTime.inMicroseconds <= other.inMicroseconds;
  @override
  bool operator >(Duration other) =>
      dayTime.inMicroseconds > other.inMicroseconds;
  @override
  bool operator >=(Duration other) =>
      dayTime.inMicroseconds >= other.inMicroseconds;

  @override
  bool operator ==(Object other) {
    if (other is XPathDayTimeDuration) return dayTime == other.dayTime;
    if (other is Duration) return dayTime == other;
    return false;
  }

  @override
  int get hashCode => dayTime.hashCode;

  @override
  String toString() => xsDayTimeDuration.castToString(this);
}

// ---------------------------------------------------------------------------
// xs:yearMonthDuration
// ---------------------------------------------------------------------------

/// The XPath yearMonthDuration type.
const xsYearMonthDuration = _XPathYearMonthDurationType();

class _XPathYearMonthDurationType extends XPathType<XPathYearMonthDuration> {
  const _XPathYearMonthDurationType();

  @override
  String get name => 'xs:yearMonthDuration';

  @override
  bool matches(Object value) => value is XPathYearMonthDuration;

  @override
  XPathYearMonthDuration cast(Object value) {
    if (value is XPathYearMonthDuration) return value;
    if (value is XPathDayTimeDuration) return XPathYearMonthDuration(0);
    if (value is XPathDuration) return XPathYearMonthDuration(value.months);
    if (value is String) return _parseYearMonthDuration(value.trim());
    if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _yearMonthDurationRegExp = RegExp(
    r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?$',
  );

  static XPathYearMonthDuration _parseYearMonthDuration(String value) {
    final match = _yearMonthDurationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(
        xsYearMonthDuration,
        value,
      );
    }
    if (match.group(2) == null && match.group(3) == null) {
      throw XPathEvaluationException.unsupportedCast(
        xsYearMonthDuration,
        value,
      );
    }
    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final total = (years * 12 + months) * (negative ? -1 : 1);
    return XPathYearMonthDuration(total);
  }

  @override
  String castToString(XPathYearMonthDuration value) {
    if (value.totalMonths == 0) return 'P0M';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final abs = value.totalMonths.abs();
    final years = abs ~/ 12;
    final months = abs.remainder(12);
    if (years > 0) buffer.write('${years}Y');
    if (months > 0 || years == 0) buffer.write('${months}M');
    return buffer.toString();
  }
}

/// An XPath xs:yearMonthDuration value storing the total months count.
class XPathYearMonthDuration extends XPathDuration {
  /// Total months (signed).
  int get totalMonths => months;

  XPathYearMonthDuration(int totalMonths)
    : super(months: totalMonths, dayTime: Duration.zero);

  @override
  bool get isNegative => months < 0;

  XPathYearMonthDuration operator +(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(months + other.months);

  XPathYearMonthDuration operator -(XPathYearMonthDuration other) =>
      XPathYearMonthDuration(months - other.months);

  XPathYearMonthDuration operator *(num factor) =>
      XPathYearMonthDuration((months * factor).round());

  XPathYearMonthDuration operator ~/(int quotient) =>
      XPathYearMonthDuration(months ~/ quotient);

  bool operator <(XPathYearMonthDuration other) => months < other.months;
  bool operator <=(XPathYearMonthDuration other) => months <= other.months;
  bool operator >(XPathYearMonthDuration other) => months > other.months;
  bool operator >=(XPathYearMonthDuration other) => months >= other.months;

  XPathYearMonthDuration operator -() => XPathYearMonthDuration(-months);

  double divideByDuration(XPathYearMonthDuration other) =>
      months / other.months;

  @override
  bool operator ==(Object other) =>
      other is XPathYearMonthDuration && months == other.months;

  @override
  int get hashCode => months.hashCode;

  @override
  String toString() => xsYearMonthDuration.castToString(this);
}
