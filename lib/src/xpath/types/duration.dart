import '../definitions/types.dart';
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
      // TODO: Implement duration parsing from string
      throw UnimplementedError('Duration from string "$value"');
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
