import '../nodes/element.dart';
import '../nodes/node.dart';

extension XmlSiblingExtension on XmlNode {
  /// Return the previous sibling of this node, or `null`.
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

  /// Return the previous element sibling of this node, or `null`.
  XmlElement? get previousElementSibling {
    if (parent != null) {
      final siblings = parent!.children;
      for (var i = siblings.length - 1; i > 0; i--) {
        if (identical(siblings[i], this)) {
          for (var j = i - 1; j >= 0; j--) {
            final candidate = siblings[j];
            if (candidate is XmlElement) {
              return candidate;
            }
          }
          return null;
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

  /// Return the next element sibling of this node, or `null`.
  XmlElement? get nextElementSibling {
    if (parent != null) {
      final siblings = parent!.children;
      for (var i = 0; i < siblings.length - 1; i++) {
        if (identical(siblings[i], this)) {
          for (var j = i + 1; j < siblings.length; j++) {
            final candidate = siblings[j];
            if (candidate is XmlElement) {
              return candidate;
            }
          }
          return null;
        }
      }
    }
    return null;
  }
}
