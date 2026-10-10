import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('compare', () {
    test('numbers', () {
      check(compare(XPathInteger.fromInt(1), XPathInteger.fromInt(2)))
          .equals(-1);
      check(compare(XPathInteger.fromInt(2), XPathInteger.fromInt(2)))
          .equals(0);
      check(compare(XPathInteger.fromInt(2), XPathInteger.fromInt(1)))
          .equals(1);
      check(compare(const XPathDouble(1.0), const XPathDouble(2.0))).equals(-1);
      check(compare(XPathInteger.fromInt(1), const XPathDouble(1.0))).equals(0);
    });
    test('strings', () {
      check(compare(const XPathString('a'), const XPathString('b'))).equals(-1);
      check(compare(const XPathString('b'), const XPathString('b'))).equals(0);
      check(compare(const XPathString('b'), const XPathString('a'))).equals(1);
    });
    test('booleans', () {
      check(compare(XPathBoolean.falseInstance, XPathBoolean.trueInstance))
          .equals(-1);
      check(compare(XPathBoolean.trueInstance, XPathBoolean.trueInstance))
          .equals(0);
      check(compare(XPathBoolean.falseInstance, XPathBoolean.falseInstance))
          .equals(0);
      check(compare(XPathBoolean.trueInstance, XPathBoolean.falseInstance))
          .equals(1);
    });
    test('incompatible types throw', () {
      check(() => compare(XPathInteger.fromInt(1), const XPathString('2')))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => compare(const XPathString('2'), XPathInteger.fromInt(1)))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  final earlier = XPathDateTime.fromDateTime(DateTime.utc(2024, 1, 1));
  final later = XPathDateTime.fromDateTime(DateTime.utc(2025, 6, 15));
  const shortDuration = XPathDuration.dayTime(Duration.microsecondsPerHour);
  const longDuration = XPathDuration.dayTime(2 * Duration.microsecondsPerDay);

  group('opValueLessThan', () {
    test('DateTime values', () {
      check(
        opValueLessThan(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
      ).isXPathSequence([true]);
    });
    test('Duration values', () {
      check(
        opValueLessThan(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
      ).isXPathSequence([true]);
    });
    test('bool values', () {
      check(
        opValueLessThan(
          const XPathSequence.single(XPathBoolean.falseInstance),
          const XPathSequence.single(XPathBoolean.trueInstance),
        ),
      ).isXPathSequence([true]);
    });
    test('empty sequence returns empty', () {
      check(
        opValueLessThan(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence(isEmpty);
    });
  });

  group('opValueGreaterThanOrEqual', () {
    test('DateTime values', () {
      check(
        opValueGreaterThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(later),
        ),
      ).isXPathSequence([false]);
    });
    test('bool values', () {
      check(
        opValueGreaterThanOrEqual(
          const XPathSequence.single(XPathBoolean.trueInstance),
          const XPathSequence.single(XPathBoolean.trueInstance),
        ),
      ).isXPathSequence([true]);
    });
  });

  group('opValueLessThanOrEqual', () {
    test('DateTime values', () {
      check(
        opValueLessThanOrEqual(
          XPathSequence.single(earlier),
          XPathSequence.single(earlier),
        ),
      ).isXPathSequence([true]);
    });
  });

  group('opValueGreaterThan', () {
    test('Duration values', () {
      check(
        opValueGreaterThan(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
      ).isXPathSequence([false]);
    });
  });

  group('opValueEqual', () {
    test('equal numbers', () {
      check(
        opValueEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence([true]);
    });
    test('not equal numbers', () {
      check(
        opValueEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ),
      ).isXPathSequence([false]);
    });
    test('atomize node', () {
      final node = XmlElement(const XmlName('a'), [], [XmlText('foo')]);
      check(
        opValueEqual(
          XPathSequence.single(XPathNode(node)),
          const XPathSequence.single(XPathString('foo')),
        ),
      ).isXPathSequence([true]);
    });
    test('empty sequence returns empty', () {
      check(
        opValueEqual(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence(isEmpty);
    });
    test('sequence with more than one item throws', () {
      final multiple = XPathSequence([
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(2),
      ]);
      final single = XPathSequence.single(XPathInteger.fromInt(1));
      check(() => opValueEqual(multiple, single))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Sequence contains more than one item',
            ),
          );
    });
    test('duration values', () {
      check(
        opValueEqual(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(shortDuration),
        ),
      ).isXPathSequence([true]);
      check(
        opValueEqual(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
      ).isXPathSequence([false]);
    });
  });

  group('opValueNotEqual', () {
    test('not equal numbers', () {
      check(
        opValueNotEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ),
      ).isXPathSequence([true]);
    });
    test('equal numbers', () {
      check(
        opValueNotEqual(
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence([false]);
    });
    test('empty sequence returns empty', () {
      check(
        opValueNotEqual(
          XPathSequence.empty,
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence(isEmpty);
    });
    test('duration values', () {
      check(
        opValueNotEqual(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(longDuration),
        ),
      ).isXPathSequence([true]);
      check(
        opValueNotEqual(
          const XPathSequence.single(shortDuration),
          const XPathSequence.single(shortDuration),
        ),
      ).isXPathSequence([false]);
    });
  });

  group('atomization of maps, arrays, and functions', () {
    test('atomize array', () {
      check(
        opValueEqual(
          XPathSequence.single(
            XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]),
          ),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isXPathSequence([true]);
    });

    test('atomize nested array', () {
      check(
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
      ).isXPathSequence([true]);
    });

    test('atomizing map throws FOTY0013', () {
      final map = XPathMap({
        const XPathString('a'): XPathSequence.single(XPathInteger.fromInt(1)),
      });
      check(
        () => opValueEqual(
          XPathSequence.single(map),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Cannot atomize a map or function item',
        ),
      );
    });

    test('atomizing function throws FOTY0013', () {
      XPathSequence dummy(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.empty;
      check(
        () => opValueEqual(
          XPathSequence.single(dummy.toXPathFunction()),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Cannot atomize a map or function item',
        ),
      );
    });

    test('QName value comparisons and order restriction', () {
      const q1 = XPathQName(XmlName('foo'));
      const q2 = XPathQName(XmlName('foo'));
      const q3 = XPathQName(XmlName('bar'));

      check(opValueEqual(seq(q1), seq(q2))).isXPathSequence([true]);
      check(opValueEqual(seq(q1), seq(q3))).isXPathSequence([false]);
      check(opValueNotEqual(seq(q1), seq(q3))).isXPathSequence([true]);

      // Comparing QName with non-QName throws XPTY0004
      check(() => opValueEqual(seq(q1), seq(1)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opValueNotEqual(seq(q1), seq(1)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );

      // Order comparisons on QNames throw XPTY0004
      check(() => opValueLessThan(seq(q1), seq(q2)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('AnyURI and String comparisons', () {
      const u1 = XPathAnyUri('http://example.com/a');
      const u2 = XPathAnyUri('http://example.com/b');
      const s1 = XPathString('http://example.com/a');

      check(compare(u1, u2)).isLessThan(0);
      check(compare(s1, u2)).isLessThan(0);
      check(compare(u2, s1)).isGreaterThan(0);
    });

    test('Binary and Duration value comparisons', () {
      final b1 = XPathBinary.fromHex('0102');
      final b2 = XPathBinary.fromHex('0102');
      final b3 = XPathBinary.fromHex('0103');

      check(opValueEqual(seq(b1), seq(b2))).isXPathSequence([true]);
      check(opValueNotEqual(seq(b1), seq(b3))).isXPathSequence([true]);
      check(compare(b1, b3)).isLessThan(0);

      final ymd1 = XPathDuration.tryParseYearMonth('P1Y')!;
      final ymd2 = XPathDuration.tryParseYearMonth('P2Y')!;
      check(compare(ymd1, ymd2)).isLessThan(0);
    });

    test('untypedAtomic value comparisons', () {
      const u = XPathUntypedAtomic('foo');
      const s = XPathString('foo');
      check(opValueEqual(seq(u), seq(s))).isXPathSequence([true]);
      check(opValueNotEqual(seq(u), seq(const XPathString('bar'))))
          .isXPathSequence([true]);
      check(opValueLessThan(seq(u), seq(const XPathString('zoo'))))
          .isXPathSequence([true]);
    });
  });
}
