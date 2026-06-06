import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/arithmetic.dart';
import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');

  group('op:numeric-add', () {
    test('numbers', () {
      expect(
        opNumericAdd(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        [3],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '1 + 2', [3]);
      expectEvaluate(xml, '3 + 4', [7]);
    });
    test('dateTime + duration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-01T00:00:00") + xs:dayTimeDuration("P1D")',
        [DateTime(2000, 1, 2)],
      );
    });
    test('duration + dateTime', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P1D") + xs:dateTime("2000-01-01T00:00:00")',
        [DateTime(2000, 1, 2)],
      );
    });
    test('duration + duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P1D") + xs:dayTimeDuration("P2D")',
        [const Duration(days: 3)],
      );
    });
  });

  group('op:numeric-subtract', () {
    test('numbers', () {
      expect(
        opNumericSubtract(
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ),
        [1],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '1 - 2', [-1]);
      expectEvaluate(xml, '4 - 3', [1]);
    });
    test('dateTime - duration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-02T00:00:00") - xs:dayTimeDuration("P1D")',
        [DateTime(2000)],
      );
    });
    test('dateTime - dateTime', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-02T00:00:00") - xs:dateTime("2000-01-01T00:00:00")',
        [const Duration(days: 1)],
      );
    });
    test('duration - duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P3D") - xs:dayTimeDuration("P1D")',
        [const Duration(days: 2)],
      );
    });
  });

  group('op:numeric-multiply', () {
    test('numbers', () {
      expect(
        opNumericMultiply(
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ),
        [6],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '2 * 3', [6]);
      expectEvaluate(xml, '3 * 2', [6]);
    });
    test('duration * number', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P1D") * 3', [
        const Duration(days: 3),
      ]);
    });
    test('number * duration', () {
      expectEvaluate(xml, '3 * xs:dayTimeDuration("P1D")', [
        const Duration(days: 3),
      ]);
    });
  });

  group('op:numeric-divide', () {
    test('numbers', () {
      expect(
        opNumericDivide(
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ),
        [3.0],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '6 div 3', [2]);
      expectEvaluate(xml, '5 div 2', [2.5]);
    });
    test('duration div number', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P6D") div 2', [
        const Duration(days: 3),
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
        opNumericIntegerDivide(
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ),
        [3],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '5 idiv 2', [2]);
      expectEvaluate(xml, '8 idiv 2', [4]);
    });
  });

  group('op:numeric-mod', () {
    test('numbers', () {
      expect(
        opNumericMod(
          const XPathSequence.single(5),
          const XPathSequence.single(2),
        ),
        [1],
      );
    });
    test('integration numbers', () {
      expectEvaluate(xml, '5 mod 2', [1]);
      expectEvaluate(xml, '8 mod 2', [0]);
    });
  });

  group('op:numeric-unary-plus', () {
    test('numbers', () {
      expect(opNumericUnaryPlus(const XPathSequence.single(1)), [1]);
    });
    test('integration numbers', () {
      expectEvaluate(xml, '+1', [1]);
      expectEvaluate(xml, '++1', [1]);
      expectEvaluate(xml, '+++1', [1]);
    });
  });

  group('op:numeric-unary-minus', () {
    test('numbers', () {
      expect(opNumericUnaryMinus(const XPathSequence.single(1)), [-1]);
    });
    test('integration numbers', () {
      expectEvaluate(xml, '-1', [-1]);
      expectEvaluate(xml, '--1', [1]);
      expectEvaluate(xml, '---1', [-1]);
    });
  });

  group('op:numeric-equal', () {
    test('numbers', () {
      expect(
        opNumericEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ),
        [true],
      );
    });
  });

  group('op:numeric-less-than', () {
    test('numbers', () {
      expect(
        opNumericLessThan(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        [true],
      );
    });
  });

  group('op:numeric-greater-than', () {
    test('numbers', () {
      expect(
        opNumericGreaterThan(
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ),
        [true],
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
        [XPathYearMonthDuration(14)],
      );
    });
    test('dateTime + yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2000-01-01T00:00:00") + xs:yearMonthDuration("P1Y")',
        [XPathDateTime(DateTime(2001))],
      );
    });
    test('yearMonthDuration + dateTime', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") + xs:dateTime("2000-01-01T00:00:00")',
        [XPathDateTime(DateTime(2001))],
      );
    });
    test('date + yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:date("2000-01-01") + xs:yearMonthDuration("P1Y")',
        [XPathDate(DateTime(2001))],
      );
    });
    test('yearMonthDuration + date', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") + xs:date("2000-01-01")',
        [XPathDate(DateTime(2001))],
      );
    });
    test('date + dayTimeDuration', () {
      expectEvaluate(xml, 'xs:date("2000-01-01") + xs:dayTimeDuration("P1D")', [
        XPathDate(DateTime(2000, 1, 2)),
      ]);
    });
    test('dayTimeDuration + date', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("P1D") + xs:date("2000-01-01")', [
        XPathDate(DateTime(2000, 1, 2)),
      ]);
    });
    test('time + dayTimeDuration', () {
      expectEvaluate(xml, 'xs:time("10:00:00") + xs:dayTimeDuration("PT2H")', [
        XPathTime(DateTime(1970, 1, 1, 12)),
      ]);
    });
    test('dayTimeDuration + time', () {
      expectEvaluate(xml, 'xs:dayTimeDuration("PT2H") + xs:time("10:00:00")', [
        XPathTime(DateTime(1970, 1, 1, 12)),
      ]);
    });
    test('empty inputs return empty', () {
      expect(
        opAdd(XPathSequence.empty, const XPathSequence.single(1)),
        isEmpty,
      );
    });
  });

  group('op:subtract dispatch', () {
    test('dateTime - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:dateTime("2001-01-01T00:00:00") - xs:yearMonthDuration("P1Y")',
        [XPathDateTime(DateTime(2000))],
      );
    });
    test('date - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:date("2001-01-01") - xs:yearMonthDuration("P1Y")',
        [XPathDate(DateTime(2000))],
      );
    });
    test('date - dayTimeDuration', () {
      expectEvaluate(xml, 'xs:date("2000-01-02") - xs:dayTimeDuration("P1D")', [
        XPathDate(DateTime(2000)),
      ]);
    });
    test('date - date', () {
      expectEvaluate(xml, 'xs:date("2000-01-02") - xs:date("2000-01-01")', [
        const Duration(days: 1),
      ]);
    });
    test('time - dayTimeDuration', () {
      expectEvaluate(xml, 'xs:time("12:00:00") - xs:dayTimeDuration("PT2H")', [
        XPathTime(DateTime(1970, 1, 1, 10)),
      ]);
    });
    test('time - time', () {
      expectEvaluate(xml, 'xs:time("12:00:00") - xs:time("10:00:00")', [
        const Duration(hours: 2),
      ]);
    });
    test('yearMonthDuration - yearMonthDuration', () {
      expectEvaluate(
        xml,
        'xs:yearMonthDuration("P1Y") - xs:yearMonthDuration("P2M")',
        [XPathYearMonthDuration(10)],
      );
    });
    test('empty inputs return empty', () {
      expect(
        opSubtract(XPathSequence.empty, const XPathSequence.single(1)),
        isEmpty,
      );
    });
  });

  group('op:multiply dispatch', () {
    test('yearMonthDuration * number', () {
      expectEvaluate(xml, 'xs:yearMonthDuration("P1Y") * 2', [
        XPathYearMonthDuration(24),
      ]);
    });
    test('number * yearMonthDuration', () {
      expectEvaluate(xml, '2 * xs:yearMonthDuration("P1Y")', [
        XPathYearMonthDuration(24),
      ]);
    });
    test('empty inputs return empty', () {
      expect(
        opMultiply(XPathSequence.empty, const XPathSequence.single(1)),
        isEmpty,
      );
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
        XPathYearMonthDuration(12),
      ]);
    });
    test('empty inputs return empty', () {
      expect(
        opDivide(XPathSequence.empty, const XPathSequence.single(1)),
        isEmpty,
      );
    });
  });
}
