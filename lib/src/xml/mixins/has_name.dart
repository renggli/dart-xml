import '../utils/name.dart';

/// Mixin for all nodes with a name.
mixin XmlHasName {
  /// The name of the node.
  XmlName get name;

  /// The fully qualified name, including the namespace prefix.
  String get qualifiedName => name.qualified;

  /// The local name, excluding the namespace prefix.
  String get localName => name.local;

  /// The namespace prefix, or `null`.
  String? get namespacePrefix => name.prefix;

  /// The namespace URI, or `null`.
  String? get namespaceUri => name.namespaceUri;
}
