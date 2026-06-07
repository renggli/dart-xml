import 'package:test/test.dart';
import 'package:xml/src/xpath/values/duration.dart';

class MockDuration extends XPathAbstractDuration {
  @override
  int? get years => null;
  @override
  int? get months => null;
  @override
  int? get days => null;
  @override
  int? get hours => null;
  @override
  int? get minutes => null;
  @override
  int? get seconds => null;
  @override
  int? get milliseconds => null;
  @override
  int? get microseconds => null;
  @override
  bool get isNegative => false;
  @override
  String toString() => 'Mock';
}

void main() {
  group('XPathAbstractDuration', () {
    test('toDuration mapping', () {
      const d = XPathDuration(
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
        milliseconds: 5,
        microseconds: 6,
        isNegative: true,
      );
      expect(
        d.toDuration(),
        const Duration(
          days: -1,
          hours: -2,
          minutes: -3,
          seconds: -4,
          milliseconds: -5,
          microseconds: -6,
        ),
      );
      const ym = XPathYearMonthDuration(12);
      expect(ym.toDuration(), Duration.zero);
    });
    test('mixed compareTo fallback', () {
      const d1 = XPathYearMonthDuration(12);
      const d2 = XPathDayTimeDuration(86400000000);
      expect(d1.compareTo(d2), isNotNull);
      expect(MockDuration().compareTo(MockDuration()), 0);
      expect(
        const XPathYearMonthDuration(
          12,
        ).compareTo(const XPathYearMonthDuration(24)),
        lessThan(0),
      );
      expect(
        const XPathDayTimeDuration(
          12,
        ).compareTo(const XPathDayTimeDuration(24)),
        lessThan(0),
      );
    });
  });

  group('XPathDuration', () {
    test('construction and getters', () {
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
      expect(d.years, 1);
      expect(d.months, 2);
      expect(d.days, 3);
      expect(d.hours, 4);
      expect(d.minutes, 5);
      expect(d.seconds, 6);
      expect(d.milliseconds, 7);
      expect(d.microseconds, 8);
      expect(d.isNegative, isTrue);
      expect(d.totalMonths, -14);
      expect(
        d.totalMicroseconds,
        -(((3 * 24 + 4) * 60 + 5) * 60 + 6) * 1000000 - 7008,
      );
    });
    test('fromValues construction', () {
      final d = XPathDuration.fromValues(14, 86400000000);
      expect(d.years, 1);
      expect(d.months, 2);
      expect(d.days, 1);
      expect(d.isNegative, isFalse);
      final dNeg = XPathDuration.fromValues(-14, -86400000000);
      expect(dNeg.isNegative, isTrue);
      expect(dNeg.years, 1);
      expect(dNeg.months, 2);
      expect(dNeg.days, 1);
    });
    test('fromDuration construction', () {
      final d = XPathDuration.fromDuration(const Duration(days: 2, hours: 3));
      expect(d.days, 2);
      expect(d.hours, 3);
      expect(d.isNegative, isFalse);
    });
    test('tryParse valid cases', () {
      expect(XPathDuration.tryParse('P1Y2M3DT4H5M6.007008S'), isNotNull);
      expect(XPathDuration.tryParse('-P1Y2M'), isNotNull);
      expect(XPathDuration.tryParse('PT4H'), isNotNull);
      expect(XPathDuration.tryParse('P0D'), isNotNull);
    });
    test('tryParse invalid cases', () {
      expect(XPathDuration.tryParse(''), isNull);
      expect(XPathDuration.tryParse('P'), isNull);
      expect(XPathDuration.tryParse('PT'), isNull);
      expect(XPathDuration.tryParse('1Y2M'), isNull);
    });
    test('equality and comparisons', () {
      const d1 = XPathDuration(years: 1, months: 2, days: 3);
      const d2 = XPathDuration(years: 1, months: 2, days: 3);
      const d3 = XPathDuration(years: 1, months: 3, days: 3);
      expect(d1 == d2, isTrue);
      expect(d1 == d3, isFalse);
      expect(d1 == const XPathYearMonthDuration(14), isFalse);
      expect(d1 == const XPathDayTimeDuration(259200000000), isFalse);
      expect(d1 == Object(), isFalse);
      expect(d1.hashCode, d2.hashCode);
      expect(d1.compareTo(d2), 0);
      expect(d1.compareTo(d3), lessThan(0));
      expect(d3.compareTo(d1), greaterThan(0));
      expect(d1.compareTo(const XPathYearMonthDuration(14)), greaterThan(0));
      expect(d1.compareTo(const XPathYearMonthDuration(15)), lessThan(0));
      expect(
        d1.compareTo(const XPathDayTimeDuration(259200000000)),
        greaterThan(0),
      );
      expect(
        d1.compareTo(const XPathDayTimeDuration(259200000001)),
        greaterThan(0),
      );
      const d4 = XPathDuration(days: 3);
      expect(d4.compareTo(const XPathDayTimeDuration(259200000000)), 0);
      expect(
        d4.compareTo(const XPathDayTimeDuration(259200000001)),
        lessThan(0),
      );
      expect(d1.compareTo(MockDuration()), greaterThan(0));
    });
    test('toString formatting', () {
      expect(const XPathDuration().toString(), 'PT0S');
      expect(
        const XPathDuration(
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 123,
          microseconds: 456,
        ).toString(),
        'P1Y2M3DT4H5M6.123456S',
      );
    });
  });

  group('XPathDayTimeDuration', () {
    test('construction and parsing', () {
      const d = XPathDayTimeDuration(93784005006);
      expect(d.years, isNull);
      expect(d.months, isNull);
      expect(d.days, 1);
      expect(d.hours, 2);
      expect(d.minutes, 3);
      expect(d.seconds, 4);
      expect(d.milliseconds, 5);
      expect(d.microseconds, 6);
      expect(d.isNegative, isFalse);
      expect(
        XPathDayTimeDuration.fromDuration(const Duration(days: 1)),
        const XPathDayTimeDuration(86400000000),
      );
      expect(XPathDayTimeDuration.tryParse('P1DT2H3M4S'), isNotNull);
      expect(XPathDayTimeDuration.tryParse('P1Y'), isNull);
      expect(XPathDayTimeDuration.tryParse('P'), isNull);
      expect(XPathDayTimeDuration.tryParse(''), isNull);
    });
    test('getters inUnits', () {
      const d = XPathDayTimeDuration(93784005006);
      expect(d.inDays, 1);
      expect(d.inHours, 26);
      expect(d.inMinutes, 1563);
      expect(d.inSeconds, 93784);
      expect(d.inMilliseconds, 93784005);
      expect(d.inMicroseconds, 93784005006);
    });
    test('operators and arithmetic', () {
      const d1 = XPathDayTimeDuration(86400000000);
      const d2 = XPathDayTimeDuration(172800000000);
      expect(d1.abs(), d1);
      expect(const XPathDayTimeDuration(-86400000000).abs(), d1);
      expect(d1 + d1, d2);
      expect(d2 - d1, d1);
      expect(d1 * 2, d2);
      expect(d2 ~/ 2, d1);
      expect(-d1, const XPathDayTimeDuration(-86400000000));
      expect(d1 < d2, isTrue);
      expect(d1 <= d1, isTrue);
      expect(d2 > d1, isTrue);
      expect(d2 >= d2, isTrue);
      expect(d1 == d1, isTrue);
      expect(d1 == const XPathDuration(days: 1), isTrue);
      expect(d1 == const XPathDuration(days: 2), isFalse);
      expect(d1 == Object(), isFalse);
      expect(d1.hashCode, d1.totalMicroseconds.hashCode);
    });
    test('toString formatting', () {
      expect(const XPathDayTimeDuration(0).toString(), 'PT0S');
      expect(
        const XPathDayTimeDuration(93784005006).toString(),
        'P1DT2H3M4.005006S',
      );
    });
  });

  group('XPathYearMonthDuration', () {
    test('construction and parsing', () {
      const ym = XPathYearMonthDuration(14);
      expect(ym.years, 1);
      expect(ym.months, 2);
      expect(ym.days, isNull);
      expect(ym.isNegative, isFalse);
      expect(XPathYearMonthDuration.tryParse('P1Y2M'), isNotNull);
      expect(XPathYearMonthDuration.tryParse('P1D'), isNull);
      expect(XPathYearMonthDuration.tryParse('P'), isNull);
      expect(XPathYearMonthDuration.tryParse(''), isNull);
    });
    test('operators and arithmetic', () {
      const y1 = XPathYearMonthDuration(12);
      const y2 = XPathYearMonthDuration(24);
      expect(y1 + y1, y2);
      expect(y2 - y1, y1);
      expect(y1 * 2, y2);
      expect(y2 ~/ 2, y1);
      expect(-y1, const XPathYearMonthDuration(-12));
      expect(y1 < y2, isTrue);
      expect(y1 <= y1, isTrue);
      expect(y2 > y1, isTrue);
      expect(y2 >= y2, isTrue);
      expect(y1 == y1, isTrue);
      expect(y1 == const XPathDuration(years: 1), isTrue);
      expect(y1 == const XPathDuration(years: 2), isFalse);
      expect(y1 == Object(), isFalse);
      expect(y2.divideByDuration(y1), 2.0);
      expect(y1.hashCode, y1.totalMonths.hashCode);
    });
    test('toString formatting', () {
      expect(const XPathYearMonthDuration(0).toString(), 'P0M');
      expect(const XPathYearMonthDuration(14).toString(), 'P1Y2M');
      expect(const XPathYearMonthDuration(-14).toString(), '-P1Y2M');
    });
  });
}
