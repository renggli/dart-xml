import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<?xml-stylesheet href="style.css"?><data/>',
    );
    final node = document.firstChild as XmlProcessing;
    expect(node.target, 'xml-stylesheet');
    expect(node.value, 'href="style.css"');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, 'href="style.css"');
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.PROCESSING);
    expect(node.toString(), '<?xml-stylesheet href="style.css"?>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<?xml-stylesheet?><data/>');
    final node = document.firstChild as XmlProcessing;
    expect(node.target, 'xml-stylesheet');
    expect(node.value, isEmpty);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.PROCESSING);
    expect(node.toString(), '<?xml-stylesheet?>');
  });
}
