library xml.utils.owned;

import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/utils/exceptions.dart';

/// Mixin for objects that are a child of a different [XmlNode].
mixin XmlOwned {
  XmlNode _parent;

  /// Return the parent node of this node, or `null` if there is none.
  XmlNode get parent => _parent;

  /// Return the root of the tree in which this node is found, whether that's
  /// a document or another element.
  XmlNode get root => hasParent ? parent.root : this;

  /// Test whether the node has a parent or not.
  bool get hasParent => parent != null;

  /// Internal method to attach a child to this parent, do not call directly.
  void attachParent(XmlNode parent) {
    XmlParentException.checkNoParent(this);
    _parent = parent;
  }

  /// Internal method to attach a child to this parent, do not call directly.
  void detachParent(XmlNode parent) {
    _parent = null;
  }
}
