import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';

extension type const XPathNode(XmlNode _value) implements XmlNode {}

extension XPathNodeExtension on Object {
  XPathNode toXPathNode() {
    final self = this;
    if (self is XmlNode) {
      return XPathNode(self);
    } else if (self is Iterable) {
      if (self.length == 1) {
        final first = self.first;
        if (first is XmlNode) {
          return XPathNode(first);
        }
      }
    }
    throw XPathEvaluationException(
      'Unsupported type for node casting: ${self.runtimeType}',
    );
  }
}
