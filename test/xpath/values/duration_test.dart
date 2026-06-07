import 'package:test/test.dart';
import 'package:xml/src/xpath/values/duration.dart';

void main() {
  group('XPathDuration value tests', () {
    test('XPathDuration construction and equality', () {
      const d1 = XPathDuration(months: 12, dayTime: Duration.zero);
      const d2 = XPathDuration(months: 12, dayTime: Duration.zero);
      const d3 = XPathDuration(months: 0, dayTime: Duration(days: 365));
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode);
      expect(d1 == d3, isFalse);
      expect(d1.isNegative, isFalse);
      expect(
        const XPathDuration(months: -1, dayTime: Duration.zero).isNegative,
        isTrue,
      );
    });

    test('XPathDayTimeDuration getters', () {
      final d = XPathDayTimeDuration(
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
          microseconds: 6,
        ),
      );
      expect(d.inDays, 1);
      expect(d.inHours, 26);
      expect(d.inMinutes, 1563);
      expect(d.inSeconds, 93784);
      expect(d.inMilliseconds, 93784005);
      expect(d.inMicroseconds, 93784005006);
      expect(d.isNegative, isFalse);
      expect(XPathDayTimeDuration(const Duration(days: -1)).isNegative, isTrue);
    });

    test('XPathDayTimeDuration operators', () {
      final d1 = XPathDayTimeDuration(const Duration(days: 1));
      final d2 = XPathDayTimeDuration(const Duration(days: 2));
      expect(d2.abs(), d2);
      expect(XPathDayTimeDuration(const Duration(days: -2)).abs(), d2);
      expect(d1 + const Duration(days: 1), d2);
      expect(d2 - const Duration(days: 1), d1);
      expect(d1 * 2, d2);
      expect(d2 ~/ 2, d1);
      expect(-d1, XPathDayTimeDuration(const Duration(days: -1)));
      expect(d1 < const Duration(days: 2), isTrue);
      expect(d1 <= const Duration(days: 1), isTrue);
      expect(d2 > const Duration(days: 1), isTrue);
      expect(d2 >= const Duration(days: 2), isTrue);
      expect(d1 == const Duration(days: 1), isTrue);
      expect(d1.hashCode, isNotNull);
    });

    test('XPathYearMonthDuration operators', () {
      final y1 = XPathYearMonthDuration(12);
      final y2 = XPathYearMonthDuration(24);
      expect(y1 + XPathYearMonthDuration(12), y2);
      expect(y2 - XPathYearMonthDuration(12), y1);
      expect(y1 * 2, y2);
      expect(y2 ~/ 2, y1);
      expect(y1 < y2, isTrue);
      expect(y1 <= y1, isTrue);
      expect(y2 > y1, isTrue);
      expect(y2 >= y2, isTrue);
      expect(-y1, XPathYearMonthDuration(-12));
      expect(y2.divideByDuration(y1), 2.0);
      expect(y1.hashCode, isNotNull);
      expect(y1 == XPathYearMonthDuration(12), isTrue);
    });
  });
}
