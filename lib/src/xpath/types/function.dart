import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../functions/array.dart';
import '../functions/map.dart';
import 'array.dart';
import 'map.dart';
import 'sequence.dart';

typedef XPathFunction =
    XPathSequence Function(XPathContext context, List<XPathSequence> arguments);

extension XPathFunctionExtension on Object {
  XPathFunction toXPathFunction() {
    final self = this;
    if (self is XPathFunction) {
      return self;
    } else if (self is XPathArray) {
      return (context, arguments) =>
          arrayGet(context, [XPathSequence.single(self), ...arguments]);
    } else if (self is XPathMap) {
      return (context, arguments) =>
          mapGet(context, [XPathSequence.single(self), ...arguments]);
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathFunction();
    }
    XPathEvaluationException.unsupportedCast(self, 'function(*)');
  }
}
