/// Shared tokens for XML reading and writing.
class XmlToken {
  static const String doubleQuote = '"';
  static const String singleQuote = "'";
  static const String equals = '=';
  static const String namespace = ':';
  static const String whitespace = ' ';
  static const String openComment = '<!--';
  static const String closeComment = '-->';
  static const String openCDATA = '<![CDATA[';
  static const String closeCDATA = ']]>';
  static const String openElement = '<';
  static const String closeElement = '>';
  static const String openEndElement = '</';
  static const String closeEndElement = '/>';
  static const String openDeclaration = '<?xml';
  static const String closeDeclaration = '?>';
  static const String openDoctype = '<!DOCTYPE';
  static const String closeDoctype = '>';
  static const String openDoctypeBlock = '[';
  static const String closeDoctypeBlock = ']';
  static const String openProcessing = '<?';
  static const String closeProcessing = '?>';
}
