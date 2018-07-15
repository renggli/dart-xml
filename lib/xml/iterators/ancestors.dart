library xml.iterators.ancestors;

import 'dart:collection';

import 'package:xml/xml/nodes/node.dart';

/// Iterable to walk over the ancestors of a node.
class XmlAncestorsIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlAncestorsIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => new XmlAncestorsIterator(start);
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
