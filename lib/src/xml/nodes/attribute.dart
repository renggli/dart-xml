import '../mixins/has_name.dart';
import '../mixins/has_parent.dart';
import '../utils/attribute_type.dart';
import '../utils/name.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML attribute node.
class XmlAttribute extends XmlNode with XmlHasParent<XmlNode>, XmlHasName {
  String _value;

  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, String value,
      [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]) {
    name.attachParent(this);
    this.value = value;
  }

  @override
  final XmlName name;

  /// Return the value of the attribute.
  String get value => _value;

  /// Update the value of the attribute.
  set value(String value) {
    ArgumentError.checkNotNull(value, 'value');
    _value = value;
  }

  /// Return the quote type.
  final XmlAttributeType attributeType;

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
