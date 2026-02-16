import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<data>Am I or are the other crazy?</data>',
    );
    final node = document.rootElement.children.single as XmlText;
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
    expect(node.nodeType, XmlNodeType.TEXT);
    expect(node.toString(), 'Am I or are the other crazy?');
  });
  test('character references', () {
    final document = XmlDocument.parse(
      '<data>&lt;&gt;&amp;&apos;&quot;</data>',
    );
    final node = document.rootElement.children.single;
    expect(node.value, '<>&\'"');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, '<>&\'"');
    expect(node.toString(), '&lt;>&amp;\'"');
  });
  test('nested', () {
    final root = XmlDocument.parse(
      '<p>Am <i>I</i> or are the <b>other</b><!-- very --> crazy?</p>',
    );
    expect(root.rootElement.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(root.rootElement.text, 'Am I or are the other crazy?');
    expect(root.rootElement.innerText, 'Am I or are the other crazy?');
  });
}
