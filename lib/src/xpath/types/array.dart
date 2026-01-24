import '../exceptions/evaluation_exception.dart';
import 'item.dart';
import 'sequence.dart';

typedef XPathArray = List<XPathItem>;

extension XPathArrayExtension on Object {
  XPathArray toXPathArray() {
    final self = this;
    if (self is XPathArray) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathArray();
    }
    XPathEvaluationException.unsupportedCast(self, 'array');
  }
}
