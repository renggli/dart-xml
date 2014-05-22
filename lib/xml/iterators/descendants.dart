part of xml;

class _XmlDescendantsIterable extends IterableBase<XmlNode> {

  final XmlNode start;

  _XmlDescendantsIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => new _XmlDescendantsIterator(start);

}

class _XmlDescendantsIterator extends Iterator<XmlNode> {

  final List<XmlNode> todo = new List();

  _XmlDescendantsIterator(XmlNode start) {
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