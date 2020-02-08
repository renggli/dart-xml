library xml.mixins.has_attributes;

import '../nodes/attribute.dart';
import '../utils/name.dart';
import '../utils/name_matcher.dart';
import '../utils/node_list.dart';

/// Interface for nodes with attributes.
mixin XmlAttributesBase {
  /// Return the attribute nodes of this node in document order.
  List<XmlAttribute> get attributes => const [];

  /// Return the attribute value with the given `name`, or `null`.
  String getAttribute(String name, {String namespace}) => null;

  /// Return the attribute node with the given `name`, or `null`.
  XmlAttribute getAttributeNode(String name, {String namespace}) => null;

  /// Set the attribute value with the given fully qualified `name` to `value`.
  /// If an attribute with the name already exist, its value is updated.
  /// If the value is `null`, the attribute is removed.
  void setAttribute(String name, String value) =>
      throw UnsupportedError('$this has no attributes.');
}

/// Mixin for nodes with attributes.
mixin XmlHasAttributes implements XmlAttributesBase {
  @override
  final XmlNodeList<XmlAttribute> attributes = XmlNodeList<XmlAttribute>();

  @override
  String getAttribute(String name, {String namespace}) =>
      getAttributeNode(name, namespace: namespace)?.value;

  @override
  XmlAttribute getAttributeNode(String name, {String namespace}) => attributes
      .firstWhere(createNameMatcher(name, namespace), orElse: () => null);

  @override
  void setAttribute(String name, String value) {
    final index =
        attributes.indexWhere((element) => element.name.qualified == name);
    if (index < 0) {
      if (value != null) {
        attributes.add(XmlAttribute(XmlName.fromString(name), value));
      }
    } else {
      if (value != null) {
        attributes[index].value = value;
      } else {
        attributes.removeAt(index);
      }
    }
  }
}
