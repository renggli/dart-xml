library xml.test.visitor_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('normalizer', () {
    test('remove empty text', () {
      final element = XmlElement(XmlName('element'), [], [
        XmlText(''),
        XmlElement(XmlName('element1')),
        XmlText(''),
        XmlElement(XmlName('element2')),
        XmlText(''),
      ]);
      element.normalize();
      expect(element.children.length, 2);
      expect(
          element.toXmlString(), '<element><element1/><element2/></element>');
    });
    test('join adjacent text', () {
      final element = XmlElement(XmlName('element'), [], [
        XmlText('aaa'),
        XmlText('bbb'),
        XmlText('ccc'),
      ]);
      element.normalize();
      expect(element.children.length, 1);
      expect(element.toXmlString(), '<element>aaabbbccc</element>');
    });
    test('document fragment', () {
      final fragment = XmlDocumentFragment([
        XmlText(''),
        XmlText('aaa'),
        XmlText(''),
        XmlElement(XmlName('element1')),
        XmlText(''),
        XmlText('bbb'),
        XmlText(''),
        XmlText('ccc'),
        XmlText(''),
        XmlElement(XmlName('element2')),
        XmlText(''),
        XmlText('ddd'),
        XmlText(''),
      ]);
      fragment.normalize();
      final element = XmlElement(XmlName('element'));
      element.children.add(fragment);
      expect(element.children.length, 5);
      expect(element.toXmlString(),
          '<element>aaa<element1/>bbbccc<element2/>ddd</element>');
    });
  });
  group('writer', () {
    final document = XmlDocument.parse('<body>\n'
        '  <a>\tWhat\r the  heck?\n</a>\n'
        '  <b>\tWhat\r the  heck?\n</b>\n'
        '</body>');
    test('default', () {
      final output = document.toXmlString();
      expect(
          output,
          '<body>\n'
          '  <a>\tWhat\r the  heck?\n</a>\n'
          '  <b>\tWhat\r the  heck?\n</b>\n'
          '</body>');
    });
    test('pretty', () {
      final output = document.toXmlString(pretty: true);
      expect(
          output,
          '<body>\n'
          '  <a>What the heck?</a>\n'
          '  <b>What the heck?</b>\n'
          '</body>');
    });
    test('indent', () {
      final output = document.toXmlString(pretty: true, indent: '\t');
      expect(
          output,
          '<body>\n'
          '\t<a>What the heck?</a>\n'
          '\t<b>What the heck?</b>\n'
          '</body>');
    });
    test('newline', () {
      final output = document.toXmlString(pretty: true, newLine: '\r\n');
      expect(
          output,
          '<body>\r\n'
          '  <a>What the heck?</a>\r\n'
          '  <b>What the heck?</b>\r\n'
          '</body>');
    });
    test('preserve all whitespace', () {
      final output = document.toXmlString(
          pretty: true, preserveWhitespace: (node) => true);
      expect(
          output,
          '<body>\n'
          '  <a>\tWhat\r the  heck?\n</a>\n'
          '  <b>\tWhat\r the  heck?\n</b>\n'
          '</body>');
    });
    test('preserve some whitespace', () {
      final output = document.toXmlString(
          pretty: true,
          preserveWhitespace: (node) =>
              node is XmlElement && node.name.local == 'b');
      expect(
          output,
          '<body>\n'
          '  <a>What the heck?</a>\n'
          '  <b>\tWhat\r the  heck?\n</b>\n'
          '</body>');
    });
    test('preserve nested whitespace', () {
      final input = XmlDocument.parse('<html><body>'
          '<p><b>bold</b>, <i>italic</i> and <b><i>both</i></b>.</p>'
          '</body></html>');
      final output = input.toXmlString(
          pretty: true,
          preserveWhitespace: (node) =>
              node is XmlElement && node.name.local == 'p');
      expect(
          output,
          '<html>\n'
          '  <body>\n'
          '    <p><b>bold</b>, <i>italic</i> and <b><i>both</i></b>.</p>\n'
          '  </body>\n'
          '</html>');
    });
  });
}
