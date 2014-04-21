part of xml;

/**
 * A iterable customizable iterator over parts of the [XmlNode] tree.
 */
class XmlNodeIterable extends IterableBase<XmlNode> {

  final XmlNode _root;

  XmlNodeIterable(this._root);

  @override
  Iterator<XmlNode> get iterator => new XmlNodeIterator(_root);

}

/**
 * Iterator over XML sub-trees of nodes and attributes.
 */
class XmlNodeIterator extends Iterator<XmlNode> {

  final List<XmlNode> _todo = new List();

  XmlNodeIterator(XmlNode root) {
    _push(root);
  }

  void _push(XmlNode node) {
    _todo.addAll(node.children.reversed);
    _todo.addAll(node.attributes.reversed);
  }

  @override
  XmlNode current;

  @override
  bool moveNext() {
    if (_todo.isEmpty) {
      return false;
    } else {
      current = _todo.removeLast();
      _push(current);
      return true;
    }
  }

}
