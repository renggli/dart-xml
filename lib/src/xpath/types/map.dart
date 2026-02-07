import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath map type.
const xsMap = _XPathMapType();

typedef XPathMap = Map<Object, Object>;

class _XPathMapType extends XPathType<XPathMap> {
  const _XPathMapType();

  @override
  String get name => 'map(*)';

  @override
  bool matches(Object value) => value is XPathMap;

  @override
  XPathMap cast(Object value) {
    if (value is XPathMap) {
      return value;
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
