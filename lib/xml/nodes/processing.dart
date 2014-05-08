part of xml;

/**
 * XML processing instruction.
 */
class XmlProcessing extends XmlData {

  /**
   * Return the processing target.
   */
  final String target;

  /**
   * Create a processing node with `target` and `text`.
   */
  XmlProcessing(this.target, String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<?');
    buffer.write(target);
    if (!text.isEmpty) {
      buffer.write(' ');
      buffer.write(text);
    }
    buffer.write('?>');
  }

  @override
  void prettyWriteTo(StringBuffer buffer, {String indent}) {
    _doPrettyIndent(buffer, indent, ancestors.length - 1);
    writeTo(buffer);
    buffer.write('\n');
  }

}
