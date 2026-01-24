import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/node.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('node', () {
    test('op:union', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opUnion(context, [XPathSequence.single(a), XPathSequence.single(b)]),
        XPathSequence([a, b]),
      );
      // Test document order preservation/enforcement
      expect(
        opUnion(context, [XPathSequence.single(b), XPathSequence.single(a)]),
        [a, b],
      );
    });
    test('op:intersect', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opIntersect(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [a],
      );
    });
    test('op:except', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opExcept(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [b],
      );
    });
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(fnName(context, [XPathSequence.single(a)]), ['a']);
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(fnLocalName(context, [XPathSequence.single(a)]), ['a']);
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(fnRoot(context, [XPathSequence.single(a)]), [document]);
    });
    test('fn:innermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, [
          XPathSequence([document, a]),
        ]),
        [a],
      );
    });
    test('fn:outermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, [
          XPathSequence([document, a]),
        ]),
        [document],
      );
    });
    test('fn:path', () {
      final a = document.findAllElements('a').first;
      expect(fnPath(context, [XPathSequence.single(a)]), ['/r/a']);
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('last()', () {
      expectEvaluate(xml, 'last()', [1]);
      expectEvaluate(xml, '/r/*[last()]', [xml.rootElement.children.last]);
    });
    test('position()', () {
      expectEvaluate(xml, 'position()', [1]);
      expectEvaluate(xml, '/r/*[position()]', xml.rootElement.children);
    });
    test('count(node-set)', () {
      expectEvaluate(xml, 'count(/*)', [1]);
      expectEvaluate(xml, 'count(/r/*)', [2]);
      expectEvaluate(xml, 'count(/r/b/*)', [1]);
      expectEvaluate(xml, 'count(/r/b/absent)', [0]);
    });
    test('local-name(node-set?)', () {
      expectEvaluate(xml, 'local-name(/r/a)', ['a']);
      expectEvaluate(xml, '/r/*[local-name()="a"]', xml.findAllElements('a'));
    });
    test('namespace-uri(node-set?)', () {
      expectEvaluate(xml, 'namespace-uri(/r/a)', ['']);
      expectEvaluate(
        xml,
        '/r/*[namespace-uri()=""]',
        xml.rootElement.findElements('*'),
      );
    });
    test('name(node-set?)', () {
      expectEvaluate(xml, 'name(/r/a)', ['a']);
      expectEvaluate(xml, '/r/*[name()="a"]', xml.findAllElements('a'));
    });
    test('intersect(node-set, node-set)', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(r/*) intersect (r/*)', children);
      expectEvaluate(xml, '(r/*) intersect (r/b)', [children[1]]);
      expectEvaluate(xml, '(r/b) intersect (r/*)', [children[1]]);
      expectEvaluate(xml, '(r/b) intersect (r/b)', [children[1]]);
      expectEvaluate(xml, '(r/a) intersect (r/c)', isEmpty);
    });
    test('except(node-set, node-set)', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(r/*) except (r/*)', isEmpty);
      expectEvaluate(xml, '(r/*) except (r/b)', [children[0], children[2]]);
      expectEvaluate(xml, '(r/b) except (r/*)', isEmpty);
      expectEvaluate(xml, '(r/b) except (r/b)', isEmpty);
      expectEvaluate(xml, '(r/a) except (r/c)', [children[0]]);
    });
    test('union(node-set, node-set)', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(r/*) union (r/*)', children);
      expectEvaluate(xml, '(r/a) union (r/a)', [children[0]]);
      expectEvaluate(xml, '(r/a) union (r/c)', [children[0], children[2]]);
      expectEvaluate(xml, '(r/c) union (r/a)', [children[0], children[2]]);
    });
    test('|(node-set, node-set)', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(r/*) | (r/*)', children);
      expectEvaluate(xml, '(r/a) | (r/a)', [children[0]]);
      expectEvaluate(xml, '(r/a) | (r/c)', [children[0], children[2]]);
      expectEvaluate(xml, '(r/c) | (r/a)', [children[0], children[2]]);
    });
    test('predicate', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(/r/*)[1]', [children[0]]);
      expectEvaluate(xml, '(/r/*)[last()]', [children[2]]);
      expectEvaluate(xml, '(/r/*)[position()]', children);
      expectEvaluate(xml, '(/r/*)[false()]', isEmpty);
      expectEvaluate(xml, '(/r/*)[true()]', children);
      expectEvaluate(xml, '(/r/*)[position()<=2][last()]', [children[1]]);
      expectEvaluate(xml, '(/r/c/preceding-sibling::*)[last()]', [children[1]]);
    });
  });
}
