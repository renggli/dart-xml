library xml.utils.token;

/// Shared tokens for XML reading and writing.
class XmlToken {
  static const String DOUBLE_QUOTE = '"';
  static const String SINGLE_QUOTE = "'";
  static const String EQUALS = '=';
  static const String WHITESPACE = ' ';
  static const String OPEN_COMMENT = '<!--';
  static const String CLOSE_COMMENT = '-->';
  static const String OPEN_CDATA = '<![CDATA[';
  static const String CLOSE_CDATA = ']]>';
  static const String OPEN_ELEMENT = '<';
  static const String CLOSE_ELEMENT = '>';
  static const String OPEN_END_ELEMENT = '</';
  static const String CLOSE_END_ELEMENT = '/>';
  static const String OPEN_DOCTYPE = '<!DOCTYPE';
  static const String CLOSE_DOCTYPE = '>';
  static const String OPEN_DOCTYPE_BLOCK = '[';
  static const String CLOSE_DOCTYPE_BLOCK = ']';
  static const String OPEN_PROCESSING = '<?';
  static const String CLOSE_PROCESSING = '?>';
}
