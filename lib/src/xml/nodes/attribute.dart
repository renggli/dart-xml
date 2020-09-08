import '../mixins/has_name.dart';
import '../mixins/has_parent.dart';
import '../utils/attribute_type.dart';
import '../utils/name.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML attribute node.
class XmlAttribute extends XmlNode with XmlHasParent<XmlNode>, XmlHasName {
  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, this.value,
      [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]) {
    name.attachParent(this);
  }

  @override
  final XmlName name;

  /// The value of the attribute.
  String value;

  /// Return the quote type.
  final XmlAttributeType attributeType;

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  XmlAttribute copy() => XmlAttribute(name.copy(), value, attributeType);

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
