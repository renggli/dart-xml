import '../nodes/node.dart';
import 'sibling.dart';

extension XmlMutatorExtension on XmlNode {
  /// Remove this node from parent.
  void remove() => siblings.remove(this);

  /// Replace this node with `other`.
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
