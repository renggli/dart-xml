import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath dateTime type.
const xsDateTime = _XPathDateTimeType();

class _XPathDateTimeType extends XPathType<DateTime> {
  const _XPathDateTimeType() : super();

  @override
  String get name => 'xs:dateTime';

  @override
  Iterable<String> get aliases => const [
    'xs:date',
    'xs:dateTimeStamp',
    'xs:gDay',
    'xs:gMonth',
    'xs:gMonthDay',
    'xs:gYear',
    'xs:gYearMonth',
    'xs:time',
  ];

  @override
  bool matches(Object value) => value is DateTime;

  @override
  DateTime cast(Object value) {
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      return _parseDateTime(value);
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  DateTime _parseDateTime(String value) {
    final isoDateTime = DateTime.tryParse(value);
    if (isoDateTime != null) return isoDateTime;
    // Handle xs:date format: YYYY-MM-DD with optional timezone
    // Examples: 1970-01-01Z, 2002-03-07-05:00
    final dateMatch = _dateRegExp.firstMatch(value);
    if (dateMatch != null) {
      final year = dateMatch.group(1)!;
      final month = int.parse(dateMatch.group(2)!);
      final day = int.parse(dateMatch.group(3)!);
      final timezone = dateMatch.group(4) ?? '';
      _validateDate(month, day);
      return DateTime.parse(
        '$year-${_pad(month)}-${_pad(day)}T00:00:00$timezone',
      );
    }
    // Handle xs:time format: HH:MM:SS with optional timezone
    // Examples: 00:00:00Z, 13:20:00+05:00, 12:01:01.123
    final timeMatch = _timeRegExp.firstMatch(value);
    if (timeMatch != null) {
      final hour = int.parse(timeMatch.group(1)!);
      final minute = int.parse(timeMatch.group(2)!);
      final secondStr = timeMatch.group(3)!;
      final second = double.parse(secondStr);
      final timezone = timeMatch.group(4) ?? '';
      _validateTime(hour, minute, second);
      return DateTime.parse(
        '1970-01-01T${_pad(hour)}:${_pad(minute)}:'
        '$secondStr$timezone',
      );
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  void _validateDate(int month, int day) {
    if (month < 1 || month > 12) {
      throw XPathEvaluationException('Invalid month: $month');
    }
    if (day < 1 || day > 31) {
      throw XPathEvaluationException('Invalid day: $day');
    }
  }

  void _validateTime(int hour, int minute, double second) {
    if (hour > 23) {
      throw XPathEvaluationException('Invalid hour: $hour');
    }
    if (minute > 59) {
      throw XPathEvaluationException('Invalid minute: $minute');
    }
    if (second >= 60) {
      throw XPathEvaluationException('Invalid second: $second');
    }
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}

final _dateRegExp = RegExp(r'^(-?\d{4,})-(\d{2})-(\d{2})(Z|[+-]\d{2}:\d{2})?$');
final _timeRegExp = RegExp(
  r'^(\d{2}):(\d{2}):(\d{2}(?:\.\d+)?)(Z|[+-]\d{2}:\d{2})?$',
);
