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
  final XmlNode _start;

  XmlPrecedingIterable(this._start);

  @override
  Iterator<XmlNode> get iterator => XmlPrecedingIterator(_start);
}

/// Iterator to walk over the precedents of a node.
class XmlPrecedingIterator extends Iterator<XmlNode> {
  final XmlNode _start;
  final List<XmlNode> _todo = [];
  XmlNode? _current;

  XmlPrecedingIterator(this._start) {
    _todo.add(_start.root);
  }

  @override
  XmlNode get current => _current!;

  @override
  bool moveNext() {
    if (_todo.isEmpty) {
      _current = null;
      return false;
    } else {
      _current = _todo.removeLast();
      if (identical(_current, _start)) {
        _current = null;
        _todo.clear();
        return false;
      }
      _todo.addAll(_current!.children.reversed);
      _todo.addAll(_current!.attributes.reversed);
      return true;
    }
  }
}
