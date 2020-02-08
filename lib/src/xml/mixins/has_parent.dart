library xml.mixins.has_parent;

import '../nodes/node.dart';
import '../utils/exceptions.dart';

/// Interface for elements with a parent.
mixin XmlParentBase {
  /// Return the parent node of this node, or `null` if there is none.
  XmlNode get parent => null;

  /// Test whether the node has a parent or not.
  bool get hasParent => false;

  /// Internal method to attach a child to this parent, do not call directly.
  void attachParent(covariant XmlNode parent) =>
      throw UnsupportedError('$this does not have parents.');

  /// Internal method to detach a child from its parent, do not call directly.
  void detachParent(covariant XmlNode parent) =>
      throw UnsupportedError('$this does not have parents.');
}

/// Mixin for nodes with a parent.
mixin XmlHasParent<T extends XmlNode> implements XmlParentBase {
  T _parent;

  @override
  T get parent => _parent;

  @override
  bool get hasParent => parent != null;

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
