library xml.nodes.parent;

import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/name_matcher.dart' show createNameMatcher;
import 'package:xml/xml/utils/node_list.dart' show XmlNodeList;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;

/// Abstract XML node with actual children.
abstract class XmlParent extends XmlNode {
  final XmlNodeList<XmlNode> _children;

  /// Create a node with a list of `children`.
  XmlParent(Set<XmlNodeType> supportedChildrenTypes, Iterable<XmlNode> children)
      : _children = new XmlNodeList(supportedChildrenTypes) {
    _children.attachParent(this);
    _children.addAll(children);
  }

  /// Return the direct children of this node.
  @override
  List<XmlNode> get children => _children;

  /// Return the _direct_ child elements with the given tag `name`.
  Iterable<XmlElement> findElements(String name, {String namespace}) =>
      _filterElements(_children, name, namespace);

  /// Return the _recursive_ child elements with the specified tag `name`.
  Iterable<XmlElement> findAllElements(String name, {String namespace}) =>
      _filterElements(descendants, name, namespace);

  Iterable<XmlElement> _filterElements(Iterable<XmlNode> iterable, String name, String namespace) {
    var matcher = createNameMatcher(name, namespace);
    return iterable
        .where((node) => node is XmlElement && matcher(node))
        .map((node) => node as XmlElement);
  }
}
