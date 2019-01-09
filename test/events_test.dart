library xml.test.axis_test;

import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

import 'assertions.dart';

void assertComplete(Iterator<XmlEvent> iterator) {
  for (var i = 0; i < 2; i++) {
    expect(iterator.moveNext(), isFalse);
    expect(iterator.current, isNull);
  }
}

void main() {
  group('events', () {
    test('cdata', () {
      final iterator = parseIterator('<![CDATA[<nasty>]]>');
      expect(iterator.moveNext(), isTrue);
      final XmlCDATAEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.CDATA);
      expect(event.text, '<nasty>');
      assertComplete(iterator);
    });
    test('comment', () {
      final iterator = parseIterator('<!--for amusement only-->');
      expect(iterator.moveNext(), isTrue);
      final XmlCommentEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.COMMENT);
      expect(event.text, 'for amusement only');
      assertComplete(iterator);
    });
    test('doctype', () {
      final iterator = parseIterator('<!DOCTYPE html>');
      expect(iterator.moveNext(), isTrue);
      final XmlDoctypeEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.DOCUMENT_TYPE);
      expect(event.text, 'html');
      assertComplete(iterator);
    });
    test('end element', () {
      final iterator = parseIterator('</bar>');
      expect(iterator.moveNext(), isTrue);
      final XmlEndElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'bar');
      assertComplete(iterator);
    });
    test('processing', () {
      final iterator = parseIterator('<?pi test?>');
      expect(iterator.moveNext(), isTrue);
      final XmlProcessingEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.PROCESSING);
      expect(event.target, 'pi');
      expect(event.text, 'test');
      assertComplete(iterator);
    });
    test('start element', () {
      final iterator = parseIterator('<foo>');
      expect(iterator.moveNext(), isTrue);
      final XmlStartElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'foo');
      expect(event.attributes, isEmpty);
      expect(event.isSelfClosing, isFalse);
      assertComplete(iterator);
    });
    test('start element (attributes, self-closing)', () {
      final iterator = parseIterator('<foo a="1" b=\'2\'/>');
      expect(iterator.moveNext(), isTrue);
      final XmlStartElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'foo');
      expect(event.attributes, hasLength(2));
      expect(event.attributes[0].name, 'a');
      expect(event.attributes[0].value, '1');
      expect(event.attributes[0].attributeType, XmlAttributeType.DOUBLE_QUOTE);
      expect(event.attributes[1].name, 'b');
      expect(event.attributes[1].value, '2');
      expect(event.attributes[1].attributeType, XmlAttributeType.SINGLE_QUOTE);
      expect(event.isSelfClosing, isTrue);
      assertComplete(iterator);
    });
    test('text', () {
      final iterator = parseIterator('Hello World!');
      expect(iterator.moveNext(), isTrue);
      final XmlTextEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.TEXT);
      expect(event.text, 'Hello World!');
      assertComplete(iterator);
    });
  });
  group('errors', () {
    test('empty', () {
      final iterator = parseIterator('');
      assertComplete(iterator);
    });
    test('invalid', () {
      final iterator = parseIterator('<hello');
      expect(iterator.moveNext, throwsA(isXmlParserException));
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      final XmlTextEvent event = iterator.current;
      expect(event.text, 'hello');
      assertComplete(iterator);
    });
  });
}
