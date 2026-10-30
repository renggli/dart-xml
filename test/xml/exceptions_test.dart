import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../utils/checks.dart';

void main() {
  group('XmlParentException', () {
    test('checkNoParent', () {
      final document = XmlDocument([XmlComment('Comment')]);
      XmlParentException.checkNoParent(document);
      check(() => XmlParentException.checkNoParent(document.firstChild!))
          .throws<XmlParentException>()
        ..message.equals('Node already has a parent, copy or remove it first')
        ..node.equals(document.firstChild!)
        ..parent.equals(document);
    });
    test('checkMatchingParent', () {
      final document = XmlDocument([XmlComment('Comment')]);
      XmlParentException.checkMatchingParent(document.firstChild!, document);
      check(
          () => XmlParentException.checkMatchingParent(
            document,
            document.firstChild!,
          ),
        ).throws<XmlParentException>()
        ..message.equals('Node already has a non-matching parent')
        ..node.equals(document)
        ..parent.equals(document.firstChild);
    });
    test('toString', () {
      final document = XmlDocument([XmlComment('Comment')]);
      final exception = XmlParentException(
        'Node already has a parent',
        node: document.firstChild!,
        parent: document,
      );
      check(exception.toString())
          .equals('XmlParentException: Node already has a parent');
    });
  });
  group('XmlParserException', () {
    test('with properties', () {
      final exception = XmlParserException(
        'Expected foo',
        buffer: 'hello\nworld',
        position: 6,
      );
      check(exception)
        ..message.equals('Expected foo')
        ..buffer.equals('hello\nworld')
        ..position.equals(6)
        ..line.equals(2)
        ..column.equals(1);
      check(exception.source).equals('hello\nworld');
      check(exception.offset).equals(6);
      check(exception.toString())
          .equals('XmlParserException: Expected foo at 2:1');
    });
    test('without anything', () {
      final exception = XmlParserException('Expected foo');
      check(exception)
        ..message.equals('Expected foo')
        ..buffer.isNull()
        ..position.isNull()
        ..line.equals(0)
        ..column.equals(0);
      check(exception.source).isNull();
      check(exception.offset).isNull();
      check(exception.toString()).equals('XmlParserException: Expected foo');
    });
  });
  group('XmlNodeTypeException', () {
    test('checkValidType', () {
      final commentNode = XmlComment('Comment');
      final commentNodeTypes = [XmlNodeType.COMMENT];
      final otherNodeTypes = [XmlNodeType.ELEMENT, XmlNodeType.TEXT];
      XmlNodeTypeException.checkValidType(commentNode, commentNodeTypes);
      check(
          () =>
              XmlNodeTypeException.checkValidType(commentNode, otherNodeTypes),
        ).throws<XmlNodeTypeException>()
        ..message.equals(
          'Got XmlNodeType.COMMENT, but expected one of '
          'XmlNodeType.ELEMENT, XmlNodeType.TEXT',
        )
        ..node.equals(commentNode)
        ..types.deepEquals(otherNodeTypes);
    });
    test('toString', () {
      final commentNode = XmlComment('Comment');
      final exception = XmlNodeTypeException(
        'Invalid type',
        node: commentNode,
        types: const [XmlNodeType.ELEMENT],
      );
      check(exception.toString()).equals('XmlNodeTypeException: Invalid type');
    });
  });
  group('XmlTagException', () {
    test('mismatchClosingTag', () {
      final exception = XmlTagException.mismatchClosingTag(
        'foo',
        'bar',
        buffer: '<foo>\n</bar>',
        position: 6,
      );
      check(exception)
        ..message.equals('Expected </foo>, but found </bar>')
        ..expectedName.equals('foo')
        ..actualName.equals('bar')
        ..buffer.equals('<foo>\n</bar>')
        ..position.equals(6)
        ..line.equals(2)
        ..column.equals(1);
    });
    test('unexpectedClosingTag', () {
      final exception = XmlTagException.unexpectedClosingTag(
        'bar',
        buffer: '</bar>',
        position: 0,
      );
      check(exception)
        ..message.equals('Unexpected closing tag </bar>')
        ..expectedName.isNull()
        ..actualName.equals('bar')
        ..buffer.equals('</bar>')
        ..position.equals(0)
        ..line.equals(1)
        ..column.equals(1);
    });
    test('missingClosingTag', () {
      final exception = XmlTagException.missingClosingTag(
        'foo',
        buffer: '<foo>',
        position: 5,
      );
      check(exception)
        ..message.equals('Missing closing tag </foo>')
        ..expectedName.equals('foo')
        ..actualName.isNull()
        ..buffer.equals('<foo>')
        ..position.equals(5)
        ..line.equals(1)
        ..column.equals(6);
    });
    test('checkClosingTag', () {
      XmlTagException.checkClosingTag('foo', 'foo');
      check(
          () => XmlTagException.checkClosingTag(
            'foo',
            'bar',
            buffer: '<foo>\n</bar>',
            position: 6,
          ),
        ).throws<XmlTagException>()
        ..message.equals('Expected </foo>, but found </bar>')
        ..expectedName.equals('foo')
        ..actualName.equals('bar')
        ..buffer.equals('<foo>\n</bar>')
        ..position.equals(6)
        ..line.equals(2)
        ..column.equals(1);
    });
    test('toString', () {
      final exceptionWithLoc = XmlTagException(
        'Mismatched tag',
        buffer: '<foo>',
        position: 1,
      );
      check(exceptionWithLoc.toString())
          .equals('XmlTagException: Mismatched tag at 1:2');
      final exceptionWithoutLoc = XmlTagException('Mismatched tag');
      check(exceptionWithoutLoc.toString())
          .equals('XmlTagException: Mismatched tag');
    });
  });
  group('XmlNamespaceException', () {
    test('with properties', () {
      final exception = XmlNamespaceException(
        'Prefix error',
        buffer: '<foo:bar/>',
        position: 1,
      );
      check(exception)
        ..message.equals('Prefix error')
        ..buffer.equals('<foo:bar/>')
        ..position.equals(1)
        ..line.equals(1)
        ..column.equals(2);
      check(exception.source).equals('<foo:bar/>');
      check(exception.offset).equals(1);
      check(exception.toString())
          .equals('XmlNamespaceException: Prefix error at 1:2');
    });
    test('unknownNamespacePrefix factory', () {
      final exception = XmlNamespaceException.unknownNamespacePrefix(
        'foo',
        buffer: '<foo:bar/>',
        position: 1,
      );
      check(exception.message).equals('Unknown namespace prefix: foo');
      check(
        exception.toString(),
      ).equals('XmlNamespaceException: Unknown namespace prefix: foo at 1:2');
    });
    test('without location', () {
      final exception = XmlNamespaceException('Prefix error');
      check(exception.source).isNull();
      check(exception.offset).isNull();
      check(exception.toString()).equals('XmlNamespaceException: Prefix error');
    });
  });
}
