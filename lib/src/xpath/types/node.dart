import '../../xml/nodes/node.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

const xsNode = XPathNodeType();

typedef XPathNode = XmlNode;

class XPathNodeType extends XPathItemType {
  const XPathNodeType();

  @override
  bool matches(Object item) => item is XPathNode;

  @override
  XPathSequence cast(Object item) => item.toXPathNode().toXPathSequence();
}

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
