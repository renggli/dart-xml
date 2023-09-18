import '../exceptions/parent_exception.dart';
import '../nodes/attribute.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';

extension XmlSiblingExtension on XmlNode {
  /// Returns a [List] of the siblings of this node. Throws an
  /// [XmlParentException] if the node has no parent.
  List<XmlNode> get siblings {
    final parent = XmlParentException.checkParent(this);
    return this is XmlAttribute ? parent.attributes : parent.children;
  }

  /// Returns an [Iterable] over the [XmlElement] siblings of this node. If the
  /// node has no parent or no siblings, return an empty collection.
  List<XmlElement> get siblingElements =>
      siblings.whereType<XmlElement>().toList(growable: false);

  /// Return the previous sibling of this node, or `null`.
  XmlNode? get previousSibling {
    final siblings = this.siblings;
    for (var i = siblings.length - 1; i > 0; i--) {
      if (identical(siblings[i], this)) {
        return siblings[i - 1];
      }
    }
    return null;
  }

  /// Return the previous element sibling of this node, or `null`.
  XmlElement? get previousElementSibling {
    final siblings = this.siblings;
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
    return null;
  }

  /// Return the next sibling of this node, or `null`.
  XmlNode? get nextSibling {
    final siblings = this.siblings;
    for (var i = 0; i < siblings.length - 1; i++) {
      if (identical(siblings[i], this)) {
        return siblings[i + 1];
      }
    }
    return null;
  }

  /// Return the next element sibling of this node, or `null`.
  XmlElement? get nextElementSibling {
    final siblings = this.siblings;
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
    return null;
  }
}
