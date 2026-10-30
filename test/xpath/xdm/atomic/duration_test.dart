import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

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
      check(d.type).equals(xsDuration);
      check(d.years).equals(1);
      check(d.months).equals(2);
      check(d.days).equals(3);
      check(d.hours).equals(4);
      check(d.minutes).equals(5);
      check(d.seconds).equals(6);
      check(d.milliseconds).equals(7);
      check(d.microseconds).equals(8);
      check(d.isNegative).isTrue();
      check(d.totalMonths).equals(-14);
    });

    test('effectiveBooleanValue throws', () {
      const d = XPathDuration();
      check(() => d.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('parsing tryParse', () {
      check(XPathDuration.tryParse('P1Y2M3DT4H5M6S')).isNotNull();
      check(XPathDuration.tryParse('-P1Y2M')).isNotNull();
      check(XPathDuration.tryParse('PT0S')).isNotNull();
      check(XPathDuration.tryParse('invalid')).isNull();
      check(XPathDuration.tryParse('P')).isNull();
    });

    test('stringValue and toString formatting', () {
      check(const XPathDuration().stringValue).equals('PT0S');
      check(const XPathDuration(years: 1, months: 2).stringValue)
          .equals('P1Y2M');
      check(
        const XPathDuration(days: 1, hours: 2, isNegative: true).stringValue,
      ).equals('-P1DT2H');
    });

    test('equality and comparisons', () {
      final d1 = XPathDuration.fromValues(12, 86400000000);
      final d2 = XPathDuration.fromValues(12, 86400000000);
      final d3 = XPathDuration.fromValues(24, 86400000000);

      check(d1).equals(d2);
      check(d1.hashCode).equals(d2.hashCode);
      check(d1.value).equals(d1);
      check(d1 == d3).isFalse();
      check(d1.compareTo(d2)).equals(0);
      check(d1.compareTo(d3)).isLessThan(0);
      check(() => d1.compareTo(const XPathString('invalid')))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('tryParse with xsDayTimeDuration type', () {
      final d = XPathDuration.tryParse('PT1H', xsDayTimeDuration);
      check(d).isNotNull();
      check(d!.type).equals(xsDayTimeDuration);
      check(d.inHours).equals(1);
    });
  });

  group('XPathDuration dayTime', () {
    test('construction, inUnits, and properties', () {
      const d = XPathDuration.dayTime(93784005006);
      check(d.type).equals(xsDayTimeDuration);
      check(d.inDays).equals(1);
      check(d.inHours).equals(26);
      check(d.inMinutes).equals(1563);
      check(d.inSeconds).equals(93784);
      check(d.inMilliseconds).equals(93784005);
      check(d.inMicroseconds).equals(93784005006);
    });

    test('parsing tryParseDayTime', () {
      check(XPathDuration.tryParseDayTime('P1DT2H3M4S')).isNotNull();
      check(XPathDuration.tryParseDayTime('PT0.5S')).isNotNull();
      check(XPathDuration.tryParseDayTime('P1Y')).isNull();
      check(XPathDuration.tryParseDayTime('invalid')).isNull();
    });

    test('arithmetic operators', () {
      const d1 = XPathDuration.dayTime(86400000000);
      const d2 = XPathDuration.dayTime(172800000000);

      check(d1 + d1).equals(d2);
      check(d2 - d1).equals(d1);
      check(d1 * 2).equals(d2);
      check(d2 ~/ 2).equals(d1);
      check(-d1).equals(const XPathDuration.dayTime(-86400000000));
      check(const XPathDuration.dayTime(-86400000000).abs()).equals(d1);
      check(d1 < d2).isTrue();
      check(d2 > d1).isTrue();
      check(d1 <= d1).isTrue();
      check(d2 >= d2).isTrue();
    });

    test('formatting stringValue', () {
      check(const XPathDuration.dayTime(0).stringValue).equals('PT0S');
      check(const XPathDuration.dayTime(86400000000).stringValue).equals('P1D');
    });
  });

  group('XPathDuration yearMonth', () {
    test('construction and parsing', () {
      const ym = XPathDuration.yearMonth(14);
      check(ym.type).equals(xsYearMonthDuration);
      check(ym.years).equals(1);
      check(ym.months).equals(2);
      check(ym.totalMonths).equals(14);
      check(XPathDuration.tryParseYearMonth('P1Y2M')).isNotNull();
      check(XPathDuration.tryParseYearMonth('-P2Y')).isNotNull();
      check(XPathDuration.tryParseYearMonth('P1D')).isNull();
      check(XPathDuration.tryParseYearMonth('invalid')).isNull();
    });

    test('arithmetic operators', () {
      const y1 = XPathDuration.yearMonth(12);
      const y2 = XPathDuration.yearMonth(24);

      check(y1 + y1).equals(y2);
      check(y2 - y1).equals(y1);
      check(y1 * 2).equals(y2);
      check(y2 / 2).equals(y1);
      check(y2 / 1.5).equals(const XPathDuration.yearMonth(16));
      check(() => y2 / 0).throws<ArgumentError>();
      check(y2 ~/ 2).equals(y1);
      check(-y1).equals(const XPathDuration.yearMonth(-12));
      check(y2.divideByDuration(y1)).equals(2.0);
      check(y1 < y2).isTrue();
      check(y2 > y1).isTrue();
    });

    test('formatting stringValue', () {
      check(const XPathDuration.yearMonth(0).stringValue).equals('P0M');
      check(const XPathDuration.yearMonth(14).stringValue).equals('P1Y2M');
      check(const XPathDuration.yearMonth(-14).stringValue).equals('-P1Y2M');
    });
  });
}
