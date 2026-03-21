import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/arithmetic.dart';
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
}
