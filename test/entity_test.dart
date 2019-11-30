library xml.test.entity_test;

import 'package:test/test.dart';
import 'package:xml/src/xml/entities/default_mapping.dart';
import 'package:xml/src/xml/utils/character_data_parser.dart';
import 'package:xml/xml.dart';

String decode(XmlEntityMapping entityMapping, String input) =>
    parse('<data>$input</data>', entityMapping: entityMapping).rootElement.text;

void testDefaultMapping(XmlEntityMapping entityMapping) {
  group('decode', () {
    test('&#xHHHH;', () {
      expect(decode(entityMapping, '&#X41;'), 'A');
      expect(decode(entityMapping, '&#x61;'), 'a');
      expect(decode(entityMapping, '&#x7A;'), 'z');
    });
    test('&#dddd;', () {
      expect(decode(entityMapping, '&#65;'), 'A');
      expect(decode(entityMapping, '&#97;'), 'a');
      expect(decode(entityMapping, '&#122;'), 'z');
    });
    test('&named;', () {
      expect(decode(entityMapping, '&lt;'), '<');
      expect(decode(entityMapping, '&gt;'), '>');
      expect(decode(entityMapping, '&amp;'), '&');
      expect(decode(entityMapping, '&apos;'), '\'');
      expect(decode(entityMapping, '&quot;'), '"');
    });
    test('invalid', () {
      expect(decode(entityMapping, '&invalid;'), '&invalid;');
    });
    test('incomplete', () {
      expect(decode(entityMapping, '&amp'), '&amp');
    });
    test('empty', () {
      expect(decode(entityMapping, '&;'), '&;');
    });
    test('surrounded', () {
      expect(decode(entityMapping, 'a&amp;b'), 'a&b');
      expect(decode(entityMapping, '&amp;x&amp;'), '&x&');
    });
    test('sequence', () {
      expect(decode(entityMapping, '&amp;&amp;'), '&&');
    });
  });
  group('encode', () {
    test('text', () {
      expect(entityMapping.encodeXmlText('<'), '&lt;');
      expect(entityMapping.encodeXmlText('&'), '&amp;');
      expect(entityMapping.encodeXmlText('hello'), 'hello');
      expect(entityMapping.encodeXmlText('<foo &amp;>'), '&lt;foo &amp;amp;>');
    });
    test('attribute (single quote)', () {
      expect(
          entityMapping.encodeXmlAttributeValue(
              "'", XmlAttributeType.SINGLE_QUOTE),
          '&apos;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '"', XmlAttributeType.SINGLE_QUOTE),
          '"');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\t', XmlAttributeType.SINGLE_QUOTE),
          '&#x9;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\n', XmlAttributeType.SINGLE_QUOTE),
          '&#xA;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\r', XmlAttributeType.SINGLE_QUOTE),
          '&#xD;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              'hello', XmlAttributeType.SINGLE_QUOTE),
          'hello');
      expect(
          entityMapping.encodeXmlAttributeValue(
              "'hello'", XmlAttributeType.SINGLE_QUOTE),
          '&apos;hello&apos;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '"hello"', XmlAttributeType.SINGLE_QUOTE),
          '"hello"');
    });
    test('encode attribute (double quote)', () {
      expect(
          entityMapping.encodeXmlAttributeValue(
              "'", XmlAttributeType.DOUBLE_QUOTE),
          "'");
      expect(
          entityMapping.encodeXmlAttributeValue(
              '"', XmlAttributeType.DOUBLE_QUOTE),
          '&quot;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\t', XmlAttributeType.DOUBLE_QUOTE),
          '&#x9;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\n', XmlAttributeType.DOUBLE_QUOTE),
          '&#xA;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              '\r', XmlAttributeType.DOUBLE_QUOTE),
          '&#xD;');
      expect(
          entityMapping.encodeXmlAttributeValue(
              'hello', XmlAttributeType.DOUBLE_QUOTE),
          'hello');
      expect(
          entityMapping.encodeXmlAttributeValue(
              "'hello'", XmlAttributeType.DOUBLE_QUOTE),
          "'hello'");
      expect(
          entityMapping.encodeXmlAttributeValue(
              '"hello"', XmlAttributeType.DOUBLE_QUOTE),
          '&quot;hello&quot;');
    });
  });
  group('character parser', () {
    final parser = XmlCharacterDataParser(entityMapping, '*', 1);
    test('parse without stopper', () {
      final result1 = parser.parse('');
      expect(result1.isFailure, isTrue);
      expect(result1.position, 0);

      final result2 = parser.parse('a');
      expect(result2.isSuccess, isTrue);
      expect(result2.position, 1);
      expect(result2.value, 'a');

      final result3 = parser.parse('ab');
      expect(result3.isSuccess, isTrue);
      expect(result3.position, 2);
      expect(result3.value, 'ab');
    });
    test('parse with stopper', () {
      final result1 = parser.parse('*');
      expect(result1.isFailure, isTrue);
      expect(result1.position, 0);

      final result2 = parser.parse('a*');
      expect(result2.isSuccess, isTrue);
      expect(result2.position, 1);
      expect(result2.value, 'a');

      final result3 = parser.parse('ab*');
      expect(result3.isSuccess, isTrue);
      expect(result3.position, 2);
      expect(result3.value, 'ab');
    });
    test('fast parse without stopper', () {
      final result1 = parser.fastParseOn('', 0);
      expect(result1, -1);

      final result2 = parser.fastParseOn('a', 0);
      expect(result2, 1);

      final result3 = parser.fastParseOn('ab', 0);
      expect(result3, 2);
    });
    test('fast parse with stopper', () {
      final result1 = parser.fastParseOn('*', 0);
      expect(result1, -1);

      final result2 = parser.fastParseOn('a*', 0);
      expect(result2, 1);

      final result3 = parser.fastParseOn('ab*', 0);
      expect(result3, 2);
    });
    test('copy and equality', () {
      expect(parser.isEqualTo(parser), isTrue);
      expect(parser.isEqualTo(parser.copy()), isTrue);
      expect(parser.isEqualTo(XmlCharacterDataParser(entityMapping, '%', 1)),
          isFalse);
      expect(parser.isEqualTo(XmlCharacterDataParser(entityMapping, '*', 2)),
          isFalse);
    });
  });
}

void main() {
  group('xml', () => testDefaultMapping(const XmlDefaultEntityMapping.xml()));
  group('html', () {
    const entityMapping = XmlDefaultEntityMapping.html();
    testDefaultMapping(entityMapping);
    test('special', () {
      expect(decode(entityMapping, '&eacute;'), 'é');
      expect(decode(entityMapping, '&Eacute;'), 'É');
    });
  });
  group('html5', () {
    const entityMapping = XmlDefaultEntityMapping.html5();
    testDefaultMapping(entityMapping);
    test('special', () {
      expect(decode(entityMapping, '&bigstar;'), '★');
      expect(decode(entityMapping, '&block;'), '█');
    });
  });
}
