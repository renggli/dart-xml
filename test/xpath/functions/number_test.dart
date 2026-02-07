import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';

import 'package:xml/src/xpath/functions/number.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
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

  test('fn:random-number-generator', () {
    final first = fnRandomNumberGenerator(context, []).single as XPathMap;
    expect(first.keys, containsAll(['number', 'next', 'permute']));
    final firstValue = first['number'];
    expect(firstValue, isA<double>());
    expect(firstValue, isNonNegative);
    expect(firstValue, lessThan(1.0));

    final second =
        (first['next'] as XPathFunction)(context, []).single as XPathMap;
    expect(second.keys, containsAll(['number', 'next', 'permute']));
    final secondValue = second['number'];
    expect(secondValue, isA<double>());
    expect(secondValue, isNonNegative);
    expect(secondValue, lessThan(1.0));
    expect(secondValue, isNot(firstValue));

    final firstPermutation = (first['permute'] as XPathFunction)(context, [
      const XPathSequence([1, 2, 3]),
    ]);
    expect(firstPermutation, isA<XPathSequence>());
    expect(firstPermutation, hasLength(3));
    expect(firstPermutation, containsAll([1, 2, 3]));
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
    expect(fnRound(context, [const XPathSequence.single(double.nan)]), [isNaN]);
    expect(
      fnRound(context, [
        const XPathSequence.single(1.5),
        const XPathSequence.single(1),
      ]),
      [1.5],
    );
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
    expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]), [2]);
    expect(fnRoundHalfToEven(context, [const XPathSequence.single(3.5)]), [4]);
    expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.4)]), [2]);
    expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.6)]), [3]);

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
      expectEvaluate(xml, 'round(1.2)', [1]);
    });
    test('xs:float', () {
      expectEvaluate(xml, 'xs:float("1.5")', [1.5]);
      expectEvaluate(xml, 'xs:float("NaN")', [isNaN]);
      expectEvaluate(xml, 'xs:float("INF")', [double.infinity]);
      expectEvaluate(xml, 'xs:float("-INF")', [double.negativeInfinity]);
    });

    test('xs:numeric', () {
      expectEvaluate(xml, 'xs:numeric("1.5")', [1.5]);
      expectEvaluate(xml, 'xs:numeric("42")', [42]);
    });
  });
}
