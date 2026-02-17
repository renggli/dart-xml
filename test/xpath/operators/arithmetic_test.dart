import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/arithmetic.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('number', () {
    test('op:numeric-add', () {
      expect(
        opNumericAdd(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        [3],
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ),
        [1],
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ),
        [6],
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ),
        [3.0],
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ),
        [3],
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(
          const XPathSequence.single(5),
          const XPathSequence.single(2),
        ),
        [1],
      );
    });
    test('op:numeric-unary-plus', () {
      expect(opNumericUnaryPlus(const XPathSequence.single(1)), [1]);
    });
    test('op:numeric-unary-minus', () {
      expect(opNumericUnaryMinus(const XPathSequence.single(1)), [-1]);
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ),
        [true],
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ),
        [true],
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ),
        [true],
      );
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('- (prefix)', () {
      expectEvaluate(xml, '-1', [-1]);
      expectEvaluate(xml, '--1', [1]);
      expectEvaluate(xml, '---1', [-1]);
    });
    test('+ (prefix)', () {
      expectEvaluate(xml, '+1', [1]);
      expectEvaluate(xml, '++1', [1]);
      expectEvaluate(xml, '+++1', [1]);
    });
    test('+', () {
      expectEvaluate(xml, '1 + 2', [3]);
      expectEvaluate(xml, '3 + 4', [7]);
    });
    test('-', () {
      expectEvaluate(xml, '1 - 2', [-1]);
      expectEvaluate(xml, '4 - 3', [1]);
    });
    test('*', () {
      expectEvaluate(xml, '2 * 3', [6]);
      expectEvaluate(xml, '3 * 2', [6]);
    });
    test('div', () {
      expectEvaluate(xml, '6 div 3', [2]);
      expectEvaluate(xml, '5 div 2', [2.5]);
    });
    test('idiv', () {
      expectEvaluate(xml, '5 idiv 2', [2]);
      expectEvaluate(xml, '8 idiv 2', [4]);
    });
    test('neg', () {
      expectEvaluate(xml, '5 mod 2', [1]);
      expectEvaluate(xml, '8 mod 2', [0]);
    });
    test('priority', () {
      expectEvaluate(xml, '2 + 3 * 4', [14]);
      expectEvaluate(xml, '2 * 3 + 4', [10]);
    });
    test('parenthesis', () {
      expectEvaluate(xml, '(2 + 3) * 4', [20]);
      expectEvaluate(xml, '2 * (3 + 4)', [14]);
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
    test('duration + duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P1D") + xs:dayTimeDuration("P2D")',
        [const Duration(days: 3)],
      );
    });
    test('duration - duration', () {
      expectEvaluate(
        xml,
        'xs:dayTimeDuration("P3D") - xs:dayTimeDuration("P1D")',
        [const Duration(days: 2)],
      );
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
}
