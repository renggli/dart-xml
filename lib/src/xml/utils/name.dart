import 'package:meta/meta.dart';

import '../exceptions/parser_exception.dart';
import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../visitors/visitor.dart';
import 'namespace.dart' as ns;
import 'token.dart';

/// XML entity name.
@immutable
class XmlName with XmlHasVisitor, XmlHasWriter {
  /// Creates a [XmlName] with the given [qualified] name and an optional
  /// [namespaceUri].
  const XmlName.qualified(this.qualified, {this.namespaceUri});

  /// Creates an [XmlName] from a [local] name and an optional [prefix] and
  /// optional [namespaceUri].
  const XmlName.parts(String local, {String? prefix, this.namespaceUri})
    : qualified = prefix == null ? local : '$prefix${XmlToken.namespace}$local';

  /// Creates an [XmlName] from a parsed string.
  ///
  /// This code also parsed extended qualified names such as `Q{uri}local` or
  /// `Q{uri}prefix:local`. If the name is not in the extended qualified form,
  /// the function tries to resolve the namespace URI from the given
  /// prefix-to-uri [namespaceUris] map. If the namespace URI is still not
  /// defined, [namespaceUri] is used instead (`null` by default).
  ///
  /// Throws a [XmlParserException] if the name is in an invalid extended form.
  factory XmlName.parse(
    String name, {
    String? namespaceUri,
    Map<String, String>? namespaceUris,
  }) {
    String? uri;
    // Handle the extended qualified name first.
    if (name.startsWith(XmlToken.openQualifiedUrl)) {
      final end = name.indexOf(XmlToken.closeQualifiedUrl);
      if (end == -1) {
        throw XmlParserException('Invalid extended qualified name: $name');
      } else if (end > XmlToken.openQualifiedUrl.length) {
        uri = name.substring(XmlToken.openQualifiedUrl.length, end);
      }
      name = name.substring(end + XmlToken.closeQualifiedUrl.length);
    }
    // Handle the prefix name lookup.
    if (uri == null && namespaceUris != null) {
      final index = name.indexOf(XmlToken.namespace);
      if (index > 0) {
        final prefix = name.substring(0, index);
        if (namespaceUris.containsKey(prefix)) {
          uri = namespaceUris[prefix];
        }
      }
    }
    // Handle the default namespace.
    return XmlName.qualified(name, namespaceUri: uri ?? namespaceUri);
  }

  /// Creates an [XmlName] for a namespace declaration with an optional [name].
  const XmlName.namespace({String? name})
    : this.qualified(
        name == null ? ns.xmlns : '${ns.xmlns}${XmlToken.namespace}$name',
        namespaceUri: ns.xmlnsUri,
      );

  /// Creates a qualified [XmlName] from a [localName] name and an optional
  /// [namespacePrefix].
  @Deprecated('Use `XmlName.parts` instead')
  const XmlName(String localName, [String? namespacePrefix])
    : qualified = namespacePrefix == null
          ? localName
          : '$namespacePrefix${XmlToken.namespace}$localName',
      namespaceUri = null;

  /// Create a [XmlName] by parsing the provided [qualified] name.
  @Deprecated('Use `XmlName.qualified` instead')
  const XmlName.fromString(this.qualified) : namespaceUri = null;

  /// The fully qualified name, including the namespace prefix.
  final String qualified;

  /// The namespace URI, or `null`.
  final String? namespaceUri;

  /// The namespace prefix, or `null`.
  String? get prefix {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(0, index) : null;
  }

  /// The local name, excluding the namespace prefix.
  String get local {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(index + 1) : qualified;
  }

  /// The Extended QName (EQName) in the form `Q{uri}local`, or the [qualified]
  /// name if the namespace URI is not defined or empty.
  String get extendedQualified => namespaceUri != null
      ? '${XmlToken.openQualifiedUrl}$namespaceUri${XmlToken.closeQualifiedUrl}$local'
      : qualified;

  @override
  String toString() => qualified;

  @override
  bool operator ==(Object other) {
    if (other is! XmlName) return false;
    // Prefix doesn't matter, if the namespaces match.
    if (namespaceUri != null || other.namespaceUri != null) {
      return local == other.local && namespaceUri == other.namespaceUri;
    }
    // Otherwise compare the qualified name.
    return qualified == other.qualified;
  }

  @override
  int get hashCode => Object.hash(local, namespaceUri);

  @override
  void accept(XmlVisitor visitor) => visitor.visitName(this);
}
