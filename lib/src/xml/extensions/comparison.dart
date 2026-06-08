import '../mixins/has_name.dart';
import '../nodes/attribute.dart';
import '../nodes/data.dart';
import '../nodes/doctype.dart';
import '../nodes/node.dart';
import '../nodes/processing.dart';
import 'parent.dart';

extension XmlComparisonExtension on XmlNode {
  /// Tests whether this node is equal to [other].
  ///
  /// The two nodes are equal when they have the same type, name, defining
  /// characteristics, attributes, and children.
  bool isEqualNode(XmlNode other) =>
      this == other ||
      (runtimeType == other.runtimeType &&
          _compareName(this, other) &&
          _compareData(this, other) &&
          _compareList(attributes, other.attributes) &&
          _compareList(children, other.children));

  /// Test whether [other] is contained in this node, that is whether this node
  /// is an ancestor of [other].
  bool contains(XmlNode other) {
    for (XmlNode? node = other; node != null; node = node.parent) {
      if (this == node) {
        return true;
      }
    }
    return false;
  }

  /// Compares the document position of this node and [other].
  ///
  /// Returns an [XmlDocumentPosition] representing the relative position of the
  /// compared node [other] relative to the reference node (this node).
  ///
  /// Implementation note: The code takes great care to avoid unnecessary memory
  /// allocations (intermediate lists) since this code might be called a lot.
  XmlDocumentPosition compareDocumentPosition(XmlNode other) {
    // Identical nodes have a position difference of 0.
    if (this == other) return const XmlDocumentPosition(0);

    var thisNode = this;
    var otherNode = other;
    XmlAttribute? thisAttribute;
    XmlAttribute? otherAttribute;

    // Normalize attributes to their parent/owner elements.
    if (thisNode is XmlAttribute) {
      thisAttribute = thisNode;
      thisNode = thisAttribute.parent ?? thisAttribute;
    }
    if (otherNode is XmlAttribute) {
      otherAttribute = otherNode;
      otherNode = otherAttribute.parent ?? otherNode;
    }

    // Handle cases where both nodes share the same owner element.
    if (thisNode == otherNode) {
      if (thisAttribute != null && otherAttribute != null) {
        for (final attr in thisNode.attributes) {
          if (attr == thisAttribute) {
            return const XmlDocumentPosition(
              XmlDocumentPosition._implementationSpecific |
                  XmlDocumentPosition._following,
            );
          }
          if (attr == otherAttribute) {
            return const XmlDocumentPosition(
              XmlDocumentPosition._implementationSpecific |
                  XmlDocumentPosition._preceding,
            );
          }
        }
      }
      if (thisAttribute == null && otherAttribute != null) {
        return const XmlDocumentPosition(
          XmlDocumentPosition._containedBy | XmlDocumentPosition._following,
        );
      }
      if (thisAttribute != null && otherAttribute == null) {
        return const XmlDocumentPosition(
          XmlDocumentPosition._contains | XmlDocumentPosition._preceding,
        );
      }
    }

    var ancestorThis = thisNode;
    var ancestorOther = otherNode;
    var depthThis = ancestorThis.depth;
    var depthOther = ancestorOther.depth;

    // Traverse up to align the depths of both nodes.
    if (depthThis > depthOther) {
      while (depthThis > depthOther) {
        ancestorThis = ancestorThis.parent!;
        depthThis--;
      }
      if (ancestorThis == ancestorOther) {
        return const XmlDocumentPosition(
          XmlDocumentPosition._contains | XmlDocumentPosition._preceding,
        );
      }
    } else if (depthOther > depthThis) {
      while (depthOther > depthThis) {
        ancestorOther = ancestorOther.parent!;
        depthOther--;
      }
      if (ancestorThis == ancestorOther) {
        return const XmlDocumentPosition(
          XmlDocumentPosition._containedBy | XmlDocumentPosition._following,
        );
      }
    }

    // Walk up in parallel until we reach a common parent.
    while (ancestorThis.parent != null &&
        ancestorOther.parent != null &&
        ancestorThis.parent != ancestorOther.parent) {
      ancestorThis = ancestorThis.parent!;
      ancestorOther = ancestorOther.parent!;
    }

    // If there is no common parent, the nodes belong to disconnected trees.
    final parent = ancestorThis.parent;
    if (parent == null || ancestorThis.parent != ancestorOther.parent) {
      return XmlDocumentPosition(
        XmlDocumentPosition._disconnected |
            XmlDocumentPosition._implementationSpecific |
            (identityHashCode(ancestorThis) < identityHashCode(ancestorOther)
                ? XmlDocumentPosition._following
                : XmlDocumentPosition._preceding),
      );
    }

    // Compare sibling order of the ancestors under the common parent.
    for (final attribute in parent.attributes) {
      if (attribute == ancestorThis) {
        return const XmlDocumentPosition(XmlDocumentPosition._following);
      }
      if (attribute == ancestorOther) {
        return const XmlDocumentPosition(XmlDocumentPosition._preceding);
      }
    }
    for (final child in parent.children) {
      if (child == ancestorThis) {
        return const XmlDocumentPosition(XmlDocumentPosition._following);
      }
      if (child == ancestorOther) {
        return const XmlDocumentPosition(XmlDocumentPosition._preceding);
      }
    }

    // Default fallback (should not be reached).
    return const XmlDocumentPosition(
      XmlDocumentPosition._disconnected |
          XmlDocumentPosition._implementationSpecific |
          XmlDocumentPosition._preceding,
    );
  }

