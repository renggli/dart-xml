import 'dart:collection';

import '../nodes/node.dart';
import 'parent.dart';

extension XmlPrecedingExtension on XmlNode {
  /// Return a lazy [Iterable] of the nodes preceding this [XmlNode] in
  /// document order.
  Iterable<XmlNode> get preceding => XmlPrecedingIterable(this);
}

/// Iterable to walk over the precedents of a node.
class XmlPrecedingIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlPrecedingIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => XmlPrecedingIterator(start);
}

/// Iterator to walk over the precedents of a node.
class XmlPrecedingIterator extends Iterator<XmlNode> {
  final XmlNode start;
  final List<XmlNode> todo = [];

  XmlPrecedingIterator(this.start) {
    todo.add(start.root);
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
      if (identical(current, start)) {
        current = null;
        todo.clear();
        return false;
      }
      todo.addAll(current.children.reversed);
      todo.addAll(current.attributes.reversed);
      return true;
    }
  }
}
