import '../../shared/names/named.dart';
import 'functions.dart';

/// Internal factory to create element lookups.
///
/// The `name` is considered to be a local name if a `namespaceUri` is provided,
/// otherwise `name` is considered to be fully qualified.
Predicate<XmlNamed> createNameLookup(String name, String? namespace) {
  if (namespace == null) {
    return (named) => named.qualifiedName == name;
  } else {
    return (named) =>
        named.localName == name && named.namespaceUri == namespace;
  }
}

/// Internal factory to create element matchers with wildcards.
Predicate<XmlNamed> createNameMatcher(String name, String? namespace) {
  if (name == '*') {
    if (namespace == null || namespace == '*') {
      return (named) => true;
    } else {
      return (named) => named.namespaceUri == namespace;
    }
  } else {
    if (namespace == null) {
      return (named) => named.qualifiedName == name;
    } else if (namespace == '*') {
      return (named) => named.localName == name;
    } else {
      return (named) =>
          named.localName == name && named.namespaceUri == namespace;
    }
  }
}
