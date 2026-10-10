import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/node.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

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
      check(opUnion(nSeq(aNode), nSeq(bNode))).isXPathSequence([aNode, bNode]);
    });
    test('preserve document order', () {
      check(opUnion(nSeq(bNode), nSeq(aNode))).isXPathSequence([aNode, bNode]);
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
      check(opIntersect(nSeqAll([aNode, bNode]), nSeq(aNode)))
          .isXPathSequence([aNode]);
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
      check(opExcept(nSeqAll([aNode, bNode]), nSeq(aNode)))
          .isXPathSequence([bNode]);
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
      check(opNodeIs(nSeq(aNode), nSeq(aNode))).isXPathSequence([true]);
    });
    test('different node', () {
      check(opNodeIs(nSeq(aNode), nSeq(bNode))).isXPathSequence([false]);
    });
    test('empty sequence returns empty', () {
      check(opNodeIs(XPathSequence.empty, nSeq(aNode))).isEmpty();
    });
    test('integration is', () {
      expectEvaluate(doc, 'r/a is r/a', [true]);
      expectEvaluate(doc, 'r/a is r/b', [false]);
      expectEvaluate(doc, '() is r/a', isEmpty);
    });
    test('namespace nodes identity on same element', () {
      final nsDoc = XmlDocument.parse('<r xmlns:ns="http://test.com"/>');
      final ns1 = nsDoc.xpathEvaluate('r/namespace::ns');
      final ns2 = nsDoc.xpathEvaluate('r/namespace::*[local-name()="ns"]');
      check(opNodeIs(ns1, ns2)).isXPathSequence([true]);
      expectEvaluate(
        nsDoc,
        'r/namespace::ns is r/namespace::*[local-name()="ns"]',
        [true],
      );
    });
    test('namespace nodes on different elements are not identical', () {
      final nsDoc = XmlDocument.parse(
        '<r xmlns:ns="http://test.com"><child xmlns:ns="http://test.com"/></r>',
      );
      expectEvaluate(nsDoc, 'r/namespace::ns is r/child/namespace::ns', [
        false,
      ]);
    });
  });

  group('opNodePrecedes', () {
    test('precedes', () {
      check(opNodePrecedes(nSeq(aNode), nSeq(bNode))).isXPathSequence([true]);
    });
    test('does not precede', () {
      check(opNodePrecedes(nSeq(bNode), nSeq(aNode))).isXPathSequence([false]);
    });
    test('empty sequence returns empty', () {
      check(opNodePrecedes(XPathSequence.empty, nSeq(aNode))).isEmpty();
    });
    test('integration <<', () {
      expectEvaluate(doc, 'r/a << r/b', [true]);
      expectEvaluate(doc, 'r/b << r/a', [false]);
    });
    test('namespace precedes attributes and children of same element', () {
      final nsDoc = XmlDocument.parse(
        '<r xmlns:ns="http://test.com" a="1"><child/></r>',
      );
      expectEvaluate(nsDoc, 'r/namespace::ns << r/@a', [true]);
      expectEvaluate(nsDoc, 'r/namespace::ns << r/child', [true]);
      expectEvaluate(nsDoc, 'r/@a << r/namespace::ns', [false]);
    });
  });

  group('opNodeFollows', () {
    test('follows', () {
      check(opNodeFollows(nSeq(bNode), nSeq(aNode))).isXPathSequence([true]);
    });
    test('does not follow', () {
      check(opNodeFollows(nSeq(aNode), nSeq(bNode))).isXPathSequence([false]);
    });
    test('empty sequence returns empty', () {
      check(opNodeFollows(XPathSequence.empty, nSeq(aNode))).isEmpty();
    });
    test('integration >>', () {
      expectEvaluate(doc, 'r/b >> r/a', [true]);
      expectEvaluate(doc, 'r/a >> r/b', [false]);
    });
    test('attribute and child follow namespace of same element', () {
      final nsDoc = XmlDocument.parse(
        '<r xmlns:ns="http://test.com" a="1"><child/></r>',
      );
      expectEvaluate(nsDoc, 'r/@a >> r/namespace::ns', [true]);
      expectEvaluate(nsDoc, 'r/child >> r/namespace::ns', [true]);
      expectEvaluate(nsDoc, 'r/namespace::ns >> r/@a', [false]);
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

      check(precedesResult).not((it) => it.equals(followsResult));

      check(
        (opNodePrecedes(nSeq(cNode), nSeq(aNode)).single as XPathBoolean).value,
      ).equals(followsResult);
      check(
        (opNodeFollows(nSeq(cNode), nSeq(aNode)).single as XPathBoolean).value,
      ).equals(precedesResult);
    });

    test('union/intersect/except on disconnected trees', () {
      final unionResult = opUnion(
        nSeqAll([bNode, aNode]),
        nSeqAll([dNode, cNode]),
      ).map((item) => (item as XPathNode).node).toList();

      check(unionResult).length.equals(4);
      check(unionResult.indexOf(aNode) < unionResult.indexOf(bNode)).isTrue();
      check(unionResult.indexOf(cNode) < unionResult.indexOf(dNode)).isTrue();

      check(opIntersect(nSeqAll([aNode, cNode]), nSeqAll([cNode, dNode])))
          .isXPathSequence([cNode]);

      check(opExcept(nSeqAll([aNode, cNode]), nSeqAll([cNode, dNode])))
          .isXPathSequence([aNode]);
    });

    test('non-node operands throw XPTY0004', () {
      check(() => opUnion(seq(1), nSeq(aNode)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opUnion(nSeq(aNode), seq(1)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opNodeIs(seq(1), nSeq(aNode)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opNodePrecedes(seq(1), nSeq(aNode)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opNodeFollows(seq(1), nSeq(aNode)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });
}
