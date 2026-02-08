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
  Iterable<String> get aliases => const [
    'xs:dayTimeDuration',
    'xs:yearMonthDuration',
  ];

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

  Duration _parseDuration(String value) {
    final match = _durationRegExp.firstMatch(value);
    if (match == null) {
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
}

final _durationRegExp = RegExp(
  r'^(-)?P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
);
