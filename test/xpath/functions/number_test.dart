import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/number.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:abs', () {
    test('returns absolute value', () {
      expect(
        fnAbs(context, [const XPathSequence.single(-5)]),
        isXPathSequence([5]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnAbs(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'abs(-2)', isXPathSequence([2]));
      expectEvaluate(xml, 'abs(3)', isXPathSequence([3]));
    });
  });

  group('fn:round-half-to-even', () {
    test('rounds half to even', () {
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(0.5)]),
        isXPathSequence([0]),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(1.5)]),
        isXPathSequence([2]),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]),
        isXPathSequence([2]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnRoundHalfToEven(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('handles precision', () {
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]),
        isXPathSequence([2]),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(3.5)]),
        isXPathSequence([4]),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.4)]),
        isXPathSequence([2]),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.6)]),
        isXPathSequence([3]),
      );
      expect(
        fnRoundHalfToEven(context, [
          const XPathSequence.single(2.5),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([2]),
      );
    });
  });

  group('fn:number', () {
    test('converts string to number', () {
      expect(
        fnNumber(context, [const XPathSequence.single('123')]),
        isXPathSequence([123]),
      );
    });

    test('returns NaN for empty sequence', () {
      expect(
        (fnNumber(context, [XPathSequence.empty]).first as num).isNaN,
        isTrue,
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('123');
      final contextWithNode = XPathContext.empty(textNode);
      expect(fnNumber(contextWithNode, []), isXPathSequence([123]));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'number()', isXPathSequence([123]));
      expectEvaluate(xml, 'number(/r/b)', isXPathSequence([23]));
      expectEvaluate(xml, 'number("")', isXPathSequence([isNaN]));
      expectEvaluate(xml, 'number("x")', isXPathSequence([isNaN]));
      expectEvaluate(xml, 'number("1")', isXPathSequence([1]));
      expectEvaluate(xml, 'number("1.2")', isXPathSequence([1.2]));
      expectEvaluate(xml, 'number("-1")', isXPathSequence([-1]));
      expectEvaluate(xml, 'number("-1.2")', isXPathSequence([-1.2]));
      expectEvaluate(xml, 'number(0)', isXPathSequence([0]));
      expectEvaluate(xml, 'number(-1)', isXPathSequence([-1]));
      expectEvaluate(xml, 'number(-1.2)', isXPathSequence([-1.2]));
      expectEvaluate(xml, 'number(true())', isXPathSequence([1]));
      expectEvaluate(xml, 'number(false())', isXPathSequence([0]));
    });
  });

  group('fn:random-number-generator', () {
    test('returns state map', () {
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

    test('handles seed', () {
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

  group('fn:ceiling', () {
    test('rounds up', () {
      expect(
        fnCeiling(context, [const XPathSequence.single(1.5)]),
        isXPathSequence([2]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnCeiling(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'ceiling(-1.5)', isXPathSequence([-1]));
      expectEvaluate(xml, 'ceiling(1.5)', isXPathSequence([2]));
    });
  });

  group('fn:floor', () {
    test('rounds down', () {
      expect(
        fnFloor(context, [const XPathSequence.single(1.5)]),
        isXPathSequence([1]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnFloor(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'floor(-1.5)', isXPathSequence([-2]));
      expectEvaluate(xml, 'floor(1.5)', isXPathSequence([1]));
    });
  });

  group('fn:round', () {
    test('rounds to nearest', () {
      expect(
        fnRound(context, [const XPathSequence.single(1.5)]),
        isXPathSequence([2]),
      );
      expect(
        fnRound(context, [const XPathSequence.single(-1.5)]),
        isXPathSequence([-1]),
      );
      expect(
        fnRound(context, [const XPathSequence.single(-0.5)]),
        isXPathSequence([-0.0]),
      );
      expect(
        fnRound(context, [const XPathSequence.single(-2.5)]),
        isXPathSequence([-2]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnRound(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns NaN for NaN', () {
      expect(
        fnRound(context, [const XPathSequence.single(double.nan)]),
        isXPathSequence([isNaN]),
      );
    });

    test('handles precision arguments', () {
      expect(
        fnRound(context, [
          const XPathSequence.single(1.5),
          const XPathSequence.single(1),
        ]),
        isXPathSequence([1.5]),
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([123.46]),
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(0),
        ]),
        isXPathSequence([123]),
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(-2),
        ]),
        isXPathSequence([100]),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'round(1.2)', isXPathSequence([1]));
    });
  });

  group('fn:sum', () {
    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'sum(//text())', isXPathSequence([6]));
      final attr = XmlDocument.parse('<r><e a="36"/><e a="6"/></r>');
      expectEvaluate(attr, 'sum(/r/e/@a)', isXPathSequence([42]));
    });
  });

  group('xs:float', () {
    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'xs:float("1.5")', isXPathSequence([1.5]));
      expectEvaluate(xml, 'xs:float("NaN")', isXPathSequence([isNaN]));
      expectEvaluate(
        xml,
        'xs:float("INF")',
        isXPathSequence([double.infinity]),
      );
      expectEvaluate(
        xml,
        'xs:float("-INF")',
        isXPathSequence([double.negativeInfinity]),
      );
    });
  });

  group('xs:numeric', () {
    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'xs:numeric("1.5")', isXPathSequence([1.5]));
      expectEvaluate(xml, 'xs:numeric("42")', isXPathSequence([42]));
    });
  });
}
