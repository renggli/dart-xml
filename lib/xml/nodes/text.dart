part of xml;

/**
 * XML text node.
 */
class XmlText extends XmlData {

  /**
   * Create a text node with `text`.
   */
  XmlText(String text): super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write(_encodeXmlText(text));
  }

}
