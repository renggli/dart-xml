import '../../xml/nodes/node.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath node type.
const xsNode = XPathTypeDefinition('xs:node', matches: _matches, cast: _cast);

bool _matches(Object item) => item is XmlNode;

XPathSequence _cast(Object item) => item.toXPathNode().toXPathSequence();

extension XPathNodeExtension on Object {
  XmlNode toXPathNode() {
    final self = this;
    if (self is XmlNode) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item is XmlNode) return item;
    }
    throw XPathEvaluationException.unsupportedCast(self, 'node');
  }
}
