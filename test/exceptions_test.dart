import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

void main() {
  group('XmlParserException', () {
    test('with properties', () {
      final exception = XmlParserException('Expected foo',
          buffer: 'hello', position: 1, line: 2, column: 3);
      expect(exception.message, 'Expected foo');
      expect(exception.buffer, 'hello');
      expect(exception.position, 1);
      expect(exception.line, 2);
      expect(exception.column, 3);
      expect(exception.source, 'hello');
      expect(exception.offset, 1);
      expect(exception.toString(), endsWith('Expected foo at 2:3'));
    });
    test('without anything', () {
      final exception = XmlParserException('Expected foo');
      expect(exception.message, 'Expected foo');
      expect(exception.buffer, isNull);
      expect(exception.position, 0);
      expect(exception.line, 0);
      expect(exception.column, 0);
      expect(exception.source, isNull);
      expect(exception.offset, 0);
      expect(exception.toString(), endsWith('Expected foo at 0:0'));
    });
  });
  group('XmlNodeTypeException', () {
    test('checkValidType', () {
      XmlNodeTypeException.checkValidType(
          XmlComment('Comment'), [XmlNodeType.COMMENT]);
      expect(
          () => XmlNodeTypeException.checkValidType(
              XmlComment('Comment'), [XmlNodeType.ATTRIBUTE]),
          throwsA(isXmlNodeTypeException));
    });
  });
  group('XmlParentException', () {
    test('checkNoParent', () {
      final document = XmlDocument([XmlComment('Comment')]);
      XmlParentException.checkNoParent(document);
      expect(() => XmlParentException.checkNoParent(document.firstChild!),
          throwsA(isXmlParentException));
    });
    test('checkMatchingParent', () {
      final document = XmlDocument([XmlComment('Comment')]);
      XmlParentException.checkMatchingParent(document.firstChild!, document);
      expect(
          () => XmlParentException.checkMatchingParent(
              document, document.firstChild!),
          throwsA(isXmlParentException));
    });
  });
  group('XmlTagException', () {
    test('checkClosingTag', () {
      XmlTagException.checkClosingTag('foo', 'foo');
      expect(() => XmlTagException.checkClosingTag('foo', 'bar'),
          throwsA(isXmlTagException));
    });
  });
}
