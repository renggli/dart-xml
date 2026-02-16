import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<data>'
      '<![CDATA[Methinks <word> it <word> is like a weasel!]]>'
      '</data>',
    );
    final node = document.rootElement.children.single;
    expect(node.value, 'Methinks <word> it <word> is like a weasel!');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, 'Methinks <word> it <word> is like a weasel!');
    expect(node.parent, same(document.rootElement));
    expect(node.parentElement, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.CDATA);
    expect(
      node.toString(),
      '<![CDATA[Methinks <word> it <word> is like a weasel!]]>',
    );
  });
  test('empty', () {
    final document = XmlDocument.parse('<data><![CDATA[]]></data>');
    final node = document.rootElement.children.single;
    expect(node.value, isEmpty);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.parent, same(document.rootElement));
    expect(node.parentElement, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.CDATA);
    expect(node.toString(), '<![CDATA[]]>');
  });
}
