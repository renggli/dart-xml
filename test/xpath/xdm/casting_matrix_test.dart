import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/error_code.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/casting_matrix.dart';
import 'package:xml/src/xpath/xdm/types.dart';

import '../../utils/matchers.dart';

void main() {
  group('canCastType', () {
    test('allowed and disallowed casts', () {
      expect(canCastType(xsString, xsInteger), isTrue);
      expect(canCastType(xsInteger, xsString), isTrue);
      expect(canCastType(xsBoolean, xsInteger), isTrue);
      expect(canCastType(xsInteger, xsBoolean), isTrue);
      expect(canCastType(xsUntypedAtomic, xsDouble), isTrue);
      expect(canCastType(xsBase64Binary, xsHexBinary), isTrue);
      expect(canCastType(xsHexBinary, xsBase64Binary), isTrue);

      // Disallowed casts
      expect(canCastType(xsBoolean, xsDate), isFalse);
      expect(canCastType(xsDate, xsInteger), isFalse);
      expect(canCastType(xsString, xsNOTATION), isFalse);
      expect(canCastType(xsString, xsAnyAtomicType), isFalse);
      expect(canCastType(xsString, xsItem), isFalse);
    });
  });

  group('primitiveCastingType', () {
    test('maps derived types to primitives', () {
      expect(primitiveCastingType(xsPositiveInteger), equals(xsInteger));
      expect(primitiveCastingType(xsNumeric), equals(xsInteger));
      expect(primitiveCastingType(xsInt), equals(xsInteger));
      expect(primitiveCastingType(xsByte), equals(xsInteger));
      expect(primitiveCastingType(xsNormalizedString), equals(xsString));
      expect(primitiveCastingType(xsToken), equals(xsString));
      expect(primitiveCastingType(xsDateTimeStamp), equals(xsDateTimeStamp));
      expect(
        primitiveCastingType(xsDayTimeDuration),
        equals(xsDayTimeDuration),
      );
      expect(
        primitiveCastingType(xsYearMonthDuration),
        equals(xsYearMonthDuration),
      );
      expect(primitiveCastingType(xsDuration), equals(xsDuration));
    });
  });

  group('castAtomic', () {
    test('same type returns identical/equal item', () {
      final i = XPathInteger.fromInt(42);
      expect(castAtomic(i, xsInteger), same(i));
    });

    test('casting string to numerics', () {
      expect(
        castAtomic(const XPathString('123'), xsInteger),
        equals(XPathInteger.fromInt(123)),
      );
      expect(
        castAtomic(const XPathString('12.5'), xsDecimal).stringValue,
        equals('12.5'),
      );
      expect(
        castAtomic(const XPathString('1.25e2'), xsDouble),
        equals(const XPathDouble(125.0)),
      );
      expect(
        () => castAtomic(const XPathString('abc'), xsInteger),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('casting numerics to boolean and string', () {
      expect(
        castAtomic(XPathInteger.fromInt(1), xsBoolean),
        equals(XPathBoolean.trueInstance),
      );
      expect(
        castAtomic(XPathInteger.fromInt(0), xsBoolean),
        equals(XPathBoolean.falseInstance),
      );
      expect(
        castAtomic(XPathInteger.fromInt(123), xsString),
        equals(const XPathString('123')),
      );
    });

    test('casting boolean to numerics and string', () {
      expect(
        castAtomic(XPathBoolean.trueInstance, xsInteger),
        equals(XPathInteger.fromInt(1)),
      );
      expect(
        castAtomic(XPathBoolean.falseInstance, xsInteger),
        equals(XPathInteger.fromInt(0)),
      );
      expect(
        castAtomic(XPathBoolean.trueInstance, xsString),
        equals(const XPathString('true')),
      );
    });

    test('casting between binary types', () {
      final hex = XPathBinary.fromHex('48656C6C6F'); // "Hello"
      final b64 = castAtomic(hex, xsBase64Binary);
      expect(b64, isA<XPathBinary>());
      expect(b64.type, equals(xsBase64Binary));
      expect(b64.stringValue, equals('SGVsbG8='));

      final hexBack = castAtomic(b64, xsHexBinary);
      expect(hexBack, equals(hex));
    });

    test('target integer subtype bounds validation', () {
      expect(
        castAtomic(XPathInteger.fromInt(100), xsByte),
        equals(XPathInteger.fromInt(100, xsByte)),
      );
      expect(
        () => castAtomic(XPathInteger.fromInt(200), xsByte),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(XPathInteger.fromInt(-5), xsNonNegativeInteger),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(XPathInteger.fromInt(0), xsPositiveInteger),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('disallowed cast throws evaluation exception', () {
      expect(
        () => castAtomic(XPathBoolean.trueInstance, xsDate),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(const XPathString('foo'), xsAnyAtomicType),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(const XPathString('foo'), xsItem),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('duration casting rules', () {
      const ymd = XPathDuration.yearMonth(14); // P1Y2M
      const dtd = XPathDuration.dayTime(90000000); // PT90S

      // Duration to numeric is disallowed
      expect(
        () => castAtomic(ymd, xsDecimal),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(ymd, xsInteger),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(dtd, xsFloat),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => castAtomic(dtd, xsDouble),
        throwsA(isXPathEvaluationException()),
      );

      // Duration to duration is allowed
      final ymdToDtd = castAtomic(ymd, xsDayTimeDuration);
      expect(ymdToDtd.stringValue, equals('PT0S'));

      final dtdToYmd = castAtomic(dtd, xsYearMonthDuration);
      expect(dtdToYmd.stringValue, equals('P0M'));
    });

    test('float 32-bit rounding and bounds', () {
      // Underflow to zero
      final underflow = XPathDouble.parse('5.4321E-100', xsFloat);
      expect(underflow.value, equals(0.0));
      expect(underflow.stringValue, equals('0'));

      // Overflow to infinity
      final overflow = XPathDouble.parse('1.0E40', xsFloat);
      expect(overflow.value, equals(double.infinity));
      expect(overflow.stringValue, equals('INF'));

      // Single-precision rounding
      final rounded = castAtomic(
        XPathDecimal.parse('12678967.543233'),
        xsFloat,
      );
      expect(rounded.stringValue, equals('1.2678968E7'));

      // Negative zero
      final negZero = XPathDouble.parse('-0.0', xsFloat);
      expect(negZero.stringValue, equals('-0'));

      // +INF parsing
      final plusInf = XPathDouble.parse('+INF', xsFloat);
      expect(plusInf.stringValue, equals('INF'));
      final plusInfDouble = XPathDouble.parse('+INF', xsDouble);
      expect(plusInfDouble.stringValue, equals('INF'));
    });

    test('double and float canonical string representation', () {
      // Decimal range: [1e-6, 1e6)
      expect(const XPathDouble(0.0).stringValue, equals('0'));
      expect(const XPathDouble(-0.0).stringValue, equals('-0'));
      expect(const XPathDouble(1.0).stringValue, equals('1'));
      expect(const XPathDouble(999999.0).stringValue, equals('999999'));
      expect(const XPathDouble(0.000001).stringValue, equals('0.000001'));
      expect(const XPathDouble(12.34).stringValue, equals('12.34'));

      // Scientific range: magnitude < 1e-6 or >= 1e6
      expect(const XPathDouble(1000000.0).stringValue, equals('1.0E6'));
      expect(const XPathDouble(-10000000.0).stringValue, equals('-1.0E7'));
      expect(
        const XPathDouble(1.26743233e15).stringValue,
        equals('1.26743233E15'),
      );
      expect(const XPathDouble(1e-7).stringValue, equals('1.0E-7'));
      expect(const XPathDouble(-1e-7).stringValue, equals('-1.0E-7'));
    });

    test('XPathDecimal parsing with scientific notation', () {
      final d1 = XPathDecimal.parse('1e-7');
      expect(d1.stringValue, equals('0.0000001'));

      final d2 = XPathDecimal.parse('1.5e3');
      expect(d2.stringValue, equals('1500'));
    });

    test('casting boolean to float and decimal', () {
      expect(
        castAtomic(XPathBoolean.trueInstance, xsDouble),
        equals(const XPathDouble(1.0)),
      );
      expect(
        castAtomic(XPathBoolean.falseInstance, xsDouble),
        equals(const XPathDouble(0.0)),
      );
      expect(
        castAtomic(XPathBoolean.trueInstance, xsDecimal).stringValue,
        equals('1'),
      );
      expect(
        castAtomic(XPathBoolean.falseInstance, xsDecimal).stringValue,
        equals('0'),
      );
    });

    test('year out of range errors throw FODT0001', () {
      void expectYearError(String text, XPathType targetType) {
        expect(
          () => castAtomic(XPathString(text), targetType),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FODT0001),
          ),
        );
      }

      expectYearError('300000-01-01', xsDate);
      expectYearError('300000-01-01T00:00:00Z', xsDateTime);
      expectYearError('300000-01-01T00:00:00Z', xsDateTimeStamp);
      expectYearError('100000000000000000000000000000-01', xsGYearMonth);
      expectYearError('100000000000000000000000000000', xsGYear);
    });

    test('invalid lexical representations throw errors', () {
      void expectLexicalError(String text, XPathType targetType) {
        expect(
          () => castAtomic(XPathString(text), targetType),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
          ),
        );
      }

      expectLexicalError('invalid', xsTime);
      expectLexicalError('invalid', xsGMonthDay);
      expectLexicalError('invalid', xsGMonth);
      expectLexicalError('invalid', xsGDay);
      expectLexicalError('invalid', xsDate);
      expectLexicalError('invalid', xsDateTime);
      expectLexicalError('invalid', xsGYearMonth);
      expectLexicalError('invalid', xsGYear);
      expectLexicalError('maybe', xsBoolean);
      expectLexicalError('2020-01-01T12:00:00', xsDateTimeStamp);

      expect(
        () => castAtomic(const XPathString('1:2:3'), xsQName),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002)),
      );
    });

    test('additional casting branches', () {
      // Line 354: numeric to xsDecimal
      expect(
        castAtomic(XPathInteger.fromInt(42), xsDecimal).stringValue,
        equals('42'),
      );
      expect(
        castAtomic(const XPathDouble(42.5), xsDecimal).stringValue,
        equals('42.5'),
      );

      // Line 390-391: xsDateTime without timezone to xsDateTimeStamp
      expect(
        () => castAtomic(
          XPathDateTime.tryParse('2020-01-01T12:00:00')!,
          xsDateTimeStamp,
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001)),
      );

      // Line 414-416: duration to xsDuration
      final ymd = XPathDuration.tryParse('P1Y2M', xsYearMonthDuration)!;
      final dur = castAtomic(ymd, xsDuration);
      expect(dur.type, equals(xsDuration));
      expect(dur.stringValue, equals('P1Y2M'));

      // string to xsAnyURI
      final uri = castAtomic(const XPathString('http://example.com'), xsAnyURI);
      expect(uri.type, equals(xsAnyURI));
      expect(uri.stringValue, equals('http://example.com'));
    });

    test('duration disallowed casts throw XPTY0004', () {
      final ymd = XPathDuration.tryParse('P1Y2M', xsYearMonthDuration)!;
      expect(
        () => castAtomic(ymd, xsInteger),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
  });
}
