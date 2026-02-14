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
      expect(fnEmpty(context, [XPathSequence.empty]), isXPathSequence([true]));
      expect(
        fnEmpty(context, [const XPathSequence.single(1)]),
        isXPathSequence([false]),
      );
    });
    test('fn:exists', () {
      expect(
        fnExists(context, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
      expect(
        fnExists(context, [const XPathSequence.single(1)]),
        isXPathSequence([true]),
      );
    });
    test('fn:head', () {
      expect(fnHead(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
      expect(
        fnHead(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([1]),
      );
    });
    test('fn:tail', () {
      expect(fnTail(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
      expect(
        fnTail(context, [
          const XPathSequence([1]),
        ]),
        isXPathSequence(isEmpty),
      );
      expect(
        fnTail(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([2, 3]),
      );
    });
    test('fn:insert-before', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(2),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 0, 2]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(3),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(0),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(10),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
    });
    test('fn:remove', () {
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([1, 3]),
      );
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 3]),
      );
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(4),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
    test('fn:reverse', () {
      expect(
        fnReverse(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([3, 2, 1]),
      );
      expect(
        fnReverse(context, [XPathSequence.empty]),
        isXPathSequence(XPathSequence.empty),
      );
    });
    test('fn:subsequence', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([2, 3, 4, 5]),
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([2, 3]),
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([1]),
      );
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(-1),
          const XPathSequence.single(3),
        ]),
        isXPathSequence([1]),
      );
    });
    test('fn:unordered', () {
      const seq = XPathSequence([1, 2, 3]);
      expect(fnUnordered(context, [seq]), isXPathSequence(seq));
    });
  });
  group('functions that compare values in sequences', () {
    test('fn:distinct-values', () {
      expect(
        fnDistinctValues(context, [
          const XPathSequence([1, 2, 1, 3, 2]),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
    test('fn:index-of', () {
      expect(
        fnIndexOf(context, [
          const XPathSequence([1, 2, 1, 3]),
          const XPathSequence.single(1),
        ]),
        isXPathSequence([1, 3]),
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
        isXPathSequence(XPathSequence.trueSequence),
      );
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 3]),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([false]),
      );
    });
  });
  group('aggregate functions', () {
    test('fn:count', () {
      expect(fnCount(context, [XPathSequence.empty]), isXPathSequence([0]));
      expect(
        fnCount(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([3]),
      );
    });
    test('fn:avg', () {
      expect(
        fnAvg(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([2.0]),
      );
      expect(fnAvg(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });
    test('fn:max', () {
      expect(
        fnMax(context, [
          const XPathSequence([1, 3, 2]),
        ]),
        isXPathSequence([3]),
      );
      expect(
        fnMax(context, [
          XPathSequence([
            DateTime(2022, 1, 1),
            DateTime(2022, 1, 3),
            DateTime(2022, 1, 2),
          ]),
        ]),
        isXPathSequence([DateTime(2022, 1, 3)]),
      );
      expect(
        fnMax(context, [
          const XPathSequence(['a', 'c', 'b']),
        ]),
        isXPathSequence(['c']),
      );
      expect(
        fnMax(context, [
          const XPathSequence([
            Duration(days: 1),
            Duration(days: 3),
            Duration(days: 2),
          ]),
        ]),
        isXPathSequence([const Duration(days: 3)]),
      );
      expect(
        fnMax(context, [
          const XPathSequence([double.nan, 1.0, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(
        fnMax(context, [
          const XPathSequence([1.0, double.nan, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(fnMax(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });
    test('fn:min', () {
      expect(
        fnMin(context, [
          const XPathSequence([3, 1, 2]),
        ]),
        isXPathSequence([1]),
      );
      expect(
        fnMin(context, [
          XPathSequence([
            DateTime(2022, 1, 3),
            DateTime(2022, 1, 1),
            DateTime(2022, 1, 2),
          ]),
        ]),
        isXPathSequence([DateTime(2022, 1, 1)]),
      );
      expect(
        fnMin(context, [
          const XPathSequence(['c', 'a', 'b']),
        ]),
        isXPathSequence(['a']),
      );
      expect(
        fnMin(context, [
          const XPathSequence([
            Duration(days: 3),
            Duration(days: 1),
            Duration(days: 2),
          ]),
        ]),
        isXPathSequence([const Duration(days: 1)]),
      );
      expect(
        fnMin(context, [
          const XPathSequence([double.nan, 1.0, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(
        fnMin(context, [
          const XPathSequence([1.0, double.nan, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(fnMin(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });
    test('fn:sum', () {
      expect(fnSum(context, [XPathSequence.empty]), isXPathSequence([0]));
      expect(
        fnSum(context, [XPathSequence.empty, const XPathSequence.single(42)]),
        isXPathSequence([42]),
      );
      expect(
        fnSum(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([6.0]),
      );
      expect(
        fnSum(context, [
          const XPathSequence([
            Duration(days: 1),
            Duration(days: 2),
            Duration(days: 3),
          ]),
        ]),
        isXPathSequence([const Duration(days: 6)]),
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
      expect(
        fnDocAvailable(context, [const XPathSequence.single('uri')]),
        isXPathSequence([false]),
      );
    });
    test('fn:collection', () {
      expect(fnCollection(context, []), isXPathSequence(isEmpty));
    });
    test('fn:uri-collection', () {
      expect(fnUriCollection(context, []), isXPathSequence(isEmpty));
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
    test('count', () {
      expectEvaluate(xml, 'count(/r/*)', isXPathSequence([3]));
    });
    test('sum', () {
      expectEvaluate(xml, 'sum(/r/*)', isXPathSequence([6]));
    });
    test('avg', () {
      expectEvaluate(xml, 'avg(/r/*)', isXPathSequence([2.0]));
    });
    test('min', () {
      expectEvaluate(xml, 'min(/r/*)', isXPathSequence([1]));
    });
    test('max', () {
      expectEvaluate(xml, 'max(/r/*)', isXPathSequence([3]));
    });
  });
}
