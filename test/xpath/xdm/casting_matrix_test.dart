import 'package:test/test.dart';
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
      final hex = XPathHexBinary.fromHex('48656C6C6F'); // "Hello"
      final b64 = castAtomic(hex, xsBase64Binary);
      expect(b64, isA<XPathBase64Binary>());
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
  });
}
