import 'dart:collection';

import '../nodes/node.dart';

extension XmlAncestorsExtension on XmlNode {
  /// Return a lazy [Iterable] of the ancestors of this [XmlNode] (parent,
  /// grandparent, ...) in reverse document order.
  Iterable<XmlNode> get ancestors => XmlAncestorsIterable(this);
}

/// Iterable to walk over the ancestors of a node.
class XmlAncestorsIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlAncestorsIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => XmlAncestorsIterator(start);
}

/// Iterator to walk over the ancestors of a node.
class XmlAncestorsIterator extends Iterator<XmlNode> {
  XmlAncestorsIterator(this.current);

  @override
  XmlNode current;

  @override
  bool moveNext() {
    if (current != null) {
      current = current.parent;
    }
    return current != null;
  }
}
