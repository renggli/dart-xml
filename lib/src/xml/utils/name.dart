import 'package:meta/meta.dart';

import '../exceptions/parser_exception.dart';
import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../visitors/visitor.dart';
import 'name_parser.dart';
import 'namespace.dart' as ns;
import 'token.dart';

/// XML entity name.
@immutable
abstract class XmlName with XmlHasVisitor, XmlHasWriter {
  /// Creates an [XmlName] from a [qualified] name and an optional [namespaceUri].
  factory(String qualified, {String? namespaceUri}) {
    final (:prefix, :local) = splitQualifiedName(qualified);
    return _XmlName._(
      qualified: qualified,
      prefix: prefix,
      local: local,
      namespaceUri: namespaceUri,
    );
  }

  /// Creates an [XmlName] from a parsed string.
  ///
  /// This code also parsed extended qualified names such as `Q{uri}local` or
  /// `Q{uri}prefix:local`. If the name is not in the extended qualified form,
  /// the function tries to resolve the namespace URI from the given
  /// prefix-to-uri [namespaceUris] map. If the namespace URI is still not
  /// defined, [namespaceUri] is used instead (`null` by default).
  ///
  /// Throws a [XmlParserException] if the name is in an invalid extended form.
  factory parse(
    String name, {
    String? namespaceUri,
    Map<String, String>? namespaceUris,
  }) {
    final (:prefix, :local, :uri) = parseEQNameParts(name);
    final effectiveUri =
        uri ??
        (prefix != null && namespaceUris != null
            ? namespaceUris[prefix]
            : null) ??
        namespaceUri;
    final qualified = prefix == null
        ? local
        : '$prefix${XmlToken.namespace}$local';
    return _XmlName._(
      qualified: qualified,
      prefix: prefix,
      local: local,
      namespaceUri: effectiveUri,
    );
  }

  /// Creates an [XmlName] from a [local] name and an optional [prefix] and
  /// optional [namespaceUri].
  const factory parts(String local, {String? prefix, String? namespaceUri}) =
      _XmlName.parts;

  /// Creates an [XmlName] for a namespace declaration with an optional [name].
  const factory namespace({String? name}) = _XmlName.namespace;

  /// Creates an [XmlName] with the given [qualified] name and an optional
  /// [namespaceUri].
  @Deprecated(
    'Use `XmlName(String qualified, {String? namespaceUri})` instead, or if a '
    'const constructor is needed `XmlName.parts(String local, {String? prefix, '
    'String? namespaceUri}).',
  )
  const factory qualified(String qualified, {String? namespaceUri}) =
      _DeprecatedXmlName;

  const new _();

  /// The fully qualified name, including the namespace prefix.
  String get qualified;

  /// The namespace prefix, or `null`.
  String? get prefix;

  /// The local name, excluding the namespace prefix.
  String get local;

  /// The namespace URI, or `null`.
  String? get namespaceUri;

  /// The Extended QName (EQName) in the form `Q{uri}local`, or the [qualified]
  /// name if the namespace URI is not defined or empty.
  String get extendedQualified => namespaceUri != null
      ? '${XmlToken.openQualifiedUrl}$namespaceUri${XmlToken.closeQualifiedUrl}$local'
      : qualified;

  /// Returns a new [XmlName] with the given [namespaceUri].
  XmlName withNamespaceUri(String? namespaceUri) => _XmlName._(
    qualified: qualified,
    prefix: prefix,
    local: local,
    namespaceUri: namespaceUri,
  );

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

// Internal implementation to replace the current [XmlName]. It contains
// precomputed qualified, prefix, local and name.
class _XmlName extends XmlName {
  const new _({
    required this.qualified,
    required this.prefix,
    required this.local,
    required this.namespaceUri,
  }) : super._();

  const new parts(String local, {String? prefix, String? namespaceUri})
    : this._(
        qualified: prefix == null
            ? local
            : '$prefix${XmlToken.namespace}$local',
        local: local,
        prefix: prefix,
        namespaceUri: namespaceUri,
      );

  const new namespace({String? name})
    : this._(
        qualified: name == null
            ? ns.xmlns
            : '${ns.xmlns}${XmlToken.namespace}$name',
        prefix: name == null ? null : ns.xmlns,
        local: name ?? ns.xmlns,
        namespaceUri: ns.xmlnsUri,
      );

  @override
  final String qualified;

  @override
  final String? prefix;

  @override
  final String local;

  @override
  final String? namespaceUri;
}

// Old implementation of [XmlName] that can be const constructed, but requires
// repeated splitting of prefix and local name.
class _DeprecatedXmlName extends XmlName {
  const new(this.qualified, {this.namespaceUri}) : super._();

  @override
  final String qualified;

  @override
  final String? namespaceUri;

  @override
  String? get prefix {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(0, index) : null;
  }

  @override
  String get local {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(index + 1) : qualified;
  }
}
