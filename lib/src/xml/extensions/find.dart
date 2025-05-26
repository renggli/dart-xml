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
  /// - `element.findElements('name', namespace: '*')` finds all direct child
  ///   elements with the local tag name `name` no matter their namespace.
  /// - `element.findElements('*', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///   finds all direct child elements within the provided namespace URI.
  ///
  Iterable<XmlElement> findElements(String name, {String? namespace}) =>
      filterElements(children, name, namespace);

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
  /// - `document.findAllElements('name', namespace: '*')` finds all elements
  ///   with the local tag name `name` no matter their namespace.
  /// - `document.findAllElements('*', namespace: 'http://www.w3.org/2001/XMLSchema')`
  ///   finds all elements with the given namespace URI.
  ///
  Iterable<XmlElement> findAllElements(String name, {String? namespace}) =>
      filterElements(descendants, name, namespace);
}

Iterable<XmlElement> filterElements(
  Iterable<XmlNode> iterable,
  String name,
  String? namespace,
) {
  final matcher = createNameMatcher(name, namespace);
  return iterable.whereType<XmlElement>().where(matcher);
}
