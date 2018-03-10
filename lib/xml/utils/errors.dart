library xml.utils.errors;

import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/utils/owned.dart' show XmlOwned;

class XmlNodeTypeError extends ArgumentError {
  /// Ensure that [node] is not null.
  static void checkNotNull(XmlNode node) {
    if (node == null) {
      throw new XmlNodeTypeError('Node must not be null.');
    }
  }

  /// Ensure that [node] is of one of the provided [types].
  static void checkValidType(XmlNode node, Iterable<XmlNodeType> types) {
    if (!types.contains(node.nodeType)) {
      throw new XmlNodeTypeError('Expected node of type: $types');
    }
  }

  XmlNodeTypeError(String message) : super(message);
}

class XmlParentError extends ArgumentError {
  /// Ensure that [owned] has no parent.
  static void checkNoParent(XmlOwned owned) {
    if (owned.hasParent) {
      throw new XmlParentError(
          'Node already has a parent, copy or remove it first: $owned');
    }
  }

  XmlParentError(String message) : super(message);
}
