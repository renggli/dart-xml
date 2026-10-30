import '../nodes/element.dart';
import '../nodes/node.dart';
import 'sibling.dart';

/// Extension providing structural mutation methods on [XmlNode].
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

  /// Inserts [other] as a sibling directly before this node.
  void before(XmlNode other) {
    final siblings = this.siblings;
    final index = siblings.indexOf(this);
    if (index != -1) {
      siblings.insert(index, other);
    }
  }

  /// Inserts [other] as a sibling directly after this node.
  void after(XmlNode other) {
    final siblings = this.siblings;
    final index = siblings.indexOf(this);
    if (index != -1) {
      siblings.insert(index + 1, other);
    }
  }

  /// Wraps this node with [wrapper], replacing this node in its parent with
  /// [wrapper] and adding this node as a child of [wrapper].
  void wrap(XmlElement wrapper) {
    replace(wrapper);
    wrapper.children.add(this);
  }

  /// Unwraps this node by replacing it with its children in its parent.
  void unwrap() {
    final siblings = this.siblings;
    final index = siblings.indexOf(this);
    if (index != -1) {
      final children = this.children.toList();
      siblings.removeAt(index);
      siblings.insertAll(index, children);
    }
  }
}

/// Extension providing element mutation methods on [XmlElement].
extension XmlElementMutatorExtension on XmlElement {
  /// Inserts [node] as the first child of this element.
  void prepend(XmlNode node) => children.insert(0, node);
}
