library xml.utils.owned;

import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/utils/exceptions.dart';

/// Interface for objects that are a child of a different [XmlNode].
abstract class XmlOwned {
  /// Return the parent node of this node, or `null` if there is none.
  XmlNode get parent;

  /// Return the root of the tree in which this node is found, whether that's
  /// a document or another element.
  XmlNode get root;

  /// Test whether the node has a parent or not.
  bool get hasParent;

  /// Return the document that contains this node, or `null` if the node is
  /// not library a document.
  XmlDocument get document;

  /// Return the depth of this node in its tree, a root node has depth 0.
  int get depth;

  /// Internal method to attach a child to this parent, do not call directly.
  void attachParent(covariant XmlNode parent);

  /// Internal method to attach a child to this parent, do not call directly.
  void detachParent(covariant XmlNode parent);
}

/// Internal mixin for objects that are a child of a different [XmlNode].
mixin XmlOwnedMixin<T extends XmlNode> implements XmlOwned {
  T _parent;

  @override
  T get parent => _parent;

  @override
  XmlNode get root => hasParent ? _parent.root : this;

  @override
  bool get hasParent => _parent != null;

  @override
  XmlDocument get document => _parent?.document;

  @override
  int get depth => _parent == null ? 0 : _parent.depth + 1;

  @override
  void attachParent(T parent) {
    XmlParentException.checkNoParent(this);
    _parent = parent;
  }

  @override
  void detachParent(T parent) {
    _parent = null;
  }
}
