/// Shared tokens for XML reading and writing.
class XmlToken {
  static const doubleQuote = '"';
  static const singleQuote = "'";
  static const equals = '=';
  static const namespace = ':';
  static const whitespace = ' ';
  static const openComment = '<!--';
  static const closeComment = '-->';
  static const openCDATA = '<![CDATA[';
  static const closeCDATA = ']]>';
  static const openElement = '<';
  static const closeElement = '>';
  static const openEndElement = '</';
  static const closeEndElement = '/>';
  static const openDeclaration = '<?xml';
  static const closeDeclaration = '?>';
  static const openDoctype = '<!DOCTYPE';
  static const closeDoctype = '>';
  static const openDoctypeIntSubset = '[';
  static const closeDoctypeIntSubset = ']';
  static const doctypeSystemId = 'SYSTEM';
  static const doctypePublicId = 'PUBLIC';
  static const doctypeElementDecl = '<!ELEMENT';
  static const doctypeAttlistDecl = '<!ATTLIST';
  static const doctypeEntityDecl = '<!ENTITY';
  static const doctypeNotationDecl = '<!NOTATION';
  static const doctypeDeclEnd = '>';
  static const doctypeReferenceStart = '%';
  static const doctypeReferenceEnd = ';';
  static const openProcessing = '<?';
  static const closeProcessing = '?>';
  static const entityStart = '&';
  static const entityEnd = ';';

  // https://en.wikipedia.org/wiki/QName
  static const nameStartChars =
      ':A-Z_a-z'
      '\u{c0}-\u{d6}'
      '\u{d8}-\u{f6}'
      '\u{f8}-\u{2ff}'
      '\u{370}-\u{37d}'
      '\u{37f}-\u{1fff}'
      '\u{200c}-\u{200d}'
      '\u{2070}-\u{218f}'
      '\u{2c00}-\u{2fef}'
      '\u{3001}-\u{d7ff}'
      '\u{f900}-\u{fdcf}'
      '\u{fdf0}-\u{fffd}'
      '\u{10000}-\u{effff}';
  static const nameChars =
      '$nameStartChars'
      '-.0-9'
      '\u{b7}'
      '\u{300}-\u{36f}'
      '\u{203f}-\u{2040}';
}
