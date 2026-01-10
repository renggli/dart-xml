import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathMap(Map<Object, Object> _)
    implements Map<Object, Object> {}

extension XPathMapExtension on Object {
  XPathMap toXPathMap() {
    final self = this;
    if (self is Map<Object, Object>) {
      return XPathMap(self);
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathMap();
    }
    XPathEvaluationException.unsupportedCast(self, 'map');
  }
}
