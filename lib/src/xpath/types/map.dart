import '../exceptions/evaluation_exception.dart';
import 'item.dart';
import 'sequence.dart';

typedef XPathMap = Map<XPathItem, XPathItem>;

extension XPathMapExtension on Object {
  XPathMap toXPathMap() {
    final self = this;
    if (self is XPathMap) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathMap();
    }
    XPathEvaluationException.unsupportedCast(self, 'map');
  }
}
