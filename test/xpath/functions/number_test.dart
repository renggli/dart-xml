import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/number.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:abs', () {
    test('returns absolute value', () {
      check(fnAbs(context, [seq(-5)])).isXPathSequence([5]);
    });

    test('returns empty for empty sequence', () {
      check(fnAbs(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('type errors on non-numeric arguments', () {
      check(() => fnAbs(context, [seq('a string')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(
        () => fnAbs(context, [
          seq([1, 2]),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
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
      check(res1).isA<XPathDouble>();
      check((res1 as XPathDouble).value).equals(0.0);

      final res2 = fnRoundHalfToEven(context, [seq(1.5)]).single;
      check(res2).isA<XPathDouble>();
      check((res2 as XPathDouble).value).equals(2.0);

      final res3 = fnRoundHalfToEven(context, [seq(2)]).single;
      check(res3).isA<XPathInteger>();
      check((res3 as XPathInteger).asInt).equals(2);
    });

    test('returns empty for empty sequence', () {
      check(fnRoundHalfToEven(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });

    test('handles precision', () {
      check(fnRoundHalfToEven(context, [seq(2.5)])).isXPathSequence([2]);
      check(fnRoundHalfToEven(context, [seq(3.5)])).isXPathSequence([4]);
      check(fnRoundHalfToEven(context, [seq(2.4)])).isXPathSequence([2]);
      check(fnRoundHalfToEven(context, [seq(2.6)])).isXPathSequence([3]);
      check(fnRoundHalfToEven(context, [seq(2.5), seq(0)]))
          .isXPathSequence([2]);
      check(fnRoundHalfToEven(context, [seq(-2.5)])).isXPathSequence([-2]);
      check(fnRoundHalfToEven(context, [seq(-1.5)])).isXPathSequence([-2]);
    });

    test('exact BigInt rounding without double precision loss', () {
      final bigInt = XPathInteger.parse('-999999999999999999');
      final res = fnRoundHalfToEven(context, [seq(bigInt)]).single;
      check(res.stringValue).equals('-999999999999999999');

      final bigDec = XPathDecimal.parse('3.567812');
      final hugePrec = XPathInteger.parse('4294967296');
      final resDec = fnRoundHalfToEven(context, [
        seq(bigDec),
        seq(hugePrec),
      ]).single;
      check(resDec.stringValue).equals('3.567812');
    });

    test('XPathInteger negative precision and tie-to-even', () {
      // Tie cases
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(125)), seq(-1)]),
      ).isXPathSequence([120]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(135)), seq(-1)]),
      ).isXPathSequence([140]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(-125)), seq(-1)]),
      ).isXPathSequence([-120]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(-135)), seq(-1)]),
      ).isXPathSequence([-140]);
      // Non-tie cases
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(124)), seq(-1)]),
      ).isXPathSequence([120]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(126)), seq(-1)]),
      ).isXPathSequence([130]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(-124)), seq(-1)]),
      ).isXPathSequence([-120]);
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(-126)), seq(-1)]),
      ).isXPathSequence([-130]);
      // Extreme shift (> 100)
      check(
        fnRoundHalfToEven(context, [seq(XPathInteger.fromInt(125)), seq(-105)]),
      ).isXPathSequence([0]);
    });

    test('XPathDecimal precision rounding and tie-to-even', () {
      // Rounding with positive precision
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('12.345')), seq(2)]),
      ).isXPathSequence([12.34]);
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('12.355')), seq(2)]),
      ).isXPathSequence([12.36]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-12.345')),
          seq(2),
        ]),
      ).isXPathSequence([-12.34]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-12.355')),
          seq(2),
        ]),
      ).isXPathSequence([-12.36]);
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('12.344')), seq(2)]),
      ).isXPathSequence([12.34]);
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('12.346')), seq(2)]),
      ).isXPathSequence([12.35]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-12.344')),
          seq(2),
        ]),
      ).isXPathSequence([-12.34]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-12.346')),
          seq(2),
        ]),
      ).isXPathSequence([-12.35]);
      // Rounding with negative precision on XPathDecimal
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('125.0')), seq(-1)]),
      ).isXPathSequence([120]);
      check(
        fnRoundHalfToEven(context, [seq(XPathDecimal.parse('135.0')), seq(-1)]),
      ).isXPathSequence([140]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-125.0')),
          seq(-1),
        ]),
      ).isXPathSequence([-120]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('-135.0')),
          seq(-1),
        ]),
      ).isXPathSequence([-140]);
      // Extreme shift (> 100)
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('12.34')),
          seq(-105),
        ]),
      ).isXPathSequence([0]);
    });
  });

  group('fn:number', () {
    test('converts string to number', () {
      check(fnNumber(context, [seq('123')])).isXPathSequence([123]);
    });

    test('returns NaN for empty sequence', () {
      check(
        (fnNumber(context, [XPathSequence.empty]).first as XPathDouble)
            .value
            .isNaN,
      ).isTrue();
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('123');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
      check(fnNumber(contextWithNode, [])).isXPathSequence([123]);
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
      check(first.keys.map((k) => k.stringValue))
          .unorderedEquals(['number', 'next', 'permute']);
      final firstValue =
          (first.get(const XPathString('number'))!.single as XPathDouble).value;
      check(firstValue).isGreaterOrEqual(0.0);
      check(firstValue).isLessThan(1.0);

      final second =
          (first.get(const XPathString('next'))!.single as XPathFunctionItem)(
                context,
                [],
              ).single
              as XPathMap;
      check(second.keys.map((k) => k.stringValue))
          .unorderedEquals(['number', 'next', 'permute']);
      final secondValue =
          (second.get(const XPathString('number'))!.single as XPathDouble)
              .value;
      check(secondValue).isGreaterOrEqual(0.0);
      check(secondValue).isLessThan(1.0);
      check(secondValue).not((it) => it.equals(firstValue));

      final firstPermutation =
          (first.get(const XPathString('permute'))!.single
              as XPathFunctionItem)(context, [
            seq([1, 2, 3]),
          ]);
      check(firstPermutation).length.equals(3);
      check(firstPermutation.map(unwrapXPathItem)).unorderedEquals([1, 2, 3]);
    });

    test('handles seed', () {
      final result = fnRandomNumberGenerator(context, [seq(123)]);
      check(result).isNotEmpty();
      // Check determinism
      final result2 = fnRandomNumberGenerator(context, [seq(123)]);
      final map1 = result.first as XPathMap;
      final map2 = result2.first as XPathMap;
      check(map1.get(const XPathString('number'))!.first)
          .equals(map2.get(const XPathString('number'))!.first);
    });
  });

  group('fn:ceiling', () {
    test('rounds up', () {
      final res1 = fnCeiling(context, [seq(1.5)]).single;
      check(res1).isA<XPathDouble>();
      check((res1 as XPathDouble).value).equals(2.0);

      final res2 = fnCeiling(context, [seq(1)]).single;
      check(res2).isA<XPathInteger>();
      check((res2 as XPathInteger).asInt).equals(1);
    });

    test('returns empty for empty sequence', () {
      check(fnCeiling(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('handles NaN and Infinity', () {
      check(
        (fnCeiling(context, [seq(double.nan)]).single as XPathDouble)
            .value
            .isNaN,
      ).isTrue();
      check(fnCeiling(context, [seq(double.infinity)]))
          .isXPathSequence([double.infinity]);
      check(fnCeiling(context, [seq(double.negativeInfinity)]))
          .isXPathSequence([double.negativeInfinity]);
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
      check(res1).isA<XPathDouble>();
      check((res1 as XPathDouble).value).equals(1.0);

      final res2 = fnFloor(context, [seq(1)]).single;
      check(res2).isA<XPathInteger>();
      check((res2 as XPathInteger).asInt).equals(1);
    });

    test('returns empty for empty sequence', () {
      check(fnFloor(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('handles NaN and Infinity', () {
      check(
        (fnFloor(context, [seq(double.nan)]).single as XPathDouble).value.isNaN,
      ).isTrue();
      check(fnFloor(context, [seq(double.infinity)]))
          .isXPathSequence([double.infinity]);
      check(fnFloor(context, [seq(double.negativeInfinity)]))
          .isXPathSequence([double.negativeInfinity]);
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
      check(res1).isA<XPathDouble>();
      check((res1 as XPathDouble).value).equals(2.0);

      final res2 = fnRound(context, [seq(-1.5)]).single;
      check(res2).isA<XPathDouble>();
      check((res2 as XPathDouble).value).equals(-1.0);

      final res3 = fnRound(context, [seq(-0.5)]).single;
      check(res3).isA<XPathDouble>();
      check((res3 as XPathDouble).value).equals(-0.0);

      final res4 = fnRound(context, [seq(2)]).single;
      check(res4).isA<XPathInteger>();
      check((res4 as XPathInteger).asInt).equals(2);
    });

    test('returns empty for empty sequence', () {
      check(fnRound(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns NaN for NaN', () {
      check(fnRound(context, [seq(double.nan)])).isXPathSequence([isNaN]);
    });

    test('handles precision arguments', () {
      check(fnRound(context, [seq(1.5), seq(1)])).isXPathSequence([1.5]);
      check(fnRound(context, [seq(123.456), seq(2)])).isXPathSequence([123.46]);
      check(fnRound(context, [seq(123.456), seq(0)])).isXPathSequence([123]);
      check(fnRound(context, [seq(123.456), seq(-2)])).isXPathSequence([100]);
    });

    test('exact decimal and integer rounding', () {
      final dec = XPathDecimal.parse('35.425');
      final resDec = fnRound(context, [seq(dec), seq(2)]).single;
      check(resDec.stringValue).equals('35.43');

      final bigInt = XPathDecimal.parse('-999999999999999999');
      final resInt = fnRound(context, [seq(bigInt)]).single;
      check(resInt.stringValue).equals('-999999999999999999');

      const negSmall = XPathDouble(-0.01);
      final resNeg = fnRound(context, [seq(negSmall), seq(0)]).single;
      check(resNeg.stringValue).equals('-0');
    });

    test('type errors on invalid arguments', () {
      check(() => fnRound(context, [seq('a string')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => fnRound(context, [seq(1), seq('a string')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
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

  group('coercion and rounding edge cases', () {
    test(
      '_coerceNumericArg and _coerceIntegerArg with untypedAtomic and errors',
      () {
        check(
          fnAbs(context, [
            const XPathSequence.single(XPathUntypedAtomic('42')),
          ]),
        ).isXPathSequence([42.0]);
        check(
          () => fnAbs(context, [
            const XPathSequence.single(XPathUntypedAtomic('not_num')),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
        );
        check(
          () => fnRound(context, [
            seq(1.234),
            XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );
        check(
          fnRound(context, [
            seq(1.234),
            const XPathSequence.single(XPathUntypedAtomic('2')),
          ]),
        ).isXPathSequence([1.23]);
        check(
          () => fnRound(context, [
            seq(1.234),
            const XPathSequence.single(XPathUntypedAtomic('abc')),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
        );
      },
    );

    test('fn:abs on Decimal and Double', () {
      check(
        fnAbs(context, [seq(XPathDecimal.parse('-3.14'))]).single.stringValue,
      ).equals('3.14');
      check(fnAbs(context, [seq(const XPathDouble(-2.5))]).single.stringValue)
          .equals('2.5');
    });

    test('fn:round edge cases and extremes', () {
      check(fnRound(context, [seq(12.34), seq(2000)])).isXPathSequence([12.34]);
      check(fnRound(context, [seq(12.34), seq(-2000)])).isXPathSequence([0.0]);
      check(fnRound(context, [seq(-12.34), seq(-2000)]).first.stringValue)
          .equals('-0');
      check(fnRound(context, [seq(12), seq(-2000)])).isXPathSequence([0]);
      check(
        fnRound(context, [
          seq(XPathDecimal.parse('12.34')),
          seq(-2000),
        ]).single.stringValue,
      ).equals('0');
      check(fnRound(context, [seq(12.34), seq(-400)])).isXPathSequence([0.0]);
      check(fnRound(context, [seq(1e17), seq(2)])).isXPathSequence([1e17]);
      check(fnRound(context, [seq(1e3), seq(306)])).isXPathSequence([1e3]);
      check(
        fnRound(context, [
          seq(const XPathDouble(1.234, xsFloat)),
          seq(2),
        ]).single.type,
      ).equals(xsFloat);
      check(fnRound(context, [seq(12345), seq(-2)])).isXPathSequence([12300]);
      check(fnRound(context, [seq(-12345), seq(-2)])).isXPathSequence([-12300]);
      check(fnRound(context, [seq(12345), seq(-150)])).isXPathSequence([0]);

      check(
        fnRound(context, [
          seq(XPathDecimal.parse('-12.345')),
          seq(1),
        ]).single.stringValue,
      ).equals('-12.3');
      check(
        fnRound(context, [
          seq(XPathDecimal.parse('12345.67')),
          seq(-2),
        ]).single.stringValue,
      ).equals('12300');
      check(
        fnRound(context, [
          seq(XPathDecimal.parse('12345.67')),
          seq(-150),
        ]).single.stringValue,
      ).equals('0');
    });

    test('fn:round-half-to-even edge cases and extremes', () {
      check(fnRoundHalfToEven(context, [seq(12.34), seq(2000)]))
          .isXPathSequence([12.34]);
      check(fnRoundHalfToEven(context, [seq(12.34), seq(-2000)]))
          .isXPathSequence([0.0]);
      check(
        fnRoundHalfToEven(context, [seq(-12.34), seq(-2000)]).first.stringValue,
      ).equals('-0');
      check(fnRoundHalfToEven(context, [seq(12), seq(-2000)]))
          .isXPathSequence([0]);
      check(
        fnRoundHalfToEven(context, [
          seq(XPathDecimal.parse('12.34')),
          seq(-2000),
        ]).single.stringValue,
      ).equals('0');
      check(fnRoundHalfToEven(context, [seq(12.34), seq(-400)]))
          .isXPathSequence([0.0]);
      check(fnRoundHalfToEven(context, [seq(1e17), seq(2)]))
          .isXPathSequence([1e17]);
      check(fnRoundHalfToEven(context, [seq(1e3), seq(306)]))
          .isXPathSequence([1e3]);
      check(fnRoundHalfToEven(context, [seq(-0.01), seq(0)]).first.stringValue)
          .equals('-0');
      check(
        fnRoundHalfToEven(context, [
          seq(const XPathDouble(1.234, xsFloat)),
          seq(2),
        ]).single.type,
      ).equals(xsFloat);
      check(fnRoundHalfToEven(context, [seq(double.nan)]))
          .isXPathSequence([isNaN]);
      check(fnRoundHalfToEven(context, [seq(double.infinity)]))
          .isXPathSequence([double.infinity]);
      check(fnRoundHalfToEven(context, [seq(0.0)])).isXPathSequence([0.0]);
    });
  });
}
