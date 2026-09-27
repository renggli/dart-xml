import '../nodes/element.dart';
import '../nodes/node.dart';
import '../utils/name_matcher.dart';
import '../utils/node_list.dart';

/// Children interface for nodes.
mixin XmlChildrenBase {
  /// The direct children of this node in document order.
  List<XmlNode> get children => const [];

  /// An [Iterable] over the [XmlElement] children of this node.
  Iterable<XmlElement> get childElements => const [];

  /// Finds the first child element with the given [name], or `null`.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to
  /// match anything. If no [namespaceUri] is provided, the fully qualified name
  /// is compared; otherwise only the local name is considered.
  ///
  /// For example:
  /// - `element.getElement('xsd:name')` returns the first element with the
  ///   fully qualified tag name `xsd:name`.
  /// - `element.getElement('name', namespaceUri: '*')` returns the first
  ///   element with the local tag name `name` no matter the namespace.
  /// - `element.getElement('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///   returns the first element within the provided namespace URI.
  ///
  XmlElement? getElement(
    String name, {
    @Deprecated('Use `namespaceUri` instead') String? namespace,
    String? namespaceUri,
  }) => null;

  /// The first child of this node, or `null` if there are no children.
  XmlNode? get firstChild => null;

  /// The first child [XmlElement], or `null` if there are none.
  XmlElement? get firstElementChild => null;

  /// The last child of this node, or `null` if there are no children.
  XmlNode? get lastChild => null;

  /// The last child [XmlElement], or `null` if there are none.
  XmlElement? get lastElementChild => null;
}

/// Mixin for nodes with children.
mixin XmlHasChildren<T extends XmlNode> implements XmlChildrenBase {
  @override
  final XmlNodeList<T> children = XmlNodeList<T>();

  @override
  Iterable<XmlElement> get childElements => children.whereType<XmlElement>();

  @override
  XmlElement? getElement(
    String name, {
    @Deprecated('Use `namespaceUri` instead') String? namespace,
    String? namespaceUri,
  }) {
    final tester = createNameMatcher(
      name,
      namespaceUri: namespaceUri ?? namespace,
    );
    for (final node in children) {
      if (node is XmlElement && tester(node)) {
        return node;
      }
    }
    return null;
  }

  @override
  T? get firstChild => children.isEmpty ? null : children.first;

  @override
  XmlElement? get firstElementChild {
    for (final node in children) {
      if (node is XmlElement) {
        return node;
      }
    }
    return null;
  }

  @override
  T? get lastChild => children.isEmpty ? null : children.last;

  @override
  XmlElement? get lastElementChild {
    for (final node in children.reversed) {
      if (node is XmlElement) {
        return node;
      }
    }
    return null;
  }
}
