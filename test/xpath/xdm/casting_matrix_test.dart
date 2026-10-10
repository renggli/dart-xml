import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/xdm/casting_matrix.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

void main() {
  group('canCastType', () {
    test('allowed and disallowed casts', () {
      check(canCastType(xsString, xsInteger)).isTrue();
      check(canCastType(xsInteger, xsString)).isTrue();
      check(canCastType(xsBoolean, xsInteger)).isTrue();
      check(canCastType(xsInteger, xsBoolean)).isTrue();
      check(canCastType(xsUntypedAtomic, xsDouble)).isTrue();
      check(canCastType(xsBase64Binary, xsHexBinary)).isTrue();
      check(canCastType(xsHexBinary, xsBase64Binary)).isTrue();

      // Disallowed casts
      check(canCastType(xsBoolean, xsDate)).isFalse();
      check(canCastType(xsDate, xsInteger)).isFalse();
      check(canCastType(xsString, xsNOTATION)).isFalse();
      check(canCastType(xsString, xsAnyAtomicType)).isFalse();
      check(canCastType(xsString, xsItem)).isFalse();
    });
  });

  group('primitiveCastingType', () {
    test('maps derived types to primitives', () {
      check(primitiveCastingType(xsPositiveInteger)).equals(xsInteger);
      check(primitiveCastingType(xsNumeric)).equals(xsInteger);
      check(primitiveCastingType(xsInt)).equals(xsInteger);
      check(primitiveCastingType(xsByte)).equals(xsInteger);
      check(primitiveCastingType(xsNormalizedString)).equals(xsString);
      check(primitiveCastingType(xsToken)).equals(xsString);
      check(primitiveCastingType(xsDateTimeStamp)).equals(xsDateTimeStamp);
      check(primitiveCastingType(xsDayTimeDuration)).equals(xsDayTimeDuration);
      check(primitiveCastingType(xsYearMonthDuration))
          .equals(xsYearMonthDuration);
      check(primitiveCastingType(xsDuration)).equals(xsDuration);
    });
  });

  group('castAtomic', () {
    test('same type returns identical/equal item', () {
      final i = XPathInteger.fromInt(42);
      check(castAtomic(i, xsInteger)).identicalTo(i);
    });

    test('casting string to numerics', () {
      check(castAtomic(const XPathString('123'), xsInteger))
          .equals(XPathInteger.fromInt(123));
      check(castAtomic(const XPathString('12.5'), xsDecimal).stringValue)
          .equals('12.5');
      check(castAtomic(const XPathString('1.25e2'), xsDouble))
          .equals(const XPathDouble(125.0));
      check(() => castAtomic(const XPathString('abc'), xsInteger))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('casting numerics to boolean and string', () {
      check(castAtomic(XPathInteger.fromInt(1), xsBoolean))
          .equals(XPathBoolean.trueInstance);
      check(castAtomic(XPathInteger.fromInt(0), xsBoolean))
          .equals(XPathBoolean.falseInstance);
      check(castAtomic(XPathInteger.fromInt(123), xsString))
          .equals(const XPathString('123'));
    });

    test('casting boolean to numerics and string', () {
      check(castAtomic(XPathBoolean.trueInstance, xsInteger))
          .equals(XPathInteger.fromInt(1));
      check(castAtomic(XPathBoolean.falseInstance, xsInteger))
          .equals(XPathInteger.fromInt(0));
      check(castAtomic(XPathBoolean.trueInstance, xsString))
          .equals(const XPathString('true'));
    });

    test('casting between binary types', () {
      final hex = XPathBinary.fromHex('48656C6C6F'); // "Hello"
      final b64 = castAtomic(hex, xsBase64Binary);
      check(b64).isA<XPathBinary>();
      check(b64.type).equals(xsBase64Binary);
      check(b64.stringValue).equals('SGVsbG8=');

      final hexBack = castAtomic(b64, xsHexBinary);
      check(hexBack).equals(hex);
    });

    test('target integer subtype bounds validation', () {
      check(castAtomic(XPathInteger.fromInt(100), xsByte))
          .equals(XPathInteger.fromInt(100, xsByte));
      check(() => castAtomic(XPathInteger.fromInt(200), xsByte))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(XPathInteger.fromInt(-5), xsNonNegativeInteger))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(XPathInteger.fromInt(0), xsPositiveInteger))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('disallowed cast throws evaluation exception', () {
      check(() => castAtomic(XPathBoolean.trueInstance, xsDate))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(const XPathString('foo'), xsAnyAtomicType))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(const XPathString('foo'), xsItem))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('duration casting rules', () {
      const ymd = XPathDuration.yearMonth(14); // P1Y2M
      const dtd = XPathDuration.dayTime(90000000); // PT90S

      // Duration to numeric is disallowed
      check(() => castAtomic(ymd, xsDecimal))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(ymd, xsInteger))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(dtd, xsFloat))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => castAtomic(dtd, xsDouble))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());

      // Duration to duration is allowed
      final ymdToDtd = castAtomic(ymd, xsDayTimeDuration);
      check(ymdToDtd.stringValue).equals('PT0S');

      final dtdToYmd = castAtomic(dtd, xsYearMonthDuration);
      check(dtdToYmd.stringValue).equals('P0M');
    });

    test('float 32-bit rounding and bounds', () {
      // Underflow to zero
      final underflow = XPathDouble.parse('5.4321E-100', xsFloat);
      check(underflow.value).equals(0.0);
      check(underflow.stringValue).equals('0');

      // Overflow to infinity
      final overflow = XPathDouble.parse('1.0E40', xsFloat);
      check(overflow.value).equals(double.infinity);
      check(overflow.stringValue).equals('INF');

      // Single-precision rounding
      final rounded = castAtomic(
        XPathDecimal.parse('12678967.543233'),
        xsFloat,
      );
      check(rounded.stringValue).equals('1.2678968E7');

      // Negative zero
      final negZero = XPathDouble.parse('-0.0', xsFloat);
      check(negZero.stringValue).equals('-0');

      // +INF parsing
      final plusInf = XPathDouble.parse('+INF', xsFloat);
      check(plusInf.stringValue).equals('INF');
      final plusInfDouble = XPathDouble.parse('+INF', xsDouble);
      check(plusInfDouble.stringValue).equals('INF');
    });

    test('double and float canonical string representation', () {
      // Decimal range: [1e-6, 1e6)
      check(const XPathDouble(0.0).stringValue).equals('0');
      check(const XPathDouble(-0.0).stringValue).equals('-0');
      check(const XPathDouble(1.0).stringValue).equals('1');
      check(const XPathDouble(999999.0).stringValue).equals('999999');
      check(const XPathDouble(0.000001).stringValue).equals('0.000001');
      check(const XPathDouble(12.34).stringValue).equals('12.34');

      // Scientific range: magnitude < 1e-6 or >= 1e6
      check(const XPathDouble(1000000.0).stringValue).equals('1.0E6');
      check(const XPathDouble(-10000000.0).stringValue).equals('-1.0E7');
      check(const XPathDouble(1.26743233e15).stringValue)
          .equals('1.26743233E15');
      check(const XPathDouble(1e-7).stringValue).equals('1.0E-7');
      check(const XPathDouble(-1e-7).stringValue).equals('-1.0E-7');
    });

    test('XPathDecimal parsing with scientific notation', () {
      final d1 = XPathDecimal.parse('1e-7');
      check(d1.stringValue).equals('0.0000001');

      final d2 = XPathDecimal.parse('1.5e3');
      check(d2.stringValue).equals('1500');
    });

    test('casting boolean to float and decimal', () {
      check(castAtomic(XPathBoolean.trueInstance, xsDouble))
          .equals(const XPathDouble(1.0));
      check(castAtomic(XPathBoolean.falseInstance, xsDouble))
          .equals(const XPathDouble(0.0));
      check(castAtomic(XPathBoolean.trueInstance, xsDecimal).stringValue)
          .equals('1');
      check(castAtomic(XPathBoolean.falseInstance, xsDecimal).stringValue)
          .equals('0');
    });

    test('year out of range errors throw FODT0001', () {
      void expectYearError(String text, XPathType targetType) {
        check(() => castAtomic(XPathString(text), targetType))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FODT0001),
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
        check(() => castAtomic(XPathString(text), targetType))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
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

      check(() => castAtomic(const XPathString('1:2:3'), xsQName))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCA0002),
          );
    });

    test('additional casting branches', () {
      // Line 354: numeric to xsDecimal
      check(castAtomic(XPathInteger.fromInt(42), xsDecimal).stringValue)
          .equals('42');
      check(castAtomic(const XPathDouble(42.5), xsDecimal).stringValue)
          .equals('42.5');

      // Line 390-391: xsDateTime without timezone to xsDateTimeStamp
      check(
        () => castAtomic(
          XPathDateTime.tryParse('2020-01-01T12:00:00')!,
          xsDateTimeStamp,
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
      );

      // Line 414-416: duration to xsDuration
      final ymd = XPathDuration.tryParse('P1Y2M', xsYearMonthDuration)!;
      final dur = castAtomic(ymd, xsDuration);
      check(dur.type).equals(xsDuration);
      check(dur.stringValue).equals('P1Y2M');

      // string to xsAnyURI
      final uri = castAtomic(const XPathString('http://example.com'), xsAnyURI);
      check(uri.type).equals(xsAnyURI);
      check(uri.stringValue).equals('http://example.com');
    });

    test('duration disallowed casts throw XPTY0004', () {
      final ymd = XPathDuration.tryParse('P1Y2M', xsYearMonthDuration)!;
      check(() => castAtomic(ymd, xsInteger))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });
}
