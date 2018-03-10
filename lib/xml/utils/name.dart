library xml.utils.name;

import 'package:xml/xml/builder.dart' show NamespaceData;
import 'package:xml/xml/utils/owned.dart' show XmlOwned;
import 'package:xml/xml/utils/prefix_name.dart' show XmlPrefixName;
import 'package:xml/xml/utils/simple_name.dart' show XmlSimpleName;
import 'package:xml/xml/utils/writable.dart' show XmlWritable;
import 'package:xml/xml/visitors/visitable.dart' show XmlVisitable;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

// separator between prefix and local name
final separator = ':';

// xml namespace declarations
final xml = 'xml';
final xmlData = new NamespaceData(xml, true);
final xmlUri = 'http://www.w3.org/XML/1998/namespace';
final xmlns = 'xmlns';

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

  /// Creates a qualified [XmlName] from a `local` name and an optional `prefix`.
  factory XmlName(String local, [String prefix]) =>
      prefix == null || prefix.isEmpty
          ? new XmlSimpleName(local)
          : new XmlPrefixName(prefix, local, '$prefix$separator$local');

  /// Create a [XmlName] by parsing the provided `qualified` name.
  factory XmlName.fromString(String qualified) {
    var index = qualified.indexOf(separator);
    if (index > 0) {
      var prefix = qualified.substring(0, index);
      var local = qualified.substring(index + 1, qualified.length);
      return new XmlPrefixName(prefix, local, qualified);
    } else {
      return new XmlSimpleName(qualified);
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
