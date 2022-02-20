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

  // https://en.wikipedia.org/wiki/QName
  static const String nameStartChars = ':A-Z_a-z'
      '\u00c0-\u00d6'
      '\u00d8-\u00f6'
      '\u00f8-\u02ff'
      '\u0370-\u037d'
      '\u037f-\u1fff'
      '\u200c-\u200d'
      '\u2070-\u218f'
      '\u2c00-\u2fef'
      '\u3001-\ud7ff'
      '\uf900-\ufdcf'
      '\ufdf0-\ufffd';
  static const String nameChars = '$nameStartChars'
      '-.0-9'
      '\u00b7'
      '\u0300-\u036f'
      '\u203f-\u2040';
}
