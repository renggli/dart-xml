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
