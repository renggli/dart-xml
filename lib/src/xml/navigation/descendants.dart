import 'dart:collection';

import '../nodes/node.dart';

extension XmlDescendantsExtension on XmlNode {
  /// Return a lazy [Iterable] of the descendants of this [XmlNode] (attributes,
  /// children, grandchildren, ...) in document order.
  Iterable<XmlNode> get descendants => XmlDescendantsIterable(this);
}

/// Iterable to walk over the descendants of a node.
class XmlDescendantsIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlDescendantsIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => XmlDescendantsIterator(start);
}

/// Iterator to walk over the descendants of a node.
class XmlDescendantsIterator extends Iterator<XmlNode> {
  final List<XmlNode> todo = [];

  XmlDescendantsIterator(XmlNode start) {
    push(start);
  }

  void push(XmlNode node) {
    todo.addAll(node.children.reversed);
    todo.addAll(node.attributes.reversed);
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
      push(current);
      return true;
    }
  }
}
