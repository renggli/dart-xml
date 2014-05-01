part of xml;

/**
 * XML element node.
 */
class XmlElement extends XmlBranch {

  /**
   * Return the name of the element.
   */
  final XmlName name;

  @override
  final List<XmlAttribute> attributes;

  /**
   * Create an [XmlElement] with the given [name], [attributes], and [children].
   */
  XmlElement(XmlName name, Iterable<XmlAttribute> attributes, Iterable<XmlNode> children)
      : super(children),
        name = name,
        attributes = attributes.toList(growable: false) {
    for (var attribute in attributes) {
      attribute._parent = this;
    }
  }

  /**
   * Return the attribute value with the given [name].
   */
  String getAttribute(name, {String namespace}) {
    var attribute = getAttributeNode(name, namespace: namespace);
    return attribute != null ? attribute.value : null;
  }

  /**
   * Return the attribute node with the given [name].
   */
  XmlAttribute getAttributeNode(String name, {String namespace}) {
    var query = new XmlName._forQuery(name, namespace);
    return attributes.firstWhere(
        (node) => query.matches(node.name),
        orElse: () => null);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<');
    name.writeTo(buffer);
    for (var attribute in attributes) {
      buffer.write(' ');
      attribute.writeTo(buffer);
    }
    if (children.isEmpty) {
      buffer.write(' />');
    } else {
      buffer.write('>');
      super.writeTo(buffer);
      buffer.write('</');
      name.writeTo(buffer);
      buffer.write('>');
    }
  }

}
