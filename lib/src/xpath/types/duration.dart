import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath duration type.
const xsDuration = _XPathDurationType();

class _XPathDurationType extends XPathType<Duration> {
  const _XPathDurationType();

  @override
  String get name => 'xs:duration';

  @override
  bool matches(Object value) => value is Duration;

  @override
  Duration cast(Object value) {
    if (value is Duration) {
      return value;
    } else if (value is String) {
      return _parseDuration(value);
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _durationRegExp = RegExp(
    r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
  );

  Duration _parseDuration(String value) {
    final match = _durationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    // Reject empty durations where no components are present (e.g. "P" or "PT").
    if (match.group(2) == null &&
        match.group(3) == null &&
        match.group(4) == null &&
        match.group(5) == null &&
        match.group(6) == null &&
        match.group(7) == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final days = int.tryParse(match.group(4) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(5) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(6) ?? '0') ?? 0;
    final seconds = double.tryParse(match.group(7) ?? '0.0') ?? 0.0;
    final duration = Duration(
      days: years * 365 + months * 30 + days,
      hours: hours,
      minutes: minutes,
      microseconds: (seconds * 1000000).round(),
    );
    return negative ? -duration : duration;
  }

  @override
  String castToString(Duration value) {
    if (value.inMicroseconds == 0) return 'PT0S';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final duration = value.abs();
    final totalDays = duration.inDays;
    final months = totalDays ~/ 30;
    final years = months ~/ 12;
    final remainingMonths = months.remainder(12);
    final days = totalDays.remainder(30);

    if (years > 0) buffer.write('${years}Y');
    if (remainingMonths > 0) buffer.write('${remainingMonths}M');
    if (days > 0) buffer.write('${days}D');
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds =
        duration.inMicroseconds.remainder(1000000) / 1000000 +
        duration.inSeconds.remainder(60);
    if (hours > 0 || minutes > 0 || seconds > 0) {
      buffer.write('T');
      if (hours > 0) buffer.write('${hours}H');
      if (minutes > 0) buffer.write('${minutes}M');
      if (seconds > 0) {
        final string = seconds.toString();
        buffer.write(
          string.endsWith('.0')
              ? string.substring(0, string.length - 2)
              : string,
        );
        buffer.write('S');
      }
    }
    return buffer.toString();
  }
}

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
    if (value is XPathDayTimeDuration) {
      return value;
    } else if (value is XPathYearMonthDuration) {
      return XPathDayTimeDuration(const Duration());
    } else if (value is Duration) {
      return XPathDayTimeDuration(value);
    } else if (value is String) {
      return _parseDayTimeDuration(value);
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _dayTimeDurationRegExp = RegExp(
    r'^(-)?P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
  );

  XPathDayTimeDuration _parseDayTimeDuration(String value) {
    final match = _dayTimeDurationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    if (match.group(2) == null &&
        match.group(3) == null &&
        match.group(4) == null &&
        match.group(5) == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    final negative = match.group(1) == '-';
    final days = int.tryParse(match.group(2) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(3) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(4) ?? '0') ?? 0;
    final seconds = double.tryParse(match.group(5) ?? '0.0') ?? 0.0;
    final duration = Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      microseconds: (seconds * 1000000).round(),
    );
    return XPathDayTimeDuration(negative ? -duration : duration);
  }

  @override
  String castToString(XPathDayTimeDuration value) {
    if (value.inMicroseconds == 0) return 'PT0S';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final duration = value.abs();
    final days = duration.inDays;
    if (days > 0) buffer.write('${days}D');
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds =
        duration.inMicroseconds.remainder(1000000) / 1000000 +
        duration.inSeconds.remainder(60);
    if (hours > 0 || minutes > 0 || seconds > 0) {
      buffer.write('T');
      if (hours > 0) buffer.write('${hours}H');
      if (minutes > 0) buffer.write('${minutes}M');
      if (seconds > 0) {
        final string = seconds.toString();
        buffer.write(
          string.endsWith('.0')
              ? string.substring(0, string.length - 2)
              : string,
        );
        buffer.write('S');
      }
    }
    return buffer.toString();
  }
}

class XPathDayTimeDuration extends _XPathDurationWrapper {
  @override
  final Duration _duration;

  XPathDayTimeDuration(this._duration);

  @override
  Duration _create(Duration duration) => XPathDayTimeDuration(duration);
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
  XPathYearMonthDuration cast(Object value) {
    if (value is XPathYearMonthDuration) {
      return value;
    } else if (value is XPathDayTimeDuration) {
      return XPathYearMonthDuration(const Duration());
    } else if (value is Duration) {
      final days = value.abs().inDays;
      final months = days ~/ 30;
      final duration =
          Duration(days: months * 30) * (value.isNegative ? -1 : 1);
      return XPathYearMonthDuration(duration);
    } else if (value is String) {
      return _parseYearMonthDuration(value);
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  static final _yearMonthDurationRegExp = RegExp(
    r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?$',
  );

  XPathYearMonthDuration _parseYearMonthDuration(String value) {
    final match = _yearMonthDurationRegExp.firstMatch(value);
    if (match == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    if (match.group(2) == null && match.group(3) == null) {
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    final negative = match.group(1) == '-';
    final years = int.tryParse(match.group(2) ?? '0') ?? 0;
    final months = int.tryParse(match.group(3) ?? '0') ?? 0;
    final duration = Duration(days: years * 365 + months * 30);
    return XPathYearMonthDuration(negative ? -duration : duration);
  }

  @override
  String castToString(XPathYearMonthDuration value) {
    if (value.inMicroseconds == 0) return 'P0M';
    final buffer = StringBuffer(value.isNegative ? '-P' : 'P');
    final duration = value.abs();
    final months = duration.inDays ~/ 30;
    final years = months ~/ 12;
    final remainingMonths = months.remainder(12);
    if (years > 0) buffer.write('${years}Y');
    if (remainingMonths > 0 || years == 0) {
      buffer.write('${remainingMonths}M');
    }
    return buffer.toString();
  }
}

class XPathYearMonthDuration extends _XPathDurationWrapper {
  @override
  final Duration _duration;

  XPathYearMonthDuration(this._duration);

  @override
  Duration _create(Duration duration) => XPathYearMonthDuration(duration);
}

// Internal
abstract class _XPathDurationWrapper implements Duration {
  Duration get _duration;
  Duration _create(Duration duration);

  @override
  int get inDays => _duration.inDays;

  @override
  int get inHours => _duration.inHours;

  @override
  int get inMinutes => _duration.inMinutes;

  @override
  int get inSeconds => _duration.inSeconds;

  @override
  int get inMilliseconds => _duration.inMilliseconds;

  @override
  int get inMicroseconds => _duration.inMicroseconds;

  @override
  bool get isNegative => _duration.isNegative;

  @override
  int compareTo(Duration other) =>
      _duration.compareTo(Duration(microseconds: other.inMicroseconds));

  @override
  Duration abs() => _create(_duration.abs());

  @override
  Duration operator +(Duration other) =>
      _create(_duration + Duration(microseconds: other.inMicroseconds));

  @override
  Duration operator -(Duration other) =>
      _create(_duration - Duration(microseconds: other.inMicroseconds));

  @override
  Duration operator *(num factor) => _create(_duration * factor);

  @override
  Duration operator ~/(int quotient) => _create(_duration ~/ quotient);

  @override
  bool operator <(Duration other) =>
      _duration < Duration(microseconds: other.inMicroseconds);

  @override
  bool operator <=(Duration other) =>
      _duration <= Duration(microseconds: other.inMicroseconds);

  @override
  bool operator >(Duration other) =>
      _duration > Duration(microseconds: other.inMicroseconds);

  @override
  bool operator >=(Duration other) =>
      _duration >= Duration(microseconds: other.inMicroseconds);

  @override
  Duration operator -() => _create(-_duration);

  @override
  int get hashCode => _duration.hashCode;

  @override
  bool operator ==(Object other) => other is Duration && _duration == other;

  @override
  String toString() => _duration.toString();
}
