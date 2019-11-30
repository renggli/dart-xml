library xml.entities.entity_mapping;

import '../utils/attribute_type.dart';

/// Describes the decoding and encoding of character entities.
abstract class XmlEntityMapping {
  const XmlEntityMapping();

  /// Decodes a single entity, or `null` if the entity is invalid.
  String decodeEntity(String entity);

  /// Encode a string to be serialized as an XML text.
  String encodeXmlText(String input);

  /// Encode a string to be serialized as an XML attribute value.
  String encodeXmlAttributeValue(String input, XmlAttributeType type);

  /// Encode a string to be serialized as an XML attribute value together with
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
