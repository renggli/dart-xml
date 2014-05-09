part of xml;

/**
 * XML doctype node.
 */
class XmlDoctype extends XmlData {

  /**
   * Create a doctype section with `text`.
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

  @override
  void prettyWriteTo(StringBuffer buffer, {String indent, int indentLevel}) {
    _doPrettyIndent(buffer, indent, indentLevel);
    writeTo(buffer);
    buffer.write('\n');
  }

}
