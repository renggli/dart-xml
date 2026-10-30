import '../mixins/has_name.dart';

/// Internal factory to create element lookups.
bool Function(XmlHasName) createNameLookup(
  String name, {
  String? namespaceUri,
}) {
  if (namespaceUri == null) {
    return (named) => named.qualifiedName == name;
  } else {
    return (named) =>
        named.localName == name && named.namespaceUri == namespaceUri;
  }
}

/// Internal factory to create element matchers with wildcards.
bool Function(XmlHasName) createNameMatcher(
  String name, {
  String? namespaceUri,
}) {
  if (name == '*') {
    if (namespaceUri == null || namespaceUri == '*') {
      return (named) => true;
    } else {
      return (named) => named.namespaceUri == namespaceUri;
    }
  } else {
    if (namespaceUri == null) {
      return (named) => named.qualifiedName == name;
    } else if (namespaceUri == '*') {
      return (named) => named.localName == name;
    } else {
      return (named) =>
          named.localName == name && named.namespaceUri == namespaceUri;
    }
  }
}
