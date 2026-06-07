import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

/// The XPath duration type (xs:duration) combining a year-month and day-time part.
const xsDuration = _XPathDurationType();

class _XPathDurationType extends XPathType<XPathDuration> {
  const _XPathDurationType();

  @override
  String get name => 'xs:duration';

  @override
  bool matches(Object value) =>
      value is XPathDuration ||
      value is XPathYearMonthDuration ||
      value is XPathDayTimeDuration ||
      value is Duration;

  @override
  XPathDuration cast(Object value) => switch (value) {
    XPathDuration() => value,
    XPathYearMonthDuration() => XPathDuration(
      years: value.years,
      months: value.months,
      isNegative: value.isNegative,
    ),
    XPathDayTimeDuration() => XPathDuration(
      days: value.days,
      hours: value.hours,
      minutes: value.minutes,
      seconds: value.seconds,
      milliseconds: value.milliseconds,
      microseconds: value.microseconds,
      isNegative: value.isNegative,
    ),
    Duration() => XPathDuration.fromDuration(value),
    String() => _parseDuration(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDuration _parseDuration(String value) =>
      XPathDuration.tryParse(value) ??
      (throw XPathEvaluationException.unsupportedCast(this, value));

  @override
  String castToString(XPathDuration value) {
    if (value.totalMonths == 0 && value.totalMicroseconds == 0) return 'PT0S';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final absYears = value.years;
    final absMonths = value.months;
    if (absYears > 0) buffer.write('${absYears}Y');
    if (absMonths > 0) buffer.write('${absMonths}M');
    _writeDayTimePart(buffer, value);
    return buffer.toString();
  }
}

/// Shared helper to write the dayTime portion (D, T, H, M, S).
void _writeDayTimePart(StringBuffer buffer, XPathAbstractDuration value) {
  final d = value.days ?? 0;
  if (d > 0) buffer.write('${d}D');
  final h = value.hours ?? 0;
  final m = value.minutes ?? 0;
  final s = value.seconds ?? 0;
  final ms = value.milliseconds ?? 0;
  final us = value.microseconds ?? 0;
  final hasTime = h > 0 || m > 0 || s > 0 || ms > 0 || us > 0;
  if (hasTime) {
    buffer.write('T');
    if (h > 0) buffer.write('${h}H');
    if (m > 0) buffer.write('${m}M');
    if (s > 0 || ms > 0 || us > 0) {
      buffer.write(s);
      if (ms > 0 || us > 0) {
        final totalUs = ms * 1000 + us;
        final usStr = totalUs
            .toString()
            .padLeft(6, '0')
            .replaceAll(RegExp(r'0+$'), '');
        buffer.write('.$usStr');
      }
      buffer.write('S');
    }
  }
}

/// The XPath dayTimeDuration type.
const xsDayTimeDuration = _XPathDayTimeDurationType();

class _XPathDayTimeDurationType extends XPathType<XPathDayTimeDuration> {
  const _XPathDayTimeDurationType();

  @override
  String get name => 'xs:dayTimeDuration';

  @override
  bool matches(Object value) =>
      value is XPathDayTimeDuration || value is Duration;

  @override
  XPathDayTimeDuration cast(Object value) => switch (value) {
    XPathDayTimeDuration() => value,
    XPathDuration() => XPathDayTimeDuration(value.totalMicroseconds),
    XPathYearMonthDuration() => const XPathDayTimeDuration(0),
    Duration() => XPathDayTimeDuration.fromDuration(value),
    String() => _parseDayTimeDuration(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDayTimeDuration _parseDayTimeDuration(String value) =>
      XPathDayTimeDuration.tryParse(value) ??
      (throw XPathEvaluationException.unsupportedCast(this, value));

  @override
  String castToString(XPathDayTimeDuration value) {
    if (value.totalMicroseconds == 0) return 'PT0S';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    _writeDayTimePart(buffer, value);
    return buffer.toString();
  }
}

/// The XPath yearMonthDuration type.
const xsYearMonthDuration = _XPathYearMonthDurationType();

class _XPathYearMonthDurationType extends XPathType<XPathYearMonthDuration> {
  const _XPathYearMonthDurationType();

  @override
  String get name => 'xs:yearMonthDuration';

  @override
  bool matches(Object value) => value is XPathYearMonthDuration;

  @override
  XPathYearMonthDuration cast(Object value) => switch (value) {
    XPathYearMonthDuration() => value,
    XPathDuration() => XPathYearMonthDuration(value.totalMonths),
    XPathDayTimeDuration() => const XPathYearMonthDuration(0),
    String() => _parseYearMonthDuration(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathYearMonthDuration _parseYearMonthDuration(String value) =>
      XPathYearMonthDuration.tryParse(value) ??
      (throw XPathEvaluationException.unsupportedCast(this, value));

  @override
  String castToString(XPathYearMonthDuration value) {
    if (value.totalMonths == 0) return 'P0M';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final absYears = value.years;
    final absMonths = value.months;
    if (absYears > 0) buffer.write('${absYears}Y');
    if (absMonths > 0 || absYears == 0) buffer.write('${absMonths}M');
    return buffer.toString();
  }
}
