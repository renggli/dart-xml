import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathArray(List<Object> _) implements List<Object> {}

extension XPathArrayExtension on Object {
  XPathArray toXPathArray() {
    final self = this;
    if (self is List<Object>) {
      return XPathArray(self);
    } else if (self is List) {
      return XPathArray(self.cast<Object>());
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathArray();
    }
    XPathEvaluationException.unsupportedCast(self, 'array');
  }
}
