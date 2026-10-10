import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/examples.dart';

void main() {
  test('attribute', () {
    final node = XmlAttribute(const XmlName.qualified('foo'), 'bar');
    check(node.xpathGenerate()).equals('@foo');
  });
  test('element', () {
    final node = XmlElement(const XmlName.qualified('foo'));
    check(node.xpathGenerate()).equals('foo');
  });
  test('element with parent', () {
    final node = XmlElement(const XmlName.qualified('foo'));
    final parent = XmlElement(const XmlName.qualified('bar'));
    parent.children.add(node);
    check(node.xpathGenerate()).equals('bar/foo');
  });
  test('element with siblings', () {
    final node1 = XmlElement(const XmlName.qualified('foo'));
    final node2 = XmlElement(const XmlName.qualified('foo'));
    final parent = XmlElement(const XmlName.qualified('bar'));
    parent.children.addAll([node1, node2]);
    check(node1.xpathGenerate()).equals('bar/foo[1]');
    check(node2.xpathGenerate()).equals('bar/foo[2]');
  });
  test('text', () {
    final node = XmlText('foo');
    check(node.xpathGenerate()).equals('text()');
  });
  test('cdata', () {
    final node = XmlCDATA('foo');
    check(node.xpathGenerate()).equals('text()');
  });
  test('comment', () {
    final node = XmlComment('foo');
    check(node.xpathGenerate()).equals('comment()');
  });
  test('processing', () {
    final node = XmlProcessing('foo', 'bar');
    check(node.xpathGenerate()).equals('processing-instruction()');
  });
  test('document', () {
    final node = XmlDocument([]);
    check(node.xpathGenerate()).equals('/');
  });
  test('declaration', () {
    final node = XmlDeclaration();
    check(node.xpathGenerate()).equals('node()');
  });
  test('doctype', () {
    final node = XmlDoctype('root');
    check(node.xpathGenerate()).equals('node()');
  });
  test('fragment', () {
    final node = XmlDocumentFragment();
    check(node.xpathGenerate()).equals('node()');
  });
  test('nested structure', () {
    final document = XmlDocument.parse('''
        <root>
          <a id="1"/>
          <b id="2">
            <c/>
          </b>
        </root>
      ''');
    final root = document.rootElement;
    // Better to query.
    final aNode = root.findElements('a').first;
    final bNode = root.findElements('b').first;
    final cNode = bNode.findElements('c').first;

    check(root.xpathGenerate()).equals('/root');
    check(aNode.xpathGenerate()).equals('/root/a');
    check(bNode.xpathGenerate()).equals('/root/b');
    check(cNode.xpathGenerate()).equals('/root/b/c');
  });
  test('byId', () {
    final document = XmlDocument.parse('''
        <root>
          <a id="1"/>
          <b id="2">
            <c/>
          </b>
        </root>
      ''');
    final root = document.rootElement;
    final aNode = root.findElements('a').first;
    final bNode = root.findElements('b').first;
    final cNode = bNode.findElements('c').first;
    check(aNode.xpathGenerate(byId: 'id')).equals('//*[@id="1"]');
    check(bNode.xpathGenerate(byId: 'id')).equals('//*[@id="2"]');
    check(cNode.xpathGenerate(byId: 'id')).equals('//*[@id="2"]/c');
  });
  group('examples', () {
    for (final MapEntry(key: key, value: value) in allXml.entries) {
      test(key, () {
        final document = XmlDocument.parse(value);
        for (final node in [document, ...document.descendants]) {
          if ((node is XmlAttribute &&
                  (node.isNamespaceDeclaration ||
                      node.parent is! XmlElement)) ||
              (node is XmlText && node.parent is XmlDocument) ||
              node is XmlDeclaration ||
              node is XmlDoctype) {
            continue;
          }

          final expression = node.xpathGenerate(byId: 'id');
          final result = document.xpath(expression);
          check(because: expression, result.single).equals(node);
        }
      });
    }
  });
}
