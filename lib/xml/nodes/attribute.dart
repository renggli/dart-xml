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

  /// Return the value of the attribute.
  final String value;

  /// Return the quote type.
  final XmlAttributeType attributeType;

  /// Create an attribute with `name` and `value`.
  XmlAttribute(this.name, this.value, [this.attributeType = XmlAttributeType.DOUBLE_QUOTE]) {
    name.adoptParent(this);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitAttribute(this);
}
