import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/constructors.dart';
import 'package:xml/src/xpath/functions/sequence.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:empty', () {
    test('returns true for empty sequence', () {
      check(fnEmpty(context, [XPathSequence.empty])).isXPathSequence([true]);
    });

    test('returns false for non-empty sequence', () {
      check(fnEmpty(context, [seq(1)])).isXPathSequence([false]);
    });
  });

  group('fn:exists', () {
    test('returns false for empty sequence', () {
      check(fnExists(context, [XPathSequence.empty])).isXPathSequence([false]);
    });

    test('returns true for non-empty sequence', () {
      check(fnExists(context, [seq(1)])).isXPathSequence([true]);
    });
  });

  group('fn:head', () {
    test('returns empty for empty sequence', () {
      check(fnHead(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns first item', () {
      check(
        fnHead(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([1]);
    });
  });

  group('fn:tail', () {
    test('returns empty for empty sequence', () {
      check(fnTail(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns empty for single item sequence', () {
      check(
        fnTail(context, [
          seq([1]),
        ]),
      ).isXPathSequence(isEmpty);
    });

    test('returns remaining items', () {
      check(
        fnTail(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([2, 3]);
    });
  });

  group('fn:insert-before', () {
    test('inserts at beginning', () {
      check(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(1),
          seq(0),
        ]),
      ).isXPathSequence([0, 1, 2]);
    });

    test('inserts in middle', () {
      check(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(2),
          seq(0),
        ]),
      ).isXPathSequence([1, 0, 2]);
    });

    test('inserts at end', () {
      check(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(3),
          seq(0),
        ]),
      ).isXPathSequence([1, 2, 0]);
    });

    test('handles zero index', () {
      check(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(0),
          seq(0),
        ]),
      ).isXPathSequence([0, 1, 2]);
    });

    test('handles out of bounds index', () {
      check(
        fnInsertBefore(context, [
          seq([1, 2]),
          seq(10),
          seq(0),
        ]),
      ).isXPathSequence([1, 2, 0]);
    });
  });

  group('fn:remove', () {
    test('removes item at index', () {
      check(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(2),
        ]),
      ).isXPathSequence([1, 3]);
    });

    test('handles zero index', () {
      check(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(0),
        ]),
      ).isXPathSequence([1, 2, 3]);
    });

    test('handles out of bounds index', () {
      check(
        fnRemove(context, [
          seq([1, 2, 3]),
          seq(4),
        ]),
      ).isXPathSequence([1, 2, 3]);
    });
  });

  group('fn:reverse', () {
    test('reverses sequence', () {
      check(
        fnReverse(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([3, 2, 1]);
    });

    test('handles empty sequence', () {
      check(fnReverse(context, [XPathSequence.empty]))
          .isXPathSequence(XPathSequence.empty);
    });
  });

  group('fn:subsequence', () {
    test('returns remaining items from starting position', () {
      check(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(2),
        ]),
      ).isXPathSequence([2, 3, 4, 5]);
    });

    test('returns items within length limit', () {
      check(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(2),
          seq(2),
        ]),
      ).isXPathSequence([2, 3]);
    });

    test('handles zero starting position', () {
      check(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(0),
          seq(2),
        ]),
      ).isXPathSequence([1]);
    });

    test('handles negative starting position', () {
      check(
        fnSubsequence(context, [
          seq([1, 2, 3, 4, 5]),
          seq(-1),
          seq(3),
        ]),
      ).isXPathSequence([1]);
    });
  });

  group('fn:unordered', () {
    test('returns sequence unchanged', () {
      final sequence = seq([1, 2, 3]);
      check(fnUnordered(context, [sequence])).isXPathSequence(sequence);
    });
  });

  group('fn:format-integer', () {
    test('formats integer', () {
      check(fnFormatInteger(context, [seq(123), seq('#')]))
          .isXPathSequence(['123']);
      check(fnFormatInteger(context, [seq(123), seq('#'), seq('en')]))
          .isXPathSequence(['123']);
    });

    test('returns empty for empty sequence', () {
      check(fnFormatInteger(context, [XPathSequence.empty, seq('#')]))
          .isXPathSequence(isEmpty);
      check(
        fnFormatInteger(context, [XPathSequence.empty, seq('#'), seq('en')]),
      ).isXPathSequence(isEmpty);
    });
  });

  group('fn:format-number', () {
    test('formats number', () {
      check(fnFormatNumber(context, [seq(123.45), seq('#')]))
          .isXPathSequence(['123.45']);
      check(fnFormatNumber(context, [seq(123.45), seq('#'), seq('df')]))
          .isXPathSequence(['123.45']);
    });

    test('returns empty for empty sequence', () {
      check(fnFormatNumber(context, [XPathSequence.empty, seq('#')]))
          .isXPathSequence(isEmpty);
      check(fnFormatNumber(context, [XPathSequence.empty, seq('#'), seq('df')]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:zero-or-one', () {
    test('returns empty for empty sequence', () {
      check(fnZeroOrOne(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });

    test('returns item for single item sequence', () {
      check(fnZeroOrOne(context, [seq(1)])).isXPathSequence([1]);
    });

    test('throws for multiple items', () {
      check(
        () => fnZeroOrOne(context, [
          seq([1, 2]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
  });

  group('fn:one-or-more', () {
    test('returns sequence with items', () {
      check(fnOneOrMore(context, [seq(1)])).isXPathSequence([1]);
    });

    test('throws for empty sequence', () {
      check(() => fnOneOrMore(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('fn:exactly-one', () {
    test('returns single item sequence', () {
      check(fnExactlyOne(context, [seq(1)])).isXPathSequence([1]);
    });

    test('throws for empty sequence', () {
      check(() => fnExactlyOne(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('throws for multiple items', () {
      check(
        () => fnExactlyOne(context, [
          seq([1, 2]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
  });

  group('fn:distinct-values', () {
    test('returns unique values', () {
      check(
        fnDistinctValues(context, [
          seq([1, 2, 1, 3, 2]),
        ]),
      ).isXPathSequence([1, 2, 3]);
    });

    test('accepts collation argument', () {
      check(
        fnDistinctValues(context, [
          seq(['a', 'b', 'a']),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
      ).isXPathSequence(['a', 'b']);
    });

    test('deduplicates across numeric types (integer, decimal, double)', () {
      check(
        fnDistinctValues(context, [
          XPathSequence([
            XPathInteger.fromInt(1),
            const XPathDouble(1.0),
            XPathDecimal.parse('1.00'),
          ]),
        ]),
      ).length.equals(1);
    });
  });

  group('fn:index-of', () {
    test('returns indices of item', () {
      check(
        fnIndexOf(context, [
          seq([1, 2, 1, 3]),
          seq(1),
        ]),
      ).isXPathSequence([1, 3]);
    });

    test('returns empty if item not found', () {
      check(
        fnIndexOf(context, [
          seq([1, 2, 3]),
          seq(4),
        ]),
      ).equals(XPathSequence.empty);
    });

    test('accepts collation argument', () {
      check(
        fnIndexOf(context, [
          seq(['a', 'b', 'a']),
          seq('a'),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
      ).isXPathSequence([1, 3]);
    });

    test('returns empty if search target is empty', () {
      check(
        fnIndexOf(context, [
          seq([1, 2, 3]),
          XPathSequence.empty,
        ]),
      ).equals(XPathSequence.empty);
      check(
        fnIndexOf(context, [
          seq([1, 2, 3]),
          XPathSequence.empty,
          seq('collation'),
        ]),
      ).equals(XPathSequence.empty);
    });
  });

  group('fn:deep-equal', () {
    test('returns true for same items', () {
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2]),
        ]),
      ).isXPathSequence(XPathSequence.trueSequence);
    });

    test('accepts collation argument', () {
      check(
        fnDeepEqual(context, [
          seq(['a']),
          seq(['a']),
          seq('collation'),
        ]),
      ).isXPathSequence([true]);
    });

    test('XPathArray deep-equal comparison', () {
      final arr1 = XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]);
      final arr2 = XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]);
      final arr3 = XPathArray([XPathSequence.single(XPathInteger.fromInt(2))]);
      final arrDiffLen = XPathArray([
        XPathSequence.single(XPathInteger.fromInt(1)),
        XPathSequence.single(XPathInteger.fromInt(2)),
      ]);
      check(
        fnDeepEqual(context, [
          XPathSequence.single(arr1),
          XPathSequence.single(arr2),
        ]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [
          XPathSequence.single(arr1),
          XPathSequence.single(arr3),
        ]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          XPathSequence.single(arr1),
          XPathSequence.single(arrDiffLen),
        ]),
      ).isXPathSequence([false]);
    });
    test('returns false for different items', () {
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 3]),
        ]),
      ).isXPathSequence([false]);
    });
    test('returns false for different length', () {
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([false]);
    });
    test('lists and maps comparison', () {
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2]),
        ]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 3]),
        ]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          seq([1, 2]),
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 1}),
        ]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 2}),
        ]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'b': 1}),
        ]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          seq({'a': 1}),
          seq({'a': 1, 'b': 2}),
        ]),
      ).isXPathSequence([false]);
    });
    test('NaN values are equal per IEEE 754 rule', () {
      check(
        fnDeepEqual(context, [
          seq([double.nan]),
          seq([double.nan]),
        ]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [
          seq({'a': double.nan}),
          seq({'a': double.nan}),
        ]),
      ).isXPathSequence([true]);
    });
    test('XmlNodes comparison', () {
      final doc1 = XmlDocument.parse('<r a="1">text</r>');
      final doc2 = XmlDocument.parse('<r a="1">text</r>');
      final doc3 = XmlDocument.parse('<r a="2">text</r>');
      final doc4 = XmlDocument.parse('<r a="1">other</r>');
      final doc5 = XmlDocument.parse('<diff>text</diff>');
      check(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc2.rootElement)]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc3.rootElement)]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc4.rootElement)]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [seq(doc1.rootElement), seq(doc5.rootElement)]),
      ).isXPathSequence([false]);
      check(
        fnDeepEqual(context, [
          seq(doc1.rootElement.attributes.first),
          seq(doc2.rootElement.attributes.first),
        ]),
      ).isXPathSequence([true]);
      check(
        fnDeepEqual(context, [
          seq(doc1.rootElement.attributes.first),
          seq(doc3.rootElement.attributes.first),
        ]),
      ).isXPathSequence([false]);
    });
    test('functions throw exception', () {
      check(
            () => fnDeepEqual(context, [
              seq(xsNumericConstructor),
              seq(xsNumericConstructor),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Cannot compare'));
    });
  });

  group('fn:count', () {
    test('returns item count', () {
      check(fnCount(context, [XPathSequence.empty])).isXPathSequence([0]);
      check(
        fnCount(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([3]);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'count(/r/*)', isXPathSequence([3]));
    });
  });

  group('fn:avg', () {
    test('returns average', () {
      check(
        fnAvg(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([2.0]);
    });

    test('returns empty for empty sequence', () {
      check(fnAvg(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns average of yearMonthDurations', () {
      const d1 = XPathDuration.yearMonth(14); // P1Y2M
      const d2 = XPathDuration.yearMonth(10); // P10M
      // Average: 12 months (P1Y)
      check(
        fnAvg(context, [
          seq([d1, d2]),
        ]),
      ).isXPathSequence([const XPathDuration.yearMonth(12)]);
    });

    test('returns average of dayTimeDurations with round-half-to-even', () {
      const d1 = XPathDuration.dayTime(86400000000); // 24 hours
      const d2 = XPathDuration.dayTime(7200000000); // 2 hours
      // Average: 13 hours
      check(
        fnAvg(context, [
          seq([d1, d2]),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(46800000000)]);

      // Testing round-half-to-even:
      // 5 months / 2 = 2.5 months. Round half-to-even -> 2 months.
      check(
        fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(5),
            const XPathDuration.yearMonth(0),
          ]),
        ]),
      ).isXPathSequence([const XPathDuration.yearMonth(2)]);
      // 7 months / 2 = 3.5 months. Round half-to-even -> 4 months.
      check(
        fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(7),
            const XPathDuration.yearMonth(0),
          ]),
        ]),
      ).isXPathSequence([const XPathDuration.yearMonth(4)]);
    });

    test('throws error for mixed sequence or invalid types', () {
      check(
        () => fnAvg(context, [
          seq([1, const XPathDuration.dayTime(86400000000)]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(
        () => fnAvg(context, [
          seq([
            const XPathDuration.yearMonth(1),
            const XPathDuration.dayTime(86400000000),
          ]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(() => fnAvg(context, [seq('not a number')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(
        () => fnAvg(context, [seq(const XPathDuration(months: 1, days: 1))]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(
        () => fnAvg(context, [
          const XPathSequence.single(XPathUntypedAtomic('invalid')),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'avg(/r/*)', isXPathSequence([2.0]));
    });
  });

  group('fn:max', () {
    test('returns maximum for numbers', () {
      check(
        fnMax(context, [
          seq([1, 3, 2]),
        ]),
      ).isXPathSequence([3]);
    });

    test('accepts collation argument', () {
      check(
        fnMax(context, [
          seq(['a', 'c', 'b']),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
      ).isXPathSequence(['c']);
    });

    test('throws for invalid untypedAtomic and mixed types', () {
      check(
        () => fnMax(context, [
          const XPathSequence.single(XPathUntypedAtomic('not-a-number')),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(
        () => fnMax(context, [
          seq([1, 'a']),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('returns maximum for dates', () {
      check(
        fnMax(context, [
          seq([
            DateTime.utc(2022, 1, 1),
            DateTime.utc(2022, 1, 3),
            DateTime.utc(2022, 1, 2),
          ]),
        ]),
      ).isXPathSequence([DateTime.utc(2022, 1, 3)]);
    });

    test('returns maximum for strings', () {
      check(
        fnMax(context, [
          seq(['a', 'c', 'b']),
        ]),
      ).isXPathSequence(['c']);
    });

    test('returns maximum for durations', () {
      check(
        fnMax(context, [
          seq([
            const XPathDuration.dayTime(86400000000),
            const XPathDuration.dayTime(259200000000),
            const XPathDuration.dayTime(172800000000),
          ]),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(259200000000)]);
    });

    test('handles NaN', () {
      check(
        fnMax(context, [
          seq([double.nan, 1.0, 2.0]),
        ]),
      ).isXPathSequence([isNaN]);
      check(
        fnMax(context, [
          seq([1.0, double.nan, 2.0]),
        ]),
      ).isXPathSequence([isNaN]);
    });

    test('returns empty for empty sequence', () {
      check(fnMax(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'max(/r/*)', isXPathSequence([3]));
    });
  });

  group('fn:min', () {
    test('returns minimum for numbers', () {
      check(
        fnMin(context, [
          seq([3, 1, 2]),
        ]),
      ).isXPathSequence([1]);
    });

    test('accepts collation argument', () {
      check(
        fnMin(context, [
          seq(['c', 'a', 'b']),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
      ).isXPathSequence(['a']);
    });

    test('returns minimum for dates', () {
      check(
        fnMin(context, [
          seq([
            DateTime.utc(2022, 1, 3),
            DateTime.utc(2022, 1, 1),
            DateTime.utc(2022, 1, 2),
          ]),
        ]),
      ).isXPathSequence([DateTime.utc(2022, 1, 1)]);
    });

    test('returns minimum for strings', () {
      check(
        fnMin(context, [
          seq(['c', 'a', 'b']),
        ]),
      ).isXPathSequence(['a']);
    });

    test('returns minimum for durations', () {
      check(
        fnMin(context, [
          seq([
            const XPathDuration.dayTime(259200000000),
            const XPathDuration.dayTime(86400000000),
            const XPathDuration.dayTime(172800000000),
          ]),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(86400000000)]);
    });

    test('handles NaN', () {
      check(
        fnMin(context, [
          seq([double.nan, 1.0, 2.0]),
        ]),
      ).isXPathSequence([isNaN]);
      check(
        fnMin(context, [
          seq([1.0, double.nan, 2.0]),
        ]),
      ).isXPathSequence([isNaN]);
    });

    test('returns empty for empty sequence', () {
      check(fnMin(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'min(/r/*)', isXPathSequence([1]));
    });
  });

  group('fn:sum', () {
    test('returns sum of numbers', () {
      check(fnSum(context, [XPathSequence.empty])).isXPathSequence([0]);
      check(fnSum(context, [XPathSequence.empty, seq(42)]))
          .isXPathSequence([42]);
      check(fnSum(context, [XPathSequence.empty, XPathSequence.empty]))
          .isXPathSequence(isEmpty);
      check(
        fnSum(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([6.0]);
    });

    test('returns sum of durations', () {
      const d1 = XPathDuration.dayTime(86400000000);
      const d2 = XPathDuration.dayTime(172800000000);
      const d3 = XPathDuration.dayTime(259200000000);
      const sum = XPathDuration.dayTime(518400000000);
      check(
        fnSum(context, [
          seq([d1, d2, d3]),
        ]),
      ).isXPathSequence([sum]);
    });

    test('returns sum of yearMonthDurations', () {
      const d1 = XPathDuration.yearMonth(12); // P1Y
      const d2 = XPathDuration.yearMonth(10); // P10M
      check(
        fnSum(context, [
          seq([d1, d2]),
        ]),
      ).isXPathSequence([const XPathDuration.yearMonth(22)]);
    });

    test('throws error for mixed sequence or invalid types', () {
      check(
        () => fnSum(context, [
          seq([1, const XPathDuration.dayTime(86400000000)]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(
        () => fnSum(context, [
          seq([
            const XPathDuration.yearMonth(1),
            const XPathDuration.dayTime(86400000000),
          ]),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(() => fnSum(context, [seq('not a number')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(
        () => fnSum(context, [seq(const XPathDuration(months: 1, days: 1))]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
      expectEvaluate(xml, 'sum(/r/*)', isXPathSequence([6]));
    });
    test('atomization of XmlNode, Map, Function', () {
      final xmlNum = XmlDocument.parse('<r>42</r>');
      final xmlNotNum = XmlDocument.parse('<r>not a number</r>');
      check(fnSum(context, [seq(xmlNum.rootElement)])).isXPathSequence([42.0]);
      check(() => fnSum(context, [seq(xmlNotNum.rootElement)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Cannot cast untypedAtomic'),
          );
      check(
            () => fnSum(context, [
              seq({'key': 'value'}),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Cannot atomize'));
      check(() => fnSum(context, [seq(xsNumericConstructor)]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Cannot atomize'));
    });
  });

  group('fn:doc', () {
    test('throws for missing document', () {
      check(() => fnDoc(context, [seq('uri')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Document not found: uri'),
          );
    });

    test('returns empty for empty sequence', () {
      check(fnDoc(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns document when registered', () {
      final doc = XmlDocument.parse('<doc/>');
      final contextWithDoc = context.configuration
          .copy(documents: {'http://example.com/doc': doc})
          .context(context.item)
          .copy(variables: context.variables);
      check(fnDoc(contextWithDoc, [seq('http://example.com/doc')]))
          .isXPathSequence([doc]);
    });
  });

  group('fn:doc-available', () {
    test('returns false if not available', () {
      check(fnDocAvailable(context, [seq('uri')])).isXPathSequence([false]);
    });

    test('returns false for empty sequence', () {
      check(fnDocAvailable(context, [XPathSequence.empty]))
          .isXPathSequence([false]);
    });

    test('returns true if available', () {
      final doc = XmlDocument.parse('<doc/>');
      final contextWithDoc = context.configuration
          .copy(documents: {'http://example.com/doc': doc})
          .context(context.item)
          .copy(variables: context.variables);
      check(fnDocAvailable(contextWithDoc, [seq('http://example.com/doc')]))
          .isXPathSequence([true]);
    });
  });

  group('fn:collection', () {
    test('throws FODC0002 when no default collection', () {
      check(() => fnCollection(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FODC0002'));
    });
  });

  group('fn:uri-collection', () {
    test('throws FODC0002 when no default collection', () {
      check(() => fnUriCollection(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FODC0002'));
    });
  });
}
