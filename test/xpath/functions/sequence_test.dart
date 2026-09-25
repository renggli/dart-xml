import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/constructors.dart';
import 'package:xml/src/xpath/functions/sequence.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:empty', () {
    test('returns true for empty sequence', () {
      expect(fnEmpty(context, [XPathSequence.empty]), isXPathSequence([true]));
    });

    test('returns false for non-empty sequence', () {
      expect(fnEmpty(context, [seq(1)]), isXPathSequence([false]));
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
      expect(fnExists(context, [seq(1)]), isXPathSequence([true]));
    });
  });

  group('fn:head', () {
    test('returns empty for empty sequence', () {
      expect(fnHead(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns first item', () {
      expect(
        fnHead(context, [
          seq([1, 2, 3]),
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
          seq([1]),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns remaining items', () {
      expect(
        fnTail(context, [
          seq([1, 2, 3]),
        ]),
        isXPathSequence([2, 3]),
      );
    });
  });

  group('fn:insert-before', () {
    test('inserts at beginning', () {
      expect(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(1),
          seq(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
    });

    test('inserts in middle', () {
      expect(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(2),
          seq(0),
        ]),
        isXPathSequence([1, 0, 2]),
      );
    });

    test('inserts at end', () {
      expect(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(3),
          seq(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
    });

    test('handles zero index', () {
      expect(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(0),
          seq(0),
        ]),
        isXPathSequence([0, 1, 2]),
      );
    });

    test('handles out of bounds index', () {
      expect(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(10),
          seq(0),
        ]),
        isXPathSequence([1, 2, 0]),
      );
    });
  });

  group('fn:remove', () {
    test('removes item at index', () {
      expect(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(2),
        ]),
        isXPathSequence([1, 3]),
      );
    });

    test('handles zero index', () {
      expect(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(0),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });

    test('handles out of bounds index', () {
      expect(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(4),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
  });

  group('fn:reverse', () {
    test('reverses sequence', () {
      expect(
        fnReverse(context, [
          seq([1, 2, 3]),
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
          seq([1, 2, 3, 4, 5]),
          seq(2),
        ]),
        isXPathSequence([2, 3, 4, 5]),
      );
    });

    test('returns items within length limit', () {
      expect(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(2),
          seq(2),
        ]),
        isXPathSequence([2, 3]),
      );
    });

    test('handles zero starting position', () {
      expect(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(0),
          seq(2),
        ]),
        isXPathSequence([1]),
      );
    });

    test('handles negative starting position', () {
      expect(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(-1),
          seq(3),
        ]),
        isXPathSequence([1]),
      );
    });
  });

  group('fn:unordered', () {
    test('returns sequence unchanged', () {
      final sequence = seq([1, 2, 3]);
      expect(fnUnordered(context, [sequence]), isXPathSequence(sequence));
    });
  });

  group('fn:format-integer', () {
    test('formats integer', () {
      expect(
        fnFormatInteger(context, [seq(123), seq('#')]),
        isXPathSequence(['123']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatInteger(context, [XPathSequence.empty, seq('#')]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:format-number', () {
    test('formats number', () {
      expect(
        fnFormatNumber(context, [seq(123.45), seq('#')]),
        isXPathSequence(['123.45']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatNumber(context, [XPathSequence.empty, seq('#')]),
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
      expect(fnZeroOrOne(context, [seq(1)]), isXPathSequence([1]));
    });

    test('throws for multiple items', () {
      expect(
        () => fnZeroOrOne(context, [
          seq([1, 2]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:one-or-more', () {
    test('returns sequence with items', () {
      expect(fnOneOrMore(context, [seq(1)]), isXPathSequence([1]));
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
      expect(fnExactlyOne(context, [seq(1)]), isXPathSequence([1]));
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
          seq([1, 2]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:distinct-values', () {
    test('returns unique values', () {
      expect(
        fnDistinctValues(context, [
          seq([1, 2, 1, 3, 2]),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
  });

  group('fn:index-of', () {
    test('returns indices of item', () {
      expect(
        fnIndexOf(context, [
          seq([1, 2, 1, 3]),
          seq(1),
        ]),
        isXPathSequence([1, 3]),
      );
    });

    test('returns empty if item not found', () {
      expect(
        fnIndexOf(context, [
          seq([1, 2, 3]),
          seq(4),
        ]),
        XPathSequence.empty,
      );
    });
  });

  group('fn:deep-equal', () {
    test('returns true for same items', () {
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2]),
        ]),
        isXPathSequence(XPathSequence.trueSequence),
      );
    });
    test('returns false for different items', () {
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 3]),
        ]),
        isXPathSequence([false]),
      );
    });
    test('returns false for different length', () {
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2, 3]),
        ]),
        isXPathSequence([false]),
      );
    });
    test('lists and maps comparison', () {
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2]),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 3]),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2, 3]),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 1}),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 2}),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'b': 1}),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 1, 'b': 2}),
        ]),
        isXPathSequence([false]),
      );
    });
    test('NaN values are equal per IEEE 754 rule', () {
      expect(
        fnDeepEqual(context, [
          seq([double.nan]),
          seq([double.nan]),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnDeepEqual(context, [
          seq({'a': double.nan}),
          seq({'a': double.nan}),
        ]),
        isXPathSequence([true]),
      );
    });
    test('XmlNodes comparison', () {
      final doc1 = XmlDocument.parse('<r a="1">text</r>');
      final doc2 = XmlDocument.parse('<r a="1">text</r>');
      final doc3 = XmlDocument.parse('<r a="2">text</r>');
      final doc4 = XmlDocument.parse('<r a="1">other</r>');
      final doc5 = XmlDocument.parse('<diff>text</diff>');
      expect(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc2.rootElement)]),
        isXPathSequence([true]),
      );
      expect(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc3.rootElement)]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc4.rootElement)]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc5.rootElement)]),
        isXPathSequence([false]),
      );
      expect(
        fnDeepEqual(context, [
          seq(doc1.rootElement.attributes.first),
          seq(doc2.rootElement.attributes.first),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnDeepEqual(context, [
          seq(doc1.rootElement.attributes.first),
          seq(doc3.rootElement.attributes.first),
        ]),
        isXPathSequence([false]),
      );
    });
    test('functions throw exception', () {
      expect(
        () => fnDeepEqual(context, [
          seq(xsNumericConstructor),
          seq(xsNumericConstructor),
        ]),
        throwsA(
          isXPathEvaluationException(message: contains('Cannot compare')),
        ),
      );
    });
  });

  group('fn:count', () {
    test('returns item count', () {
      expect(fnCount(context, [XPathSequence.empty]), isXPathSequence([0]));
      expect(
        fnCount(context, [
          seq([1, 2, 3]),
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
          seq([1, 2, 3]),
        ]),
        isXPathSequence([2.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnAvg(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns average of yearMonthDurations', () {
      const d1 = XPathDuration.yearMonth(14); // P1Y2M
      const d2 = XPathDuration.yearMonth(10); // P10M
      // Average: 12 months (P1Y)
      expect(
        fnAvg(context, [
          seq([d1, d2]),
        ]),
        isXPathSequence([const XPathDuration.yearMonth(12)]),
      );
    });

    test('returns average of dayTimeDurations with round-half-to-even', () {
      const d1 = XPathDuration.dayTime(86400000000); // 24 hours
      const d2 = XPathDuration.dayTime(7200000000); // 2 hours
      // Average: 13 hours
      expect(
        fnAvg(context, [
          seq([d1, d2]),
        ]),
        isXPathSequence([const XPathDuration.dayTime(46800000000)]),
      );

      // Testing round-half-to-even:
      // 5 months / 2 = 2.5 months. Round half-to-even -> 2 months.
      expect(
        fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(5),
            const XPathDuration.yearMonth(0),
          ]),
        ]),
        isXPathSequence([const XPathDuration.yearMonth(2)]),
      );
      // 7 months / 2 = 3.5 months. Round half-to-even -> 4 months.
      expect(
        fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(7),
            const XPathDuration.yearMonth(0),
          ]),
        ]),
        isXPathSequence([const XPathDuration.yearMonth(4)]),
      );
    });

    test('throws error for mixed sequence or invalid types', () {
      expect(
        () => fnAvg(context, [
          seq([1, const XPathDuration.dayTime(86400000000)]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(1),
            const XPathDuration.dayTime(86400000000),
          ]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnAvg(context, [seq('not a number')]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnAvg(context, [seq(const XPathDuration(months: 1, days: 1))]),
        throwsA(isXPathEvaluationException()),
      );
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
          seq([1, 3, 2]),
        ]),
        isXPathSequence([3]),
      );
    });

    test('returns maximum for dates', () {
      expect(
        fnMax(context, [
          seq([
            DateTime.utc(2022, 1, 1),
            DateTime.utc(2022, 1, 3),
            DateTime.utc(2022, 1, 2),
          ]),
        ]),
        isXPathSequence([DateTime.utc(2022, 1, 3)]),
      );
    });

    test('returns maximum for strings', () {
      expect(
        fnMax(context, [
          seq(['a', 'c', 'b']),
        ]),
        isXPathSequence(['c']),
      );
    });

    test('returns maximum for durations', () {
      expect(
        fnMax(context, [
          seq([
            const XPathDuration.dayTime(86400000000),
            const XPathDuration.dayTime(259200000000),
            const XPathDuration.dayTime(172800000000),
          ]),
        ]),
        isXPathSequence([const XPathDuration.dayTime(259200000000)]),
      );
    });

    test('handles NaN', () {
      expect(
        fnMax(context, [
          seq([double.nan, 1.0, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(
        fnMax(context, [
          seq([1.0, double.nan, 2.0]),
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
          seq([3, 1, 2]),
        ]),
        isXPathSequence([1]),
      );
    });

    test('returns minimum for dates', () {
      expect(
        fnMin(context, [
          seq([
            DateTime.utc(2022, 1, 3),
            DateTime.utc(2022, 1, 1),
            DateTime.utc(2022, 1, 2),
          ]),
        ]),
        isXPathSequence([DateTime.utc(2022, 1, 1)]),
      );
    });

    test('returns minimum for strings', () {
      expect(
        fnMin(context, [
          seq(['c', 'a', 'b']),
        ]),
        isXPathSequence(['a']),
      );
    });

    test('returns minimum for durations', () {
      expect(
        fnMin(context, [
          seq([
            const XPathDuration.dayTime(259200000000),
            const XPathDuration.dayTime(86400000000),
            const XPathDuration.dayTime(172800000000),
          ]),
        ]),
        isXPathSequence([const XPathDuration.dayTime(86400000000)]),
      );
    });

    test('handles NaN', () {
      expect(
        fnMin(context, [
          seq([double.nan, 1.0, 2.0]),
        ]),
        isXPathSequence([isNaN]),
      );
      expect(
        fnMin(context, [
          seq([1.0, double.nan, 2.0]),
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
        fnSum(context, [XPathSequence.empty, seq(42)]),
        isXPathSequence([42]),
      );
      expect(
        fnSum(context, [XPathSequence.empty, XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
      expect(
        fnSum(context, [
          seq([1, 2, 3]),
        ]),
        isXPathSequence([6.0]),
      );
    });

    test('returns sum of durations', () {
      const d1 = XPathDuration.dayTime(86400000000);
      const d2 = XPathDuration.dayTime(172800000000);
      const d3 = XPathDuration.dayTime(259200000000);
      const sum = XPathDuration.dayTime(518400000000);
      expect(
        fnSum(context, [
          seq([d1, d2, d3]),
        ]),
        isXPathSequence([sum]),
      );
    });

    test('returns sum of yearMonthDurations', () {
      const d1 = XPathDuration.yearMonth(12); // P1Y
      const d2 = XPathDuration.yearMonth(10); // P10M
      expect(
        fnSum(context, [
          seq([d1, d2]),
        ]),
        isXPathSequence([const XPathDuration.yearMonth(22)]),
      );
    });

    test('throws error for mixed sequence or invalid types', () {
      expect(
        () => fnSum(context, [
          seq([1, const XPathDuration.dayTime(86400000000)]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnSum(context, [
          seq([
            const XPathDuration.yearMonth(1),
            const XPathDuration.dayTime(86400000000),
          ]),
        ]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnSum(context, [seq('not a number')]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => fnSum(context, [seq(const XPathDuration(months: 1, days: 1))]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'sum(/r/*)', isXPathSequence([6]));
    });
    test('atomization of XmlNode, Map, Function', () {
      final xmlNum = XmlDocument.parse('<r>42</r>');
      final xmlNotNum = XmlDocument.parse('<r>not a number</r>');
      expect(
        fnSum(context, [seq(xmlNum.rootElement)]),
        isXPathSequence([42.0]),
      );
      expect(
        () => fnSum(context, [seq(xmlNotNum.rootElement)]),
        throwsA(
          isXPathEvaluationException(
            message: contains('Cannot cast untypedAtomic'),
          ),
        ),
      );
      expect(
        () => fnSum(context, [
          seq({'key': 'value'}),
        ]),
        throwsA(
          isXPathEvaluationException(message: contains('Cannot atomize')),
        ),
      );
      expect(
        () => fnSum(context, [seq(xsNumericConstructor)]),
        throwsA(
          isXPathEvaluationException(message: contains('Cannot atomize')),
        ),
      );
    });
  });

  group('fn:doc', () {
    test('throws for missing document', () {
      expect(
        () => fnDoc(context, [seq('uri')]),
        throwsA(isXPathEvaluationException(message: 'Document not found: uri')),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnDoc(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns document when registered', () {
      final doc = XmlDocument.parse('<doc/>');
      final contextWithDoc = context.configuration
          .copy(documents: {'http://example.com/doc': doc})
          .context(context.item)
          .copy(variables: context.variables);
      expect(
        fnDoc(contextWithDoc, [seq('http://example.com/doc')]),
        isXPathSequence([doc]),
      );
    });
  });

  group('fn:doc-available', () {
    test('returns false if not available', () {
      expect(fnDocAvailable(context, [seq('uri')]), isXPathSequence([false]));
    });

    test('returns false for empty sequence', () {
      expect(
        fnDocAvailable(context, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });

    test('returns true if available', () {
      final doc = XmlDocument.parse('<doc/>');
      final contextWithDoc = context.configuration
          .copy(documents: {'http://example.com/doc': doc})
          .context(context.item)
          .copy(variables: context.variables);
      expect(
        fnDocAvailable(contextWithDoc, [seq('http://example.com/doc')]),
        isXPathSequence([true]),
      );
    });
  });

  group('fn:collection', () {
    test('throws FODC0002 when no default collection', () {
      expect(
        () => fnCollection(context, []),
        throwsA(isXPathEvaluationException(message: contains('FODC0002'))),
      );
    });
  });

  group('fn:uri-collection', () {
    test('throws FODC0002 when no default collection', () {
      expect(
        () => fnUriCollection(context, []),
        throwsA(isXPathEvaluationException(message: contains('FODC0002'))),
      );
    });
  });
}
