import 'package:meta/meta.dart';

import '../mixins/has_parent.dart';
import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../mixins/xml_camparable.dart';
import '../nodes/node.dart';
import '../visitors/visitor.dart';
import 'prefix_name.dart';
import 'simple_name.dart';
import 'token.dart';

/// XML entity name.
abstract class XmlName extends Object
    with
        XmlComparable,
        XmlHasVisitor,
        XmlHasWriter,
        XmlHasParent<XmlNode>,
        Comparable<XmlName> {
  /// Creates a qualified [XmlName] from a `local` name and an optional
  /// `prefix`.
  factory XmlName(String local, [String? prefix]) =>
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

  @internal
  XmlName.internal();

  /// Return the namespace prefix, or `null`.
  String? get prefix;

  /// Return the local name, excluding the namespace prefix.
  String get local;

  /// Return the fully qualified name, including the namespace prefix.
  String get qualified;

  /// Return the namespace URI, or `null`.
  String? get namespaceUri;

  XmlName copy();

  @override
  void accept(XmlVisitor visitor) => visitor.visitName(this);

  @override
  List<Object?> get comparable => [local, namespaceUri];

  @override
  bool? additionalComparator(Object other) =>
      other is XmlName && (other.local == local && other.prefix == prefix)
          ? true
          : null;

  String get _compareToName => '$namespaceUri:$local';

  @override
  // comparing pseudo-namespace String preserving order of [namespaceUri]
  int compareTo(XmlName other) =>
      _compareToName.compareTo(other._compareToName);
}
