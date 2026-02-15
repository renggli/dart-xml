import '../mixins/has_name.dart';
import 'predicate.dart';

/// Internal factory to create element lookups.
///
/// The `name` is considered to be a local name if a `namespaceUri` is provided,
/// otherwise `name` is considered to be fully qualified.
Predicate<XmlHasName> createNameLookup(String name, {String? namespaceUri}) {
  if (namespaceUri == null) {
    return (named) => named.name.qualified == name;
  } else {
    return (named) =>
        named.name.local == name && named.name.namespaceUri == namespaceUri;
  }
}

/// Internal factory to create element matchers with wildcards.
Predicate<XmlHasName> createNameMatcher(String name, {String? namespaceUri}) {
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
