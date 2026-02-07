import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/node.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('node', () {
    test('op:union', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opUnion(XPathSequence.single(a), XPathSequence.single(b)),
        XPathSequence([a, b]),
      );
      // Test document order preservation/enforcement
      expect(opUnion(XPathSequence.single(b), XPathSequence.single(a)), [a, b]);
    });
    test('op:intersect', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(opIntersect(XPathSequence([a, b]), XPathSequence.single(a)), [a]);
    });
    test('op:except', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(opExcept(XPathSequence([a, b]), XPathSequence.single(a)), [b]);
    });
  });
  group('integration', () {
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
  });
}
