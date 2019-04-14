library xml.nodes.attribute;

import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/utils/attribute_type.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xml/utils/named.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// XML attribute node.
class XmlAttribute extends XmlNode implements XmlNamed {
  @override
  final XmlName name;

  String _value;

  /// Return the value of the attribute.
  String get value => _value;

  /// Update the value of the attribute.
  set value(String value) {
    ArgumentError.checkNotNull(value, 'value');
    _value = value;
  }

  /// Return the quote type.
  final XmlAttributeType attributeType;

  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, String value,
      [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]) {
    name.attachParent(this);
    this.value = value;
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
