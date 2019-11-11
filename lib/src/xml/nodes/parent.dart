library xml.nodes.parent;

import '../utils/name_matcher.dart';
import '../utils/node_list.dart';
import '../utils/node_type.dart';
import '../utils/owned.dart';
import 'element.dart';
import 'node.dart';

/// Abstract XML node with actual children.
abstract class XmlParent extends XmlNode with XmlOwnedMixin<XmlParent> {
  /// Create a node with a list of [children].
  XmlParent(Set<XmlNodeType> supportedChildrenTypes,
      Iterable<XmlNode> childrenIterable)
      : children = XmlNodeList(supportedChildrenTypes) {
    children.attachParent(this);
    children.addAll(childrenIterable);
  }

  /// Return the direct children of this node.
  @override
  final XmlNodeList<XmlNode> children;

  /// Return a lazy [Iterable] of the _direct_ child elements in document
  /// order with the specified tag `name`.
  Iterable<XmlElement> findElements(String name, {String namespace}) =>
      _filterElements(children, name, namespace);

  /// Return a lazy [Iterable] of the _recursive_ child elements in document
  /// order with the specified tag `name`.
  Iterable<XmlElement> findAllElements(String name, {String namespace}) =>
      _filterElements(descendants, name, namespace);

  Iterable<XmlElement> _filterElements(
      Iterable<XmlNode> iterable, String name, String namespace) {
    final matcher = createNameMatcher(name, namespace);
    return iterable.whereType<XmlElement>().where(matcher);
  }
}
