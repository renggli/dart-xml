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
      final month = dateMatch.group(2)!;
      final day = dateMatch.group(3)!;
      final timezone = dateMatch.group(4) ?? '';
      return DateTime.parse('$year-$month-${day}T00:00:00$timezone');
    }
    // Handle xs:time format: HH:MM:SS with optional timezone
    // Examples: 00:00:00Z, 13:20:00+05:00, 12:01:01.123
    final timeMatch = _timeRegExp.firstMatch(value);
    if (timeMatch != null) {
      final hour = timeMatch.group(1)!;
      final minute = timeMatch.group(2)!;
      final second = timeMatch.group(3)!;
      final timezone = timeMatch.group(4) ?? '';
      return DateTime.parse('1970-01-01T$hour:$minute:$second$timezone');
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

final _dateRegExp = RegExp(r'^(-?\d{4,})-(\d{2})-(\d{2})(Z|[+-]\d{2}:\d{2})?$');
final _timeRegExp = RegExp(
  r'^(\d{2}):(\d{2}):(\d{2}(?:\.\d+)?)(Z|[+-]\d{2}:\d{2})?$',
);
