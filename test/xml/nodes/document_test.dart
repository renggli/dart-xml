import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('basic', () {
    final node = XmlDocument.parse('<data/>');
    check(node.parent).isNull();
    check(node.parentElement).isNull();
    check(node.root).identicalTo(node);
    check(node.document).identicalTo(node);
    check(node.depth).equals(0);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).length.equals(1);
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.nodeType).equals(XmlNodeType.DOCUMENT);
    check(node.toString()).equals('<data/>');
  });
  test('definition', () {
    final node = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<element/>',
    );
    check(node.children).length.equals(2);
    check(node.toString()).equals(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<element/>',
    );
  });
  test('comments and whitespace', () {
    final node = XmlDocument.parse(
      '<?xml version="1.0" encoding="UTF-8"?> '
      '<!-- before -->\n<element/>\t<!-- after -->',
    );
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).length.equals(7);
    check(node.toString()).equals(
      '<?xml version="1.0" encoding="UTF-8"?> '
      '<!-- before -->\n<element/>\t<!-- after -->',
    );
    check(node.toXmlString(pretty: true)).equals(
      '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<!-- before -->\n<element/>\n<!-- after -->',
    );
  });
  test('empty', () {
    final document = XmlDocument();
    check(document.declaration).isNull();
    check(document.doctypeElement).isNull();
    check(() => document.rootElement).throws<StateError>();
  });
  test('attributes', () {
    final document = XmlDocument();
    check(document.attributes).isEmpty();
    check(document.elementAttributes).isEmpty();
    check(document.getAttribute('attr')).isNull();
    check(document.getAttributeNode('attr')).isNull();
    check(() => document.setAttribute('attr', 'value'))
        .throws<UnsupportedError>();
    check(() => document.removeAttribute('attr')).throws<UnsupportedError>();
    check(
      () => document.attributes.add(
        XmlAttribute(const XmlName.qualified('attr'), 'value'),
      ),
    ).throws<UnsupportedError>();
  });
  test('getElementById', () {
    final document = XmlDocument.parse('''
<!DOCTYPE root [
  <!ATTLIST item customId ID #REQUIRED>
]>
<root>
  <user id="u1" name="Alice"/>
  <user xml:id="u2" name="Bob"/>
  <item customId="i1" value="Widget"/>
</root>
''');
    check(document.getElementById('u1')?.getAttribute('name')).equals('Alice');
    check(document.getElementById('u2')?.getAttribute('name')).equals('Bob');
    check(document.getElementById('i1')?.getAttribute('value'))
        .equals('Widget');
    check(document.getElementById('u3')).isNull();
  });
  test('validateAttributes', () {
    check(
      () => XmlDocument.parse(
        '<user role="guest" role="admin"/>',
        validateAttributes: true,
      ),
    ).throws<XmlTagException>();
    check(() => XmlDocument.parse('<user role="guest" role="admin"/>'))
        .returnsNormally();
  });
}
