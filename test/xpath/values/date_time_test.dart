import 'package:test/test.dart';
import 'package:xml/src/xpath/values/date_time.dart';

class MockDateTime extends XPathAbstractDateTime {
  @override
  int? get year => 2021;
  @override
  int? get month => 1;
  @override
  int? get day => 1;
  @override
  int? get hour => 0;
  @override
  int? get minute => 0;
  @override
  int? get second => 0;
  @override
  int? get millisecond => 0;
  @override
  int? get microsecond => 0;
  @override
  int? get timezoneOffsetMinutes => null;
  @override
  DateTime toDateTime() => DateTime(2021, 1, 1);
  @override
  XPathAbstractDateTime toUtc() => this;
  @override
  XPathAbstractDateTime toLocal() => this;
}

class ThrowingMockDateTime extends XPathAbstractDateTime {
  @override
  int? get year => throw UnimplementedError();
  @override
  int? get month => null;
  @override
  int? get day => null;
  @override
  int? get hour => null;
  @override
  int? get minute => null;
  @override
  int? get second => null;
  @override
  int? get millisecond => null;
  @override
  int? get microsecond => null;
  @override
  int? get timezoneOffsetMinutes => null;
  @override
  DateTime toDateTime() => throw UnimplementedError();
  @override
  XPathAbstractDateTime toUtc() => this;
  @override
  XPathAbstractDateTime toLocal() => this;
}

