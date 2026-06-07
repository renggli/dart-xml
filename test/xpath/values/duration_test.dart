import 'package:test/test.dart';
import 'package:xml/src/xpath/values/duration.dart';

void main() {
  group('XPathDuration value tests', () {
    test('XPathDuration construction and equality', () {
      const d1 = XPathDuration(months: 12);
      const d2 = XPathDuration(months: 12);
      const d3 = XPathDuration(days: 365);
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode);
      expect(d1 == d3, isFalse);
      expect(d1.isNegative, isFalse);
      expect(
        const XPathDuration(months: 1, isNegative: true).isNegative,
        isTrue,
      );
    });

    test('XPathDayTimeDuration getters', () {
      const d = XPathDayTimeDuration(93784005006);
      expect(d.inDays, 1);
      expect(d.inHours, 26);
      expect(d.inMinutes, 1563);
      expect(d.inSeconds, 93784);
      expect(d.inMilliseconds, 93784005);
      expect(d.inMicroseconds, 93784005006);
      expect(d.isNegative, isFalse);
      expect(const XPathDayTimeDuration(-86400000000).isNegative, isTrue);
    });

    test('XPathDayTimeDuration operators', () {
      const d1 = XPathDayTimeDuration(86400000000);
      const d2 = XPathDayTimeDuration(172800000000);
      expect(d2.abs(), d2);
      expect(const XPathDayTimeDuration(-172800000000).abs(), d2);
      expect(d1 + const XPathDayTimeDuration(86400000000), d2);
      expect(d2 - const XPathDayTimeDuration(86400000000), d1);
      expect(d1 * 2, d2);
      expect(d2 ~/ 2, d1);
      expect(-d1, const XPathDayTimeDuration(-86400000000));
      expect(d1 < const XPathDayTimeDuration(172800000000), isTrue);
      expect(d1 <= const XPathDayTimeDuration(86400000000), isTrue);
      expect(d2 > const XPathDayTimeDuration(86400000000), isTrue);
      expect(d2 >= const XPathDayTimeDuration(172800000000), isTrue);
      expect(d1 == const XPathDayTimeDuration(86400000000), isTrue);
      expect(d1.hashCode, isNotNull);
    });

    test('XPathYearMonthDuration operators', () {
      const y1 = XPathYearMonthDuration(12);
      const y2 = XPathYearMonthDuration(24);
      expect(y1 + const XPathYearMonthDuration(12), y2);
      expect(y2 - const XPathYearMonthDuration(12), y1);
      expect(y1 * 2, y2);
      expect(y2 ~/ 2, y1);
      expect(y1 < y2, isTrue);
      expect(y1 <= y1, isTrue);
      expect(y2 > y1, isTrue);
      expect(y2 >= y2, isTrue);
      expect(-y1, const XPathYearMonthDuration(-12));
      expect(y2.divideByDuration(y1), 2.0);
      expect(y1.hashCode, isNotNull);
      expect(y1 == const XPathYearMonthDuration(12), isTrue);
    });
  });
}
