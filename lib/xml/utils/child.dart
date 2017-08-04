library xml.utils.child;

import 'package:xml/xml/nodes/node.dart' show XmlNode;

/// Mixin for objects that are a child of a different [XmlNode].
abstract class XmlOwned {
  XmlNode _parent;

  /// Return the parent node of this node, or `null` if there is none.
  XmlNode get parent => _parent;

  /// Return the root of the tree in which this node is found, whether that's
  /// a document or another element.
  XmlNode get root => parent == null ? this : parent.root;

  /// Internal method to adopt a parent node, do not call directly.
  void adoptParent(XmlNode node) {
    if (_parent != null) {
      throw new StateError('Node is already part of node tree.');
    }
    _parent = node;
  }
}
