import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath boolean type.
const xsBoolean = _XPathBooleanType();

class _XPathBooleanType extends XPathType<bool> {
  const _XPathBooleanType();

  @override
  String get name => 'xs:boolean';

  @override
  bool matches(Object value) => value is bool;

  @override
  bool cast(Object value) {
    if (value is bool) {
      return value;
    } else if (value is num) {
      return value != 0 && !value.isNaN;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed == 'true' || trimmed == '1') return true;
      if (trimmed == 'false' || trimmed == '0') return false;
    } else if (value is XPathSequence) {
      final atomic = value.toAtomicValue();
      if (atomic is! XPathSequence) return cast(atomic);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
