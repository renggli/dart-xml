import '../enums/node_type.dart';
import '../mixins/has_name.dart';
import '../utils/name.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML namespace node.
class XmlNamespace extends XmlNode with XmlHasName {
  /// Create a namespace node with `prefix` and `uri`.
  XmlNamespace(this.prefix, this.uri);

  /// The namespace prefix.
  final String prefix;

  /// The namespace URI.
  final String uri;

  /// The namespace name.
  @override
  XmlName get name => XmlName.qualified(prefix);

  @override
  String get value => uri;

  @override
  XmlNodeType get nodeType => XmlNodeType.NAMESPACE;

  @override
  XmlNamespace copy() => XmlNamespace(prefix, uri);

  @override
  void accept(XmlVisitor visitor) => visitor.visitNamespace(this);
}
