import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<data>Am I or are the other crazy?</data>',
    );
    final node = document.rootElement.children.single as XmlText;
    check(node.value).equals('Am I or are the other crazy?');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('Am I or are the other crazy?');
    check(node.parent).identicalTo(document.rootElement);
    check(node.parentElement).identicalTo(document.rootElement);
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(2);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.TEXT);
    check(node.toString()).equals('Am I or are the other crazy?');
  });
  test('character references', () {
    final document = XmlDocument.parse(
      '<data>&lt;&gt;&amp;&apos;&quot;</data>',
    );
    final node = document.rootElement.children.single;
    check(node.value).equals('<>&\'"');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('<>&\'"');
    check(node.toString()).equals('&lt;>&amp;\'"');
  });
  test('nested', () {
    final root = XmlDocument.parse(
      '<p>Am <i>I</i> or are the <b>other</b><!-- very --> crazy?</p>',
    );
    check(root.rootElement.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(root.rootElement.text).equals('Am I or are the other crazy?');
    check(root.rootElement.innerText).equals('Am I or are the other crazy?');
  });
}
