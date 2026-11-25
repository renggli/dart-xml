import '../enums/attribute_type.dart';
import '../utils/token.dart';

/// Describes the decoding and encoding of character entities.
abstract class XmlEntityMapping {
  /// Abstract const constructor.
  const new();

  /// Decodes a string, resolving all possible entities.
  String decode(String input) {
    // If we obviously have no entities, return the input string.
    var start = input.indexOf(XmlToken.entityStart, 0);
    if (start < 0) return input;
    // Otherwise traverse the input and decode all entities.
    final buffer = StringBuffer(input.substring(0, start));
    while (true) {
      final index = _indexOfEntityEnd(input, start + 1);
      if (start + 1 < index) {
        final entity = input.substring(start + 1, index);
        final value = decodeEntity(entity);
        if (value != null) {
          // Valid entity found, write the transformed value.
          buffer.write(value);
          start = index + 1;
        } else {
          buffer.write(XmlToken.entityStart);
          start++;
        }
      } else {
        buffer.write(XmlToken.entityStart);
        start++;
      }
      // Find the next possible start position of an entity.
      final next = input.indexOf(XmlToken.entityStart, start);
      if (next == -1) {
        // Reached the end of the input.
        buffer.write(input.substring(start));
        break;
      }
      buffer.write(input.substring(start, next));
      start = next;
    }
    return buffer.toString();
  }

  /// Decodes a single character entity, returning the decoded entity or `null` if
  /// the input is invalid.
  String? decodeEntity(String input);

  /// Encodes a string to be serialized as XML text.
  String encodeText(String input);

  /// Encodes a string to be serialized as an XML attribute value.
  String encodeAttributeValue(String input, XmlAttributeType type);

  /// Encodes a string to be serialized as an XML attribute value together with
  /// its corresponding quotes.
  String encodeAttributeValueWithQuotes(String input, XmlAttributeType type) =>
      '${type.token}${encodeAttributeValue(input, type)}${type.token}';
}

/// Returns the index of the [XmlToken.entityEnd] terminating an entity body
/// that begins at [start], or `-1` if the end of the [input] or another
/// [XmlToken.entityStart] comes first.
///
/// Stopping at the next [XmlToken.entityStart] keeps decoding linear for
/// inputs with many unterminated entities (e.g. `'&' * 100000`), instead of
/// scanning to the end of the input for every one of them.
int _indexOfEntityEnd(String input, int start) {
  for (var index = start; index < input.length; index++) {
    final char = input.codeUnitAt(index);
    if (char == _entityEnd) return index;
    if (char == _entityStart) return -1;
  }
  return -1;
}

const _entityStart = 0x26; // XmlToken.entityStart
const _entityEnd = 0x3B; // XmlToken.entityEnd
