part of xml;

/**
 * XML comment node.
 */
class XmlComment extends XmlData {

  /**
   * Create a comment section with `text`.
   */
  XmlComment(String text): super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<!--');
    buffer.write(text);
    buffer.write('-->');
  }

  @override
  void prettyWriteTo(StringBuffer buffer, {String indent, int indentLevel}) {
    _doPrettyIndent(buffer, indent, indentLevel);
    writeTo(buffer);
  }

}
