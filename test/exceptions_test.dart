library xml.test.exception_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

void main() {
  test('XmlParserException', () {
    expect(XmlParserException(null, 1, 2).toString(), endsWith('at 1:2'));
    expect(XmlParserException('Expected foo', 3, 4).toString(),
        'Expected foo at 3:4');
  });
  test('XmlNodeTypeException.checkNotNull()', () {
    XmlNodeTypeException.checkNotNull(XmlComment('Comment'));
    expect(() => XmlNodeTypeException.checkNotNull(null),
        throwsA(isXmlNodeTypeException));
  });
  test('XmlNodeTypeException.checkValidType()', () {
    XmlNodeTypeException.checkValidType(
        XmlComment('Comment'), [XmlNodeType.COMMENT]);
    expect(
        () => XmlNodeTypeException.checkValidType(
            XmlComment('Comment'), [XmlNodeType.ATTRIBUTE]),
        throwsA(isXmlNodeTypeException));
  });
  test('XmlParentException.checkNoParent()', () {
    final node = XmlDocument([XmlComment('Comment')]);
    XmlParentException.checkNoParent(node);
    expect(() => XmlParentException.checkNoParent(node.children.first),
        throwsA(isXmlParentException));
  });
  test('XmlTagException', () {
    expect(XmlTagException('Expected </foo>').toString(), 'Expected </foo>');
  });
}
