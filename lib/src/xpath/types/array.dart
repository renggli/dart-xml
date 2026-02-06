import '../definitions/types.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath array type.
const xsArray = _XPathArrayType();

typedef XPathArray = List<Object>;

class _XPathArrayType extends XPathType<XPathArray> {
  const _XPathArrayType();

  @override
  String get name => 'array(*)';

  @override
  bool matches(Object value) => value is XPathArray;

  @override
  XPathArray cast(Object value) {
    if (value is XPathArray) {
      return value;
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
