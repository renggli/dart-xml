import 'package:test/test.dart';
import 'package:xml/src/xpath/xdm/atomic/duration.dart';
import 'package:xml/src/xpath/xdm/types.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathDuration', () {
    test('construction, getters and properties', () {
      const d = XPathDuration(
        years: 1,
        months: 2,
        days: 3,
        hours: 4,
        minutes: 5,
        seconds: 6,
        milliseconds: 7,
        microseconds: 8,
        isNegative: true,
      );
      expect(d.type, equals(xsDuration));
      expect(d.years, equals(1));
      expect(d.months, equals(2));
      expect(d.days, equals(3));
      expect(d.hours, equals(4));
      expect(d.minutes, equals(5));
      expect(d.seconds, equals(6));
      expect(d.milliseconds, equals(7));
      expect(d.microseconds, equals(8));
      expect(d.isNegative, isTrue);
      expect(d.totalMonths, equals(-14));
    });

    test('effectiveBooleanValue throws', () {
      const d = XPathDuration();
      expect(
        () => d.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });

    test('parsing tryParse', () {
      expect(XPathDuration.tryParse('P1Y2M3DT4H5M6S'), isNotNull);
      expect(XPathDuration.tryParse('-P1Y2M'), isNotNull);
      expect(XPathDuration.tryParse('PT0S'), isNotNull);
      expect(XPathDuration.tryParse('invalid'), isNull);
      expect(XPathDuration.tryParse('P'), isNull);
    });

    test('stringValue and toString formatting', () {
      expect(const XPathDuration().stringValue, equals('PT0S'));
      expect(
        const XPathDuration(years: 1, months: 2).stringValue,
        equals('P1Y2M'),
      );
      expect(
        const XPathDuration(days: 1, hours: 2, isNegative: true).stringValue,
        equals('-P1DT2H'),
      );
    });

    test('equality and comparisons', () {
      final d1 = XPathDuration.fromValues(12, 86400000000);
      final d2 = XPathDuration.fromValues(12, 86400000000);
      final d3 = XPathDuration.fromValues(24, 86400000000);

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
      expect(d1 == d3, isFalse);
      expect(d1.compareTo(d2), equals(0));
      expect(d1.compareTo(d3), lessThan(0));
    });
  });

  group('XPathDuration dayTime', () {
    test('construction, inUnits, and properties', () {
      const d = XPathDuration.dayTime(93784005006);
      expect(d.type, equals(xsDayTimeDuration));
      expect(d.inDays, equals(1));
      expect(d.inHours, equals(26));
      expect(d.inMinutes, equals(1563));
      expect(d.inSeconds, equals(93784));
      expect(d.inMilliseconds, equals(93784005));
      expect(d.inMicroseconds, equals(93784005006));
    });

    test('parsing tryParseDayTime', () {
      expect(XPathDuration.tryParseDayTime('P1DT2H3M4S'), isNotNull);
      expect(XPathDuration.tryParseDayTime('PT0.5S'), isNotNull);
      expect(XPathDuration.tryParseDayTime('P1Y'), isNull);
      expect(XPathDuration.tryParseDayTime('invalid'), isNull);
    });

    test('arithmetic operators', () {
      const d1 = XPathDuration.dayTime(86400000000);
      const d2 = XPathDuration.dayTime(172800000000);

      expect(d1 + d1, equals(d2));
      expect(d2 - d1, equals(d1));
      expect(d1 * 2, equals(d2));
      expect(d2 ~/ 2, equals(d1));
      expect(-d1, equals(const XPathDuration.dayTime(-86400000000)));
      expect(const XPathDuration.dayTime(-86400000000).abs(), equals(d1));
      expect(d1 < d2, isTrue);
      expect(d2 > d1, isTrue);
      expect(d1 <= d1, isTrue);
      expect(d2 >= d2, isTrue);
    });

    test('formatting stringValue', () {
      expect(const XPathDuration.dayTime(0).stringValue, equals('PT0S'));
      expect(
        const XPathDuration.dayTime(86400000000).stringValue,
        equals('P1D'),
      );
    });
  });

  group('XPathDuration yearMonth', () {
    test('construction and parsing', () {
      const ym = XPathDuration.yearMonth(14);
      expect(ym.type, equals(xsYearMonthDuration));
      expect(ym.years, equals(1));
      expect(ym.months, equals(2));
      expect(ym.totalMonths, equals(14));
      expect(XPathDuration.tryParseYearMonth('P1Y2M'), isNotNull);
      expect(XPathDuration.tryParseYearMonth('-P2Y'), isNotNull);
      expect(XPathDuration.tryParseYearMonth('P1D'), isNull);
      expect(XPathDuration.tryParseYearMonth('invalid'), isNull);
    });

    test('arithmetic operators', () {
      const y1 = XPathDuration.yearMonth(12);
      const y2 = XPathDuration.yearMonth(24);

      expect(y1 + y1, equals(y2));
      expect(y2 - y1, equals(y1));
      expect(y1 * 2, equals(y2));
      expect(y2 ~/ 2, equals(y1));
      expect(-y1, equals(const XPathDuration.yearMonth(-12)));
      expect(y2.divideByDuration(y1), equals(2.0));
      expect(y1 < y2, isTrue);
      expect(y2 > y1, isTrue);
    });

    test('formatting stringValue', () {
      expect(const XPathDuration.yearMonth(0).stringValue, equals('P0M'));
      expect(const XPathDuration.yearMonth(14).stringValue, equals('P1Y2M'));
      expect(const XPathDuration.yearMonth(-14).stringValue, equals('-P1Y2M'));
    });
  });
}
