library xml.entities.entity_mapping;

import '../utils/attribute_type.dart';

/// Describes the decoding and encoding of character entities.
abstract class XmlEntityMapping {
  const XmlEntityMapping();

  /// Decodes a character entity, returns the decoded entity or `null` if the
  /// input is invalid.
  String decodeEntity(String input);

  /// Encodes a string to be serialized as XML text.
  String encodeXmlText(String input);

  /// Encodes a string to be serialized as XML attribute value.
  String encodeXmlAttributeValue(String input, XmlAttributeType type);

  /// Encodes a string to be serialized as XML attribute value together with
  /// its corresponding quotes.
  String encodeXmlAttributeValueWithQuotes(
      String input, XmlAttributeType type) {
    final quote = _attributeQuote[type];
    final buffer = StringBuffer();
    buffer.write(quote);
    buffer.write(encodeXmlAttributeValue(input, type));
    buffer.write(quote);
    return buffer.toString();
  }
}

const Map<XmlAttributeType, String> _attributeQuote = {
  XmlAttributeType.SINGLE_QUOTE: "'",
  XmlAttributeType.DOUBLE_QUOTE: '"'
};
