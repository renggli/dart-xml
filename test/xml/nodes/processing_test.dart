import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<?xml-stylesheet href="style.css"?><data/>',
    );
    final node = document.firstChild as XmlProcessing;
    check(node.target).equals('xml-stylesheet');
    check(node.value).equals('href="style.css"');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('href="style.css"');
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.PROCESSING);
    check(node.toString()).equals('<?xml-stylesheet href="style.css"?>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<?xml-stylesheet?><data/>');
    final node = document.firstChild as XmlProcessing;
    check(node.target).equals('xml-stylesheet');
    check(node.value).isEmpty();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.PROCESSING);
    check(node.toString()).equals('<?xml-stylesheet?>');
  });
}
