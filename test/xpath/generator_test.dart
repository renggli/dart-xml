import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/examples.dart';

void main() {
  test('attribute', () {
    final node = XmlAttribute(XmlName('foo'), 'bar');
    expect(node.xpathGenerate(), '@foo');
  });
  test('element', () {
    final node = XmlElement(XmlName('foo'));
    expect(node.xpathGenerate(), 'foo');
  });
  test('element with parent', () {
    final node = XmlElement(XmlName('foo'));
    final parent = XmlElement(XmlName('bar'));
    parent.children.add(node);
    expect(node.xpathGenerate(), 'bar/foo');
  });
  test('element with siblings', () {
    final node1 = XmlElement(XmlName('foo'));
    final node2 = XmlElement(XmlName('foo'));
    final parent = XmlElement(XmlName('bar'));
    parent.children.addAll([node1, node2]);
    expect(node1.xpathGenerate(), 'bar/foo[1]');
    expect(node2.xpathGenerate(), 'bar/foo[2]');
  });
  test('text', () {
    final node = XmlText('foo');
    expect(node.xpathGenerate(), 'text()');
  });
  test('cdata', () {
    final node = XmlCDATA('foo');
    expect(node.xpathGenerate(), 'text()');
  });
  test('comment', () {
    final node = XmlComment('foo');
    expect(node.xpathGenerate(), 'comment()');
  });
  test('processing', () {
    final node = XmlProcessing('foo', 'bar');
    expect(node.xpathGenerate(), 'processing-instruction()');
  });
  test('document', () {
    final node = XmlDocument([]);
    expect(node.xpathGenerate(), '/');
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

    expect(root.xpathGenerate(), '/root');
    expect(aNode.xpathGenerate(), '/root/a');
    expect(bNode.xpathGenerate(), '/root/b');
    expect(cNode.xpathGenerate(), '/root/b/c');
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
    expect(aNode.xpathGenerate(byId: 'id'), '//*[@id="1"]');
    expect(bNode.xpathGenerate(byId: 'id'), '//*[@id="2"]');
    expect(cNode.xpathGenerate(byId: 'id'), '//*[@id="2"]/c');
  });
  group('examples', () {
    for (final MapEntry(key: key, value: value) in allXml.entries) {
      test(key, () {
        final document = XmlDocument.parse(value);
        for (final node in [document, ...document.descendants]) {
          final expression = node.xpathGenerate(byId: 'id');
          final result = document.xpath(expression);
          expect(result.single, node, reason: expression);
        }
      });
    }
  });
}
