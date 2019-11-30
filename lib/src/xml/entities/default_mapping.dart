library xml.entities.default_mapping;

import '../utils/attribute_type.dart';
import 'default_entities.dart';
import 'entity_mapping.dart';

class XmlDefaultEntityMapping extends XmlEntityMapping {
  final Map<String, String> entities;

  const XmlDefaultEntityMapping([this.entities = allEntities]);

  @override
  String decodeEntity(String entity) {
    if (entity.length > 1 && entity[0] == '#') {
      if (entity.length > 2 && (entity[1] == 'x' || entity[1] == 'X')) {
        // Hexadecimal character reference.
        return String.fromCharCode(int.parse(entity.substring(2), radix: 16));
      } else {
        // Decimal character reference.
        return String.fromCharCode(int.parse(entity.substring(1)));
      }
    } else {
      // Named character reference.
      return entities[entity];
    }
  }

  @override
  String encodeXmlText(String input) =>
      input.replaceAllMapped(_textPattern, _textReplace);

  @override
  String encodeXmlAttributeValue(String input, XmlAttributeType type) {
    switch (type) {
      case XmlAttributeType.SINGLE_QUOTE:
        return input.replaceAllMapped(
            _singeQuoteAttributePattern, _singeQuoteAttributeReplace);
      case XmlAttributeType.DOUBLE_QUOTE:
        return input.replaceAllMapped(
            _doubleQuoteAttributePattern, _doubleQuoteAttributeReplace);
      default:
        throw AssertionError();
    }
  }
}

// Encode XML text.

final _textPattern = RegExp(r'[&<]|]]>');

String _textReplace(Match match) {
  switch (match.group(0)) {
    case '<':
      return '&lt;';
    case '&':
      return '&amp;';
    case ']]>':
      return ']]&gt;';
    default:
      throw AssertionError();
  }
}

// Encode XML attribute values (single quotes).

final _singeQuoteAttributePattern = RegExp(r"['&<\n\r\t]");

String _singeQuoteAttributeReplace(Match match) {
  switch (match.group(0)) {
    case "'":
      return '&apos;';
    case '&':
      return '&amp;';
    case '<':
      return '&lt;';
    case '\n':
      return '&#xA;';
    case '\r':
      return '&#xD;';
    case '\t':
      return '&#x9;';
    default:
      throw AssertionError();
  }
}

// Encode XML attribute values (double quotes).

final _doubleQuoteAttributePattern = RegExp(r'["&<\n\r\t]');

String _doubleQuoteAttributeReplace(Match match) {
  switch (match.group(0)) {
    case '"':
      return '&quot;';
    case '&':
      return '&amp;';
    case '<':
      return '&lt;';
    case '\n':
      return '&#xA;';
    case '\r':
      return '&#xD;';
    case '\t':
      return '&#x9;';
    default:
      throw AssertionError();
  }
}
