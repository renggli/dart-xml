import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/arithmetic.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

XPathSequence intSeq(int val) =>
    XPathSequence.single(XPathInteger.fromInt(val));

void main() {
  final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');

  group('op:numeric-add', () {
    test('numbers', () {
      expect(opNumericAdd(intSeq(1), intSeq(2)), isXPathSequence([3]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '1 + 2', [3]);
      expectEvaluate(xml, '3 + 4', [7]);
    });
    test('dateTime + duration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-01T00:00:00") + xs:dayTimeDuration("P1D")',
        [const XPathDateTime(2000, 1, 2, 0, 0, 0)],
      );
    });
    test('duration + dateTime', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P1D") + xs:dateTime("2000-01-01T00:00:00")',
        [const XPathDateTime(2000, 1, 2, 0, 0, 0)],
      );
    });
    test('duration + duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P1D") + xs:dayTimeDuration("P2D")',
        [const XPathDuration.dayTime(259200000000)],
      );
    });
  });

  group('op:numeric-subtract', () {
    test('numbers', () {
      expect(opNumericSubtract(intSeq(2), intSeq(1)), isXPathSequence([1]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '1 - 2', [-1]);
      expectEvaluate(xml, '4 - 3', [1]);
    });
    test('dateTime - duration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-02T00:00:00") - xs:dayTimeDuration("P1D")',
        [const XPathDateTime(2000, 1, 1, 0, 0, 0)],
      );
    });
    test('dateTime - dateTime', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-02T00:00:00") - xs:dateTime("2000-01-01T00:00:00")',
        [const XPathDuration.dayTime(86400000000)],
      );
    });
    test('duration - duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P3D") - xs:dayTimeDuration("P1D")',
        [const XPathDuration.dayTime(172800000000)],
      );
    });
  });

  group('op:numeric-multiply', () {
    test('numbers', () {
      expect(opNumericMultiply(intSeq(2), intSeq(3)), isXPathSequence([6]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '2 * 3', [6]);
      expectEvaluate(xml, '3 * 2', [6]);
    });
    test('duration * number', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P1D") * 3', [
        const XPathDuration.dayTime(259200000000),
      ]);
    });
    test('number * duration', () {
      expectEvaluate(xml, '3 * xs:dayTimeDuration("P1D")', [
        const XPathDuration.dayTime(259200000000),
      ]);
    });
  });

  group('op:numeric-divide', () {
    test('numbers', () {
      expect(opNumericDivide(intSeq(6), intSeq(2)), isXPathSequence([3.0]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '6 div 3', [2]);
      expectEvaluate(xml, '5 div 2', [2.5]);
    });
    test('duration div number', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P6D") div 2', [
        const XPathDuration.dayTime(259200000000),
      ]);
    });
    test('duration div duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P6D") div xs:dayTimeDuration("P2D")',
        [3.0],
      );
    });
  });

  group('op:numeric-integer-divide', () {
    test('numbers', () {
      expect(
        opNumericIntegerDivide(intSeq(6), intSeq(2)),
        isXPathSequence([3]),
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '5 idiv 2', [2]);
      expectEvaluate(xml, '8 idiv 2', [4]);
      expect(
        () => xml.xpathEvaluate('5 idiv 0'),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('op:numeric-mod', () {
    test('numbers', () {
      expect(opNumericMod(intSeq(5), intSeq(2)), isXPathSequence([1]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '5 mod 2', [1]);
      expectEvaluate(xml, '8 mod 2', [0]);
      expectEvaluate(xml, '-5 mod 3', [-2]);
      expectEvaluate(xml, '5 mod -3', [2]);
      expectEvaluate(xml, '-5 mod -3', [-2]);
      expect(
        () => xml.xpathEvaluate('5 mod 0'),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('op:numeric-unary-plus', () {
    test('numbers', () {
      expect(opNumericUnaryPlus(intSeq(1)), isXPathSequence([1]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '+1', [1]);
      expectEvaluate(xml, '++1', [1]);
      expectEvaluate(xml, '+++1', [1]);
    });
  });

  group('op:numeric-unary-minus', () {
    test('numbers', () {
      expect(opNumericUnaryMinus(intSeq(1)), isXPathSequence([-1]));
    });
    test('integration numbers', () {
      expectEvaluate(xml, '-1', [-1]);
      expectEvaluate(xml, '--1', [1]);
      expectEvaluate(xml, '---1', [-1]);
    });
  });

  group('op:numeric-equal', () {
    test('numbers', () {
      expect(opNumericEqual(intSeq(1), intSeq(1)), isXPathSequence([true]));
    });
  });

  group('op:numeric-less-than', () {
    test('numbers', () {
      expect(opNumericLessThan(intSeq(1), intSeq(2)), isXPathSequence([true]));
    });
  });

  group('op:numeric-greater-than', () {
    test('numbers', () {
      expect(
        opNumericGreaterThan(intSeq(2), intSeq(1)),
        isXPathSequence([true]),
      );
    });
  });

  group('priority', () {
    test('multiplication before addition', () {
      expectEvaluate(xml, '2 + 3 * 4', [14]);
      expectEvaluate(xml, '2 * 3 + 4', [10]);
    });
  });

  group('parenthesis', () {
    test('override priority', () {
      expectEvaluate(xml, '(2 + 3) * 4', [20]);
      expectEvaluate(xml, '2 * (3 + 4)', [14]);
    });
  });
  group('op:add dispatch', () {
    test('yearMonthDuration + yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") + xs:yearMonthDuration("P2M")',
        [const XPathDuration.yearMonth(14)],
      );
    });
    test('dateTime + yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-01T00:00:00") + xs:yearMonthDuration("P1Y")',
        [const XPathDateTime(2001, 1, 1, 0, 0, 0)],
      );
    });
    test('yearMonthDuration + dateTime', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") + xs:dateTime("2000-01-01T00:00:00")',
        [const XPathDateTime(2001, 1, 1, 0, 0, 0)],
      );
    });
    test('date + yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:date("2000-01-01") + xs:yearMonthDuration("P1Y")',
        [const XPathDateTime.date(2001, 1, 1)],
      );
    });
    test('yearMonthDuration + date', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") + xs:date("2000-01-01")',
        [const XPathDateTime.date(2001, 1, 1)],
      );
    });
    test('date + dayTimeDuration', () {
      expectEvaluate(xml, 'xs:date("2000-01-01") + xs:dayTimeDuration("P1D")', [
        const XPathDateTime.date(2000, 1, 2),
      ]);
    });
    test('dayTimeDuration + date', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P1D") + xs:date("2000-01-01")', [
        const XPathDateTime.date(2000, 1, 2),
      ]);
    });
    test('time + dayTimeDuration', () {
      expectEvaluate(xml, 'xs:time("10:00:00") + xs:dayTimeDuration("PT2H")', [
        const XPathDateTime.time(12, 0, 0),
      ]);
    });
    test('dayTimeDuration + time', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("PT2H") + xs:time("10:00:00")', [
        const XPathDateTime.time(12, 0, 0),
      ]);
    });
    test('empty inputs return empty', () {
      expect(opAdd(XPathSequence.empty, intSeq(1)), isEmpty);
    });
  });

  group('op:subtract dispatch', () {
    test('dateTime - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2001-01-01T00:00:00") - xs:yearMonthDuration("P1Y")',
        [const XPathDateTime(2000, 1, 1, 0, 0, 0)],
      );
    });
    test('date - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:date("2001-01-01") - xs:yearMonthDuration("P1Y")',
        [const XPathDateTime.date(2000, 1, 1)],
      );
    });
    test('date - dayTimeDuration', () {
      expectEvaluate(xml, 'xs:date("2000-01-02") - xs:dayTimeDuration("P1D")', [
        const XPathDateTime.date(2000, 1, 1),
      ]);
    });
    test('date - date', () {
      expectEvaluate(xml, 'xs:date("2000-01-02") - xs:date("2000-01-01")', [
        const XPathDuration.dayTime(86400000000),
      ]);
    });
    test('time - dayTimeDuration', () {
      expectEvaluate(xml, 'xs:time("12:00:00") - xs:dayTimeDuration("PT2H")', [
        const XPathDateTime.time(10, 0, 0),
      ]);
    });
    test('time - time', () {
      expectEvaluate(xml, 'xs:time("12:00:00") - xs:time("10:00:00")', [
        const XPathDuration.dayTime(7200000000),
      ]);
    });
    test('yearMonthDuration - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") - xs:yearMonthDuration("P2M")',
        [const XPathDuration.yearMonth(10)],
      );
    });
    test('empty inputs return empty', () {
      expect(opSubtract(XPathSequence.empty, intSeq(1)), isEmpty);
    });
  });

  group('op:multiply dispatch', () {
    test('yearMonthDuration * number', () {
      expectEvaluate(xml, 'xs:yearMonthDuration("P1Y") * 2', [
        const XPathDuration.yearMonth(24),
      ]);
    });
    test('number * yearMonthDuration', () {
      expectEvaluate(xml, '2 * xs:yearMonthDuration("P1Y")', [
        const XPathDuration.yearMonth(24),
      ]);
    });
    test('empty inputs return empty', () {
      expect(opMultiply(XPathSequence.empty, intSeq(1)), isEmpty);
    });
  });

  group('op:divide dispatch', () {
    test('yearMonthDuration div yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P2Y") div xs:yearMonthDuration("P1Y")',
        [2.0],
      );
    });
    test('yearMonthDuration div number', () {
      expectEvaluate(xml, 'xs:yearMonthDuration("P2Y") div 2', [
        const XPathDuration.yearMonth(12),
      ]);
    });
    test('empty inputs return empty', () {
      expect(opDivide(XPathSequence.empty, intSeq(1)), isEmpty);
    });
  });
}
