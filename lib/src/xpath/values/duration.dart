import '../types/duration.dart';

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
  bool operator ==(Object other) => switch (other) {
    XPathDayTimeDuration() => dayTime == other.dayTime,
    Duration() => dayTime == other,
    _ => false,
  };

  @override
  int get hashCode => dayTime.hashCode;

  @override
  String toString() => xsDayTimeDuration.castToString(this);
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
