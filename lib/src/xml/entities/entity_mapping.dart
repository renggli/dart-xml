import '../utils/attribute_type.dart';

/// Describes the decoding and encoding of character entities.
abstract class XmlEntityMapping {
  const XmlEntityMapping();

  /// Decodes a string, resolving all possible entities.
  String decode(String input) {
    final output = StringBuffer();
    final length = input.length;
    var position = 0;
    var start = position;
    while (position < length) {
      final value = input.codeUnitAt(position);
      if (value == 38) {
        final index = input.indexOf(';', position + 1);
        if (position + 1 < index) {
          final entity = input.substring(position + 1, index);
          final value = decodeEntity(entity);
          if (value != null) {
            output.write(input.substring(start, position));
            output.write(value);
            position = index + 1;
            start = position;
          } else {
            position++;
          }
        } else {
          position++;
        }
      } else {
        position++;
      }
    }
    output.write(input.substring(start, position));
    return output.toString();
  }

  /// Decodes a single character entity, returns the decoded entity or `null` if
  /// the input is invalid.
  String? decodeEntity(String input);

  /// Encodes a string to be serialized as XML text.
  String encodeText(String input);

  /// Encodes a string to be serialized as XML attribute value.
  String encodeAttributeValue(String input, XmlAttributeType type);

  /// Encodes a string to be serialized as XML attribute value together with
  /// its corresponding quotes.
  String encodeAttributeValueWithQuotes(String input, XmlAttributeType type) {
    final quote = _attributeQuote[type];
    return '$quote${encodeAttributeValue(input, type)}$quote';
  }
}

const Map<XmlAttributeType, String> _attributeQuote = {
  XmlAttributeType.SINGLE_QUOTE: "'",
  XmlAttributeType.DOUBLE_QUOTE: '"'
};
