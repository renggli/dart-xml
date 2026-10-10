import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

XPathSequence intSeq(List<int> values) =>
    XPathSequence(values.map(XPathInteger.fromInt));

void main() {
  group('opAnd', () {
    test('true and true', () {
      check(opAnd(XPathSequence.trueSequence, XPathSequence.trueSequence))
          .equals(XPathSequence.trueSequence);
    });
    test('true and false', () {
      check(opAnd(XPathSequence.trueSequence, XPathSequence.falseSequence))
          .equals(XPathSequence.falseSequence);
    });
    test('false and true', () {
      check(opAnd(XPathSequence.falseSequence, XPathSequence.trueSequence))
          .equals(XPathSequence.falseSequence);
    });
  });

  group('opOr', () {
    test('true or true', () {
      check(opOr(XPathSequence.trueSequence, XPathSequence.trueSequence))
          .equals(XPathSequence.trueSequence);
    });
    test('false or false', () {
      check(opOr(XPathSequence.falseSequence, XPathSequence.falseSequence))
          .equals(XPathSequence.falseSequence);
    });
    test('true or false', () {
      check(opOr(XPathSequence.trueSequence, XPathSequence.falseSequence))
          .equals(XPathSequence.trueSequence);
    });
    test('false or true', () {
      check(opOr(XPathSequence.falseSequence, XPathSequence.trueSequence))
          .equals(XPathSequence.trueSequence);
    });
  });

  group('opGeneralEqual', () {
    test('overlapping ranges', () {
      check(opGeneralEqual(intSeq([1, 2]), intSeq([2, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('disjoint ranges', () {
      check(opGeneralEqual(intSeq([1, 2]), intSeq([3, 4])))
          .equals(XPathSequence.falseSequence);
    });
    test('type coercion with untypedAtomic', () {
      check(
        opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
      ).equals(XPathSequence.trueSequence);
      check(
        () => opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
  });

  group('opGeneralNotEqual', () {
    test('overlapping with not equal', () {
      check(opGeneralNotEqual(intSeq([1, 2]), intSeq([2, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('single value equal', () {
      check(opGeneralNotEqual(intSeq([1]), intSeq([1])))
          .equals(XPathSequence.falseSequence);
    });
    test('type coercion with untypedAtomic', () {
      check(
        opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
      ).equals(XPathSequence.falseSequence);
      check(
        () => opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
  });

  group('opGeneralLessThan', () {
    test('less than', () {
      check(opGeneralLessThan(intSeq([1, 2]), intSeq([0, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      check(() => opGeneralLessThan(q1, q2))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('opGeneralGreaterThan', () {
    test('greater than', () {
      check(opGeneralGreaterThan(intSeq([1, 2]), intSeq([0, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      check(() => opGeneralGreaterThan(q1, q2))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('opGeneralLessThanOrEqual', () {
    test('less than or equal', () {
      check(opGeneralLessThanOrEqual(intSeq([1, 2]), intSeq([0, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      check(() => opGeneralLessThanOrEqual(q1, q2))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('opGeneralGreaterThanOrEqual', () {
    test('greater than or equal', () {
      check(opGeneralGreaterThanOrEqual(intSeq([1, 2]), intSeq([0, 3])))
          .equals(XPathSequence.trueSequence);
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      check(() => opGeneralGreaterThanOrEqual(q1, q2))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('general comparison with QName, Duration, Binary, Untyped', () {
    test('QName equality and inequality', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q2 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q3 = XPathSequence.single(XPathQName(XmlName('bar')));
      check(opGeneralEqual(q1, q2)).equals(XPathSequence.trueSequence);
      check(opGeneralEqual(q1, q3)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(q1, q2)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(q1, q3)).equals(XPathSequence.trueSequence);
    });

    test('Duration equality and inequality', () {
      const d1 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d2 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d3 = XPathSequence.single(XPathDuration.dayTime(2000));
      check(opGeneralEqual(d1, d2)).equals(XPathSequence.trueSequence);
      check(opGeneralEqual(d1, d3)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(d1, d2)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(d1, d3)).equals(XPathSequence.trueSequence);
    });

    test('Binary equality and inequality', () {
      final b1 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b2 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b3 = XPathSequence.single(XPathBinary.fromHex('0304'));
      check(opGeneralEqual(b1, b2)).equals(XPathSequence.trueSequence);
      check(opGeneralEqual(b1, b3)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(b1, b2)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(b1, b3)).equals(XPathSequence.trueSequence);
    });

    test('untypedAtomic comparisons', () {
      const u1 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u2 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u3 = XPathSequence.single(XPathUntypedAtomic('def'));
      check(opGeneralEqual(u1, u2)).equals(XPathSequence.trueSequence);
      check(opGeneralEqual(u1, u3)).equals(XPathSequence.falseSequence);

      const uDate = XPathSequence.single(
        XPathUntypedAtomic('2024-01-01T00:00:00Z'),
      );
      final date = XPathSequence.single(
        XPathDateTime.fromDateTime(DateTime.utc(2024, 1, 1), 0),
      );
      check(opGeneralEqual(uDate, date)).equals(XPathSequence.trueSequence);

      const strA = XPathSequence.single(XPathString('a'));
      check(opGeneralEqual(strA, u1)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(u1, u3)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(strA, u3)).equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(strA, u3)).equals(XPathSequence.trueSequence);

      final num1 = XPathSequence.single(XPathInteger.fromInt(1));
      final num2 = XPathSequence.single(XPathInteger.fromInt(2));
      const uNum1 = XPathSequence.single(XPathUntypedAtomic('1'));
      const uNum2 = XPathSequence.single(XPathUntypedAtomic('2'));
      check(opGeneralNotEqual(uNum1, num2)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(num1, uNum2)).equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(num1, uNum2)).equals(XPathSequence.trueSequence);

      final date1 = XPathSequence.single(
        XPathDateTime.tryParseDate('2000-01-01')!,
      );
      final date2 = XPathSequence.single(
        XPathDateTime.tryParseDate('2000-01-02')!,
      );
      const uDate1 = XPathSequence.single(XPathUntypedAtomic('2000-01-01'));
      const uDate2 = XPathSequence.single(XPathUntypedAtomic('2000-01-02'));
      check(opGeneralEqual(date1, uDate1)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(uDate1, date2))
          .equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(date1, uDate2))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(uDate1, date2))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(date1, uDate2))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(date1, date2)).equals(XPathSequence.trueSequence);

      const uInf = XPathSequence.single(XPathUntypedAtomic('INF'));
      const inf = XPathSequence.single(XPathDouble(double.infinity));
      const one = XPathSequence.single(XPathDouble(1.0));
      check(opGeneralEqual(uInf, inf)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(uInf, one)).equals(XPathSequence.trueSequence);
      check(
        () => opGeneralNotEqual(
          const XPathSequence.single(XPathUntypedAtomic('invalid')),
          one,
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
      );
      check(opGeneralLessThan(one, uInf)).equals(XPathSequence.trueSequence);
    });

    test('QName order comparisons throw XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      final mq1 = XPathSequence([
        const XPathQName(XmlName('a')),
        const XPathQName(XmlName('a')),
      ]);
      final mq2 = XPathSequence([
        const XPathQName(XmlName('b')),
        const XPathQName(XmlName('b')),
      ]);
      check(() => opGeneralLessThan(q1, q2))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralLessThan(mq1, mq2))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralGreaterThan(mq1, mq2))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralLessThanOrEqual(mq1, mq2))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralGreaterThanOrEqual(mq1, mq2))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('BigInt XPathInteger comparisons', () {
      final bigA = XPathSequence.single(
        XPathInteger(BigInt.parse('1000000000000000000000000000000')),
      );
      final bigB = XPathSequence.single(
        XPathInteger(BigInt.parse('1000000000000000000000000000001')),
      );
      check(opGeneralEqual(bigA, bigA)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(bigA, bigB)).equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(bigA, bigB)).equals(XPathSequence.trueSequence);
    });

    test('Double and Boolean edge comparisons', () {
      const nan = XPathSequence.single(XPathDouble(double.nan));
      check(opGeneralEqual(nan, nan)).equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(nan, nan)).equals(XPathSequence.trueSequence);

      const d1 = XPathSequence.single(XPathDouble(1.5));
      const d2 = XPathSequence.single(XPathDouble(2.5));
      check(opGeneralEqual(d1, d1)).equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(d1, d2)).equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(d1, d1)).equals(XPathSequence.falseSequence);
      check(opGeneralLessThan(d1, d2)).equals(XPathSequence.trueSequence);

      check(
        opGeneralNotEqual(
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ),
      ).equals(XPathSequence.trueSequence);
      check(
        opGeneralLessThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
      ).equals(XPathSequence.trueSequence);
    });

    test(
      'Multi-item sequence general comparisons with untyped and numeric',
      () {
        final multiU1 = XPathSequence.from([
          const XPathUntypedAtomic('a'),
          const XPathUntypedAtomic('b'),
        ]);
        final multiU2 = XPathSequence.from([
          const XPathUntypedAtomic('b'),
          const XPathUntypedAtomic('c'),
        ]);
        check(opGeneralEqual(multiU1, multiU2))
            .equals(XPathSequence.trueSequence);

        final multiNum = XPathSequence.from([1, 2]);
        final multiUNum = XPathSequence.from([
          const XPathUntypedAtomic('2'),
          const XPathUntypedAtomic('3'),
        ]);
        check(opGeneralEqual(multiNum, multiUNum))
            .equals(XPathSequence.trueSequence);
      },
    );
  });
}
