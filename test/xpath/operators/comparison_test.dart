import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

void main() {
  group('compare', () {
    test('numbers', () {
      expect(compare(XPathInteger.fromInt(1), XPathInteger.fromInt(2)), -1);
      expect(compare(XPathInteger.fromInt(2), XPathInteger.fromInt(2)), 0);
      expect(compare(XPathInteger.fromInt(2), XPathInteger.fromInt(1)), 1);
      expect(compare(const XPathDouble(1.0), const XPathDouble(2.0)), -1);
      expect(compare(XPathInteger.fromInt(1), const XPathDouble(1.0)), 0);
    });
    test('strings', () {
      expect(compare(const XPathString('a'), const XPathString('b')), -1);
      expect(compare(const XPathString('b'), const XPathString('b')), 0);
      expect(compare(const XPathString('b'), const XPathString('a')), 1);
    });
    test('booleans', () {
      expect(
        compare(XPathBoolean.falseInstance, XPathBoolean.trueInstance),
        -1,
      );
      expect(compare(XPathBoolean.trueInstance, XPathBoolean.trueInstance), 0);
      expect(
        compare(XPathBoolean.falseInstance, XPathBoolean.falseInstance),
        0,
      );
      expect(compare(XPathBoolean.trueInstance, XPathBoolean.falseInstance), 1);
    });
    test('incompatible types throw', () {
      expect(
        () => compare(XPathInteger.fromInt(1), const XPathString('2')),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => compare(const XPathString('2'), XPathInteger.fromInt(1)),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  final earlier = XPathDateTime.fromDateTime(DateTime.utc(2024, 1, 1));
  final later = XPathDateTime.fromDateTime(DateTime.utc(2025, 6, 15));
  const shortDuration = XPathDuration.dayTime(Duration.microsecondsPerHour);
  const longDuration = XPathDuration.dayTime(2 * Duration.microsecondsPerDay);

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
          const XPathSequence.single(XPathBoolean.falseInstance),
          const XPathSequence.single(XPathBoolean.trueInstance),
        ),
        isXPathSequence([true]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueLessThan(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
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
          const XPathSequence.single(XPathBoolean.trueInstance),
          const XPathSequence.single(XPathBoolean.trueInstance),
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
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence([true]),
      );
    });
    test('not equal numbers', () {
      expect(
        opValueEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ),
        isXPathSequence([false]),
      );
    });
    test('atomize node', () {
      final node = XmlElement(const XmlName('a'), [], [XmlText('foo')]);
      expect(
        opValueEqual(
          XPathSequence.single(XPathNode(node)),
          const XPathSequence.single(XPathString('foo')),
        ),
        isXPathSequence([true]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueEqual(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence(isEmpty),
      );
    });
    test('sequence with more than one item throws', () {
      final multiple = XPathSequence([
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(2),
      ]);
      final single = XPathSequence.single(XPathInteger.fromInt(1));
      expect(
        () => opValueEqual(multiple, single),
        throwsA(
          isXPathEvaluationException(
            message: contains('Sequence contains more than one item'),
          ),
        ),
      );
    });
  });

  group('opValueNotEqual', () {
    test('not equal numbers', () {
      expect(
        opValueNotEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ),
        isXPathSequence([true]),
      );
    });
    test('equal numbers', () {
      expect(
        opValueNotEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence([false]),
      );
    });
    test('empty sequence returns empty', () {
      expect(
        opValueNotEqual(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('atomization of maps, arrays, and functions', () {
    test('atomize array', () {
      expect(
        opValueEqual(
          XPathSequence.single(
            XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]),
          ),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence([true]),
      );
    });

    test('atomize nested array', () {
      expect(
        opValueEqual(
          XPathSequence.single(
            XPathArray([
              XPathSequence.single(
                XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]),
              ),
            ]),
          ),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isXPathSequence([true]),
      );
    });

    test('atomizing map throws FOTY0013', () {
      final map = XPathMap({
        const XPathString('a'): XPathSequence.single(XPathInteger.fromInt(1)),
      });
      expect(
        () => opValueEqual(
          XPathSequence.single(map),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        throwsA(
          isXPathEvaluationException(
            message: contains('Cannot atomize a map or function item'),
          ),
        ),
      );
    });

    test('atomizing function throws FOTY0013', () {
      XPathSequence dummy(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.empty;
      expect(
        () => opValueEqual(
          XPathSequence.single(dummy.toXPathFunction()),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        throwsA(
          isXPathEvaluationException(
            message: contains('Cannot atomize a map or function item'),
          ),
        ),
      );
    });
  });
}
