part of xml;

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
    assert(this.name._parent == null);
    this.name._parent = this;
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitAttribute(this);

}

/// Enum of the attribute quote types.
enum XmlAttributeType {
  SINGLE_QUOTE,
  DOUBLE_QUOTE
}