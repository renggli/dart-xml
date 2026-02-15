import '../nodes/attribute.dart';

// Internal class to define a namespace.
class NamespaceDefinition {
  NamespaceDefinition({required this.attribute, this.prefix, this.uri});

  // Attribute with the definition.
  final XmlAttribute attribute;

  // The namespace prefix.
  final String? prefix;

  // The namespace URI.
  final String? uri;

  // Whether the namespace has been used.
  bool isUsed = false;
}
