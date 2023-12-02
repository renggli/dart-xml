import '../../../xml.dart';
import '../nodes/data.dart';

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

  /// Test whether [other] is this node or contained in this node.
  bool contains(XmlNode other) {
    for (XmlNode? node = other; node != null; node = node.parent) {
      if (this == node) {
        return true;
      }
    }
    return false;
  }

  /// Compares the position of this node and [other].
  ///
  /// Returns _0_ if the nodes are the same, _-1_ if this node is before the
  /// argument, and _1_ if after. Throws a [StateError], if the nodes do not
  /// share a parent.
  ///
  /// Implementation note: The code takes great care to avoid unnecessary
  /// object allocation (intermediate lists) since this code might be called a
  /// lot.
  int compareNodePosition(XmlNode other) {
    if (this == other) return 0;
    XmlNode? node1 = this, node2 = other;
    var depth1 = node1.depth, depth2 = node2.depth;
    if (depth1 > depth2) {
      while (node1 != null && depth1 > depth2) {
        node1 = node1.parent;
        depth1--;
      }
      if (node1 == node2) return 1;
    } else if (depth2 > depth1) {
      while (node2 != null && depth2 > depth1) {
        node2 = node2.parent;
        depth2--;
      }
      if (node1 == node2) return -1;
    }
    while (node1 != null && node2 != null && node1.parent != node2.parent) {
      node1 = node1.parent;
      node2 = node2.parent;
    }
    if (node1 != null && node2 != null) {
      final parent = node1.parent;
      assert(parent == node2.parent);
      if (parent != null) {
        for (final attribute in parent.attributes) {
          if (attribute == node1) return -1;
          if (attribute == node2) return 1;
        }
        for (final child in parent.children) {
          if (child == node1) return -1;
          if (child == node2) return 1;
        }
      }
    }
    throw StateError('$this and $other are in disconnected DOM trees.');
  }
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
