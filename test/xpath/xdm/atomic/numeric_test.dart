import 'package:test/test.dart';
import 'package:xml/src/xpath/xdm/atomic/numeric.dart';
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
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => XPathInteger.fromInt(1).idiv(XPathInteger.fromInt(0)),
        throwsA(isXPathEvaluationException()),
      );
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
      expect(XPathDouble.infinity.stringValue, equals('INF'));
      expect(XPathDouble.negativeInfinity.stringValue, equals('-INF'));
      expect(XPathDouble.nan.stringValue, equals('NaN'));
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
      expect(XPathDouble.nan.effectiveBooleanValue, isFalse);
    });

    test('compareTo', () {
      const d1 = XPathDouble(1.0);
      const d2 = XPathDouble(2.0);
      expect(d1.compareTo(d2), lessThan(0));
      expect(d2.compareTo(d1), greaterThan(0));
      expect(d1.compareTo(const XPathDouble(1.0)), equals(0));
    });
  });
}
