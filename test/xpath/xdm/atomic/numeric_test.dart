import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathInteger', () {
    test('creates from int and BigInt', () {
      final a = XPathInteger.fromInt(42);
      final b = XPathInteger(BigInt.from(42));
      check(a).equals(b);
      check(a.value).equals(BigInt.from(42));
      check(a.asInt).equals(42);
      check(a.toDouble()).equals(42.0);
      check(a.toBigInt()).equals(BigInt.from(42));
      check(a.stringValue).equals('42');
      check(a.effectiveBooleanValue).isTrue();
      check(a.isNumeric).isTrue();
      check(a.type).equals(xsInteger);
    });

    test('parse from text', () {
      final i = XPathInteger.parse('  -999  ');
      check(i.value).equals(BigInt.from(-999));
    });

    test('arbitrary precision without 64-bit overflow', () {
      final huge = BigInt.parse('123456789012345678901234567890');
      final a = XPathInteger(huge);
      final b = a + XPathInteger.fromInt(10);
      check(b.stringValue).equals('123456789012345678901234567900');
    });

    test('arithmetic operations', () {
      final a = XPathInteger.fromInt(10);
      final b = XPathInteger.fromInt(3);

      check(a + b).equals(XPathInteger.fromInt(13));
      check(a - b).equals(XPathInteger.fromInt(7));
      check(a * b).equals(XPathInteger.fromInt(30));
      check(a.idiv(b)).equals(XPathInteger.fromInt(3));
      check(a % b).equals(XPathInteger.fromInt(1));
      check(-a).equals(XPathInteger.fromInt(-10));

      final div = a / b;
      check(div).isA<XPathDecimal>();
      check(div.stringValue.startsWith('3.333333')).isTrue();
    });

    test('comparisons and equality', () {
      final a = XPathInteger.fromInt(5);
      final b = XPathInteger.fromInt(10);
      check(a.compareTo(b)).isLessThan(0);
      check(b.compareTo(a)).isGreaterThan(0);
      check(a.compareTo(XPathInteger.fromInt(5))).equals(0);
      check(a == XPathInteger.fromInt(5)).isTrue();
      check(a == Object()).isFalse();

      final big1 = XPathInteger(
        BigInt.parse('1000000000000000000000000000000'),
      );
      final big2 = XPathInteger(
        BigInt.parse('1000000000000000000000000000001'),
      );
      check(big1.compareTo(big2)).isLessThan(0);
      check(big2.compareTo(big1)).isGreaterThan(0);
      check(big1.compareTo(big1)).equals(0);
      check(big1 == big1).isTrue();
      check(big1 == big2).isFalse();
    });

    test('EBV for zero is false', () {
      check(XPathInteger.fromInt(0).effectiveBooleanValue).isFalse();
      check(XPathInteger.fromInt(-1).effectiveBooleanValue).isTrue();
    });
  });

  group('XPathDecimal', () {
    test('parse and normalize', () {
      final d1 = XPathDecimal.parse('12.3400');
      check(d1.scale).equals(2);
      check(d1.unscaledValue).equals(BigInt.from(1234));
      check(d1.stringValue).equals('12.34');
      check(d1.isNumeric).isTrue();
      check(d1.type).equals(xsDecimal);

      final d2 = XPathDecimal.parse('0.0050');
      check(d2.scale).equals(3);
      check(d2.unscaledValue).equals(BigInt.from(5));
      check(d2.stringValue).equals('0.005');

      final d3 = XPathDecimal.parse('-0.5');
      check(d3.stringValue).equals('-0.5');
      check(d3.effectiveBooleanValue).isTrue();
      check(XPathDecimal.fromInt(0).effectiveBooleanValue).isFalse();
    });

    test('exact addition and subtraction without float drift', () {
      final a = XPathDecimal.parse('0.1');
      final b = XPathDecimal.parse('0.2');
      final sum = a + b;
      check(sum).isA<XPathDecimal>();
      check(sum.stringValue).equals('0.3');

      final diff = b - a;
      check(diff.stringValue).equals('0.1');
    });

    test('multiplication and division', () {
      final a = XPathDecimal.parse('1.5');
      final b = XPathDecimal.parse('2.0');
      check((a * b).stringValue).equals('3');

      final d = XPathDecimal.parse('1') / XPathDecimal.parse('4');
      check(d.stringValue).equals('0.25');
    });

    test('mixed operations with XPathInteger', () {
      final i = XPathInteger.fromInt(2);
      final d = XPathDecimal.parse('1.5');
      check((i + d).stringValue).equals('3.5');
      check((d + i).stringValue).equals('3.5');
      check((i * d).stringValue).equals('3');
    });

    test('division by zero throws evaluation exception', () {
      check(() => XPathDecimal.parse('1.0') / XPathDecimal.fromInt(0))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => XPathInteger.fromInt(1).idiv(XPathInteger.fromInt(0)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
    });

    test('idiv exact unscaled decimal division', () {
      final a = XPathDecimal.parse('3.5');
      final b = XPathDecimal.parse('1.2');
      check(a.idiv(b)).equals(XPathInteger.fromInt(2));

      final c = XPathDecimal.parse('0.9');
      final d = XPathDecimal.parse('0.4');
      check(c.idiv(d)).equals(XPathInteger.fromInt(2));
    });
  });

  group('XPathDouble', () {
    test('constants and parsing', () {
      check(XPathDouble.parse('INF')).equals(XPathDouble.infinity);
      check(XPathDouble.parse('-INF')).equals(XPathDouble.negativeInfinity);
      check(XPathDouble.parse('NaN').value.isNaN).isTrue();
      check(XPathDouble.parse('12.5').value).equals(12.5);
      check(const XPathDouble(12.5).isNumeric).isTrue();
      check(const XPathDouble(12.5).type).equals(xsDouble);
    });

    test('formatting stringValue', () {
      check(const XPathDouble(1.0).stringValue).equals('1');
      check(const XPathDouble(0.0).stringValue).equals('0');
      check(const XPathDouble(-0.0).stringValue).equals('-0');
      check(XPathDouble.infinity.stringValue).equals('INF');
      check(XPathDouble.negativeInfinity.stringValue).equals('-INF');
      check(XPathDouble.nan.stringValue).equals('NaN');
    });

    test('single-precision float stringValue uses shortest precision', () {
      final f = XPathDouble(roundToFloat(1.13), xsFloat);
      check(f.stringValue).equals('1.13');
    });

    test('negative zero equality and comparisons', () {
      const negZero = XPathDouble(-0.0);
      const posZero = XPathDouble(0.0);
      check(negZero == posZero).isTrue();
      check(negZero.compareTo(posZero)).equals(0);
      check(posZero.compareTo(negZero)).equals(0);
      check(negZero.compareTo(XPathInteger.zero)).equals(0);
      check(XPathInteger.zero.compareTo(negZero)).equals(0);
      check(XPathDecimal.zero.compareTo(negZero)).equals(0);
      check(-posZero).equals(negZero);
    });

    test('idiv semantics and error codes', () {
      const d10 = XPathDouble(10.0);
      const d0 = XPathDouble(0.0);
      check(() => d10.idiv(d0)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
      );
      check(() => d10.idiv(XPathDouble.nan))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002),
          );
      check(() => XPathDouble.infinity.idiv(d10))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002),
          );
      check(d10.idiv(XPathDouble.infinity)).equals(XPathInteger(BigInt.zero));
      check(d10.idiv(XPathDouble.negativeInfinity))
          .equals(XPathInteger(BigInt.zero));
      check(() => const XPathDouble(1e30).idiv(const XPathDouble(1e-30)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002),
          );
    });

    test('mixed operations promote to double', () {
      const d = XPathDouble(2.5);
      final i = XPathInteger.fromInt(2);
      final sum = d + i;
      check(sum).isA<XPathDouble>();
      check(sum.toDouble()).equals(4.5);
    });

    test('EBV', () {
      check(const XPathDouble(1.0).effectiveBooleanValue).isTrue();
      check(const XPathDouble(0.0).effectiveBooleanValue).isFalse();
      check(const XPathDouble(-0.0).effectiveBooleanValue).isFalse();
      check(XPathDouble.nan.effectiveBooleanValue).isFalse();
    });

    test('compareTo', () {
      const d1 = XPathDouble(1.0);
      const d2 = XPathDouble(2.0);
      check(d1.compareTo(d2)).isLessThan(0);
      check(d2.compareTo(d1)).isGreaterThan(0);
      check(d1.compareTo(const XPathDouble(1.0))).equals(0);
    });

    test('toBigInt conversions and errors', () {
      check(const XPathDouble(42.0).toBigInt()).equals(BigInt.from(42));
      check(() => XPathDouble.nan.toBigInt())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002),
          );
      check(() => XPathDouble.infinity.toBigInt())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002),
          );
      check(() => const XPathDouble(1e25).toBigInt())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0003),
          );
    });

    test('toDecimal conversions and errors', () {
      check(const XPathDouble(12.34).toDecimal().stringValue).equals('12.34');
      check(() => XPathDouble.nan.toDecimal())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002),
          );
      check(() => XPathDouble.infinity.toDecimal())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002),
          );
      check(() => const XPathDouble(1e105).toDecimal())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0001),
          );
    });

    test('cross-type idiv and mod on XPathInteger', () {
      final i10 = XPathInteger.fromInt(10);
      check(i10.idiv(XPathDecimal.parse('2.5')))
          .equals(XPathInteger.fromInt(4));
      check(i10.idiv(const XPathDouble(3.0))).equals(XPathInteger.fromInt(3));
      check(() => i10.idiv(XPathInteger.fromInt(0)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => i10.idiv(XPathDecimal.zero))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => i10.idiv(const XPathDouble(0.0)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => i10.idiv(XPathDouble.nan))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002),
          );
      check(i10.idiv(XPathDouble.infinity)).equals(XPathInteger(BigInt.zero));

      // mod
      check(i10 % XPathDecimal.parse('3.5')).isA<XPathDecimal>();
      check(i10 % const XPathDouble(3.0)).isA<XPathDouble>();
      check(() => i10 % XPathInteger.fromInt(0))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => i10 % XPathDecimal.zero)
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => const XPathDouble(10.0) % const XPathDouble(0.0))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
    });

    test('cross-type idiv and mod on XPathDecimal', () {
      final d10 = XPathDecimal.parse('10.5');
      check(d10.idiv(XPathInteger.fromInt(2))).equals(XPathInteger.fromInt(5));
      check(d10.idiv(XPathDecimal.parse('2.0')))
          .equals(XPathInteger.fromInt(5));
      check(d10.idiv(const XPathDouble(2.0))).equals(XPathInteger.fromInt(5));
      check(() => d10.idiv(XPathDecimal.zero))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => d10.idiv(const XPathDouble(0.0)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );
      check(() => d10.idiv(XPathDouble.nan))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002),
          );
      check(d10.idiv(XPathDouble.infinity)).equals(XPathInteger(BigInt.zero));

      // mod
      check(d10 % XPathInteger.fromInt(3)).isA<XPathDecimal>();
      check(d10 % const XPathDouble(3.0)).isA<XPathDouble>();
      check(() => d10 % XPathDecimal.zero)
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001),
          );

      // compareTo with Double
      check(d10.compareTo(XPathDouble.nan)).equals(-1);
      check(d10.compareTo(const XPathDouble(10.5))).equals(0);
      check(d10.compareTo(const XPathDouble(20.0))).isLessThan(0);
      check(d10.compareTo(const XPathDouble(5.0))).isGreaterThan(0);
      check(d10 == const XPathDouble(10.5)).isTrue();
      check(d10 == XPathDouble.nan).isFalse();
    });

    test(
      'additional XPathInteger, XPathDecimal, and XPathDouble operations',
      () {
        final i = XPathInteger.fromInt(10);
        final d = XPathDecimal.parse('2.5');
        const dbl = XPathDouble(2.5);

        // XPathInteger cross-type
        check(i + dbl).equals(const XPathDouble(12.5));
        check(i - d).equals(XPathDecimal.parse('7.5'));
        check(i - dbl).equals(const XPathDouble(7.5));
        check(i * dbl).equals(const XPathDouble(25.0));
        check(i / d).equals(XPathDecimal.parse('4'));
        check(i / dbl).equals(const XPathDouble(4.0));
        check(i.compareTo(const XPathDouble(5.0))).isGreaterThan(0);
        check(() => i.compareTo(const XPathString('abc')))
            .throws<XPathEvaluationException>()
            .which(isXPathEvaluationException());
        check(i == const XPathDouble(10.0)).isTrue();

        // XPathDecimal edge cases
        final bigD = XPathDecimal.fromBigInt(BigInt.from(123));
        check(bigD.value).equals(bigD);
        check(bigD.toDecimal()).identicalTo(bigD);
        check(d + dbl).equals(const XPathDouble(5.0));
        check(d - dbl).equals(const XPathDouble(0.0));
        check(d - XPathDecimal.parse('1.25'))
            .equals(XPathDecimal.parse('1.25'));
        check(d * dbl).equals(const XPathDouble(6.25));
        check(d / dbl).equals(const XPathDouble(1.0));
        final tinyD = XPathDecimal(BigInt.one, 25);
        check(tinyD / XPathDecimal.fromInt(1)).isA<XPathDecimal>();
        check(d.compareTo(XPathDecimal.parse('2.25'))).isGreaterThan(0);
        check(() => d.compareTo(const XPathString('abc')))
            .throws<XPathEvaluationException>()
            .which(isXPathEvaluationException());
        check(d == XPathDecimal.parse('2.5')).isTrue();
        check(d.hashCode).isA<int>();

        // XPathDouble edge cases
        final parsedDbl = XPathDouble.parse('3.14');
        check(parsedDbl.value).equals(3.14);
        check(() => XPathDouble.parse('abc')).throws<FormatException>();
        check(dbl - i).equals(const XPathDouble(-7.5));
        check(dbl * i).equals(const XPathDouble(25.0));
        check(dbl % i).equals(const XPathDouble(2.5));
        check(() => dbl.compareTo(const XPathString('abc')))
            .throws<XPathEvaluationException>()
            .which(isXPathEvaluationException());
        check(dbl.hashCode).isA<int>();

        // _toXPathScientific
        check(const XPathDouble(1e7).stringValue).equals('1.0E7');
        check(const XPathDouble(-1250000.0).stringValue).equals('-1.25E6');
        check(const XPathDouble(1e20).stringValue).equals('1.0E20');
      },
    );
  });
}
