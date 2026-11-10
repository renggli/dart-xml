import 'package:meta/meta.dart';

import '../../xml/utils/name_parser.dart';

/// Mixin with information about the name of an event.
mixin XmlHasName {
  /// The fully qualified name.
  String get name;

  /// The fully qualified name (alias for [name]).
  String get qualifiedName => name;

  /// The namespace prefix, or `null`.
  String? get namespacePrefix {
    if (_localName == null) _splitName();
    return _namespacePrefix;
  }

  String? _namespacePrefix;

  /// The local name, excluding the namespace prefix.
  String get localName {
    if (_localName == null) _splitName();
    return _localName!;
  }

  String? _localName;

  /// Hold an optional reference to the namespace URI.
  String? _namespaceUri;

  /// The namespace URI, or `null`.
  String? get namespaceUri => _namespaceUri;

  /// Internal helper to attach the namespace to the event.
  @internal
  void attachNamespace(String namespaceUri) {
    assert(_namespaceUri == null, 'Namespace is already initialized.');
    _namespaceUri = namespaceUri;
  }

  void _splitName() {
    final (:prefix, :local) = splitQualifiedName(name);
    _namespacePrefix = prefix;
    _localName = local;
  }
}
