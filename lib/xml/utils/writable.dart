part of xml;

/**
 * Mixin to serialize XML to a [StringBuffer].
 */
abstract class XmlWritable {

  /**
   * Write this object to a `buffer`.
   */
  void writeTo(StringBuffer buffer);

  /**
   * Write this object in a 'pretty' format to a `buffer`.
   */
  void writePrettyTo(StringBuffer buffer, int level, String indent) => writeTo(buffer);

  /**
   * Return an XML string of this object.
   */
  @override
  String toString() => toXmlString();

  /**
   * Return an XML string of this object.
   *
   * If `pretty` is set to `true` the output is nicely reformatted, otherwise the
   * tree is emitted verbatimely.
   *
   * The option `indent` is only used when pretty formatting to customize the
   * indention of nodes, by default nodes are indented with 2 spaces.
   */
  String toXmlString({bool pretty: false, String indent: '  '}) {
    var buffer = new StringBuffer();
    if (pretty) {
      writePrettyTo(buffer, 0, indent);
    } else {
      writeTo(buffer);
    }
    return buffer.toString();
  }

  void _writeIndentTo(StringBuffer buffer, int level, String indent, [bool newline = true]) {
    if (indent != null) {
      if (newline) {
        _writeNewline(buffer);
      }
      for (int i = 0; i < level; i++) {
        buffer.write(indent);
      }
    }
  }

  void _writeNewline(StringBuffer buffer) {
    if (buffer.isNotEmpty) {
      buffer.write('\n');
    }
  }

}
