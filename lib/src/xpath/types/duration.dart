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
    final absYears = value.years;
    final absMonths = value.months;
    if (absYears > 0) buffer.write('${absYears}Y');
    if (absMonths > 0 || absYears == 0) buffer.write('${absMonths}M');
    return buffer.toString();
  }
}
