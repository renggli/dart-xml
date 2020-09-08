import 'dart:collection';

import '../nodes/node.dart';

extension XmlAncestorsExtension on XmlNode {
  /// Return a lazy [Iterable] of the ancestors of this [XmlNode] (parent,
  /// grandparent, ...) in reverse document order.
  Iterable<XmlNode> get ancestors => XmlAncestorsIterable(this);
}

/// Iterable to walk over the ancestors of a node.
class XmlAncestorsIterable extends IterableBase<XmlNode> {
  final XmlNode _start;

  XmlAncestorsIterable(this._start);

  @override
  Iterator<XmlNode> get iterator => XmlAncestorsIterator(_start);
}

/// Iterator to walk over the ancestors of a node.
class XmlAncestorsIterator extends Iterator<XmlNode> {
  XmlNode? _current;

  XmlAncestorsIterator(this._current);

  @override
  XmlNode get current => _current!;

  @override
  bool moveNext() {
    if (_current != null) {
      _current = _current!.parent;
    }
    return _current != null;
  }
}
