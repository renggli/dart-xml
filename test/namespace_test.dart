import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('default namespace', () {
    final document =
        XmlDocument.parse('<html xmlns="http://www.w3.org/1999/xhtml">'
            '  <body lang="en"/>'
            '</html>');
    final nodes = List.from(document.descendants)..add(document);
    for (final node in nodes) {
      if (node is XmlAttribute && node.namespacePrefix == 'xmlns') {
        break;
      }
      if (node is XmlHasName) {
        expect(node.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
  test('prefix namespace', () {
    final document = XmlDocument.parse(
        '<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml">'
        '  <xhtml:body xhtml:lang="en"/>'
        '</xhtml:html>');
    final nodes = List.from(document.descendants)..add(document);
    for (final node in nodes) {
      if (node is XmlAttribute && node.namespacePrefix == 'xmlns') {
        break;
      }
      if (node is XmlHasName) {
        expect(node.namespaceUri, 'http://www.w3.org/1999/xhtml');
      }
    }
  });
  test('data equality across namespaces', () {
    final documentPrefixed = XmlDocument.parse(
        '<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:unused="http://schema.example.com/unused">'
        '  <xhtml:body xhtml:lang="en"/>'
        '</xhtml:html>');

    final document =
        XmlDocument.parse('<html xmlns="http://www.w3.org/1999/xhtml">'
            '  <body lang="en"/>'
            '</html>');

    expect(document, documentPrefixed);
  });
  test('argument order compares', () {
    final unorderedDocument = XmlDocument.parse('<html>'
        '  <body lang="en" id="body"/>'
        '</html>');

    final document = XmlDocument.parse('<html >'
        '  <body id="body" lang="en"/>'
        '</html>');

    expect(document, unorderedDocument);
  });
}
