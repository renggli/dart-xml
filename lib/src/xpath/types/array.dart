import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/array.dart';
import '../values/sequence.dart';

/// The XPath array type.
const xsArray = _XPathArrayType();

class _XPathArrayType extends XPathType<XPathArray> {
  const _XPathArrayType();

  @override
  String get name => 'array(*)';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) => value is List;

  @override
  XPathArray cast(Object value) => switch (value) {
    XPathArray() => value,
    List() => value.cast<Object>().map((e) => XPathSequence([e])).toList(),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };
}
