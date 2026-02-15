import 'package:meta/meta.dart';

import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../visitors/visitor.dart';
import 'namespace.dart' as ns;
import 'token.dart';

/// XML entity name.
@immutable
class XmlName with XmlHasVisitor, XmlHasWriter {
  /// Creates a qualified [XmlName] with the given [qualified] name.
  const XmlName.qualified(this.qualified, {this.namespaceUri});

  /// Creates an [XmlName] from a [localName] and an optional [namespacePrefix].
  const XmlName.parts(
    String localName, {
    String? namespacePrefix,
    this.namespaceUri,
  }) : qualified = namespacePrefix == null
           ? localName
           : '$namespacePrefix${XmlToken.namespace}$localName';

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

  @override
  String toString() => qualified;

  @override
  bool operator ==(Object other) =>
      other is XmlName &&
      other.qualified == qualified &&
      other.namespaceUri == namespaceUri;

  @override
  int get hashCode => Object.hash(qualified, namespaceUri);

  @override
  void accept(XmlVisitor visitor) => visitor.visitName(this);
}