void main() {
  group('XPathAbstractDateTime', () {
    test('abstract fallback equality and types', () {
      const dt = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 0);
      expect(dt == Object(), isFalse);
      expect(dt.hashCode, isNotNull);
      expect(ThrowingMockDateTime() == ThrowingMockDateTime(), isFalse);
      final mock = MockDateTime();
      final added = mock.add(const Duration(days: 1));
      expect(added, isA<XPathDateTime>());
    });
  });

  group('XPathDateTime', () {
    test('properties and components', () {
      const dt = XPathDateTime(2021, 12, 25, 13, 14, 15, 123, 456, 120);
      expect(dt.year, 2021);
      expect(dt.month, 12);
      expect(dt.day, 25);
      expect(dt.hour, 13);
      expect(dt.minute, 14);
      expect(dt.second, 15);
      expect(dt.millisecond, 123);
      expect(dt.microsecond, 456);
      expect(dt.timezoneOffsetMinutes, 120);
      expect(dt.isUtc, isTrue);
      expect(dt.utcInstant, isA<DateTime>());
    });
    test('toDateTime with and without timezone', () {
      const dtUtc = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 0);
      expect(dtUtc.toDateTime().isUtc, isTrue);
      const dtTz = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 120);
      expect(dtTz.toDateTime().isUtc, isTrue);
      expect(dtTz.toDateTime().hour, 10);
      const dtLocal = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, null);
      expect(dtLocal.toDateTime().isUtc, isFalse);
      final fromDt = XPathDateTime.fromDateTime(DateTime.utc(2021), 60);
      expect(fromDt.timezoneOffsetMinutes, 60);
    });
    test('toUtc and toLocal conversions', () {
      const dt = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 120);
      final utc = dt.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.hour, 10);
      expect(utc.toUtc(), same(utc));
      final local = dt.toLocal();
      expect(
        local.timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      const dtLocal = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, null);
      expect(dtLocal.toUtc(), same(dtLocal));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final dtLocalOffset = XPathDateTime(
        2021,
        1,
        1,
        12,
        0,
        0,
        0,
        0,
        localOffset,
      );
      expect(dtLocalOffset.toLocal(), same(dtLocalOffset));
    });
    test('tryParse valid cases', () {
      expect(XPathDateTime.tryParse('2021-01-01T12:00:00'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:00Z'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:00+02:00'), isNotNull);
      expect(
        XPathDateTime.tryParse('-0004-01-01T12:00:00.123456-05:00'),
        isNotNull,
      );
    });
    test('tryParse invalid cases', () {
      expect(XPathDateTime.tryParse(''), isNull);
      expect(XPathDateTime.tryParse('2021-01-01'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:00+25:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:00+14:01'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:60'), isNull);
      expect(XPathDateTime.tryParse('2021-13-01T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-02-29T12:00:00'), isNull);
    });
    test('toString formatting', () {
      expect(
        const XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 0).toString(),
        '2021-01-01T12:00:00Z',
      );
      expect(
        const XPathDateTime(2021, 1, 1, 12, 0, 0, 123, 456, 60).toString(),
        '2021-01-01T12:00:00.123456+01:00',
      );
      expect(
        const XPathDateTime(-4, 1, 1, 12, 0, 0, 0, 0, -60).toString(),
        '-0004-01-01T12:00:00-01:00',
      );
    });
    test('equality and operators', () {
      const dt1 = XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 0);
      const dt2 = XPathDateTime(2021, 1, 1, 13, 0, 0, 0, 0, 0);
      expect(dt1 == dt2, isFalse);
      expect(dt1 == const XPathDateTime(2021, 1, 1, 12, 0, 0, 0, 0, 0), isTrue);
      expect(dt1.isBefore(dt2), isTrue);
      expect(dt2.isAfter(dt1), isTrue);
      expect(dt1.isAtSameMomentAs(dt1), isTrue);
      expect(dt1.add(const Duration(hours: 1)), dt2);
      expect(dt2.subtract(const Duration(hours: 1)), dt1);
      expect(dt2.difference(dt1), const Duration(hours: 1));
    });
  });

  group('XPathDateTimeStamp', () {
    test('construction and parsing', () {
      const dts = XPathDateTimeStamp(2021, 1, 1, 12, 0, 0, 0, 0, 0);
      expect(dts.timezoneOffsetMinutes, 0);
      final fromDt = XPathDateTimeStamp.fromDateTime(DateTime.utc(2021), 60);
      expect(fromDt.timezoneOffsetMinutes, 60);
      expect(XPathDateTimeStamp.tryParse('2021-01-01T12:00:00Z'), isNotNull);
      expect(XPathDateTimeStamp.tryParse('2021-01-01T12:00:00'), isNull);
      expect(XPathDateTimeStamp.tryParse('2021-01-01T12:00:00+25:00'), isNull);
    });
    test('toUtc and toLocal', () {
      const dts = XPathDateTimeStamp(2021, 1, 1, 12, 0, 0, 0, 0, 60);
      expect(dts.toUtc().timezoneOffsetMinutes, 0);
      expect(dts.toUtc(), isA<XPathDateTimeStamp>());
      expect(
        dts.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(dts.toLocal(), isA<XPathDateTimeStamp>());
      const dtsUtc = XPathDateTimeStamp(2021, 1, 1, 12, 0, 0, 0, 0, 0);
      expect(dtsUtc.toUtc(), same(dtsUtc));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final dtsLocal = XPathDateTimeStamp(
        2021,
        1,
        1,
        12,
        0,
        0,
        0,
        0,
        localOffset,
      );
      expect(dtsLocal.toLocal(), same(dtsLocal));
    });
  });

  group('XPathDate', () {
    test('properties and parsing', () {
      const d = XPathDate(2021, 12, 25, 0);
      expect(d.year, 2021);
      expect(d.month, 12);
      expect(d.day, 25);
      expect(d.hour, isNull);
      expect(d.minute, isNull);
      expect(d.second, isNull);
      expect(d.millisecond, isNull);
      expect(d.microsecond, isNull);
      expect(XPathDate.tryParse('2021-12-25'), isNotNull);
      expect(XPathDate.tryParse('2021-12-25Z'), isNotNull);
      expect(XPathDate.tryParse('2021-12-25+02:00'), isNotNull);
      expect(XPathDate.tryParse('2021-12-25+25:00'), isNull);
      expect(XPathDate.tryParse('2021-12'), isNull);
      final fromDt = XPathDate.fromDateTime(DateTime.utc(2021, 12, 25), 60);
      expect(fromDt.year, 2021);
      expect(fromDt.timezoneOffsetMinutes, 60);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const d = XPathDate(2021, 12, 25, 60);
      expect(d.toDateTime(), isA<DateTime>());
      final utc = d.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        d.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(d.toString(), '2021-12-25+01:00');
      const dNoTz = XPathDate(2021, 12, 25, null);
      expect(dNoTz.toDateTime().isUtc, isFalse);
      expect(dNoTz.toUtc(), same(dNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final dLocal = XPathDate(2021, 12, 25, localOffset);
      expect(dLocal.toLocal(), same(dLocal));
    });
    test('add and subtract and difference', () {
      const d = XPathDate(2021, 12, 25, 0);
      final added = d.add(const Duration(days: 1));
      expect(added, const XPathDate(2021, 12, 26, 0));
      final subtracted = d.subtract(const Duration(days: 1));
      expect(subtracted, const XPathDate(2021, 12, 24, 0));
      expect(added.difference(d), const Duration(days: 1));
    });
  });

  group('XPathTime', () {
    test('properties and parsing', () {
      const t = XPathTime(13, 14, 15, 123, 456, 0);
      expect(t.hour, 13);
      expect(t.minute, 14);
      expect(t.second, 15);
      expect(t.millisecond, 123);
      expect(t.microsecond, 456);
      expect(t.year, isNull);
      expect(XPathTime.tryParse('13:14:15'), isNotNull);
      expect(XPathTime.tryParse('13:14:15Z'), isNotNull);
      expect(XPathTime.tryParse('13:14:15.123456+02:00'), isNotNull);
      expect(XPathTime.tryParse('13:14:15+25:00'), isNull);
      expect(XPathTime.tryParse('13:14'), isNull);
      final fromDt = XPathTime.fromDateTime(
        DateTime.utc(1970, 1, 1, 13, 14, 15),
        60,
      );
      expect(fromDt.hour, 13);
      expect(fromDt.timezoneOffsetMinutes, 60);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const t = XPathTime(13, 14, 15, 123, 456, 60);
      expect(t.toDateTime(), isA<DateTime>());
      final utc = t.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        t.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(t.toString(), '13:14:15.123456+01:00');
      const tNoTz = XPathTime(13, 14, 15, 0, 0, null);
      expect(tNoTz.toDateTime().isUtc, isFalse);
      expect(tNoTz.toUtc(), same(tNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final tLocal = XPathTime(13, 14, 15, 0, 0, localOffset);
      expect(tLocal.toLocal(), same(tLocal));
    });
    test('add and subtract and difference', () {
      const t = XPathTime(13, 14, 15, 0, 0, 0);
      final added = t.add(const Duration(hours: 1));
      expect(added, const XPathTime(14, 14, 15, 0, 0, 0));
      final subtracted = t.subtract(const Duration(hours: 1));
      expect(subtracted, const XPathTime(12, 14, 15, 0, 0, 0));
      expect(added.difference(t), const Duration(hours: 1));
    });
  });

  group('XPathYearMonth', () {
    test('properties and parsing', () {
      const ym = XPathYearMonth(2021, 12, 0);
      expect(ym.year, 2021);
      expect(ym.month, 12);
      expect(ym.day, isNull);
      expect(XPathYearMonth.tryParse('2021-12'), isNotNull);
      expect(XPathYearMonth.tryParse('2021-12Z'), isNotNull);
      expect(XPathYearMonth.tryParse('2021-12+25:00'), isNull);
      expect(XPathYearMonth.tryParse('2021'), isNull);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const ym = XPathYearMonth(2021, 12, 60);
      expect(ym.toDateTime(), isA<DateTime>());
      final utc = ym.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        ym.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(ym.toString(), '2021-12+01:00');
      const ymNoTz = XPathYearMonth(2021, 12, null);
      expect(ymNoTz.toDateTime().isUtc, isFalse);
      expect(ymNoTz.toUtc(), same(ymNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final ymLocal = XPathYearMonth(2021, 12, localOffset);
      expect(ymLocal.toLocal(), same(ymLocal));
    });
    test('add and subtract and difference', () {
      const ym = XPathYearMonth(2021, 12, 0);
      final added = ym.add(const Duration(days: 31));
      expect(added, const XPathYearMonth(2022, 1, 0));
      final subtracted = ym.subtract(const Duration(days: 30));
      expect(subtracted, const XPathYearMonth(2021, 11, 0));
      expect(added.difference(ym), const Duration(days: 31));
    });
  });

  group('XPathYear', () {
    test('properties and parsing', () {
      const y = XPathYear(2021, 0);
      expect(y.year, 2021);
      expect(y.month, isNull);
      expect(XPathYear.tryParse('2021'), isNotNull);
      expect(XPathYear.tryParse('2021Z'), isNotNull);
      expect(XPathYear.tryParse('2021+25:00'), isNull);
      expect(XPathYear.tryParse('20'), isNull);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const y = XPathYear(2021, 60);
      expect(y.toDateTime(), isA<DateTime>());
      final utc = y.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        y.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(y.toString(), '2021+01:00');
      const yNoTz = XPathYear(2021, null);
      expect(yNoTz.toDateTime().isUtc, isFalse);
      expect(yNoTz.toUtc(), same(yNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final yLocal = XPathYear(2021, localOffset);
      expect(yLocal.toLocal(), same(yLocal));
    });
    test('add and subtract and difference', () {
      const y = XPathYear(2021, 0);
      final added = y.add(const Duration(days: 365));
      expect(added, const XPathYear(2022, 0));
      final subtracted = y.subtract(const Duration(days: 365));
      expect(subtracted, const XPathYear(2020, 0));
      expect(added.difference(y), const Duration(days: 365));
    });
  });

  group('XPathMonthDay', () {
    test('properties and parsing', () {
      const md = XPathMonthDay(12, 25, 0);
      expect(md.month, 12);
      expect(md.day, 25);
      expect(md.year, isNull);
      expect(XPathMonthDay.tryParse('--12-25'), isNotNull);
      expect(XPathMonthDay.tryParse('--12-25Z'), isNotNull);
      expect(XPathMonthDay.tryParse('--12-25+25:00'), isNull);
      expect(XPathMonthDay.tryParse('--12'), isNull);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const md = XPathMonthDay(12, 25, 60);
      expect(md.toDateTime(), isA<DateTime>());
      final utc = md.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        md.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(md.toString(), '--12-25+01:00');
      const mdNoTz = XPathMonthDay(12, 25, null);
      expect(mdNoTz.toDateTime().isUtc, isFalse);
      expect(mdNoTz.toUtc(), same(mdNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final mdLocal = XPathMonthDay(12, 25, localOffset);
      expect(mdLocal.toLocal(), same(mdLocal));
    });
    test('add and subtract and difference', () {
      const md = XPathMonthDay(12, 25, 0);
      final added = md.add(const Duration(days: 1));
      expect(added, const XPathMonthDay(12, 26, 0));
      final subtracted = md.subtract(const Duration(days: 1));
      expect(subtracted, const XPathMonthDay(12, 24, 0));
      expect(added.difference(md), const Duration(days: 1));
    });
  });

  group('XPathMonth', () {
    test('properties and parsing', () {
      const m = XPathMonth(12, 0);
      expect(m.month, 12);
      expect(m.year, isNull);
      expect(XPathMonth.tryParse('--12'), isNotNull);
      expect(XPathMonth.tryParse('--12Z'), isNotNull);
      expect(XPathMonth.tryParse('--12+25:00'), isNull);
      expect(XPathMonth.tryParse('--'), isNull);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const m = XPathMonth(12, 60);
      expect(m.toDateTime(), isA<DateTime>());
      final utc = m.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        m.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(m.toString(), '--12+01:00');
      const mNoTz = XPathMonth(12, null);
      expect(mNoTz.toDateTime().isUtc, isFalse);
      expect(mNoTz.toUtc(), same(mNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final mLocal = XPathMonth(12, localOffset);
      expect(mLocal.toLocal(), same(mLocal));
    });
    test('add and subtract and difference', () {
      const m = XPathMonth(12, 0);
      final added = m.add(const Duration(days: 31));
      expect(added, const XPathMonth(1, 0));
      final subtracted = m.subtract(const Duration(days: 30));
      expect(subtracted, const XPathMonth(11, 0));
      expect(added.difference(m), const Duration(days: -334));
    });
  });

  group('XPathDay', () {
    test('properties and parsing', () {
      const d = XPathDay(25, 0);
      expect(d.day, 25);
      expect(d.year, isNull);
      expect(XPathDay.tryParse('---25'), isNotNull);
      expect(XPathDay.tryParse('---25Z'), isNotNull);
      expect(XPathDay.tryParse('---25+25:00'), isNull);
      expect(XPathDay.tryParse('---'), isNull);
    });
    test('toDateTime, toUtc, toLocal, toString', () {
      const d = XPathDay(25, 60);
      expect(d.toDateTime(), isA<DateTime>());
      final utc = d.toUtc();
      expect(utc.timezoneOffsetMinutes, 0);
      expect(utc.toUtc(), same(utc));
      expect(
        d.toLocal().timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
      expect(d.toString(), '---25+01:00');
      const dNoTz = XPathDay(25, null);
      expect(dNoTz.toDateTime().isUtc, isFalse);
      expect(dNoTz.toUtc(), same(dNoTz));
      final localOffset = DateTime.now().timeZoneOffset.inMinutes;
      final dLocal = XPathDay(25, localOffset);
      expect(dLocal.toLocal(), same(dLocal));
    });
    test('add and subtract and difference', () {
      const d = XPathDay(25, 0);
      final added = d.add(const Duration(days: 1));
      expect(added, const XPathDay(26, 0));
      final subtracted = d.subtract(const Duration(days: 1));
      expect(subtracted, const XPathDay(24, 0));
      expect(added.difference(d), const Duration(days: 1));
    });
  });

  group('Validation helper', () {
    test('leap years', () {
      expect(XPathDateTime.tryParse('2000-02-29T12:00:00'), isNotNull);
      expect(XPathDateTime.tryParse('1900-02-29T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2004-02-29T12:00:00'), isNotNull);
      expect(XPathDateTime.tryParse('2001-02-29T12:00:00'), isNull);
    });
    test('invalid days per month', () {
      expect(XPathDateTime.tryParse('2021-04-31T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-02-30T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-00-01T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-00T12:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-32T12:00:00'), isNull);
    });
    test('invalid hours, minutes, seconds', () {
      expect(XPathDateTime.tryParse('2021-01-01T25:00:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T24:01:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T24:00:01'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:60:00'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T12:00:60'), isNull);
      expect(XPathDateTime.tryParse('2021-01-01T24:00:00'), isNotNull);
    });
  });
}
