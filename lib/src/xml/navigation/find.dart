import '../nodes/element.dart';
import '../nodes/node.dart';
import '../utils/name_matcher.dart';
import 'descendants.dart';

extension XmlFindExtension on XmlNode {
  /// Return a lazy [Iterable] of the _direct_ child elements in document
  /// order with the specified tag `name` and `namespace`.
  Iterable<XmlElement> findElements(String name, {String? namespace}) =>
      filterElements(children, name, namespace);

  /// Return a lazy [Iterable] of the _recursive_ child elements in document
  /// order with the specified tag `name`.
  Iterable<XmlElement> findAllElements(String name, {String? namespace}) =>
      filterElements(descendants, name, namespace);
}

Iterable<XmlElement> filterElements(
    Iterable<XmlNode> iterable, String name, String? namespace) {
  final matcher = createNameMatcher(name, namespace);
  return iterable.whereType<XmlElement>().where(matcher);
}
