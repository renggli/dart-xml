import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?><data/>',
    );
    final node = document.declaration!;
    check(node.value).equals('version="1.0" encoding="UTF-8"');
    check(node.version).equals('1.0');
    check(node.encoding).equals('UTF-8');
    check(node.standalone).isFalse();
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).length.equals(2);
    check(node.elementAttributes).length.equals(2);
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.DECLARATION);
    check(node.toString()).equals('<?xml version="1.0" encoding="UTF-8"?>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    check(node.value).equals('');
    check(node.version).isNull();
    check(node.encoding).isNull();
    check(node.standalone).isFalse();
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.nodeType).equals(XmlNodeType.DECLARATION);
    check(node.toString()).equals('<?xml?>');
  });
  test('add attribute', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    node.setAttribute('other', 'value');
    check(node.toString()).equals('<?xml other="value"?>');
  });
  test('update attribute', () {
    final document = XmlDocument.parse('<?xml other="value"?><data/>');
    final node = document.declaration!;
    node.setAttribute('other', 'some');
    check(node.toString()).equals('<?xml other="some"?>');
  });
  test('remove attribute', () {
    final document = XmlDocument.parse(
      '<?xml version="1.0" other="value"?><data/>',
    );
    final node = document.declaration!;
    node.removeAttribute('other');
    check(node.toString()).equals('<?xml version="1.0"?>');
  });
  test('version', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    check(node.version).isNull();
    node.version = '1.1';
    check(node.version).equals('1.1');
    check(node.toString()).equals('<?xml version="1.1"?>');
    node.version = null;
    check(node.version).isNull();
    check(node.toString()).equals('<?xml?>');
  });
  test('encoding', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    check(node.encoding).isNull();
    node.encoding = 'utf-16';
    check(node.encoding).equals('utf-16');
    check(node.toString()).equals('<?xml encoding="utf-16"?>');
    node.encoding = null;
    check(node.encoding).isNull();
    check(node.toString()).equals('<?xml?>');
  });
  test('standalone', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    node.standalone = true;
    check(node.standalone).isTrue();
    check(node.toString()).equals('<?xml standalone="yes"?>');
    node.standalone = false;
    check(node.standalone).isFalse();
    check(node.toString()).equals('<?xml standalone="no"?>');
    node.standalone = null;
    check(node.standalone).isFalse();
    check(node.toString()).equals('<?xml?>');
  });
}
