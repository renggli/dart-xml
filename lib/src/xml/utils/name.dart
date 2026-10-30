// ignore_for_file: prefer_initializing_formals

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
  /// Creates an [XmlName] with the given [qualified] name and an optional
  /// [namespaceUri].
  const new qualified(
    this.qualified, {
    this.namespaceUri,
    String? local,
    String? prefix,
  }) : _local = local,
       _prefix = prefix;

  /// Creates an [XmlName] from a [local] name and an optional [prefix] and
  /// optional [namespaceUri].
  const new parts(String local, {String? prefix, this.namespaceUri})
    : qualified = prefix == null ? local : '$prefix${XmlToken.namespace}$local',
      _local = local,
      _prefix = prefix;

  /// Creates an [XmlName] by splitting the [qualified] name into prefix and local.
  factory fromQualified(String qualified, {String? namespaceUri}) {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0
        ? XmlName.qualified(
            qualified,
            namespaceUri: namespaceUri,
            prefix: qualified.substring(0, index),
            local: qualified.substring(index + 1),
          )
        : XmlName.qualified(
            qualified,
            namespaceUri: namespaceUri,
            local: qualified,
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
    final index = name.indexOf(XmlToken.namespace);
    final String? prefix;
    final String local;
    if (index > 0) {
      prefix = name.substring(0, index);
      local = name.substring(index + 1);
      if (uri == null && namespaceUris != null) {
        uri = namespaceUris[prefix];
      }
    } else {
      prefix = null;
      local = name;
    }
    // Handle the default namespace.
    return XmlName.qualified(
      name,
      namespaceUri: uri ?? namespaceUri,
      prefix: prefix,
      local: local,
    );
  }

  /// Creates an [XmlName] for a namespace declaration with an optional [name].
  const new namespace({String? name})
    : this.qualified(
        name == null ? ns.xmlns : '${ns.xmlns}${XmlToken.namespace}$name',
        namespaceUri: ns.xmlnsUri,
        prefix: name == null ? null : ns.xmlns,
        local: name ?? ns.xmlns,
      );

  /// Creates a qualified [XmlName] from a [localName] name and an optional
  /// [namespacePrefix].
  @Deprecated('Use `XmlName.parts` instead')
  const new(String localName, [String? namespacePrefix])
    : qualified = namespacePrefix == null
          ? localName
          : '$namespacePrefix${XmlToken.namespace}$localName',
      namespaceUri = null,
      _local = localName,
      _prefix = namespacePrefix;

  /// Creates an [XmlName] by parsing the provided [qualified] name.
  @Deprecated('Use `XmlName.qualified` instead')
  const new fromString(this.qualified)
    : namespaceUri = null,
      _local = null,
      _prefix = null;

  /// The fully qualified name, including the namespace prefix.
  final String qualified;

  /// The namespace URI, or `null`.
  final String? namespaceUri;

  final String? _local;
  final String? _prefix;

  static final _cache = Expando<({String local, String? prefix})>();

  /// The namespace prefix, or `null`.
  String? get prefix {
    if (_local != null) return _prefix;
    final cached = _cache[this];
    if (cached != null) return cached.prefix;
    return _splitAndCache().prefix;
  }

  /// The local name, excluding the namespace prefix.
  String get local {
    if (_local != null) return _local;
    final cached = _cache[this];
    if (cached != null) return cached.local;
    return _splitAndCache().local;
  }

  ({String local, String? prefix}) _splitAndCache() {
    final index = qualified.indexOf(XmlToken.namespace);
    final result = index > 0
        ? (
            local: qualified.substring(index + 1),
            prefix: qualified.substring(0, index),
          )
        : (local: qualified, prefix: null);
    _cache[this] = result;
    return result;
  }

  /// The Extended QName (EQName) in the form `Q{uri}local`, or the [qualified]
  /// name if the namespace URI is not defined or empty.
  String get extendedQualified => namespaceUri != null
      ? '${XmlToken.openQualifiedUrl}$namespaceUri${XmlToken.closeQualifiedUrl}$local'
      : qualified;

  /// Returns a new [XmlName] with the given [namespaceUri].
  XmlName withNamespaceUri(String? namespaceUri) => XmlName.qualified(
    qualified,
    namespaceUri: namespaceUri,
    local: _local,
    prefix: _prefix,
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
