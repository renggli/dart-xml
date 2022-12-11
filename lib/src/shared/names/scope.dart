import 'package:meta/meta.dart';

abstract class NamespaceScope {
  // The prefix of xml-namespace declarations.
  static const String xmlns = 'xmlns';

  // The prefix of the standard xml-namespace.
  static const xml = 'xml';

  // The namespace URI of the standard xml-namespace.
  static const xmlUri = 'http://www.w3.org/XML/1998/namespace';

  /// Adds the given namespace to the scope.
  void add(String? prefix, String uri);

  /// Removes the given namespace from the scope.
  void remove(String? prefix);

  /// Returns the namespace URI of the specified prefix.
  ///
  /// Starts the search in this scope and continues with the parents. Returns
  /// `null` if no default namespace is defined.
  String? lookupUri(String? prefix);

  /// Returns the namespace prefix of the specified URI.
  ///
  /// Starts the search in this scope and continues with the parents. Returns
  /// `null` if no default namespace is defined.
  String? lookupPrefix(String uri);

  /// Returns a namespace declaration name with the provided prefix.
  @protected
  String namespaceDeclarationName(String? prefix) =>
      prefix == null ? xmlns : '$xmlns:$prefix';
}
