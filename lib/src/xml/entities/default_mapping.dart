import '../utils/attribute_type.dart';
import 'entity_mapping.dart';
import 'named_entities.dart';

/// The entity mapping used when nothing else is specified.
XmlEntityMapping defaultEntityMapping = const XmlDefaultEntityMapping.xml();

/// Default entity mapping for XML, HTML, and HTML5 entities.
class XmlDefaultEntityMapping extends XmlEntityMapping {
  /// Named character references.
  final Map<String, String> entities;

  /// Minimal entity mapping of XML character references.
  const XmlDefaultEntityMapping.xml() : this(xmlEntities);

  /// Minimal entity mapping of HTML character references.
  const XmlDefaultEntityMapping.html() : this(htmlEntities);

  /// Extensive entity mapping of HTML5 character references.
  const XmlDefaultEntityMapping.html5() : this(html5Entities);

  /// Custom entity mapping.
  const XmlDefaultEntityMapping(this.entities);

  @override
  String? decodeEntity(String input) {
    if (input.length > 1 && input[0] == '#') {
      if (input.length > 2 && (input[1] == 'x' || input[1] == 'X')) {
        // Hexadecimal character reference.
        return String.fromCharCode(int.parse(input.substring(2), radix: 16));
      } else {
        // Decimal character reference.
        return String.fromCharCode(int.parse(input.substring(1)));
      }
    } else {
      // Named character reference.
      return entities[input];
    }
  }

  @override
  String encodeText(String input) =>
      input.replaceAllMapped(_textPattern, _textReplace);

  @override
  String encodeAttributeValue(String input, XmlAttributeType type) {
    switch (type) {
      case XmlAttributeType.SINGLE_QUOTE:
        return input.replaceAllMapped(
            _singeQuoteAttributePattern, _singeQuoteAttributeReplace);
      case XmlAttributeType.DOUBLE_QUOTE:
        return input.replaceAllMapped(
            _doubleQuoteAttributePattern, _doubleQuoteAttributeReplace);
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
  }
  throw ArgumentError.value(match, 'match');
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
  }
  throw ArgumentError.value(match, 'match');
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
  }
  throw ArgumentError.value(match, 'match');
}
