part of xml;

class _XmlAncestorsIterable extends IterableBase<XmlNode> {

  final XmlNode start;

  _XmlAncestorsIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => new _XmlAncestorsIterator(start);

}

class _XmlAncestorsIterator extends Iterator<XmlNode> {

  _XmlAncestorsIterator(this.current);

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