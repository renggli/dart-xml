import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/sequence.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:empty', () {
    test('returns true for empty sequence', () {
      expect(fnEmpty(context, [XPathSequence.empty]), isXPathSequence([true]));
    });

    test('returns false for non-empty sequence', () {
      expect(
        fnEmpty(context, [const XPathSequence.single(1)]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:exists', () {
    test('returns false for empty sequence', () {
      expect(
        fnExists(context, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });

    test('returns true for non-empty sequence', () {
      expect(
        fnExists(context, [const XPathSequence.single(1)]),
        isXPathSequence([true]),
      );
    });
  });

  group('fn:head', () {
    test('returns empty for empty sequence', () {
      expect(fnHead(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns first item', () {
      expect(
        fnHead(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([1]),
      );
    });
  });

  group('fn:tail', () {
    test('returns empty for empty sequence', () {
      expect(fnTail(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns empty for single item sequence', () {
      expect(
        fnTail(context, [
          const XPathSequence([1]),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns remaining items', () {
      expect(
        fnTail(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([2, 3]),
      );
    });
  });

  group('fn:insert-before', () {
    test('inserts at beginning', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
    });

    test('inserts in middle', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(2),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 0, 2]),
      );
    });

    test('inserts at end', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(3),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
    });

    test('handles zero index', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(0),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
    });

    test('handles out of bounds index', () {
      expect(
        fnInsertBefore(context, [
          const XPathSequence([1, 2]),
          const XPathSequence.single(10),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
    });
  });

  group('fn:remove', () {
    test('removes item at index', () {
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([1, 3]),
      );
    });

    test('handles zero index', () {
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });

    test('handles out of bounds index', () {
      expect(
        fnRemove(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(4),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
  });

  group('fn:reverse', () {
    test('reverses sequence', () {
      expect(
        fnReverse(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([3, 2, 1]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnReverse(context, [XPathSequence.empty]),
        isXPathSequence(XPathSequence.empty),
      );
    });
  });

  group('fn:subsequence', () {
    test('returns remaining items from starting position', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([2, 3, 4, 5]),
      );
    });

    test('returns items within length limit', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([2, 3]),
      );
    });

    test('handles zero starting position', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([1]),
      );
    });

    test('handles negative starting position', () {
      expect(
        fnSubsequence(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(-1),
          const XPathSequence.single(3),
        ]),
        isXPathSequence([1]),
      );
    });
  });

  group('fn:unordered', () {
    test('returns sequence unchanged', () {
      const seq = XPathSequence([1, 2, 3]);
      expect(fnUnordered(context, [seq]), isXPathSequence(seq));
    });
  });

  group('fn:format-integer', () {
    test('formats integer', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('#'),
        ]),
        isXPathSequence(['123']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatInteger(context, [
          XPathSequence.empty,
          const XPathSequence.single('#'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:format-number', () {
    test('formats number', () {
      expect(
        fnFormatNumber(context, [
          const XPathSequence.single(123.45),
          const XPathSequence.single('#'),
        ]),
        isXPathSequence(['123.45']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatNumber(context, [
          XPathSequence.empty,
          const XPathSequence.single('#'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:zero-or-one', () {
    test('returns empty for empty sequence', () {
      expect(
        fnZeroOrOne(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns item for single item sequence', () {
      expect(
        fnZeroOrOne(context, [const XPathSequence.single(1)]),
        isXPathSequence([1]),
      );
    });

    test('throws for multiple items', () {
      expect(
        () => fnZeroOrOne(context, [
          const XPathSequence([1, 2]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:one-or-more', () {
    test('returns sequence with items', () {
      expect(
        fnOneOrMore(context, [const XPathSequence.single(1)]),
        isXPathSequence([1]),
      );
    });

    test('throws for empty sequence', () {
      expect(
        () => fnOneOrMore(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:exactly-one', () {
    test('returns single item sequence', () {
      expect(
        fnExactlyOne(context, [const XPathSequence.single(1)]),
        isXPathSequence([1]),
      );
    });

    test('throws for empty sequence', () {
      expect(
        () => fnExactlyOne(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('throws for multiple items', () {
      expect(
        () => fnExactlyOne(context, [
          const XPathSequence([1, 2]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:distinct-values', () {
    test('returns unique values', () {
      expect(
        fnDistinctValues(context, [
          const XPathSequence([1, 2, 1, 3, 2]),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
  });

  group('fn:index-of', () {
    test('returns indices of item', () {
      expect(
        fnIndexOf(context, [
          const XPathSequence([1, 2, 1, 3]),
          const XPathSequence.single(1),
        ]),
        isXPathSequence([1, 3]),
      );
    });

    test('returns empty if item not found', () {
      expect(
        fnIndexOf(context, [
          const XPathSequence([1, 2, 3]),
          const XPathSequence.single(4),
        ]),
        XPathSequence.empty,
      );
    });
  });

  group('fn:deep-equal', () {
    test('returns true for same items', () {
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 2]),
        ]),
        isXPathSequence(XPathSequence.trueSequence),
      );
    });

    test('returns false for different items', () {
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 3]),
        ]),
        isXPathSequence([false]),
      );
    });

    test('returns false for different length', () {
      expect(
        fnDeepEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:count', () {
    test('returns item count', () {
      expect(fnCount(context, [XPathSequence.empty]), isXPathSequence([0]));
      expect(
        fnCount(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([3]),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'count(/r/*)', isXPathSequence([3]));
    });
  });

  group('fn:avg', () {
    test('returns average', () {
      expect(
        fnAvg(context, [
          const XPathSequence([1, 2, 3]),
        ]),
        isXPathSequence([2.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnAvg(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'avg(/r/*)', isXPathSequence([2.0]));
    });
  });

  group('fn:max', () {
    test('returns maximum for numbers', () {
      expect(
        fnMax(context, [
          const XPathSequence([1, 3, 2]),
        ]),
        isXPathSequence([3]),
      );
    });

    test('returns maximum for dates', () {
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
    });

    test('returns maximum for strings', () {
      expect(
        fnMax(context, [
          const XPathSequence(['a', 'c', 'b']),
        ]),
        isXPathSequence(['c']),
      );
    });

    test('returns maximum for durations', () {
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
    });

    test('handles NaN', () {
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
    });

    test('returns empty for empty sequence', () {
      expect(fnMax(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'max(/r/*)', isXPathSequence([3]));
    });
  });

  group('fn:min', () {
    test('returns minimum for numbers', () {
      expect(
        fnMin(context, [
          const XPathSequence([3, 1, 2]),
        ]),
        isXPathSequence([1]),
      );
    });

    test('returns minimum for dates', () {
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
    });

    test('returns minimum for strings', () {
      expect(
        fnMin(context, [
          const XPathSequence(['c', 'a', 'b']),
        ]),
        isXPathSequence(['a']),
      );
    });

    test('returns minimum for durations', () {
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
    });

    test('handles NaN', () {
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
    });

    test('returns empty for empty sequence', () {
      expect(fnMin(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'min(/r/*)', isXPathSequence([1]));
    });
  });

  group('fn:sum', () {
    test('returns sum of numbers', () {
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
    });

    test('returns sum of durations', () {
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

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'sum(/r/*)', isXPathSequence([6]));
    });
  });

  group('fn:doc', () {
    test('throws for missing document', () {
      expect(
        () => fnDoc(context, [const XPathSequence.single('uri')]),
        throwsA(isXPathEvaluationException(message: 'Document not found: uri')),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnDoc(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });
  });

  group('fn:doc-available', () {
    test('returns false if not available', () {
      expect(
        fnDocAvailable(context, [const XPathSequence.single('uri')]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:collection', () {
    test('returns empty sequence', () {
      expect(fnCollection(context, []), isXPathSequence(isEmpty));
    });
  });

  group('fn:uri-collection', () {
    test('returns empty sequence', () {
      expect(fnUriCollection(context, []), isXPathSequence(isEmpty));
    });
  });
}
