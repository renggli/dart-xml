library xml.test.entity_test;

import 'package:test/test.dart';
import 'package:xml/src/xml/utils/entities.dart';
import 'package:xml/xml.dart';

String decode(String input) => parse('<data>$input</data>').rootElement.text;

String encodeText(String input) => XmlText(input).toString();

String encodeAttributeValue(XmlAttributeType type, String input) {
  final attribute = XmlAttribute(XmlName('a'), input, type).toString();
  final quote = type == XmlAttributeType.SINGLE_QUOTE ? "'" : '"';
  expect(attribute.substring(0, 3), 'a=$quote');
  expect(attribute[attribute.length - 1], quote);
  return attribute.substring(3, attribute.length - 1);
}

void main() {
  test('decode &#xHHHH;', () {
    expect(decode('&#X41;'), 'A');
    expect(decode('&#x61;'), 'a');
    expect(decode('&#x7A;'), 'z');
  });
  test('decode &#dddd;', () {
    expect(decode('&#65;'), 'A');
    expect(decode('&#97;'), 'a');
    expect(decode('&#122;'), 'z');
  });
  test('decode &named;', () {
    expect(decode('&lt;'), '<');
    expect(decode('&gt;'), '>');
    expect(decode('&amp;'), '&');
    expect(decode('&apos;'), '\'');
    expect(decode('&quot;'), '"');
  });
  test('decode invalid', () {
    expect(decode('&invalid;'), '&invalid;');
  });
  test('decode incomplete', () {
    expect(decode('&amp'), '&amp');
  });
  test('decode empty', () {
    expect(decode('&;'), '&;');
  });
  test('decode surrounded', () {
    expect(decode('a&amp;b'), 'a&b');
    expect(decode('&amp;x&amp;'), '&x&');
  });
  test('decode sequence', () {
    expect(decode('&amp;&amp;'), '&&');
  });
  test('encode text', () {
    expect(encodeText('<'), '&lt;');
    expect(encodeText('&'), '&amp;');
    expect(encodeText('hello'), 'hello');
    expect(encodeText('<foo &amp;>'), '&lt;foo &amp;amp;>');
  });
  test('encode attribute (single quote)', () {
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, "'"), '&apos;');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '"'), '"');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\t'), '&#x9;');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\n'), '&#xA;');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\r'), '&#xD;');
    expect(
        encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, 'hello'), 'hello');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, "'hello'"),
        '&apos;hello&apos;');
    expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '"hello"'),
        '"hello"');
  });
  test('encode attribute (double quote)', () {
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, "'"), "'");
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '"'), '&quot;');
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\t'), '&#x9;');
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\n'), '&#xA;');
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\r'), '&#xD;');
    expect(
        encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, 'hello'), 'hello');
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, "'hello'"),
        "'hello'");
    expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '"hello"'),
        '&quot;hello&quot;');
  });
  group('character parser', () {
    final parser = XmlCharacterDataParser('*', 1);
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
      expect(parser.isEqualTo(XmlCharacterDataParser('%', 1)), isFalse);
      expect(parser.isEqualTo(XmlCharacterDataParser('*', 2)), isFalse);
    });
  });
}
