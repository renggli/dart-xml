import '../nodes/element.dart';
import '../nodes/node.dart';
import '../utils/name_matcher.dart';
import '../utils/node_list.dart';

/// Children interface for nodes.
mixin XmlChildrenBase {
  /// Return the direct children of this node in document order.
  List<XmlNode> get children => const [];

  /// Return the first child element with the given `name`, or `null`.
  XmlElement getElement(String name, {String namespace}) => null;

  /// Return the first child of this node, or `null` if there are no children.
  XmlNode get firstChild => null;

  /// Return the first child [XmlElement], or `null` if there are none.
  XmlElement get firstElementChild => null;

  /// Return the last child of this node, or `null` if there are no children.
  XmlNode get lastChild => null;

  /// Return the last child [XmlElement], or `null` if there are none.
  XmlElement get lastElementChild => null;
}

/// Mixin for nodes with children.
mixin XmlHasChildren implements XmlChildrenBase {
  @override
  final XmlNodeList<XmlNode> children = XmlNodeList<XmlNode>();

  @override
  XmlElement getElement(String name, {String namespace}) => children
      .whereType<XmlElement>()
      .firstWhere(createNameMatcher(name, namespace), orElse: () => null);

  @override
  XmlNode get firstChild => children.isEmpty ? null : children.first;

  @override
  XmlElement get firstElementChild =>
      children.firstWhere((node) => node is XmlElement, orElse: () => null);

  @override
  XmlNode get lastChild => children.isEmpty ? null : children.last;

  @override
  XmlElement get lastElementChild =>
      children.lastWhere((node) => node is XmlElement, orElse: () => null);
}
