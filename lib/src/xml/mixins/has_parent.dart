import '../nodes/node.dart';
import '../utils/exceptions.dart';

/// Parent interface for nodes.
mixin XmlParentBase {
  /// Return the parent node of this node, or `null` if there is none.
  XmlNode get parent => null;

  /// Test whether the node has a parent or not.
  bool get hasParent => false;

  /// Replace this node with `other`.
  void replace(XmlNode other) => _noParent();

  /// Internal helper to attach a child to this parent, do not call directly.
  void attachParent(covariant XmlNode parent) => _noParent();

  /// Internal helper to detach a child from its parent, do not call directly.
  void detachParent(covariant XmlNode parent) => _noParent();

  /// Internal helper to throw an exception.
  void _noParent() => throw UnsupportedError('$this does not have a parent.');
}

/// Mixin for nodes with a parent.
mixin XmlHasParent<T extends XmlNode> implements XmlParentBase {
  T _parent;

  @override
  T get parent => _parent;

  @override
  bool get hasParent => parent != null;

  @override
  void replace(XmlNode other) {
    if (hasParent) {
      final siblings = parent.children;
      for (var i = 0; i < siblings.length; i++) {
        if (identical(siblings[i], this)) {
          siblings[i] = other;
          break;
        }
      }
    }
  }

  @override
  void attachParent(T parent) {
    XmlParentException.checkNoParent(this);
    _parent = parent;
  }

  @override
  void detachParent(T parent) {
    XmlParentException.checkMatchingParent(this, parent);
    _parent = null;
  }
}
