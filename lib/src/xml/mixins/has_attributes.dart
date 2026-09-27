import '../nodes/attribute.dart';
import '../nodes/node.dart';
import '../utils/name.dart';
import '../utils/name_matcher.dart';
import '../utils/node_list.dart';

/// Attribute interface for nodes.
mixin XmlAttributesBase {
  /// The attribute nodes of this node in document order.
  List<XmlAttribute> get attributes => const [];

  /// The attribute nodes of this node in document order, excluding namespace
  /// declarations.
  Iterable<XmlAttribute> get elementAttributes =>
      attributes.where((attribute) => !attribute.isNamespaceDeclaration);

  /// Returns the attribute value with the given [name], or `null`.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to
  /// match anything. If no [namespaceUri] is provided, the fully qualified
  /// name is compared; otherwise only the local name is considered.
  ///
  /// For example:
  /// - `element.getAttribute('xsd:name')` returns the first attribute value
  ///   with the fully qualified attribute name `xsd:name`.
  /// - `element.getAttribute('name', namespaceUri: '*')` returns the first
  ///   attribute value with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.getAttribute('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///  returns the first attribute value within the provided namespace URI.
  ///
  String? getAttribute(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => null;

  /// Returns the attribute node with the given [name], or `null`.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to
  /// match anything. If no [namespaceUri] is provided, the fully qualified
  /// name is compared; otherwise only the local name is considered.
  ///
  /// For example:
  /// - `element.getAttributeNode('xsd:name')` returns the first attribute node
  ///   with the fully qualified attribute name `xsd:name`.
  /// - `element.getAttributeNode('name', namespaceUri: '*')` returns the first
  ///   attribute node with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.getAttributeNode('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///  returns the first attribute node within the provided namespace URI.
  ///
  XmlAttribute? getAttributeNode(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => null;

  /// Sets the attribute value with the given fully qualified [name] to [value].
  ///
  /// If an attribute with the name already exists, its value is updated.
  /// If the value is `null`, the attribute is removed.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to match
  /// anything. If no [namespaceUri] is provided, the fully qualified name is
  /// compared; otherwise only the local name is considered.
  ///
  /// For example:
  /// - `element.setAttribute('xsd:name', 'value')` updates the attribute with
  ///   the fully qualified attribute name `xsd:name`.
  /// - `element.setAttribute('name', 'value', namespaceUri: '*')` updates the
  ///   attribute with the local attribute name `name` no matter the
  ///   namespace.
  /// - `element.setAttribute('*', 'value', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///   updates the attribute within the provided namespace URI.
  ///
  void setAttribute(
    String name,
    String? value, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => throw UnsupportedError('$this has no attributes');

  /// Removes the attribute with the given fully qualified [name].
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to match
  /// anything. If no [namespaceUri] is provided, the fully qualified name is
  /// compared; otherwise only the local name is considered.
  ///
  /// For example:
  /// - `element.removeAttribute('xsd:name')` removes the attribute with the
  ///   fully qualified attribute name `xsd:name`.
  /// - `element.removeAttribute('name', namespaceUri: '*')` removes the attribute
  ///   with the local attribute name `name` no matter the namespace.
  /// - `element.removeAttribute('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///   removes the attribute within the provided namespace URI.
  ///
  void removeAttribute(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => setAttribute(name, null, namespaceUri: namespaceUri ?? namespace);
}

/// Mixin for nodes with attributes.
mixin XmlHasAttributes implements XmlAttributesBase, XmlNode {
  @override
  final XmlNodeList<XmlAttribute> attributes = XmlNodeList<XmlAttribute>();

  @override
  String? getAttribute(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => getAttributeNode(name, namespaceUri: namespaceUri ?? namespace)?.value;

  @override
  XmlAttribute? getAttributeNode(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) {
    final tester = createNameMatcher(
      name,
      namespaceUri: namespaceUri ?? namespace,
    );
    for (final attribute in attributes) {
      if (tester(attribute)) {
        return attribute;
      }
    }
    return null;
  }

  @override
  void setAttribute(
    String name,
    String? value, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) {
    final index = attributes.indexWhere(
      createNameLookup(name, namespaceUri: namespaceUri ?? namespace),
    );
    if (index < 0) {
      if (value != null) {
        attributes.add(
          XmlAttribute(
            XmlName.parts(name, namespaceUri: namespaceUri ?? namespace),
            value,
          ),
        );
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
