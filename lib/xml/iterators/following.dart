part of xml;

class _XmlFollowingIterable extends IterableBase<XmlNode> {

  final XmlNode start;

  _XmlFollowingIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => new _XmlFollowingIterator(start);

}

class _XmlFollowingIterator extends Iterator<XmlNode> {

  final List<XmlNode> todo = new List();

  _XmlFollowingIterator(XmlNode start) {
    var parent = start.parent;
    var todo_reverse = new List();
    while (parent != null) {
      var attributes_index = parent.attributes.indexOf(start);
      if (attributes_index != -1) {
        todo_reverse.addAll(parent.attributes.sublist(attributes_index + 1));
        todo_reverse.addAll(parent.children);
      } else {
        var children_index = parent.children.indexOf(start);
        if (children_index != -1) {
          todo_reverse.addAll(parent.children.sublist(children_index + 1));
        } else {
          throw new StateError('Internal error');
        }
      }
      parent = parent.parent;
      start = start.parent;
    }
    todo.addAll(todo_reverse.reversed);
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
      todo.addAll(current.children.reversed);
      todo.addAll(current.attributes.reversed);
      return true;
    }
  }

}