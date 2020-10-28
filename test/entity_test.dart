import 'package:test/test.dart';
import 'package:xml/src/xml/entities/default_mapping.dart';
import 'package:xml/src/xml/utils/character_data_parser.dart';
import 'package:xml/xml.dart';

void expectDecode(XmlEntityMapping mapping, String input, String output) {
  final nodeText =
      XmlDocument.parse('<data>$input</data>', entityMapping: mapping)
          .rootElement
          .text;
  expect(nodeText, output, reason: 'parser decoding');

  final entityText = mapping.decode(input);
  expect(entityText, output, reason: 'entity decoding');
}

void testDefaultMapping(XmlEntityMapping entityMapping) {
  group('decode', () {
    test('&#xHHHH;', () {
      expectDecode(entityMapping, '&#X41;', 'A');
      expectDecode(entityMapping, '&#x61;', 'a');
      expectDecode(entityMapping, '&#x7A;', 'z');
    });
    test('&#dddd;', () {
      expectDecode(entityMapping, '&#65;', 'A');
      expectDecode(entityMapping, '&#97;', 'a');
      expectDecode(entityMapping, '&#122;', 'z');
    });
    test('&named;', () {
      expectDecode(entityMapping, '&lt;', '<');
      expectDecode(entityMapping, '&gt;', '>');
      expectDecode(entityMapping, '&amp;', '&');
      expectDecode(entityMapping, '&apos;', '\'');
      expectDecode(entityMapping, '&quot;', '"');
    });
    test('invalid', () {
      expectDecode(entityMapping, '&invalid;', '&invalid;');
    });
    test('incomplete', () {
      expectDecode(entityMapping, '&amp', '&amp');
    });
    test('empty', () {
      expectDecode(entityMapping, '&;', '&;');
    });
    test('surrounded', () {
      expectDecode(entityMapping, 'a&amp;b', 'a&b');
      expectDecode(entityMapping, '&amp;x&amp;', '&x&');
    });
    test('sequence', () {
      expectDecode(entityMapping, '&amp;&amp;', '&&');
    });
  });
  group('encode', () {
    test('text', () {
      expect(entityMapping.encodeText('<'), '&lt;');
      expect(entityMapping.encodeText('&'), '&amp;');
      expect(entityMapping.encodeText('hello'), 'hello');
      expect(entityMapping.encodeText('<foo &amp;>'), '&lt;foo &amp;amp;>');
    });
    test('attribute (single quote)', () {
      expect(
          entityMapping.encodeAttributeValue(
              "'", XmlAttributeType.SINGLE_QUOTE),
          '&apos;');
      expect(
          entityMapping.encodeAttributeValue(
              '"', XmlAttributeType.SINGLE_QUOTE),
          '"');
      expect(
          entityMapping.encodeAttributeValue(
              '\t', XmlAttributeType.SINGLE_QUOTE),
          '&#x9;');
      expect(
          entityMapping.encodeAttributeValue(
              '\n', XmlAttributeType.SINGLE_QUOTE),
          '&#xA;');
      expect(
          entityMapping.encodeAttributeValue(
              '\r', XmlAttributeType.SINGLE_QUOTE),
          '&#xD;');
      expect(
          entityMapping.encodeAttributeValue(
              'hello', XmlAttributeType.SINGLE_QUOTE),
          'hello');
      expect(
          entityMapping.encodeAttributeValue(
              "'hello'", XmlAttributeType.SINGLE_QUOTE),
          '&apos;hello&apos;');
      expect(
          entityMapping.encodeAttributeValue(
              '"hello"', XmlAttributeType.SINGLE_QUOTE),
          '"hello"');
    });
    test('encode attribute (double quote)', () {
      expect(
          entityMapping.encodeAttributeValue(
              "'", XmlAttributeType.DOUBLE_QUOTE),
          "'");
      expect(
          entityMapping.encodeAttributeValue(
              '"', XmlAttributeType.DOUBLE_QUOTE),
          '&quot;');
      expect(
          entityMapping.encodeAttributeValue(
              '\t', XmlAttributeType.DOUBLE_QUOTE),
          '&#x9;');
      expect(
          entityMapping.encodeAttributeValue(
              '\n', XmlAttributeType.DOUBLE_QUOTE),
          '&#xA;');
      expect(
          entityMapping.encodeAttributeValue(
              '\r', XmlAttributeType.DOUBLE_QUOTE),
          '&#xD;');
      expect(
          entityMapping.encodeAttributeValue(
              'hello', XmlAttributeType.DOUBLE_QUOTE),
          'hello');
      expect(
          entityMapping.encodeAttributeValue(
              "'hello'", XmlAttributeType.DOUBLE_QUOTE),
          "'hello'");
      expect(
          entityMapping.encodeAttributeValue(
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
  group('xml', () {
    testDefaultMapping(defaultEntityMapping);
  });
  group('html', () {
    const entityMapping = XmlDefaultEntityMapping.html();
    testDefaultMapping(entityMapping);
    test('special', () {
      expectDecode(entityMapping, '&eacute;', 'é');
      expectDecode(entityMapping, '&Eacute;', 'É');
    });
  });
  group('html5', () {
    const entityMapping = XmlDefaultEntityMapping.html5();
    testDefaultMapping(entityMapping);
    test('special', () {
      expectDecode(entityMapping, '&bigstar;', '★');
      expectDecode(entityMapping, '&block;', '█');
    });
  });
  group('null', () {
    const entityMapping = XmlNullEntityMapping();
    group('decode', () {
      test('entities', () {
        expectDecode(entityMapping, '&#X41;', '&#X41;');
        expectDecode(entityMapping, '&#65;', '&#65;');
        expectDecode(entityMapping, '&amp;', '&amp;');
      });
      test('invalid entities', () {
        expectDecode(entityMapping, '&;', '&;');
        expectDecode(entityMapping, '&invalid;', '&invalid;');
        expectDecode(entityMapping, '&incomplete', '&incomplete');
      });
      test('combinations', () {
        expectDecode(entityMapping, 'a&amp;b', 'a&amp;b');
        expectDecode(entityMapping, '&amp;x&amp;', '&amp;x&amp;');
        expectDecode(entityMapping, '&amp;&amp;', '&amp;&amp;');
      });
    });
    group('encode', () {
      test('text', () {
        expect(entityMapping.encodeText('<'), '<');
        expect(entityMapping.encodeText('&'), '&');
        expect(entityMapping.encodeText('hello'), 'hello');
        expect(entityMapping.encodeText('<foo &amp;>'), '<foo &amp;>');
      });
      test('attribute', () {
        expect(
            entityMapping.encodeAttributeValue(
                '<>&\'"', XmlAttributeType.SINGLE_QUOTE),
            '<>&\'"');
        expect(
            entityMapping.encodeAttributeValue(
                '<>&\'"', XmlAttributeType.DOUBLE_QUOTE),
            '<>&\'"');
      });
    });
  });
}
