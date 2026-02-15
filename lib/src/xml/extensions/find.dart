import '../nodes/element.dart';
import '../nodes/node.dart';
import '../utils/name_matcher.dart';
import 'descendants.dart';

extension XmlFindExtension on XmlNode {
  /// Return a lazy [Iterable] of the _direct_ child elements in document
  /// order with the specified tag `name` and `namespace`.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `element.findElements('xsd:name')` finds all direct child elements with
  ///   the fully qualified tag name `xsd:name`.
  /// - `element.findElements('name', namespaceUri: '*')` finds all direct child
  ///   elements with the local tag name `name` no matter their namespace.
  /// - `element.findElements('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///   finds all direct child elements within the provided namespace URI.
  ///
  Iterable<XmlElement> findElements(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) =>
      _filterElements(children, name, namespaceUri: namespaceUri ?? namespace);

  /// Return a lazy [Iterable] of the _recursive_ child elements in document
  /// order with the specified tag `name`.
  ///
  /// Both `name` and `namespace` can be a specific [String]; or `'*'` to match
  /// anything. If no `namespace` is provided, the _fully qualified_ name is
  /// compared; otherwise only the _local name_ is considered.
  ///
  /// For example:
  /// - `document.findAllElements('xsd:name')` finds all elements with the fully
  ///   qualified tag name `xsd:name`.
  /// - `document.findAllElements('name', namespaceUri: '*')` finds all elements
  ///   with the local tag name `name` no matter their namespace.
  /// - `document.findAllElements('*', namespaceUri: 'http://www.w3.org/2001/XMLSchema')`
  ///   finds all elements with the given namespace URI.
  ///
  Iterable<XmlElement> findAllElements(
    String name, {
    String? namespaceUri,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) => _filterElements(
    descendants,
    name,
    namespaceUri: namespaceUri ?? namespace,
  );
}

Iterable<XmlElement> _filterElements(
  Iterable<XmlNode> iterable,
  String name, {
  String? namespaceUri,
}) {
  final matcher = createNameMatcher(name, namespaceUri: namespaceUri);
  return iterable.whereType<XmlElement>().where(matcher);
}
