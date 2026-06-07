import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/map.dart';
import '../values/sequence.dart';

/// The XPath map type.
const xsMap = _XPathMapType();

class _XPathMapType extends XPathType<XPathMap> {
  const _XPathMapType();

  @override
  String get name => 'map(*)';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) => value is Map;

  @override
  XPathMap cast(Object value) => switch (value) {
    XPathMap() => value,
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };
}
