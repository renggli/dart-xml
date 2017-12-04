library xml.utils.errors;

import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;

class XmlNodeTypeError extends ArgumentError {

  static void checkValidType(XmlNode node, Iterable<XmlNodeType> validTypes) {
    if (!validTypes.contains(node.nodeType)) {
      throw new XmlNodeTypeError('Expected node of type: $validTypes');
    }
  }

  XmlNodeTypeError(String message) : super(message);
}

class XmlParentError extends ArgumentError {

  static void checkAttached(XmlNode parent, XmlNode child) {
    if (child.parent == parent) {
      throw new XmlParentError('Nodes does not have a parent: $child');
    }
  }

  static void checkDetached(XmlNode node) {
    if (node.hasParent) {
      throw new XmlParentError('Nodes does not have a parent: $node');
    }
  }

  XmlParentError(String message) : super(message);
}
