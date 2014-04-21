part of xml;

/**
 * XML doctype node.
 */
class XmlDoctype extends XmlData {

  /**
   * Create a doctype section with [text].
   */
  XmlDoctype(String text): super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<!DOCTYPE ');
    buffer.write(text);
    buffer.write('>');
  }

}
