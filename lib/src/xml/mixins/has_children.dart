library xml.mixins.has_children;

import '../nodes/node.dart';
import '../utils/node_list.dart';

/// Children interface for nodes.
mixin XmlChildrenBase {
  /// Return the direct children of this node in document order.
  List<XmlNode> get children => const [];

  /// Return the first child of this node, or `null` if there are no children.
  XmlNode get firstChild => null;

  /// Return the last child of this node, or `null` if there are no children.
  XmlNode get lastChild => null;
}

/// Mixin for nodes with children.
mixin XmlHasChildren implements XmlChildrenBase {
  @override
  final XmlNodeList<XmlNode> children = XmlNodeList<XmlNode>();

  @override
  XmlNode get firstChild => children.isEmpty ? null : children.first;

  @override
  XmlNode get lastChild => children.isEmpty ? null : children.last;
}
