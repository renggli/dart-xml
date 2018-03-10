library xml.nodes.attribute;

import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/attribute_type.dart' show XmlAttributeType;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/utils/named.dart' show XmlNamed;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML attribute node.
class XmlAttribute extends XmlNode implements XmlNamed {
  @override
  final XmlName name;

  String _value;

  /// Return the value of the attribute.
  String get value => _value;

  /// Update the value of the attribute.
  set value(String value) {
    if (value == null) {
      throw new ArgumentError.notNull('value');
    }
    _value = value;
  }

  /// Return the quote type.
  final XmlAttributeType attributeType;

  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, String value, [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]) {
    name.attachParent(this);
    this.value = value;
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
