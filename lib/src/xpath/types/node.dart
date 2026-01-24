import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

typedef XPathNode = XmlNode;

extension XPathNodeExtension on Object {
  XPathNode toXPathNode() {
    final self = this;
    if (self is XmlNode) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item is XmlNode) return item;
    }
    XPathEvaluationException.unsupportedCast(self, 'node');
  }
}
