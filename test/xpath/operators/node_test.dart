import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/node.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  final doc = XmlDocument.parse('<r><a/><b/><c/></r>');
  final aNode = doc.findAllElements('a').single;
  final bNode = doc.findAllElements('b').single;
  final children = doc.rootElement.children;

  group('opUnion', () {
    test('union', () {
      expect(
        opUnion(XPathSequence.single(aNode), XPathSequence.single(bNode)),
        XPathSequence([aNode, bNode]),
      );
    });
    test('preserve document order', () {
      expect(
        opUnion(XPathSequence.single(bNode), XPathSequence.single(aNode)),
        [aNode, bNode],
      );
    });
    test('integration union', () {
      expectEvaluate(doc, '(r/*) union (r/*)', children);
      expectEvaluate(doc, '(r/a) union (r/a)', [children[0]]);
      expectEvaluate(doc, '(r/a) union (r/c)', [children[0], children[2]]);
      expectEvaluate(doc, '(r/c) union (r/a)', [children[0], children[2]]);
    });
    test('integration | operator', () {
      expectEvaluate(doc, '(r/*) | (r/*)', children);
      expectEvaluate(doc, '(r/a) | (r/a)', [children[0]]);
      expectEvaluate(doc, '(r/a) | (r/c)', [children[0], children[2]]);
      expectEvaluate(doc, '(r/c) | (r/a)', [children[0], children[2]]);
    });
  });

  group('opIntersect', () {
    test('intersect', () {
      expect(
        opIntersect(XPathSequence([aNode, bNode]), XPathSequence.single(aNode)),
        [aNode],
      );
    });
    test('integration intersect', () {
      expectEvaluate(doc, '(r/*) intersect (r/*)', children);
      expectEvaluate(doc, '(r/*) intersect (r/b)', [children[1]]);
      expectEvaluate(doc, '(r/b) intersect (r/*)', [children[1]]);
      expectEvaluate(doc, '(r/b) intersect (r/b)', [children[1]]);
      expectEvaluate(doc, '(r/a) intersect (r/c)', isEmpty);
    });
  });

  group('opExcept', () {
    test('except', () {
      expect(
        opExcept(XPathSequence([aNode, bNode]), XPathSequence.single(aNode)),
        [bNode],
      );
    });
    test('integration except', () {
      expectEvaluate(doc, '(r/*) except (r/*)', isEmpty);
      expectEvaluate(doc, '(r/*) except (r/b)', [children[0], children[2]]);
      expectEvaluate(doc, '(r/b) except (r/*)', isEmpty);
      expectEvaluate(doc, '(r/b) except (r/b)', isEmpty);
      expectEvaluate(doc, '(r/a) except (r/c)', [children[0]]);
    });
  });

  group('opNodeIs', () {
    test('same node', () {
      expect(
        opNodeIs(XPathSequence.single(aNode), XPathSequence.single(aNode)),
        isXPathSequence([true]),
      );
    });
    test('different node', () {
      expect(
        opNodeIs(XPathSequence.single(aNode), XPathSequence.single(bNode)),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opNodeIs(XPathSequence.empty, XPathSequence.single(aNode)),
        isEmpty,
      );
    });
    test('integration is', () {
      expectEvaluate(doc, 'r/a is r/a', [true]);
      expectEvaluate(doc, 'r/a is r/b', [false]);
      expectEvaluate(doc, '() is r/a', isEmpty);
    });
  });

  group('opNodePrecedes', () {
    test('precedes', () {
      expect(
        opNodePrecedes(
          XPathSequence.single(aNode),
          XPathSequence.single(bNode),
        ),
        isXPathSequence([true]),
      );
    });
    test('does not precede', () {
      expect(
        opNodePrecedes(
          XPathSequence.single(bNode),
          XPathSequence.single(aNode),
        ),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opNodePrecedes(XPathSequence.empty, XPathSequence.single(aNode)),
        isEmpty,
      );
    });
    test('integration <<', () {
      expectEvaluate(doc, 'r/a << r/b', [true]);
      expectEvaluate(doc, 'r/b << r/a', [false]);
    });
  });

  group('opNodeFollows', () {
    test('follows', () {
      expect(
        opNodeFollows(XPathSequence.single(bNode), XPathSequence.single(aNode)),
        isXPathSequence([true]),
      );
    });
    test('does not follow', () {
      expect(
        opNodeFollows(XPathSequence.single(aNode), XPathSequence.single(bNode)),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opNodeFollows(XPathSequence.empty, XPathSequence.single(aNode)),
        isEmpty,
      );
    });
    test('integration >>', () {
      expectEvaluate(doc, 'r/b >> r/a', [true]);
      expectEvaluate(doc, 'r/a >> r/b', [false]);
    });
  });
}
