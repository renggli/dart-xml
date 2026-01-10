import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';

extension type const XPathNode(XmlNode _) implements XmlNode {}

extension XPathNodeExtension on Object {
  XPathNode toXPathNode() {
    final self = this;
    if (self is XmlNode) {
      return XPathNode(self);
    } else if (self is Iterable<Object>) {
      if (self.length == 1) {
        final first = self.first;
        if (first is XmlNode) {
          return XPathNode(first);
        }
      }
    }
    XPathEvaluationException.unsupportedCast(self, 'node');
  }
}
