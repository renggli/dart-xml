import 'package:meta/meta.dart';

import '../../xml/utils/token.dart';

@immutable
class XmlName {
  factory XmlName(String name, {String? namespaceUri}) {
    final index = name.indexOf(XmlToken.namespace);
    if (index > 0) {
      return XmlName.fromParts(
          prefix: name.substring(0, index),
          local: name.substring(index + 1),
          namespaceUri: namespaceUri);
    } else {
      return XmlName.fromParts(local: name, namespaceUri: namespaceUri);
    }
  }

  factory XmlName.fromParts({
    String? prefix,
    required String local,
    String? qualified,
    String? namespaceUri,
  }) {
    if (prefix != null && prefix.isEmpty) prefix = null;
    if (qualified == null || qualified.isEmpty) {
      qualified = prefix == null ? local : '$prefix${XmlToken.namespace}$local';
    }
    if (namespaceUri != null && namespaceUri.isEmpty) namespaceUri = null;
    return XmlName._(prefix, local, qualified, namespaceUri);
  }

  /// Internal constructor.
  XmlName._(this.prefix, this.local, this.qualified, this.namespaceUri);

  /// Return the namespace prefix, or `null`.
  final String? prefix;

  /// Return the local name, excluding the namespace prefix.
  final String local;

  /// Return the fully qualified name, including the namespace prefix.
  final String qualified;

  /// Return the namespace URI, or `null`.
  final String? namespaceUri;
}
