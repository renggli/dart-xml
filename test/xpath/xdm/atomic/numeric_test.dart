import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/error_code.dart';
import 'package:xml/src/xpath/xdm/atomic/numeric.dart';
import 'package:xml/src/xpath/xdm/atomic/string.dart';
import 'package:xml/src/xpath/xdm/types.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathInteger', () {
    test('creates from int and BigInt', () {
      final a = XPathInteger.fromInt(42);
      final b = XPathInteger(BigInt.from(42));
      expect(a, equals(b));
      expect(a.value, equals(BigInt.from(42)));
      expect(a.asInt, equals(42));
      expect(a.toDouble(), equals(42.0));
      expect(a.toBigInt(), equals(BigInt.from(42)));
      expect(a.stringValue, equals('42'));
      expect(a.effectiveBooleanValue, isTrue);
      expect(a.isNumeric, isTrue);
      expect(a.type, equals(xsInteger));
    });

    test('parse from text', () {
      final i = XPathInteger.parse('  -999  ');
      expect(i.value, equals(BigInt.from(-999)));
    });

    test('arbitrary precision without 64-bit overflow', () {
      final huge = BigInt.parse('123456789012345678901234567890');
      final a = XPathInteger(huge);
      final b = a + XPathInteger.fromInt(10);
      expect(b.stringValue, equals('123456789012345678901234567900'));
    });

    test('arithmetic operations', () {
      final a = XPathInteger.fromInt(10);
      final b = XPathInteger.fromInt(3);

      expect(a + b, equals(XPathInteger.fromInt(13)));
      expect(a - b, equals(XPathInteger.fromInt(7)));
      expect(a * b, equals(XPathInteger.fromInt(30)));
      expect(a.idiv(b), equals(XPathInteger.fromInt(3)));
      expect(a % b, equals(XPathInteger.fromInt(1)));
      expect(-a, equals(XPathInteger.fromInt(-10)));

      final div = a / b;
      expect(div, isA<XPathDecimal>());
      expect(div.stringValue.startsWith('3.333333'), isTrue);
    });

    test('comparisons and equality', () {
      final a = XPathInteger.fromInt(5);
      final b = XPathInteger.fromInt(10);
      expect(a.compareTo(b), isNegative);
      expect(b.compareTo(a), isPositive);
      expect(a.compareTo(XPathInteger.fromInt(5)), isZero);
      expect(a == XPathInteger.fromInt(5), isTrue);
      expect(a == Object(), isFalse);
    });

    test('EBV for zero is false', () {
      expect(XPathInteger.fromInt(0).effectiveBooleanValue, isFalse);
      expect(XPathInteger.fromInt(-1).effectiveBooleanValue, isTrue);
    });
  });

  group('XPathDecimal', () {
    test('parse and normalize', () {
      final d1 = XPathDecimal.parse('12.3400');
      expect(d1.scale, equals(2));
      expect(d1.unscaledValue, equals(BigInt.from(1234)));
      expect(d1.stringValue, equals('12.34'));
      expect(d1.isNumeric, isTrue);
      expect(d1.type, equals(xsDecimal));

      final d2 = XPathDecimal.parse('0.0050');
      expect(d2.scale, equals(3));
      expect(d2.unscaledValue, equals(BigInt.from(5)));
      expect(d2.stringValue, equals('0.005'));

      final d3 = XPathDecimal.parse('-0.5');
      expect(d3.stringValue, equals('-0.5'));
      expect(d3.effectiveBooleanValue, isTrue);
      expect(XPathDecimal.fromInt(0).effectiveBooleanValue, isFalse);
    });

    test('exact addition and subtraction without float drift', () {
      final a = XPathDecimal.parse('0.1');
      final b = XPathDecimal.parse('0.2');
      final sum = a + b;
      expect(sum, isA<XPathDecimal>());
      expect(sum.stringValue, equals('0.3'));

      final diff = b - a;
      expect(diff.stringValue, equals('0.1'));
    });

    test('multiplication and division', () {
      final a = XPathDecimal.parse('1.5');
      final b = XPathDecimal.parse('2.0');
      expect((a * b).stringValue, equals('3'));

      final d = XPathDecimal.parse('1') / XPathDecimal.parse('4');
      expect(d.stringValue, equals('0.25'));
    });

    test('mixed operations with XPathInteger', () {
      final i = XPathInteger.fromInt(2);
      final d = XPathDecimal.parse('1.5');
      expect((i + d).stringValue, equals('3.5'));
      expect((d + i).stringValue, equals('3.5'));
      expect((i * d).stringValue, equals('3'));
    });

    test('division by zero throws evaluation exception', () {
      expect(
        () => XPathDecimal.parse('1.0') / XPathDecimal.fromInt(0),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => XPathInteger.fromInt(1).idiv(XPathInteger.fromInt(0)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
    });

    test('idiv exact unscaled decimal division', () {
      final a = XPathDecimal.parse('3.5');
      final b = XPathDecimal.parse('1.2');
      expect(a.idiv(b), equals(XPathInteger.fromInt(2)));

      final c = XPathDecimal.parse('0.9');
      final d = XPathDecimal.parse('0.4');
      expect(c.idiv(d), equals(XPathInteger.fromInt(2)));
    });
  });

  group('XPathDouble', () {
    test('constants and parsing', () {
      expect(XPathDouble.parse('INF'), equals(XPathDouble.infinity));
      expect(XPathDouble.parse('-INF'), equals(XPathDouble.negativeInfinity));
      expect(XPathDouble.parse('NaN').value.isNaN, isTrue);
      expect(XPathDouble.parse('12.5').value, equals(12.5));
      expect(const XPathDouble(12.5).isNumeric, isTrue);
      expect(const XPathDouble(12.5).type, equals(xsDouble));
    });

    test('formatting stringValue', () {
      expect(const XPathDouble(1.0).stringValue, equals('1'));
      expect(const XPathDouble(0.0).stringValue, equals('0'));
      expect(const XPathDouble(-0.0).stringValue, equals('-0'));
      expect(XPathDouble.infinity.stringValue, equals('INF'));
      expect(XPathDouble.negativeInfinity.stringValue, equals('-INF'));
      expect(XPathDouble.nan.stringValue, equals('NaN'));
    });

    test('single-precision float stringValue uses shortest precision', () {
      final f = XPathDouble(roundToFloat(1.13), xsFloat);
      expect(f.stringValue, equals('1.13'));
    });

    test('negative zero equality and comparisons', () {
      const negZero = XPathDouble(-0.0);
      const posZero = XPathDouble(0.0);
      expect(negZero == posZero, isTrue);
      expect(negZero.compareTo(posZero), equals(0));
      expect(posZero.compareTo(negZero), equals(0));
      expect(negZero.compareTo(XPathInteger.zero), equals(0));
      expect(XPathInteger.zero.compareTo(negZero), equals(0));
      expect(XPathDecimal.zero.compareTo(negZero), equals(0));
      expect(-posZero, equals(negZero));
    });

    test('idiv semantics and error codes', () {
      const d10 = XPathDouble(10.0);
      const d0 = XPathDouble(0.0);
      expect(
        () => d10.idiv(d0),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => d10.idiv(XPathDouble.nan),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002)),
      );
      expect(
        () => XPathDouble.infinity.idiv(d10),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002)),
      );
      expect(d10.idiv(XPathDouble.infinity), equals(XPathInteger(BigInt.zero)));
      expect(
        d10.idiv(XPathDouble.negativeInfinity),
        equals(XPathInteger(BigInt.zero)),
      );
      expect(
        () => const XPathDouble(1e30).idiv(const XPathDouble(1e-30)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002)),
      );
    });

    test('mixed operations promote to double', () {
      const d = XPathDouble(2.5);
      final i = XPathInteger.fromInt(2);
      final sum = d + i;
      expect(sum, isA<XPathDouble>());
      expect(sum.toDouble(), equals(4.5));
    });

    test('EBV', () {
      expect(const XPathDouble(1.0).effectiveBooleanValue, isTrue);
      expect(const XPathDouble(0.0).effectiveBooleanValue, isFalse);
      expect(const XPathDouble(-0.0).effectiveBooleanValue, isFalse);
      expect(XPathDouble.nan.effectiveBooleanValue, isFalse);
    });

    test('compareTo', () {
      const d1 = XPathDouble(1.0);
      const d2 = XPathDouble(2.0);
      expect(d1.compareTo(d2), lessThan(0));
      expect(d2.compareTo(d1), greaterThan(0));
      expect(d1.compareTo(const XPathDouble(1.0)), equals(0));
    });

    test('toBigInt conversions and errors', () {
      expect(const XPathDouble(42.0).toBigInt(), equals(BigInt.from(42)));
      expect(
        () => XPathDouble.nan.toBigInt(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002)),
      );
      expect(
        () => XPathDouble.infinity.toBigInt(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002)),
      );
      expect(
        () => const XPathDouble(1e25).toBigInt(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0003)),
      );
    });

    test('toDecimal conversions and errors', () {
      expect(const XPathDouble(12.34).toDecimal().stringValue, equals('12.34'));
      expect(
        () => XPathDouble.nan.toDecimal(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002)),
      );
      expect(
        () => XPathDouble.infinity.toDecimal(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002)),
      );
      expect(
        () => const XPathDouble(1e105).toDecimal(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0001)),
      );
    });

    test('cross-type idiv and mod on XPathInteger', () {
      final i10 = XPathInteger.fromInt(10);
      expect(
        i10.idiv(XPathDecimal.parse('2.5')),
        equals(XPathInteger.fromInt(4)),
      );
      expect(i10.idiv(const XPathDouble(3.0)), equals(XPathInteger.fromInt(3)));
      expect(
        () => i10.idiv(XPathInteger.fromInt(0)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => i10.idiv(XPathDecimal.zero),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => i10.idiv(const XPathDouble(0.0)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => i10.idiv(XPathDouble.nan),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002)),
      );
      expect(i10.idiv(XPathDouble.infinity), equals(XPathInteger(BigInt.zero)));

      // mod
      expect(i10 % XPathDecimal.parse('3.5'), isA<XPathDecimal>());
      expect(i10 % const XPathDouble(3.0), isA<XPathDouble>());
      expect(
        () => i10 % XPathInteger.fromInt(0),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => i10 % XPathDecimal.zero,
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => const XPathDouble(10.0) % const XPathDouble(0.0),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
    });

    test('cross-type idiv and mod on XPathDecimal', () {
      final d10 = XPathDecimal.parse('10.5');
      expect(
        d10.idiv(XPathInteger.fromInt(2)),
        equals(XPathInteger.fromInt(5)),
      );
      expect(
        d10.idiv(XPathDecimal.parse('2.0')),
        equals(XPathInteger.fromInt(5)),
      );
      expect(d10.idiv(const XPathDouble(2.0)), equals(XPathInteger.fromInt(5)));
      expect(
        () => d10.idiv(XPathDecimal.zero),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => d10.idiv(const XPathDouble(0.0)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );
      expect(
        () => d10.idiv(XPathDouble.nan),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0002)),
      );
      expect(d10.idiv(XPathDouble.infinity), equals(XPathInteger(BigInt.zero)));

      // mod
      expect(d10 % XPathInteger.fromInt(3), isA<XPathDecimal>());
      expect(d10 % const XPathDouble(3.0), isA<XPathDouble>());
      expect(
        () => d10 % XPathDecimal.zero,
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOAR0001)),
      );

      // compareTo with Double
      expect(d10.compareTo(XPathDouble.nan), equals(-1));
      expect(d10.compareTo(const XPathDouble(10.5)), equals(0));
      expect(d10.compareTo(const XPathDouble(20.0)), lessThan(0));
      expect(d10.compareTo(const XPathDouble(5.0)), greaterThan(0));
      expect(d10 == const XPathDouble(10.5), isTrue);
      expect(d10 == XPathDouble.nan, isFalse);
    });

    test(
      'additional XPathInteger, XPathDecimal, and XPathDouble operations',
      () {
        final i = XPathInteger.fromInt(10);
        final d = XPathDecimal.parse('2.5');
        const dbl = XPathDouble(2.5);

        // XPathInteger cross-type
        expect(i + dbl, equals(const XPathDouble(12.5)));
        expect(i - d, equals(XPathDecimal.parse('7.5')));
        expect(i - dbl, equals(const XPathDouble(7.5)));
        expect(i * dbl, equals(const XPathDouble(25.0)));
        expect(i / d, equals(XPathDecimal.parse('4')));
        expect(i / dbl, equals(const XPathDouble(4.0)));
        expect(i.compareTo(const XPathDouble(5.0)), greaterThan(0));
        expect(
          () => i.compareTo(const XPathString('abc')),
          throwsA(isXPathEvaluationException()),
        );
        expect(i == const XPathDouble(10.0), isTrue);

        // XPathDecimal edge cases
        final bigD = XPathDecimal.fromBigInt(BigInt.from(123));
        expect(bigD.value, equals(bigD));
        expect(bigD.toDecimal(), same(bigD));
        expect(d + dbl, equals(const XPathDouble(5.0)));
        expect(d - dbl, equals(const XPathDouble(0.0)));
        expect(
          d - XPathDecimal.parse('1.25'),
          equals(XPathDecimal.parse('1.25')),
        );
        expect(d * dbl, equals(const XPathDouble(6.25)));
        expect(d / dbl, equals(const XPathDouble(1.0)));
        final tinyD = XPathDecimal(BigInt.one, 25);
        expect(tinyD / XPathDecimal.fromInt(1), isA<XPathDecimal>());
        expect(d.compareTo(XPathDecimal.parse('2.25')), greaterThan(0));
        expect(
          () => d.compareTo(const XPathString('abc')),
          throwsA(isXPathEvaluationException()),
        );
        expect(d == XPathDecimal.parse('2.5'), isTrue);
        expect(d.hashCode, isA<int>());

        // XPathDouble edge cases
        final parsedDbl = XPathDouble.parse('3.14');
        expect(parsedDbl.value, equals(3.14));
        expect(() => XPathDouble.parse('abc'), throwsFormatException);
        expect(dbl - i, equals(const XPathDouble(-7.5)));
        expect(dbl * i, equals(const XPathDouble(25.0)));
        expect(dbl % i, equals(const XPathDouble(2.5)));
        expect(
          () => dbl.compareTo(const XPathString('abc')),
          throwsA(isXPathEvaluationException()),
        );
        expect(dbl.hashCode, isA<int>());

        // _toXPathScientific
        expect(const XPathDouble(1e7).stringValue, equals('1.0E7'));
        expect(const XPathDouble(-1250000.0).stringValue, equals('-1.25E6'));
        expect(const XPathDouble(1e20).stringValue, equals('1.0E20'));
      },
    );
  });
}
