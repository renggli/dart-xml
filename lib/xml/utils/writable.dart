part of xml;

/**
 * Mixin to serialize XML to a [StringBuffer].
 */
abstract class XmlWritable {

  /**
   * Write the this object to a [buffer].
   */
  void writeTo(StringBuffer buffer);

  @override
  String toString() {
    var buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

}
