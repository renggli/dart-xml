import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?><data/>',
    );
    final node = document.declaration!;
    expect(node.value, 'version="1.0" encoding="UTF-8"');
    expect(node.version, '1.0');
    expect(node.encoding, 'UTF-8');
    expect(node.standalone, isFalse);
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, hasLength(2));
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.DECLARATION);
    expect(node.toString(), '<?xml version="1.0" encoding="UTF-8"?>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    expect(node.value, '');
    expect(node.version, isNull);
    expect(node.encoding, isNull);
    expect(node.standalone, isFalse);
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.DECLARATION);
    expect(node.toString(), '<?xml?>');
  });
  test('add attribute', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    node.setAttribute('other', 'value');
    expect(node.toString(), '<?xml other="value"?>');
  });
  test('update attribute', () {
    final document = XmlDocument.parse('<?xml other="value"?><data/>');
    final node = document.declaration!;
    node.setAttribute('other', 'some');
    expect(node.toString(), '<?xml other="some"?>');
  });
  test('remove attribute', () {
    final document = XmlDocument.parse(
      '<?xml version="1.0" other="value"?><data/>',
    );
    final node = document.declaration!;
    node.removeAttribute('other');
    expect(node.toString(), '<?xml version="1.0"?>');
  });
  test('version', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    expect(node.version, isNull);
    node.version = '1.1';
    expect(node.version, '1.1');
    expect(node.toString(), '<?xml version="1.1"?>');
    node.version = null;
    expect(node.version, isNull);
    expect(node.toString(), '<?xml?>');
  });
  test('encoding', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    expect(node.encoding, isNull);
    node.encoding = 'utf-16';
    expect(node.encoding, 'utf-16');
    expect(node.toString(), '<?xml encoding="utf-16"?>');
    node.encoding = null;
    expect(node.encoding, isNull);
    expect(node.toString(), '<?xml?>');
  });
  test('standalone', () {
    final document = XmlDocument.parse('<?xml?><data/>');
    final node = document.declaration!;
    node.standalone = true;
    expect(node.standalone, isTrue);
    expect(node.toString(), '<?xml standalone="yes"?>');
    node.standalone = false;
    expect(node.standalone, isFalse);
    expect(node.toString(), '<?xml standalone="no"?>');
    node.standalone = null;
    expect(node.standalone, isFalse);
    expect(node.toString(), '<?xml?>');
  });
}
