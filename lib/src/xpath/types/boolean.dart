import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/sequence.dart';

/// The XPath boolean type.
const xsBoolean = _XPathBooleanType();

class _XPathBooleanType extends XPathType<bool> {
  const _XPathBooleanType();

  @override
  String get name => 'xs:boolean';

  @override
  bool matches(Object value) => value is bool;

  @override
  bool cast(Object value) => switch (value) {
    bool() => value,
    num() => value != 0 && !value.isNaN,
    String() => _parseBoolean(value.trim()),
    XPathSequence() => _castSequence(value),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  bool _parseBoolean(String trimmed) {
    if (trimmed == 'true' || trimmed == '1') return true;
    if (trimmed == 'false' || trimmed == '0') return false;
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  bool _castSequence(XPathSequence sequence) {
    final atomic = sequence.toAtomicValue();
    if (atomic is! XPathSequence) return cast(atomic);
    throw XPathEvaluationException.unsupportedCast(this, sequence);
  }

  @override
  String castToString(bool value) => value ? 'true' : 'false';
}
