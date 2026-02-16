import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final node = XmlDocument.parse('<data/>');
    expect(node.parent, isNull);
    expect(node.parentElement, isNull);
    expect(node.root, same(node));
    expect(node.document, same(node));
    expect(node.depth, 0);
    expect(node.attributes, isEmpty);
    expect(node.children, hasLength(1));
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.nodeType, XmlNodeType.DOCUMENT);
    expect(node.toString(), '<data/>');
  });
  test('definition', () {
    final node = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<element/>',
    );
    expect(node.children, hasLength(2));
    expect(
      node.toString(),
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<element/>',
    );
  });
  test('comments and whitespace', () {
    final node = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?> '
      '<!-- before -->\n<element/>\t<!-- after -->',
    );
    expect(node.attributes, isEmpty);
    expect(node.children, hasLength(7));
    expect(
      node.toString(),
      '<?xml version="1.0" encoding="UTF-8"?> '
      '<!-- before -->\n<element/>\t<!-- after -->',
    );
    expect(
      node.toXmlString(pretty: true),
      '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<!-- before -->\n<element/>\n<!-- after -->',
    );
  });
  test('empty', () {
    final document = XmlDocument();
    expect(document.declaration, isNull);
    expect(document.doctypeElement, isNull);
    expect(() => document.rootElement, throwsStateError);
  });
  test('attributes', () {
    final document = XmlDocument();
    expect(document.attributes, isEmpty);
    expect(document.getAttribute('attr'), isNull);
    expect(document.getAttributeNode('attr'), isNull);
    expect(
      () => document.setAttribute('attr', 'value'),
      throwsUnsupportedError,
    );
    expect(() => document.removeAttribute('attr'), throwsUnsupportedError);
    expect(
      () => document.attributes.add(
        XmlAttribute(const XmlName.qualified('attr'), 'value'),
      ),
      throwsUnsupportedError,
    );
  });
}
