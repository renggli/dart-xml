part of xml;

/**
 * XML CDATA node.
 */
class XmlCDATA extends XmlData {

  /**
   * Create a CDATA section with `text`.
   */
  XmlCDATA(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<![CDATA[');
    buffer.write(text);
    buffer.write(']]>');
  }

  @override
  void prettyWriteTo(StringBuffer buffer, {String indent}) {
    _doPrettyIndent(buffer, indent, ancestors.length - 1);
    writeTo(buffer);
  }

}
