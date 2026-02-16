import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<data><!--Am I or are the other crazy?--></data>',
    );
    final node = document.rootElement.children.single;
    expect(node.value, 'Am I or are the other crazy?');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.parent, same(document.rootElement));
    expect(node.parentElement, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.COMMENT);
    expect(node.toString(), '<!--Am I or are the other crazy?-->');
  });
  test('empty', () {
    final document = XmlDocument.parse('<data><!----></data>');
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
    expect(node.nodeType, XmlNodeType.COMMENT);
    expect(node.toString(), '<!---->');
  });
}
