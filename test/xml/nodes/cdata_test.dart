import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<data>'
      '<![CDATA[Methinks <word> it <word> is like a weasel!]]>'
      '</data>',
    );
    final node = document.rootElement.children.single;
    check(node.value).equals('Methinks <word> it <word> is like a weasel!');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('Methinks <word> it <word> is like a weasel!');
    check(node.parent).identicalTo(document.rootElement);
    check(node.parentElement).identicalTo(document.rootElement);
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(2);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.CDATA);
    check(node.toString())
        .equals('<![CDATA[Methinks <word> it <word> is like a weasel!]]>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<data><![CDATA[]]></data>');
    final node = document.rootElement.children.single;
    check(node.value).isNotNull().isEmpty();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isNotNull().isEmpty();
    check(node.parent).identicalTo(document.rootElement);
    check(node.parentElement).identicalTo(document.rootElement);
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(2);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.CDATA);
    check(node.toString()).equals('<![CDATA[]]>');
  });
}
