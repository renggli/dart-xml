library xml.test.entity_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

String decode(String input) => parse('<data>$input</data>').rootElement.text;

String encodeText(String input) => new XmlText(input).toString();

String encodeAttributeValue(XmlAttributeType type, String input) {
  var attribute = new XmlAttribute(new XmlName('a'), input, type).toString();
  var quote = type == XmlAttributeType.SINGLE_QUOTE ? "'" : '"';
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
}
