import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/function.dart';
import '../values/sequence.dart';
import 'array.dart';
import 'map.dart';

/// The XPath function type.
const xsFunction = _XPathFunctionType();

class _XPathFunctionType extends XPathType<XPathFunction> {
  const _XPathFunctionType();

  @override
  String get name => 'function(*)';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) =>
      value is XPathFunction ||
      value is Function ||
      value is Map ||
      value is List;

  @override
  XPathFunction cast(Object value) => switch (value) {
    XPathFunction() => value,
    Function() => value.toXPathFunction(),
    List() => XPathArrayFunction(xsArray.cast(value)),
    Map() => XPathMapFunction(xsMap.cast(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };
}
