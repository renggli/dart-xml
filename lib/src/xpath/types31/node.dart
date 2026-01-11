import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathNode(XmlNode _) implements XmlNode {}

extension XPathNodeExtension on Object {
  XPathNode toXPathNode() {
    final self = this;
    if (self is XmlNode) {
      return XPathNode(self);
    } else if (self is XPathSequence) {
      final iterator = self.singleOrNull;
      if (iterator is XmlNode) {
        return XPathNode(iterator);
      }
    }
    XPathEvaluationException.unsupportedCast(self, 'node');
  }
}
