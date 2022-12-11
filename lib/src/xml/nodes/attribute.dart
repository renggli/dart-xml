import '../../shared/names/name.dart';
import '../../shared/names/named.dart';
import '../enums/attribute_type.dart';
import '../enums/node_type.dart';
import '../mixins/has_parent.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML attribute node.
class XmlAttribute extends XmlNode with XmlNamed, XmlHasParent<XmlNode> {
  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, this.value,
      [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]);

  @override
  final XmlName name;

  /// The value of the attribute.
  String value;

  /// Return the quote type.
  final XmlAttributeType attributeType;

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  XmlAttribute copy() => XmlAttribute(name, value, attributeType);

  @override
  void accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
