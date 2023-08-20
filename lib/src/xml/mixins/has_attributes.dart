import '../nodes/attribute.dart';
import '../nodes/node.dart';
import '../utils/name.dart';
import '../utils/name_matcher.dart';
import '../utils/namespace.dart';
import '../utils/node_list.dart';

/// Attribute interface for nodes.
mixin XmlAttributesBase {
  /// Return the attribute nodes of this node in document order.
  List<XmlAttribute> get attributes => const [];

  /// Return the attribute value with the given `name`, or `null`.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `element.getAttribute('xsd:name')` returns the first attribute value
  ///   with the fully qualified attribute name `xsd:name`.
  /// - `element.getAttribute('name', namespace: '*')` returns the first
  ///   attribute value with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.getAttribute('*', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///  returns the first attribute value within the provided namespace URI.
  ///
  String? getAttribute(String name, {String? namespace}) => null;

  /// Return the attribute node with the given `name`, or `null`.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `element.getAttributeNode('xsd:name')` returns the first attribute node
  ///   with the fully qualified attribute name `xsd:name`.
  /// - `element.getAttributeNode('name', namespace: '*')` returns the first
  ///   attribute node with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.getAttributeNode('*', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///  returns the first attribute node within the provided namespace URI.
  ///
  XmlAttribute? getAttributeNode(String name, {String? namespace}) => null;

  /// Set the attribute value with the given fully qualified `name` to `value`.
  /// If an attribute with the name already exist, its value is updated.
  /// If the value is `null`, the attribute is removed.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `element.setAttribute('xsd:name', 'value')` updates the attribute with
  ///   the fully qualified attribute name `xsd:name`.
  /// - `element.setAttribute('name', 'value', namespace: '*')` updates the
  ///   attribute with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.setAttribute('*', 'value', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///   updates the attribute within the provided namespace URI.
  ///
  void setAttribute(String name, String? value, {String? namespace}) =>
      throw UnsupportedError('$this has no attributes');

  /// Removes the attribute value with the given fully qualified `name`.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `element.removeAttribute('xsd:name')` removes the attribute with the
  ///   fully qualified attribute name `xsd:name`.
  /// - `element.removeAttribute('name', namespace: '*')` removes the attribute
  ///   with the local attribute name `name` no matter the namespace.
  /// - `element.removeAttribute('*', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///   removes the attribute within the provided namespace URI.
  ///
  void removeAttribute(String name, {String? namespace}) =>
      setAttribute(name, null, namespace: namespace);
}

/// Mixin for nodes with attributes.
mixin XmlHasAttributes implements XmlAttributesBase, XmlNode {
  @override
  final XmlNodeList<XmlAttribute> attributes = XmlNodeList<XmlAttribute>();

  @override
  String? getAttribute(String name, {String? namespace}) =>
      getAttributeNode(name, namespace: namespace)?.value;

  @override
  XmlAttribute? getAttributeNode(String name, {String? namespace}) {
    final tester = createNameMatcher(name, namespace);
    for (final attribute in attributes) {
      if (tester(attribute)) {
        return attribute;
      }
    }
    return null;
  }

  @override
  void setAttribute(String name, String? value, {String? namespace}) {
    final index = attributes.indexWhere(createNameLookup(name, namespace));
    if (index < 0) {
      if (value != null) {
        final prefix =
            namespace == null ? null : lookupNamespacePrefix(this, namespace);
        attributes.add(XmlAttribute(XmlName(name, prefix), value));
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
