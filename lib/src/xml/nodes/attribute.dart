import '../enums/attribute_type.dart';
import '../enums/node_type.dart';
import '../mixins/has_name.dart';
import '../mixins/has_parent.dart';
import '../utils/name.dart';
import '../utils/namespace.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML attribute node.
class XmlAttribute extends XmlNode with XmlHasName, XmlHasParent<XmlNode> {
  /// Create an attribute with `name` and `value`.
  new(
    this.name,
    this.value, [
    this.attributeType = XmlAttributeType.DOUBLE_QUOTE,
  ]);

  @override
  final XmlName name;

  /// The value of the attribute.
  @override
  String value;

  /// Return the quote type.
  final XmlAttributeType attributeType;

  /// Return `true` if this attribute is a namespace declaration (`xmlns` or
  /// `xmlns:*`).
  bool get isNamespaceDeclaration =>
      name.prefix == xmlns || name.local == xmlns;

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  XmlAttribute copy() => XmlAttribute(name, value, attributeType);

  @override
  void accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
