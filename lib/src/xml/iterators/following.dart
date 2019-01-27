library xml.iterators.following;

import 'dart:collection' show IterableBase;

import 'package:xml/src/xml/nodes/attribute.dart';
import 'package:xml/src/xml/nodes/node.dart';

/// Iterable to walk over the followers of a node.
class XmlFollowingIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlFollowingIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => XmlFollowingIterator(start);
}

/// Iterator to walk over the followers of a node.
class XmlFollowingIterator extends Iterator<XmlNode> {
  final List<XmlNode> todo = [];

  XmlFollowingIterator(XmlNode start) {
    final following = <XmlNode>[];
    for (var parent = start.parent, child = start;
        parent != null;
        parent = parent.parent, child = child.parent) {
      if (child is XmlAttribute) {
        final attributesIndex = parent.attributes.indexOf(child);
        following.addAll(parent.attributes.sublist(attributesIndex + 1));
        following.addAll(parent.children);
      } else {
        final childrenIndex = parent.children.indexOf(child);
        following.addAll(parent.children.sublist(childrenIndex + 1));
      }
    }
    todo.addAll(following.reversed);
  }

  @override
  XmlNode current;

  @override
  bool moveNext() {
    if (todo.isEmpty) {
      current = null;
      return false;
    } else {
      current = todo.removeLast();
      todo.addAll(current.children.reversed);
      todo.addAll(current.attributes.reversed);
      return true;
    }
  }
}
