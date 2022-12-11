import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('default namespace', () {
    final document =
        XmlDocument.parse('<html xmlns="http://www.w3.org/1999/xhtml">'
            '  <body lang="en"/>'
            '</html>');
    final nodes = [...document.descendants, document];
    for (final node in nodes) {
      if (node is XmlAttribute && node.namespacePrefix == 'xmlns') {
        break;
      }
      if (node is XmlHasName) {
        final namedNode = node as XmlHasName;
        expect(namedNode.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
  test('prefix namespace', () {
    final document = XmlDocument.parse(
        '<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml">'
        '  <xhtml:body xhtml:lang="en"/>'
        '</xhtml:html>');
    final nodes = [...document.descendants, document];
    for (final node in nodes) {
      if (node is XmlAttribute && node.namespacePrefix == 'xmlns') {
        break;
      }
      if (node is XmlHasName) {
        final namedNode = node as XmlHasName;
        expect(namedNode.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
}