  /// Compares the position of this node and [other].
  ///
  /// Returns _0_ if the nodes are the same, _-1_ if this node is before the
  /// argument, and _1_ if after. Throws a [StateError], if the nodes do not
  /// share a parent.
  @Deprecated('Use `compareDocumentPosition` instead')
  int compareNodePosition(XmlNode other) {
    final result = compareDocumentPosition(other);
    if (result.isDisconnected) {
      throw StateError('$this and $other are in disconnected DOM trees.');
    }
    if (result.isPreceding) {
      return 1;
    }
    if (result.isFollowing) {
      return -1;
    }
    return 0;
  }
}

/// Represents the document position of an [XmlNode] relative to another.
///
/// This is a bitmask of document position values returned by
/// `compareDocumentPosition`.
extension type const XmlDocumentPosition(int value) {
  /// The two nodes are in different documents or different trees in the same document.
  static const int _disconnected = 1;

  /// The other node precedes the reference node.
  static const int _preceding = 2;

  /// The other node follows the reference node.
  static const int _following = 4;

  /// The other node contains the reference node (it is an ancestor).
  static const int _contains = 8;

  /// The other node is contained by the reference node (it is a descendant).
  static const int _containedBy = 16;

  /// The relationship is implementation-specific.
  static const int _implementationSpecific = 32;

  /// Whether the nodes are the same.
  bool get isSame => value == 0;

  /// Whether the nodes are disconnected.
  bool get isDisconnected => (value & _disconnected) != 0;

  /// Whether the other node precedes the reference node.
  bool get isPreceding => (value & _preceding) != 0;

  /// Whether the other node follows the reference node.
  bool get isFollowing => (value & _following) != 0;

  /// Whether the other node contains the reference node.
  bool get isContains => (value & _contains) != 0;

  /// Whether the other node is contained by the reference node.
  bool get isContainedBy => (value & _containedBy) != 0;

  /// Whether the relationship is implementation-specific.
  bool get isImplementationSpecific => (value & _implementationSpecific) != 0;
}

bool _compareName(XmlNode node1, XmlNode node2) {
  if (node1 case XmlHasName(name: final name1)) {
    if (node2 case XmlHasName(name: final name2)) {
      // Do we actually have to compare namespace resolution?
      return name1.qualified == name2.qualified;
    }
  }
  return true;
}

bool _compareData(XmlNode node1, XmlNode node2) {
  if (node1 is XmlData && node2 is XmlData) {
    if (node1 is XmlProcessing && node2 is XmlProcessing) {
      return node1.target == node2.target && node1.value == node2.value;
    } else {
      return node1.value == node2.value;
    }
  } else if (node1 is XmlDoctype && node2 is XmlDoctype) {
    return node1.name == node2.name &&
        node1.externalId == node2.externalId &&
        node1.internalSubset == node2.internalSubset;
  }
  return true;
}

bool _compareList(List<XmlNode> node1, List<XmlNode> node2) {
  if (node1.length != node2.length) {
    return false;
  }
  for (var i = 0; i < node1.length; i++) {
    if (!node1[i].isEqualNode(node2[i])) {
      return false;
    }
  }
  return true;
}
