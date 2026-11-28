import 'dart:collection';

import '../nodes/element.dart';
import '../nodes/node.dart';

extension XmlDescendantsExtension on XmlNode {
  /// A lazy [Iterable] of the descendants of this node in document order.
  Iterable<XmlNode> get descendants => XmlDescendantsIterable(this);

  /// A lazy [Iterable] of the descendant [XmlElement] nodes of this node in
  /// document order.
  Iterable<XmlElement> get descendantElements =>
      descendants.whereType<XmlElement>();
}

/// Iterable to walk over the descendants of a node.
class XmlDescendantsIterable extends IterableBase<XmlNode> {
  new(this._start);

  final XmlNode _start;

  @override
  Iterator<XmlNode> get iterator => XmlDescendantsIterator(_start);
}

/// Iterator to walk over the descendants of a node.
class XmlDescendantsIterator implements Iterator<XmlNode> {
  new(XmlNode start) {
    push(start);
  }

  final List<XmlNode> _todo = [];
  late XmlNode _current;

  void push(XmlNode node) {
    // Push in reverse order so the LIFO stack still walks document order,
    // without allocating reversed-iterable wrappers for every node.
    final children = node.children;
    for (var i = children.length - 1; i >= 0; i--) {
      _todo.add(children[i]);
    }
    final attributes = node.attributes;
    for (var i = attributes.length - 1; i >= 0; i--) {
      _todo.add(attributes[i]);
    }
  }

  @override
  XmlNode get current => _current;

  @override
  bool moveNext() {
    if (_todo.isEmpty) {
      return false;
    } else {
      _current = _todo.removeLast();
      push(_current);
      return true;
    }
  }
}
