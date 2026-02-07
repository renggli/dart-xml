import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/sequence.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('general functions and operators on sequences', () {
    test('fn:empty', () {
      expect(fnEmpty(context, [XPathSequence.empty]), [true]);
      expect(fnEmpty(context, [const XPathSequence.single(1)]), [false]);
    });
    test('fn:exists', () {
      expect(fnExists(context, [XPathSequence.empty]), [false]);
      expect(fnExists(context, [const XPathSequence.single(1)]), [true]);
    });
    test('fn:head', () {
      expect(fnHead(context, [XPathSequence.empty]), isEmpty);
      expect(
        fnHead(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [1],
      );
    });
    test('fn:tail', () {
      expect(fnTail(context, [XPathSequence.empty]), isEmpty);
      expect(
        fnTail(context, [
          const XPathSequence([1]),
        ]),
        isEmpty,
      );
      expect(
        fnTail(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [2, 3],
      );
    });
    test('fn:insert-before', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        const XPathSequence([0, 1, 2]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(2),
          const XPathSequence.single(0),
        ]),
        [1, 0, 2],
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(3),
          const XPathSequence.single(0),
        ]),
        const XPathSequence([1, 2, 0]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(0),
          const XPathSequence.single(0),
        ]),
        const XPathSequence([0, 1, 2]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(10),
          const XPathSequence.single(0),
        ]),
        const XPathSequence([1, 2, 0]),
      );
    });
    test('fn:remove', () {
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(2),
        ]),
        const XPathSequence([1, 3]),
      );
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(0),
        ]),
        const XPathSequence([1, 2, 3]),
      );
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(4),
        ]),
        const XPathSequence([1, 2, 3]),
      );
    });
    test('fn:reverse', () {
      expect(
        fnReverse(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [3, 2, 1],
      );
      expect(fnReverse(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:subsequence', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
        ]),
        [2, 3, 4, 5],
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]),
        [2, 3],
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          const XPathSequence.single(2),
        ]),
        const XPathSequence([1]),
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(-1),
          const XPathSequence.single(3),
        ]),
        const XPathSequence([1]),
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0.5),
          const XPathSequence.single(1),
        ]),
        const XPathSequence([1]),
      );
    });
    test('fn:unordered', () {
      const seq = XPathSequence([1, 2, 3]);
      expect(fnUnordered(context, [seq]), seq);
    });
  });
  group('functions that compare values in sequences', () {
    test('fn:distinct-values', () {
      expect(
        fnDistinctValues(context, [
          const XPathSequence([1, 2, 1, 3, 2]),
        ]),
        const XPathSequence([1, 2, 3]),
      );
    });
    test('fn:index-of', () {
      expect(
        fnIndexOf(context, [
          const XPathSequence([1, 2, 1, 3]),
          const XPathSequence.single(1),
        ]),
        const XPathSequence([1, 3]),
      );
      expect(
        fnIndexOf(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(4),
        ]),
        XPathSequence.empty,
      );
    });
    test('fn:deep-equal', () {
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 2]),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 3]),
        ]),
        [false],
      );
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 2, 3]),
        ]),
        [false],
      );
    });
  });
  group('aggregate functions', () {
    test('fn:count', () {
      expect(fnCount(context, [XPathSequence.empty]), [0]);
      expect(
        fnCount(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [3],
      );
    });
    test('fn:avg', () {
      expect(
        fnAvg(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [2.0],
      );
      expect(fnAvg(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:max', () {
      expect(
        fnMax(context, [
          const XPathSequence([1, 3, 2]),
        ]),
        [3],
      );
      expect(fnMax(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:min', () {
      expect(
        fnMin(context, [
          const XPathSequence([3, 1, 2]),
        ]),
        [1],
      );
      expect(fnMin(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:sum', () {
      expect(fnSum(context, [XPathSequence.empty]), [0]);
      expect(
        fnSum(context, [XPathSequence.empty, const XPathSequence.single(42)]),
        [42],
      );
      expect(
        fnSum(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        [6.0],
      );
    });
  });
  group('functions giving access to external information', () {
    test('fn:doc', () {
      expect(
        () => fnDoc(context, [const XPathSequence.single('uri')]),
        throwsA(isXPathEvaluationException(message: 'Document not found: uri')),
      );
    });
    test('fn:doc-available', () {
      expect(fnDocAvailable(context, [const XPathSequence.single('uri')]), [
        false,
      ]);
    });
    test('fn:collection', () {
      expect(fnCollection(context, []), isEmpty);
    });
    test('fn:uri-collection', () {
      expect(fnUriCollection(context, []), isEmpty);
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
    test('count', () {
      expectEvaluate(xml, 'count(/r/*)', [3]);
    });
    test('sum', () {
      expectEvaluate(xml, 'sum(/r/*)', [6]);
    });
    test('avg', () {
      expectEvaluate(xml, 'avg(/r/*)', [2.0]);
    });
    test('min', () {
      expectEvaluate(xml, 'min(/r/*)', [1]);
    });
    test('max', () {
      expectEvaluate(xml, 'max(/r/*)', [3]);
    });
  });
}
