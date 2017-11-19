library xml.nodes.parent;

import 'dart:collection';

import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/name_matcher.dart' show createNameMatcher;

/// Abstract XML node with actual children.
abstract class XmlParent extends XmlNode {
  @override
  final List<XmlNode> children;

  /// Create a node with a list of `children`.
  XmlParent(Iterable<XmlNode> children)
      : children = new UnmodifiableListView(children.toList(growable: false)) {
    for (var child in this.children) {
      child.adoptParent(this);
    }
  }

  /// Create a mutable node with a list of `children`.
  XmlParent.mutable(Iterable<XmlNode> children)
      : children = children.toList(growable: true) {
    for (var child in this.children) {
      child.adoptParent(this);
    }
  }

  /// Return the _direct_ child elements with the given tag `name`.
  Iterable<XmlElement> findElements(String name, {String namespace}) =>
      _filterElements(children, name, namespace);

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
