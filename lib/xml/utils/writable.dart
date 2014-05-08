part of xml;

/**
 * Mixin to serialize XML to a [StringBuffer].
 */
abstract class XmlWritable {

  /**
   * Write the this object to a `buffer`.
   */
  void writeTo(StringBuffer buffer);

  /**
   * Returns an XML string of this object.
   */
  @override
  String toString() {
    var buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  /**
   * Write the this object in a 'pretty' format to a `buffer`.
   */
  void prettyWriteTo(StringBuffer buffer, {String indent: ''});

  /**
   * Returns an XML string of this object.
   */
  String toPrettyString({String indent: '    '}) {
    var buffer = new StringBuffer();
    prettyWriteTo(buffer, indent: indent);
    return buffer.toString();
  }

  void _doPrettyIndent(StringBuffer buffer, String indent, int numIndents, [bool startNewline = true]) {
    if (indent != null) {
      if (startNewline) {
        buffer.write('\n');
      }
      for (int i = 0; i < numIndents; i++) {
        buffer.write(indent);
      }
    }
  }

}
