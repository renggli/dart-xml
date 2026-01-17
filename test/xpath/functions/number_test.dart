import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/number.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('number', () {
    test('fn:abs', () {
      expect(
        fnAbs(context, [const XPathSequence.single(-5)]),
        const XPathSequence.single(5),
      );
      expect(fnAbs(context, [XPathSequence.empty]), isEmpty);
    });

    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(0.5)]),
        const XPathSequence.single(0),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(1.5)]),
        const XPathSequence.single(2),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]),
        const XPathSequence.single(2),
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, [const XPathSequence.single('123')]),
        const XPathSequence.single(123),
      );
      expect(
        (fnNumber(context, [XPathSequence.empty]).first as num).isNaN,
        isTrue,
      );
    });
    test('math:pi', () {
      expect(mathPi(context, const <XPathSequence>[]), [math.pi]);
    });
    test('math:sqrt', () {
      expect(
        mathSqrt(context, [const XPathSequence.single(4)]),
        const XPathSequence.single(2),
      );
    });
    test('fn:random-number-generator', () {
      final result =
          fnRandomNumberGenerator(context, const <XPathSequence>[]).first
              as Map;
      expect(result.keys, containsAll(['number', 'next', 'permute']));
      final current = result['number'];
      expect(current, isA<double>());
      expect(current, isNonNegative);
      expect(current, lessThan(1.0));
      final next = (result['next'] as Function)(
        context,
        const <XPathSequence>[],
      );
      expect(next, isA<double>());
      expect(next, isNonNegative);
      expect(next, lessThan(1.0));
      expect(next, result['number']);
      expect(next, isNot(current));
      final permuted = (result['permute'] as Function)(context, [
        const XPathSequence([1, 2, 3]),
      ]);
      expect(permuted, isA<XPathSequence>());
      expect(permuted, hasLength(3));
      expect(permuted, containsAll([1, 2, 3]));
    });
    test('op:numeric-add', () {
      expect(
        opNumericAdd(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        [3],
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(context, [
          const XPathSequence.single(3),
          const XPathSequence.single(2),
        ]),
        [1],
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        [6],
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(context, [
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ]),
        [3.0],
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        [3],
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        [1],
      );
    });
    test('op:numeric-unary-plus', () {
      expect(opNumericUnaryPlus(context, [const XPathSequence.single(1)]), [1]);
    });
    test('op:numeric-unary-minus', () {
      expect(opNumericUnaryMinus(context, [const XPathSequence.single(1)]), [
        -1,
      ]);
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ]),
        [true],
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        [true],
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ]),
        [true],
      );
    });
    test('fn:ceiling', () {
      expect(fnCeiling(context, [const XPathSequence.single(1.5)]), [2]);
    });
    test('fn:floor', () {
      expect(fnFloor(context, [const XPathSequence.single(1.5)]), [1]);
    });
    test('fn:round', () {
      expect(fnRound(context, [const XPathSequence.single(1.5)]), [2]);
      expect(fnRound(context, [XPathSequence.empty]), isEmpty);
      expect(fnRound(context, [const XPathSequence.single(double.nan)]), [
        isNaN,
      ]);
      expect(
        fnRound(context, [
          const XPathSequence.single(1.5),
          const XPathSequence.single(1),
        ]),
        [1.5],
      );
    });
    test('fn:format-integer', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('000'),
        ]),
        ['123'],
      );
      expect(
        fnFormatInteger(context, [
          XPathSequence.empty,
          const XPathSequence.single('000'),
        ]),
        isEmpty,
      );
    });
    test('math functions', () {
      expect(mathPi(context, const <XPathSequence>[]), [
        predicate((x) => (x as double) > 3.14),
      ]);
      expect(mathExp(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathExp10(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathLog(context, [const XPathSequence.single(math.e)]), [1.0]);
      expect(mathLog10(context, [const XPathSequence.single(10)]), [1.0]);
      expect(
        mathPow(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        [8.0],
      );
      expect(mathSqrt(context, [const XPathSequence.single(4)]), [2.0]);
      expect(mathSin(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathCos(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathTan(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathAsin(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathAcos(context, [const XPathSequence.single(1)]), [0.0]);
      expect(mathAtan(context, [const XPathSequence.single(0)]), [0.0]);
      expect(
        mathAtan2(context, [
          const XPathSequence.single(0),
          const XPathSequence.single(1),
        ]),
        [0.0],
      );
    });

    test('fn:format-integer (3 args)', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('0000'),
          const XPathSequence.single('en'),
        ]),
        [const v31.XPathString('123')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (basic)', () {
      expect(
        fnFormatNumber(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single('#.00'),
        ]),
        [const v31.XPathString('123.456')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (3 args)', () {
      expect(
        fnFormatNumber(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single('#.00'),
          const XPathSequence.single('foo'), // decimal format name
        ]),
        [const v31.XPathString('123.456')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (empty)', () {
      expect(
        fnFormatNumber(context, [
          XPathSequence.empty,
          const XPathSequence.single('#.00'),
        ]),
        isEmpty,
      ); // Partial implementation returns empty seq
    });

    test('fn:round (precision)', () {
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(2),
        ]),
        [123.46],
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(0),
        ]),
        [123],
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(-2),
        ]),
        [100],
      ); // Round to hundreds
    });

    test('fn:round-half-to-even (coverage)', () {
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]), [
        2,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(3.5)]), [
        4,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.4)]), [
        2,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.6)]), [
        3,
      ]);

      expect(
        fnRoundHalfToEven(context, [
          const XPathSequence.single(2.5),
          const XPathSequence.single(0),
        ]),
        [2],
      );
    });

    test('fn:number (context item)', () {
      final textNode = XmlText('123');
      final contextWithNode = XPathContext(textNode);
      expect(fnNumber(contextWithNode, []), [123]);
    });

    test('fn:random-number-generator (seed)', () {
      final result = fnRandomNumberGenerator(context, [
        const XPathSequence.single(123),
      ]);
      expect(result, isNotEmpty);
      // Check determinism
      final result2 = fnRandomNumberGenerator(context, [
        const XPathSequence.single(123),
      ]);
      final map1 = result.first as Map;
      final map2 = result2.first as Map;
      expect(map1['number'], map2['number']);
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('number(nodes)', () {
      expectEvaluate(xml, 'number()', [123]);
      expectEvaluate(xml, 'number(/r/b)', [23]);
    });
    test('number(string)', () {
      expectEvaluate(xml, 'number("")', [isNaN]);
      expectEvaluate(xml, 'number("x")', [isNaN]);
      expectEvaluate(xml, 'number("1")', [1]);
      expectEvaluate(xml, 'number("1.2")', [1.2]);
      expectEvaluate(xml, 'number("-1")', [-1]);
      expectEvaluate(xml, 'number("-1.2")', [-1.2]);
    });
    test('number(number)', () {
      expectEvaluate(xml, 'number(0)', [0]);
      expectEvaluate(xml, 'number(-1)', [-1]);
      expectEvaluate(xml, 'number(-1.2)', [-1.2]);
    });
    test('number(boolean)', () {
      expectEvaluate(xml, 'number(true())', [1]);
      expectEvaluate(xml, 'number(false())', [0]);
    });
    test('sum', () {
      expectEvaluate(xml, 'sum(//text())', [6]);
      final attr = XmlDocument.parse('<r><e a="36"/><e a="6"/></r>');
      expectEvaluate(attr, 'sum(/r/e/@a)', [42]);
    });
    test('floor', () {
      expectEvaluate(xml, 'floor(-1.5)', [-2]);
      expectEvaluate(xml, 'floor(1.5)', [1]);
    });
    test('abs', () {
      expectEvaluate(xml, 'abs(-2)', [2]);
      expectEvaluate(xml, 'abs(3)', [3]);
    });
    test('ceiling', () {
      expectEvaluate(xml, 'ceiling(-1.5)', [-1]);
      expectEvaluate(xml, 'ceiling(1.5)', [2]);
    });
    test('round', () {
      expectEvaluate(xml, 'round(-1.2)', [-1]);
      expectEvaluate(xml, 'round(1.2)', [1]);
    });
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
  });
}
