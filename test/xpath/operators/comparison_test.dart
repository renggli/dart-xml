import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('comparator', () {
    test('compare numbers', () {
      expect(compare(1, 2), -1);
      expect(compare(2, 2), 0);
      expect(compare(2, 1), 1);
      expect(compare(1.0, 2.0), -1);
      expect(compare(1, 1.0), 0);
    });
    test('compare strings', () {
      expect(compare('a', 'b'), -1);
      expect(compare('b', 'b'), 0);
      expect(compare('b', 'a'), 1);
    });
    test('compare booleans', () {
      expect(compare(false, true), -1);
      expect(compare(true, true), 0);
      expect(compare(false, false), 0);
      expect(compare(true, false), 1);
    });
    test('compare mixed types', () {
      expect(compare(1, '2'), -1); // "1" < "2"
      expect(compare('2', 1), 1); // "2" > "1"
    });
  });
  group('value comparison operators', () {
    test('compare DateTime values', () {
      final earlier = DateTime.utc(2024, 1, 1);
      final later = DateTime.utc(2025, 6, 15);
      expect(
        opValueLessThan(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
        isXPathSequence([true]),
      );
      expect(
        opValueGreaterThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
        isXPathSequence([false]),
      );
      expect(
        opValueLessThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(earlier),
        ),
        isXPathSequence([true]),
      );
    });
    test('compare Duration values', () {
      const short = Duration(hours: 1);
      const long = Duration(days: 2);
      expect(
        opValueLessThan(
          const XPathSequence.single(short),
          const XPathSequence.single(long),
        ),
        isXPathSequence([true]),
      );
      expect(
        opValueGreaterThan(
          const XPathSequence.single(short),
          const XPathSequence.single(long),
        ),
        isXPathSequence([false]),
      );
    });
    test('compare bool values', () {
      expect(
        opValueLessThan(
          const XPathSequence.single(false),
          const XPathSequence.single(true),
        ),
        isXPathSequence([true]),
      );
      expect(
        opValueGreaterThanOrEqual(
          const XPathSequence.single(true),
          const XPathSequence.single(true),
        ),
        isXPathSequence([true]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueLessThan(XPathSequence.empty, const XPathSequence.single(1)),
        isXPathSequence(isEmpty),
      );
    });
  });
}
