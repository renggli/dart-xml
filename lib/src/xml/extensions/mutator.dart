import '../nodes/node.dart';
import 'sibling.dart';

extension XmlMutatorExtension on XmlNode {
  /// Removes this node from its parent.
  void remove() => siblings.remove(this);

  /// Replaces this node with [other].
  void replace(XmlNode other) {
    final siblings = this.siblings;
    for (var i = 0; i < siblings.length; i++) {
      if (identical(siblings[i], this)) {
        siblings[i] = other;
        break;
      }
    }
  }
}
