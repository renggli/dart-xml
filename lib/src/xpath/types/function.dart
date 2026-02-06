import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'item.dart';
import 'number.dart';

/// The XPath function type.
const xsFunction = XPathTypeDefinition(
  'function(*)',
  matches: _matches,
  cast: _cast,
);

bool _matches(Object item) => item is XPathFunction;

XPathSequence _cast(Object item) => item.toXPathFunction().toXPathSequence();

/// An XPath function.
typedef XPathFunction =
    XPathSequence Function(XPathContext context, List<XPathSequence> arguments);

extension XPathFunctionExtension on Object {
  XPathFunction toXPathFunction() {
    final self = this;
    if (self is XPathFunction) {
      return self;
    } else if (self is List<Object>) {
      // Arrays are functions
      return (context, arguments) {
        if (arguments.length != 1) {
          throw XPathEvaluationException(
            'Array as function expects exactly 1 argument, but got ${arguments.length}',
          );
        }
        final index = arguments[0].toXPathNumber().toInt();
        if (index < 1 || index > self.length) {
          throw XPathEvaluationException('Array index out of bounds: $index');
        }
        return self[index - 1].toXPathSequence();
      };
    } else if (self is Map<Object, Object>) {
      // Maps are functions
      return (context, arguments) {
        if (arguments.length != 1) {
          throw XPathEvaluationException(
            'Map as function expects exactly 1 argument, but got ${arguments.length}',
          );
        }
        final key = arguments[0].toAtomicValue();
        return self[key]?.toXPathSequence() ?? XPathSequence.empty;
      };
    } else if (self is Function) {
      if (self is XPathFunction) return self;
      return (context, arguments) {
        final positionalArguments = [context, ...arguments];
        return Function.apply(self, positionalArguments) as XPathSequence;
      };
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathFunction();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'function(*)');
  }
}
