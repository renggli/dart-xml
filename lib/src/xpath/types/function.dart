import '../definitions/type.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import 'array.dart';
import 'map.dart';
import 'number.dart';
import 'sequence.dart';

/// The XPath function type.
const xsFunction = _XPathFunctionType();

typedef XPathFunction =
    XPathSequence Function(XPathContext context, List<XPathSequence> arguments);

class _XPathFunctionType extends XPathType<XPathFunction> {
  const _XPathFunctionType();

  @override
  String get name => 'function(*)';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) =>
      value is XPathFunction || value is Map || value is List;

  @override
  XPathFunction cast(Object value) => switch (value) {
    XPathFunction() => value,
    List() => _castArray(value),
    Map() => _castMap(value),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathFunction _castArray(List<dynamic> value) {
    final array = xsArray.cast(value);
    return (context, List<XPathSequence> arguments) {
      if (arguments.length != 1) {
        throw XPathEvaluationException(
          'Arrays expect exactly 1 argument, but got ${arguments.length}',
        );
      }
      final index = xsInteger.cast(arguments.single);
      if (index < 1 || index > array.length) {
        throw XPathEvaluationException('Array index out of bounds: $index');
      }
      return xsSequence.cast(array[index - 1]);
    };
  }

  XPathFunction _castMap(Map<dynamic, dynamic> value) {
    final map = xsMap.cast(value);
    return (context, arguments) {
      if (arguments.length != 1) {
        throw XPathEvaluationException(
          'Maps expects exactly 1 argument, but got ${arguments.length}',
        );
      }
      final key = arguments[0].toAtomicValue();
      final result = map[key];
      return result != null ? xsSequence.cast(result) : XPathSequence.empty;
    };
  }
}
