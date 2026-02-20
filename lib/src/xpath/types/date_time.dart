import '../../../xml.dart';

import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

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
      return _parseDateTime(value.trim());
    } else if (value is XmlNode) {
      return _parseDateTime(xsString.cast(value).trim());
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }

  DateTime _parseDateTime(String value) {
    final isoDateTime = DateTime.tryParse(value);
    if (isoDateTime != null) return isoDateTime;
    for (final parser in _dateTimeRegexpList) {
      final match = parser.firstMatch(value);
      if (match != null) {
        final year = match.getGroupOrNull('year') ?? '1970';
        final monthStr = match.getGroupOrNull('month') ?? '01';
        final dayStr = match.getGroupOrNull('day') ?? '01';
        final hourStr = match.getGroupOrNull('hour') ?? '00';
        final minuteStr = match.getGroupOrNull('minute') ?? '00';
        final secondStr = match.getGroupOrNull('second') ?? '00';
        final timezone = match.getGroupOrNull('timezone') ?? '';
        final month = int.parse(monthStr);
        final day = int.parse(dayStr);
        final hour = int.parse(hourStr);
        final minute = int.parse(minuteStr);
        final second = double.parse(secondStr);
        _validateDate(month, day);
        _validateTime(hour, minute, second);
        return DateTime.parse(
          '$year-${_pad(month)}-${_pad(day)}T'
          '${_pad(hour)}:${_pad(minute)}:$secondStr$timezone',
        );
      }
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

extension on RegExpMatch {
  String? getGroupOrNull(String name) =>
      groupNames.contains(name) ? namedGroup(name) : null;
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
  if (hour > 23) throw XPathEvaluationException('Invalid hour: $hour');
  if (minute > 59) throw XPathEvaluationException('Invalid minute: $minute');
  if (second >= 60) throw XPathEvaluationException('Invalid second: $second');
}

String _pad(int value) => value.toString().padLeft(2, '0');

final _dateTimeRegexpList = [
  RegExp(
    r'^(?<year>-?\d{4,})-(?<month>\d{2})-(?<day>\d{2})(?<timezone>Z|[+-]\d{2}:\d{2})?$',
  ),
  RegExp(
    r'^(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}(?:\.\d+)?)(?<timezone>Z|[+-]\d{2}:\d{2})?$',
  ),
  RegExp(r'^(?<year>-?\d{4,})-(?<month>\d{2})(?<timezone>Z|[+-]\d{2}:\d{2})?$'),
  RegExp(r'^(?<year>-?\d{4,})(?<timezone>Z|[+-]\d{2}:\d{2})?$'),
  RegExp(r'^--(?<month>\d{2})-(?<day>\d{2})(?<timezone>Z|[+-]\d{2}:\d{2})?$'),
  RegExp(r'^---(?<day>\d{2})(?<timezone>Z|[+-]\d{2}:\d{2})?$'),
  RegExp(r'^--(?<month>\d{2})(?<timezone>Z|[+-]\d{2}:\d{2})?$'),
];
