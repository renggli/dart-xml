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
  bool matches(Object value) => value is DateTime;

  @override
  DateTime cast(Object value) {
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
