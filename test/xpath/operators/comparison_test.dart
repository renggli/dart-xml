import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  group('compare', () {
    test('numbers', () {
      expect(compare(1, 2), -1);
      expect(compare(2, 2), 0);
      expect(compare(2, 1), 1);
      expect(compare(1.0, 2.0), -1);
      expect(compare(1, 1.0), 0);
    });
    test('strings', () {
      expect(compare('a', 'b'), -1);
      expect(compare('b', 'b'), 0);
      expect(compare('b', 'a'), 1);
    });
    test('booleans', () {
      expect(compare(false, true), -1);
      expect(compare(true, true), 0);
      expect(compare(false, false), 0);
      expect(compare(true, false), 1);
    });
    test('mixed types', () {
      expect(compare(1, '2'), -1); // "1" < "2"
      expect(compare('2', 1), 1); // "2" > "1"
    });
  });

  final earlier = DateTime.utc(2024, 1, 1);
  final later = DateTime.utc(2025, 6, 15);
  const shortDuration = Duration(hours: 1);
  const longDuration = Duration(days: 2);

  group('opValueLessThan', () {
    test('DateTime values', () {
      expect(
        opValueLessThan(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
        isXPathSequence([true]),
      );
    });
    test('Duration values', () {
      expect(
        opValueLessThan(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
        isXPathSequence([true]),
      );
    });
    test('bool values', () {
      expect(
        opValueLessThan(
          const XPathSequence.single(false),
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

  group('opValueGreaterThanOrEqual', () {
    test('DateTime values', () {
      expect(
        opValueGreaterThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
        isXPathSequence([false]),
      );
    });
    test('bool values', () {
      expect(
        opValueGreaterThanOrEqual(
          const XPathSequence.single(true),
          const XPathSequence.single(true),
        ),
        isXPathSequence([true]),
      );
    });
  });

  group('opValueLessThanOrEqual', () {
    test('DateTime values', () {
      expect(
        opValueLessThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(earlier),
        ),
        isXPathSequence([true]),
      );
    });
  });

  group('opValueGreaterThan', () {
    test('Duration values', () {
      expect(
        opValueGreaterThan(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
        isXPathSequence([false]),
      );
    });
  });

  group('opValueEqual', () {
    test('equal numbers', () {
      expect(
        opValueEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ),
        isXPathSequence([true]),
      );
    });
    test('not equal numbers', () {
      expect(
        opValueEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        isXPathSequence([false]),
      );
    });
    test('atomize node', () {
      final node = XmlElement(const XmlName('a'), [], [XmlText('foo')]);
      expect(
        opValueEqual(
          XPathSequence.single(node),
          const XPathSequence.single('foo'),
        ),
        isXPathSequence([true]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueEqual(XPathSequence.empty, const XPathSequence.single(1)),
        isXPathSequence(isEmpty),
      );
    });
    test('sequence with more than one item throws', () {
      const multiple = XPathSequence([1, 2]);
      const single = XPathSequence.single(1);
      expect(
        () => opValueEqual(multiple, single),
        throwsA(
          isXPathEvaluationException(
            message: 'Sequence contains more than one item: (1, 2)',
          ),
        ),
      );
    });
  });

  group('opValueNotEqual', () {
    test('not equal numbers', () {
      expect(
        opValueNotEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        isXPathSequence([true]),
      );
    });
    test('equal numbers', () {
      expect(
        opValueNotEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueNotEqual(XPathSequence.empty, const XPathSequence.single(1)),
        isXPathSequence(isEmpty),
      );
    });
  });
}
