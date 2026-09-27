import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

XPathSequence intSeq(List<int> values) =>
    XPathSequence(values.map(XPathInteger.fromInt));

void main() {
  group('opAnd', () {
    test('true and true', () {
      expect(
        opAnd(XPathSequence.trueSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
    test('true and false', () {
      expect(
        opAnd(XPathSequence.trueSequence, XPathSequence.falseSequence),
        XPathSequence.falseSequence,
      );
    });
    test('false and true', () {
      expect(
        opAnd(XPathSequence.falseSequence, XPathSequence.trueSequence),
        XPathSequence.falseSequence,
      );
    });
  });

  group('opOr', () {
    test('true or true', () {
      expect(
        opOr(XPathSequence.trueSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
    test('false or false', () {
      expect(
        opOr(XPathSequence.falseSequence, XPathSequence.falseSequence),
        XPathSequence.falseSequence,
      );
    });
    test('true or false', () {
      expect(
        opOr(XPathSequence.trueSequence, XPathSequence.falseSequence),
        XPathSequence.trueSequence,
      );
    });
    test('false or true', () {
      expect(
        opOr(XPathSequence.falseSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGeneralEqual', () {
    test('overlapping ranges', () {
      expect(
        opGeneralEqual(intSeq([1, 2]), intSeq([2, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('disjoint ranges', () {
      expect(
        opGeneralEqual(intSeq([1, 2]), intSeq([3, 4])),
        XPathSequence.falseSequence,
      );
    });
    test('type coercion with untypedAtomic', () {
      expect(
        opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
        XPathSequence.trueSequence,
      );
      expect(
        () => opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralNotEqual', () {
    test('overlapping with not equal', () {
      expect(
        opGeneralNotEqual(intSeq([1, 2]), intSeq([2, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('single value equal', () {
      expect(
        opGeneralNotEqual(intSeq([1]), intSeq([1])),
        XPathSequence.falseSequence,
      );
    });
    test('type coercion with untypedAtomic', () {
      expect(
        opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
        XPathSequence.falseSequence,
      );
      expect(
        () => opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralLessThan', () {
    test('less than', () {
      expect(
        opGeneralLessThan(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralLessThan(q1, q2),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralGreaterThan', () {
    test('greater than', () {
      expect(
        opGeneralGreaterThan(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralGreaterThan(q1, q2),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralLessThanOrEqual', () {
    test('less than or equal', () {
      expect(
        opGeneralLessThanOrEqual(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralLessThanOrEqual(q1, q2),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralGreaterThanOrEqual', () {
    test('greater than or equal', () {
      expect(
        opGeneralGreaterThanOrEqual(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralGreaterThanOrEqual(q1, q2),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('general comparison with QName, Duration, Binary, Untyped', () {
    test('QName equality and inequality', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q2 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q3 = XPathSequence.single(XPathQName(XmlName('bar')));
      expect(opGeneralEqual(q1, q2), XPathSequence.trueSequence);
      expect(opGeneralEqual(q1, q3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(q1, q2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(q1, q3), XPathSequence.trueSequence);
    });

    test('Duration equality and inequality', () {
      const d1 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d2 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d3 = XPathSequence.single(XPathDuration.dayTime(2000));
      expect(opGeneralEqual(d1, d2), XPathSequence.trueSequence);
      expect(opGeneralEqual(d1, d3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(d1, d2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(d1, d3), XPathSequence.trueSequence);
    });

    test('Binary equality and inequality', () {
      final b1 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b2 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b3 = XPathSequence.single(XPathBinary.fromHex('0304'));
      expect(opGeneralEqual(b1, b2), XPathSequence.trueSequence);
      expect(opGeneralEqual(b1, b3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(b1, b2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(b1, b3), XPathSequence.trueSequence);
    });

    test('untypedAtomic comparisons', () {
      const u1 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u2 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u3 = XPathSequence.single(XPathUntypedAtomic('def'));
      expect(opGeneralEqual(u1, u2), XPathSequence.trueSequence);
      expect(opGeneralEqual(u1, u3), XPathSequence.falseSequence);

      const uDate = XPathSequence.single(
        XPathUntypedAtomic('2024-01-01T00:00:00Z'),
      );
      final date = XPathSequence.single(
        XPathDateTime.fromDateTime(DateTime.utc(2024, 1, 1), 0),
      );
      expect(opGeneralEqual(uDate, date), XPathSequence.trueSequence);

      const strA = XPathSequence.single(XPathString('a'));
      expect(opGeneralEqual(strA, u1), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(u1, u3), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(strA, u3), XPathSequence.trueSequence);
      expect(opGeneralLessThan(strA, u3), XPathSequence.trueSequence);

      final num1 = XPathSequence.single(XPathInteger.fromInt(1));
      final num2 = XPathSequence.single(XPathInteger.fromInt(2));
      const uNum1 = XPathSequence.single(XPathUntypedAtomic('1'));
      const uNum2 = XPathSequence.single(XPathUntypedAtomic('2'));
      expect(opGeneralNotEqual(uNum1, num2), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(num1, uNum2), XPathSequence.trueSequence);
      expect(opGeneralLessThan(num1, uNum2), XPathSequence.trueSequence);

      final date1 = XPathSequence.single(
        XPathDateTime.tryParseDate('2000-01-01')!,
      );
      final date2 = XPathSequence.single(
        XPathDateTime.tryParseDate('2000-01-02')!,
      );
      const uDate1 = XPathSequence.single(XPathUntypedAtomic('2000-01-01'));
      const uDate2 = XPathSequence.single(XPathUntypedAtomic('2000-01-02'));
      expect(opGeneralEqual(date1, uDate1), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(uDate1, date2), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(date1, uDate2), XPathSequence.trueSequence);
      expect(opGeneralLessThan(uDate1, date2), XPathSequence.trueSequence);
      expect(opGeneralLessThan(date1, uDate2), XPathSequence.trueSequence);
      expect(opGeneralLessThan(date1, date2), XPathSequence.trueSequence);

      const uInf = XPathSequence.single(XPathUntypedAtomic('INF'));
      const inf = XPathSequence.single(XPathDouble(double.infinity));
      const one = XPathSequence.single(XPathDouble(1.0));
      expect(opGeneralEqual(uInf, inf), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(uInf, one), XPathSequence.trueSequence);
      expect(
        () => opGeneralNotEqual(
          const XPathSequence.single(XPathUntypedAtomic('invalid')),
          one,
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001)),
      );
      expect(opGeneralLessThan(one, uInf), XPathSequence.trueSequence);
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
      expect(
        () => opGeneralLessThan(q1, q2),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralLessThan(mq1, mq2),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralGreaterThan(mq1, mq2),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralLessThanOrEqual(mq1, mq2),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralGreaterThanOrEqual(mq1, mq2),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('BigInt XPathInteger comparisons', () {
      final bigA = XPathSequence.single(
        XPathInteger(BigInt.parse('1000000000000000000000000000000')),
      );
      final bigB = XPathSequence.single(
        XPathInteger(BigInt.parse('1000000000000000000000000000001')),
      );
      expect(opGeneralEqual(bigA, bigA), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(bigA, bigB), XPathSequence.trueSequence);
      expect(opGeneralLessThan(bigA, bigB), XPathSequence.trueSequence);
    });

    test('Double and Boolean edge comparisons', () {
      const nan = XPathSequence.single(XPathDouble(double.nan));
      expect(opGeneralEqual(nan, nan), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(nan, nan), XPathSequence.trueSequence);

      const d1 = XPathSequence.single(XPathDouble(1.5));
      const d2 = XPathSequence.single(XPathDouble(2.5));
      expect(opGeneralEqual(d1, d1), XPathSequence.trueSequence);
      expect(opGeneralNotEqual(d1, d2), XPathSequence.trueSequence);
      expect(opGeneralLessThan(d1, d1), XPathSequence.falseSequence);
      expect(opGeneralLessThan(d1, d2), XPathSequence.trueSequence);

      expect(
        opGeneralNotEqual(
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
        XPathSequence.trueSequence,
      );
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
        expect(opGeneralEqual(multiU1, multiU2), XPathSequence.trueSequence);

        final multiNum = XPathSequence.from([1, 2]);
        final multiUNum = XPathSequence.from([
          const XPathUntypedAtomic('2'),
          const XPathUntypedAtomic('3'),
        ]);
        expect(opGeneralEqual(multiNum, multiUNum), XPathSequence.trueSequence);
      },
    );
  });
}
