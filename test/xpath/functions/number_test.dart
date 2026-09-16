import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/number.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:abs', () {
    test('returns absolute value', () {
      expect(fnAbs(context, [seq(-5)]), isXPathSequence([5]));
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
      final res1 = fnRoundHalfToEven(context, [seq(0.5)]).single;
      expect(res1, isA<XPathDouble>());
      expect((res1 as XPathDouble).value, 0.0);

      final res2 = fnRoundHalfToEven(context, [seq(1.5)]).single;
      expect(res2, isA<XPathDouble>());
      expect((res2 as XPathDouble).value, 2.0);

      final res3 = fnRoundHalfToEven(context, [seq(2)]).single;
      expect(res3, isA<XPathInteger>());
      expect((res3 as XPathInteger).asInt, 2);
    });

    test('returns empty for empty sequence', () {
      expect(
        fnRoundHalfToEven(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('handles precision', () {
      expect(fnRoundHalfToEven(context, [seq(2.5)]), isXPathSequence([2]));
      expect(fnRoundHalfToEven(context, [seq(3.5)]), isXPathSequence([4]));
      expect(fnRoundHalfToEven(context, [seq(2.4)]), isXPathSequence([2]));
      expect(fnRoundHalfToEven(context, [seq(2.6)]), isXPathSequence([3]));
      expect(
        fnRoundHalfToEven(context, [seq(2.5), seq(0)]),
        isXPathSequence([2]),
      );
    });
  });

  group('fn:number', () {
    test('converts string to number', () {
      expect(fnNumber(context, [seq('123')]), isXPathSequence([123]));
    });

    test('returns NaN for empty sequence', () {
      expect(
        (fnNumber(context, [XPathSequence.empty]).first as XPathDouble)
            .value
            .isNaN,
        isTrue,
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('123');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
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
      expect(
        first.keys.map((k) => k.stringValue),
        containsAll(['number', 'next', 'permute']),
      );
      final firstValue =
          (first.get(const XPathString('number'))!.single as XPathDouble).value;
      expect(firstValue, isNonNegative);
      expect(firstValue, lessThan(1.0));

      final second =
          (first.get(const XPathString('next'))!.single as XPathFunctionItem)(
                context,
                [],
              ).single
              as XPathMap;
      expect(
        second.keys.map((k) => k.stringValue),
        containsAll(['number', 'next', 'permute']),
      );
      final secondValue =
          (second.get(const XPathString('number'))!.single as XPathDouble)
              .value;
      expect(secondValue, isNonNegative);
      expect(secondValue, lessThan(1.0));
      expect(secondValue, isNot(firstValue));

      final firstPermutation =
          (first.get(const XPathString('permute'))!.single
              as XPathFunctionItem)(context, [
            seq([1, 2, 3]),
          ]);
      expect(firstPermutation, hasLength(3));
      expect(firstPermutation.map(unwrapXPathItem), containsAll([1, 2, 3]));
    });

    test('handles seed', () {
      final result = fnRandomNumberGenerator(context, [seq(123)]);
      expect(result, isNotEmpty);
      // Check determinism
      final result2 = fnRandomNumberGenerator(context, [seq(123)]);
      final map1 = result.first as XPathMap;
      final map2 = result2.first as XPathMap;
      expect(
        map1.get(const XPathString('number'))!.first,
        map2.get(const XPathString('number'))!.first,
      );
    });
  });

  group('fn:ceiling', () {
    test('rounds up', () {
      final res1 = fnCeiling(context, [seq(1.5)]).single;
      expect(res1, isA<XPathDouble>());
      expect((res1 as XPathDouble).value, 2.0);

      final res2 = fnCeiling(context, [seq(1)]).single;
      expect(res2, isA<XPathInteger>());
      expect((res2 as XPathInteger).asInt, 1);
    });

    test('returns empty for empty sequence', () {
      expect(
        fnCeiling(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('handles NaN and Infinity', () {
      expect(
        (fnCeiling(context, [seq(double.nan)]).single as XPathDouble)
            .value
            .isNaN,
        isTrue,
      );
      expect(
        fnCeiling(context, [seq(double.infinity)]),
        isXPathSequence([double.infinity]),
      );
      expect(
        fnCeiling(context, [seq(double.negativeInfinity)]),
        isXPathSequence([double.negativeInfinity]),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'ceiling(-1.5)', isXPathSequence([-1]));
      expectEvaluate(xml, 'ceiling(1.5)', isXPathSequence([2]));
      expectEvaluate(
        xml,
        'ceiling(xs:double("NaN"))',
        isXPathSequence([isNaN]),
      );
      expectEvaluate(
        xml,
        'ceiling(xs:double("INF"))',
        isXPathSequence([double.infinity]),
      );
      expectEvaluate(
        xml,
        'ceiling(xs:double("-INF"))',
        isXPathSequence([double.negativeInfinity]),
      );
    });
  });

  group('fn:floor', () {
    test('rounds down', () {
      final res1 = fnFloor(context, [seq(1.5)]).single;
      expect(res1, isA<XPathDouble>());
      expect((res1 as XPathDouble).value, 1.0);

      final res2 = fnFloor(context, [seq(1)]).single;
      expect(res2, isA<XPathInteger>());
      expect((res2 as XPathInteger).asInt, 1);
    });

    test('returns empty for empty sequence', () {
      expect(fnFloor(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('handles NaN and Infinity', () {
      expect(
        (fnFloor(context, [seq(double.nan)]).single as XPathDouble).value.isNaN,
        isTrue,
      );
      expect(
        fnFloor(context, [seq(double.infinity)]),
        isXPathSequence([double.infinity]),
      );
      expect(
        fnFloor(context, [seq(double.negativeInfinity)]),
        isXPathSequence([double.negativeInfinity]),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'floor(-1.5)', isXPathSequence([-2]));
      expectEvaluate(xml, 'floor(1.5)', isXPathSequence([1]));
      expectEvaluate(xml, 'floor(xs:double("NaN"))', isXPathSequence([isNaN]));
      expectEvaluate(
        xml,
        'floor(xs:double("INF"))',
        isXPathSequence([double.infinity]),
      );
      expectEvaluate(
        xml,
        'floor(xs:double("-INF"))',
        isXPathSequence([double.negativeInfinity]),
      );
    });
  });

  group('fn:round', () {
    test('rounds to nearest', () {
      final res1 = fnRound(context, [seq(1.5)]).single;
      expect(res1, isA<XPathDouble>());
      expect((res1 as XPathDouble).value, 2.0);

      final res2 = fnRound(context, [seq(-1.5)]).single;
      expect(res2, isA<XPathDouble>());
      expect((res2 as XPathDouble).value, -1.0);

      final res3 = fnRound(context, [seq(-0.5)]).single;
      expect(res3, isA<XPathDouble>());
      expect((res3 as XPathDouble).value, -0.0);

      final res4 = fnRound(context, [seq(2)]).single;
      expect(res4, isA<XPathInteger>());
      expect((res4 as XPathInteger).asInt, 2);
    });

    test('returns empty for empty sequence', () {
      expect(fnRound(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns NaN for NaN', () {
      expect(fnRound(context, [seq(double.nan)]), isXPathSequence([isNaN]));
    });

    test('handles precision arguments', () {
      expect(fnRound(context, [seq(1.5), seq(1)]), isXPathSequence([1.5]));
      expect(
        fnRound(context, [seq(123.456), seq(2)]),
        isXPathSequence([123.46]),
      );
      expect(fnRound(context, [seq(123.456), seq(0)]), isXPathSequence([123]));
      expect(fnRound(context, [seq(123.456), seq(-2)]), isXPathSequence([100]));
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
