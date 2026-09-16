import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/node.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

XPathSequence nSeq(XmlNode n) => XPathSequence.single(XPathNode(n));
XPathSequence nSeqAll(List<XmlNode> nodes) =>
    XPathSequence(nodes.map(XPathNode.new));

void main() {
  final doc = XmlDocument.parse('<r><a/><b/><c/></r>');
  final aNode = doc.findAllElements('a').single;
  final bNode = doc.findAllElements('b').single;
  final children = doc.rootElement.children;

  group('opUnion', () {
    test('union', () {
      expect(
        opUnion(nSeq(aNode), nSeq(bNode)),
        isXPathSequence([aNode, bNode]),
      );
    });
    test('preserve document order', () {
      expect(
        opUnion(nSeq(bNode), nSeq(aNode)),
        isXPathSequence([aNode, bNode]),
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
        opIntersect(nSeqAll([aNode, bNode]), nSeq(aNode)),
        isXPathSequence([aNode]),
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
        opExcept(nSeqAll([aNode, bNode]), nSeq(aNode)),
        isXPathSequence([bNode]),
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
      expect(opNodeIs(nSeq(aNode), nSeq(aNode)), isXPathSequence([true]));
    });
    test('different node', () {
      expect(opNodeIs(nSeq(aNode), nSeq(bNode)), isXPathSequence([false]));
    });
    test('empty sequence returns empty', () {
      expect(opNodeIs(XPathSequence.empty, nSeq(aNode)), isEmpty);
    });
    test('integration is', () {
      expectEvaluate(doc, 'r/a is r/a', [true]);
      expectEvaluate(doc, 'r/a is r/b', [false]);
      expectEvaluate(doc, '() is r/a', isEmpty);
    });
  });

  group('opNodePrecedes', () {
    test('precedes', () {
      expect(opNodePrecedes(nSeq(aNode), nSeq(bNode)), isXPathSequence([true]));
    });
    test('does not precede', () {
      expect(
        opNodePrecedes(nSeq(bNode), nSeq(aNode)),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(opNodePrecedes(XPathSequence.empty, nSeq(aNode)), isEmpty);
    });
    test('integration <<', () {
      expectEvaluate(doc, 'r/a << r/b', [true]);
      expectEvaluate(doc, 'r/b << r/a', [false]);
    });
  });

  group('opNodeFollows', () {
    test('follows', () {
      expect(opNodeFollows(nSeq(bNode), nSeq(aNode)), isXPathSequence([true]));
    });
    test('does not follow', () {
      expect(opNodeFollows(nSeq(aNode), nSeq(bNode)), isXPathSequence([false]));
    });
    test('empty sequence returns empty', () {
      expect(opNodeFollows(XPathSequence.empty, nSeq(aNode)), isEmpty);
    });
    test('integration >>', () {
      expectEvaluate(doc, 'r/b >> r/a', [true]);
      expectEvaluate(doc, 'r/a >> r/b', [false]);
    });
  });

  group('disconnected DOM trees', () {
    final doc1 = XmlDocument.parse('<r><a/><b/></r>');
    final doc2 = XmlDocument.parse('<r><c/><d/></r>');
    final aNode = doc1.findAllElements('a').single;
    final bNode = doc1.findAllElements('b').single;
    final cNode = doc2.findAllElements('c').single;
    final dNode = doc2.findAllElements('d').single;

    test('node comparisons on disconnected trees', () {
      final precedesResult =
          (opNodePrecedes(nSeq(aNode), nSeq(cNode)).single as XPathBoolean)
              .value;

      final followsResult =
          (opNodeFollows(nSeq(aNode), nSeq(cNode)).single as XPathBoolean)
              .value;

      expect(precedesResult, isNot(followsResult));

      expect(
        (opNodePrecedes(nSeq(cNode), nSeq(aNode)).single as XPathBoolean).value,
        followsResult,
      );
      expect(
        (opNodeFollows(nSeq(cNode), nSeq(aNode)).single as XPathBoolean).value,
        precedesResult,
      );
    });

    test('union/intersect/except on disconnected trees', () {
      final unionResult = opUnion(
        nSeqAll([bNode, aNode]),
        nSeqAll([dNode, cNode]),
      ).map((item) => (item as XPathNode).node).toList();

      expect(unionResult, hasLength(4));
      expect(unionResult.indexOf(aNode) < unionResult.indexOf(bNode), isTrue);
      expect(unionResult.indexOf(cNode) < unionResult.indexOf(dNode), isTrue);

      expect(
        opIntersect(nSeqAll([aNode, cNode]), nSeqAll([cNode, dNode])),
        isXPathSequence([cNode]),
      );

      expect(
        opExcept(nSeqAll([aNode, cNode]), nSeqAll([cNode, dNode])),
        isXPathSequence([aNode]),
      );
    });
  });
}
