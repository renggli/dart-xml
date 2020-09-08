import '../nodes/node.dart';

extension XmlSiblingExtension on XmlNode {
  /// Return the next sibling of this node, or `null`.
  XmlNode? get previousSibling {
    if (parent != null) {
      final siblings = parent!.children;
      for (var i = siblings.length - 1; i > 0; i--) {
        if (identical(siblings[i], this)) {
          return siblings[i - 1];
        }
      }
    }
    return null;
  }

  /// Return the next sibling of this node, or `null`.
  XmlNode? get nextSibling {
    if (parent != null) {
      final siblings = parent!.children;
      for (var i = 0; i < siblings.length - 1; i++) {
        if (identical(siblings[i], this)) {
          return siblings[i + 1];
        }
      }
    }
    return null;
  }
}
