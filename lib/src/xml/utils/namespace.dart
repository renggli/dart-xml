import '../../shared/names/scope.dart';
import '../navigation/parent.dart';
import '../nodes/element.dart';

class ElementNamespaceScope extends NamespaceScope {
  ElementNamespaceScope(this.element);

  final XmlElement element;

  @override
  void add(String? prefix, String uri) =>
      element.setAttribute(namespaceDeclarationName(prefix), uri);

  @override
  void remove(String? prefix) =>
      element.removeAttribute(namespaceDeclarationName(prefix));

  @override
  String? lookupUri([String? prefix]) {
    final name = namespaceDeclarationName(prefix);
    for (XmlElement? current = element;
        current != null;
        current = current.parentElement) {
      for (final attribute in current.attributes) {
        if (attribute.qualifiedName == name) {
          return attribute.value;
        }
      }
    }
    return null;
  }

  @override
  String? lookupPrefix(String uri) {
    for (XmlElement? current = element;
        current != null;
        current = current.parentElement) {
      for (final attribute in current.attributes) {
        if (attribute.value == uri) {
          if (attribute.namespacePrefix == NamespaceScope.xmlns) {
            return attribute.localName;
          } else if (attribute.namespacePrefix == null &&
              attribute.localName == NamespaceScope.xmlns) {
            return '';
          }
        }
      }
    }
    return null;
  }
}
