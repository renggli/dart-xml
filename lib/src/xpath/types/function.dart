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
  XPathFunction cast(Object value) {
    if (value is XPathFunction) {
      return value;
    } else if (value is List) {
      // Arrays are functions
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
    } else if (value is Map) {
      // Maps are functions
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
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
