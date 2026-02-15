import 'package:meta/meta.dart';

import '../../xml/utils/token.dart';

/// Mixin with information about the parent event.
mixin XmlHasName {
  /// The fully qualified name.
  String get name;

  /// The fully qualified name (alias for [name]).
  String get qualifiedName => name;

  /// The namespace prefix, or `null`.
  String? get namespacePrefix {
    final index = name.indexOf(XmlToken.namespace);
    return index > 0 ? name.substring(0, index) : null;
  }

  /// The local name, excluding the namespace prefix.
  String get localName {
    final index = name.indexOf(XmlToken.namespace);
    return index > 0 ? name.substring(index + 1) : name;
  }

  /// Hold an optional reference to the namespace URI.
  String? _namespaceUri;

  /// Return the namespace URI.
  String? get namespaceUri => _namespaceUri;

  /// Internal helper to attach the namespace to the event.
  @internal
  void attachNamespace(String namespaceUri) {
    assert(_namespaceUri == null, 'Namespace is already initialized.');
    _namespaceUri = namespaceUri;
  }
}
