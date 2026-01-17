import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  const input =
      '<?xml version="1.0"?>'
      '<r xmlns:ns1="uri1" xmlns:ns2="uri2">'
      '<!--comment-->'
      '<e1 a="1"/><e2 b="2"/>'
      '<ns1:e3/><ns2:e3/>'
      '<?p1?><?p2?>'
      'text'
      '<![CDATA[data]]>'
      '</r>';
  final document = XmlDocument.parse(input);
  final current = document.rootElement;
  test('fully qualified name', () {
    expectXPath(current, 'e1', ['<e1 a="1"/>']);
    expectXPath(current, 'e2', ['<e2 b="2"/>']);
    expectXPath(current, 'e3', []);
    expectXPath(current, 'ns1:e3', ['<ns1:e3/>']);
    expectXPath(current, 'ns2:e3', ['<ns2:e3/>']);
  });
  test('fully qualified name with URI namespace', () {
    expectXPath(current, 'Q{uri1}e3', ['<ns1:e3/>']);
    expectXPath(current, 'Q{uri2}e3', ['<ns2:e3/>']);
    expectXPath(current, 'Q{uri3}e3', []);
  });
  test('local name wildcard', () {
    expectXPath(current, 'ns1:*', ['<ns1:e3/>']);
    expectXPath(current, 'ns2:*', ['<ns2:e3/>']);
    expectXPath(current, 'ns3:*', []);
  });
  test('local name wildcard with URI namespace', () {
    expectXPath(current, 'Q{uri1}*', ['<ns1:e3/>']);
    expectXPath(current, 'Q{uri2}*', ['<ns2:e3/>']);
    expectXPath(current, 'Q{uri3}*', []);
  });
  test('namespace prefix wildcard', () {
    expectXPath(current, '*:e1', ['<e1 a="1"/>']);
    expectXPath(current, '*:e2', ['<e2 b="2"/>']);
    expectXPath(current, '*:e3', ['<ns1:e3/>', '<ns2:e3/>']);
  });
  test('wildcard', () {
    expectXPath(current, '*', [
      '<e1 a="1"/>',
      '<e2 b="2"/>',
      '<ns1:e3/>',
      '<ns2:e3/>',
    ]);
    expectXPath(document, 'self::*', []);
  });
  test('attribute()', () {
    expectXPath(current, 'attribute()', []);
    expectXPath(current, '*/@attribute()', ['a="1"', 'b="2"']);
  });
  test('comment()', () {
    expectXPath(current, 'comment()', ['<!--comment-->']);
  });
  test('document-node()', () {
    expectXPath(current, 'document-node()', []);
    expectXPath(current, 'ancestor-or-self::document-node()', [document]);
  });
  test('element()', () {
    expectXPath(current, 'element()', [
      '<e1 a="1"/>',
      '<e2 b="2"/>',
      '<ns1:e3/>',
      '<ns2:e3/>',
    ]);
  });
  test('node()', () {
    expectXPath(current, 'node()', current.children);
    expectXPath(document, 'self::node()', [document]);
  });
  test('processing-instruction()', () {
    expectXPath(current, 'processing-instruction()', ['<?p1?>', '<?p2?>']);
  });
  test('processing-instruction(p2)', () {
    expectXPath(current, 'processing-instruction(p2)', ['<?p2?>']);
  });
  test('processing-instruction("p2")', () {
    expectXPath(current, 'processing-instruction("p2")', ['<?p2?>']);
  });
  test('text()', () {
    expectXPath(current, 'text()', ['text', '<![CDATA[data]]>']);
  });
}
