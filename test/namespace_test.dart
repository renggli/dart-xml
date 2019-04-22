library xml.test.namespace_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('default namespace', () {
    final document = parse('<html xmlns="http://www.w3.org/1999/xhtml">'
        '  <body lang="en"/>'
        '</html>');
    final nodes = List.from(document.descendants)..add(document);
    for (final node in nodes) {
      if (node is XmlAttribute && node.name.prefix == 'xmlns') {
        break;
      }
      if (node is XmlNamed) {
        expect(node.name.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
  test('prefix namespace', () {
    final document =
        parse('<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml">'
            '  <xhtml:body xhtml:lang="en"/>'
            '</xhtml:html>');
    final nodes = List.from(document.descendants)..add(document);
    for (final node in nodes) {
      if (node is XmlAttribute && node.name.prefix == 'xmlns') {
        break;
      }
      if (node is XmlNamed) {
        expect(node.name.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
}
