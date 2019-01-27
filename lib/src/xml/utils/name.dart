library xml.utils.name;

import 'package:xml/src/xml/builder.dart';
import 'package:xml/src/xml/utils/owned.dart';
import 'package:xml/src/xml/utils/prefix_name.dart';
import 'package:xml/src/xml/utils/simple_name.dart';
import 'package:xml/src/xml/utils/token.dart';
import 'package:xml/src/xml/utils/writable.dart';
import 'package:xml/src/xml/visitors/visitable.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

// xml namespace declarations
const String xml = 'xml';
const String xmlUri = 'http://www.w3.org/XML/1998/namespace';
const String xmlns = 'xmlns';
final NamespaceData xmlData = NamespaceData(xml, true);

/// XML entity name.
abstract class XmlName extends Object with XmlVisitable, XmlWritable, XmlOwned {
  /// Return the namespace prefix, or `null`.
  String get prefix;

  /// Return the local name, excluding the namespace prefix.
  String get local;

  /// Return the fully qualified name, including the namespace prefix.
  String get qualified;

  /// Return the namespace URI, or `null`.
  String get namespaceUri;

  /// Creates a qualified [XmlName] from a `local` name and an optional
  /// `prefix`.
  factory XmlName(String local, [String prefix]) =>
      prefix == null || prefix.isEmpty
          ? XmlSimpleName(local)
          : XmlPrefixName(prefix, local, '$prefix${XmlToken.namespace}$local');

  /// Create a [XmlName] by parsing the provided `qualified` name.
  factory XmlName.fromString(String qualified) {
    final index = qualified.indexOf(XmlToken.namespace);
    if (index > 0) {
      final prefix = qualified.substring(0, index);
      final local = qualified.substring(index + 1);
      return XmlPrefixName(prefix, local, qualified);
    } else {
      return XmlSimpleName(qualified);
    }
  }

  XmlName.internal();

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitName(this);

  @override
  bool operator ==(Object other) =>
      other is XmlName &&
      other.local == local &&
      other.namespaceUri == namespaceUri;

  @override
  int get hashCode => qualified.hashCode;
}
