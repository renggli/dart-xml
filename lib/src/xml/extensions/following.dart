import 'dart:collection';

import '../nodes/attribute.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';

extension XmlFollowingExtension on XmlNode {
  /// A lazy [Iterable] of the nodes following this node in document order.
  Iterable<XmlNode> get following => XmlFollowingIterable(this);

  /// A lazy [Iterable] of the [XmlElement] nodes following this node in
  /// document order.
  Iterable<XmlElement> get followingElements =>
      following.whereType<XmlElement>();
}

/// Iterable to walk over the followers of a node.
class XmlFollowingIterable extends IterableBase<XmlNode> {
  new(this._start);

  final XmlNode _start;

  @override
  Iterator<XmlNode> get iterator => XmlFollowingIterator(_start);
}

/// Iterator to walk over the followers of a node.
class XmlFollowingIterator implements Iterator<XmlNode> {
  new(XmlNode start) {
    final ancestors = <(XmlNode, XmlNode)>[];
    for (
      var parent = start.parent, child = start;
      parent != null;
      parent = parent.parent, child = child.parent!
    ) {
      ancestors.add((parent, child));
    }
    for (final (parent, child) in ancestors.reversed) {
      if (child is XmlAttribute) {
        final children = parent.children;
        for (var i = children.length - 1; i >= 0; i--) {
          _todo.add(children[i]);
        }
        final attributes = parent.attributes;
        final attributesIndex = attributes.indexOf(child);
        for (var i = attributes.length - 1; i > attributesIndex; i--) {
          _todo.add(attributes[i]);
        }
      } else {
        final children = parent.children;
        final childrenIndex = children.indexOf(child);
        for (var i = children.length - 1; i > childrenIndex; i--) {
          _todo.add(children[i]);
        }
      }
    }
  }

  final List<XmlNode> _todo = [];
  XmlNode? _current;

  @override
  XmlNode get current => _current!;

  @override
  bool moveNext() {
    if (_todo.isEmpty) {
      _current = null;
      return false;
    } else {
      _current = _todo.removeLast();
      _todo.addAll(_current!.children.reversed);
      _todo.addAll(_current!.attributes.reversed);
      return true;
    }
  }
}
