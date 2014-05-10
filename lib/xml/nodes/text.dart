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
  
  @override
  void prettyWriteTo(StringBuffer buffer, {String indent: '', int indentLevel: 0})
  {
    // if text is purely whitespace, don't output to the buffer
    // the indentation and newlines will be handled elsewhere
    if(text != null && text.trim().isNotEmpty)
    {
      writeTo(buffer);
    }
  }

}
