import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathDateTime', () {
    test('properties, toDateTime and formatting', () {
      const dt = XPathDateTime(2021, 1, 2, 3, 4, 5, 6, 7, 0);
      check(dt.type).equals(xsDateTime);
      check(dt.year).equals(2021);
      check(dt.month).equals(1);
      check(dt.day).equals(2);
      check(dt.hour).equals(3);
      check(dt.minute).equals(4);
      check(dt.second).equals(5);
      check(dt.millisecond).equals(6);
      check(dt.microsecond).equals(7);
      check(dt.timezoneOffsetMinutes).equals(0);
      check(dt.isUtc).isTrue();
      check(dt.toString()).equals('2021-01-02T03:04:05.006007Z');

      final d = dt.toDateTime();
      check(d.isUtc).isTrue();
      check(d.year).equals(2021);
    });

    test('effectiveBooleanValue throws', () {
      const dt = XPathDateTime(2021, 1, 1, 0, 0, 0);
      check(() => dt.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('parsing tryParse valid and invalid', () {
      check(XPathDateTime.tryParse('2021-01-02T03:04:05Z')).isNotNull();
      check(XPathDateTime.tryParse('2021-01-02T03:04:05+02:00')).isNotNull();
      check(XPathDateTime.tryParse('2021-01-02T03:04:05')).isNotNull();
      check(XPathDateTime.tryParse('2021-01-02T24:00:00')).isNotNull();
      check(XPathDateTime.tryParse('2021-01-02')).isNull();
      check(XPathDateTime.tryParse('invalid')).isNull();
    });

    test('comparison, before, after, equality', () {
      final dt1 = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt2 = XPathDateTime.tryParse('2021-01-01T13:00:00Z')!;
      final dt1Equiv = XPathDateTime.tryParse('2021-01-01T14:00:00+02:00')!;

      check(dt1.isBefore(dt2)).isTrue();
      check(dt2.isAfter(dt1)).isTrue();
      check(dt1.isAtSameMomentAs(dt1Equiv)).isTrue();
      check(dt1 == dt1Equiv).isTrue();
      check(dt1 == dt2).isFalse();
    });

    test('add, subtract, difference', () {
      final dt = XPathDateTime.tryParse('2021-01-01T00:00:00Z')!;
      final added = dt.add(const Duration(days: 1));
      check(added.day).equals(2);
      final subtracted = dt.subtract(const Duration(days: 1));
      check(subtracted.day).equals(31);
      check(added.difference(dt)).equals(const Duration(days: 1));
    });
  });

  group('XPathDateTimeStamp', () {
    test('parsing requires timezone offset', () {
      check(XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05Z'))
          .isNotNull();
      check(XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05+05:00'))
          .isNotNull();
      check(XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05'))
          .isNull();
    });
  });

  group('XPathDateTime date', () {
    test('properties, parsing and formatting', () {
      const date = XPathDateTime.date(2021, 5, 20, 0);
      check(date.type).equals(xsDate);
      check(date.year).equals(2021);
      check(date.month).equals(5);
      check(date.day).equals(20);
      check(date.toString()).equals('2021-05-20Z');

      check(XPathDateTime.tryParseDate('2021-05-20')).isNotNull();
      check(XPathDateTime.tryParseDate('2021-05-20-05:00')).isNotNull();
      check(XPathDateTime.tryParseDate('2021-02-30')).isNull();
    });
  });

  group('XPathDateTime time', () {
    test('properties, parsing and formatting', () {
      const time = XPathDateTime.time(12, 34, 56, 0, 0, 0);
      check(time.type).equals(xsTime);
      check(time.hour).equals(12);
      check(time.minute).equals(34);
      check(time.second).equals(56);
      check(time.toString()).equals('12:34:56Z');

      check(XPathDateTime.tryParseTime('12:34:56')).isNotNull();
      check(XPathDateTime.tryParseTime('24:00:00')).isNotNull();
      check(XPathDateTime.tryParseTime('24:01:00')).isNull();
    });
  });

  group('XPathDateTime partial temporal types', () {
    test('XPathDateTime yearMonth', () {
      const ym = XPathDateTime.yearMonth(2021, 12, 0);
      check(ym.type).equals(xsGYearMonth);
      check(ym.year).equals(2021);
      check(ym.month).equals(12);
      check(ym.toString()).equals('2021-12Z');
      check(XPathDateTime.tryParseYearMonth('2021-12')).isNotNull();
      check(XPathDateTime.tryParseYearMonth('2021-13')).isNull();
    });

    test('XPathDateTime year', () {
      const y = XPathDateTime.year(2021, 0);
      check(y.type).equals(xsGYear);
      check(y.year).equals(2021);
      check(y.toString()).equals('2021Z');
      check(XPathDateTime.tryParseYear('2021')).isNotNull();
      check(XPathDateTime.tryParseYear('20')).isNull();
    });

    test('XPathDateTime monthDay', () {
      const md = XPathDateTime.monthDay(12, 25, 0);
      check(md.type).equals(xsGMonthDay);
      check(md.month).equals(12);
      check(md.day).equals(25);
      check(md.toString()).equals('--12-25Z');
      check(XPathDateTime.tryParseMonthDay('--12-25')).isNotNull();
      check(XPathDateTime.tryParseMonthDay('--12-32')).isNull();
    });

    test('XPathDateTime month', () {
      const m = XPathDateTime.month(5, 0);
      check(m.type).equals(xsGMonth);
      check(m.month).equals(5);
      check(m.toString()).equals('--05Z');
      check(XPathDateTime.tryParseMonth('--05')).isNotNull();
      check(XPathDateTime.tryParseMonth('--13')).isNull();
    });

    test('XPathDateTime day', () {
      const d = XPathDateTime.day(15, 0);
      check(d.type).equals(xsGDay);
      check(d.day).equals(15);
      check(d.toString()).equals('---15Z');
      check(XPathDateTime.tryParseDay('---15')).isNotNull();
      check(XPathDateTime.tryParseDay('---32')).isNull();
    });

    test('toLocal conversion and negative timezone offsets', () {
      final dtUtc = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dtLocal = dtUtc.toLocal();
      check(dtLocal.timezoneOffsetMinutes).isNotNull();
      // toLocal on same offset returns itself
      check(dtLocal.toLocal().timezoneOffsetMinutes)
          .equals(dtLocal.timezoneOffsetMinutes);

      const dtNeg = XPathDateTime.date(2021, 5, 20, -300);
      check(dtNeg.toString()).equals('2021-05-20-05:00');

      const timeNeg = XPathDateTime.time(12, 30, 0, 0, 0, -330);
      check(timeNeg.toString()).equals('12:30:00-05:30');
    });

    test('hashCode and equality', () {
      final dt1 = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt1Clone = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt2 = XPathDateTime.tryParse('2021-01-01T14:00:00+02:00')!;
      check(dt1.hashCode).equals(dt1Clone.hashCode);
      check(dt1 == dt2).isTrue();
    });

    test('calendar validations for days in months', () {
      check(XPathDateTime.tryParseDate('2021-04-30')).isNotNull();
      check(XPathDateTime.tryParseDate('2021-04-31')).isNull();
      check(XPathDateTime.tryParseDate('2020-02-29')).isNotNull();
      check(XPathDateTime.tryParseDate('2021-02-29')).isNull();
      check(XPathDateTime.tryParseDate('2021-06-31')).isNull();
      check(XPathDateTime.tryParseDate('2021-09-31')).isNull();
      check(XPathDateTime.tryParseDate('2021-11-31')).isNull();
    });

    test('fromDateTime with xsTime, value getter, and negative year', () {
      final now = DateTime.utc(2023, 5, 10, 14, 30, 45, 12, 34);
      final t = XPathDateTime.fromDateTime(now, 0, xsTime);
      check(t.type).equals(xsTime);
      check(t.value).equals(t);

      const negDate = XPathDateTime.date(-42, 1, 1);
      check(negDate.toString()).equals('-0042-01-01');
    });

    test('xsDateTime and xsDateTimeStamp comparison and hashCode fallback', () {
      final dt = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dtStamp = XPathDateTime.tryParse(
        '2021-01-01T12:00:00Z',
        xsDateTimeStamp,
      )!;
      check(dt == dtStamp).isTrue();
      check(dt.compareTo(dtStamp)).equals(0);

      final date = XPathDateTime.tryParseDate('2021-01-01')!;
      final time = XPathDateTime.tryParseTime('12:00:00')!;
      check(date == time).isFalse();
      check(() => date.compareTo(time))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());

      const largeYear = XPathDateTime(300000, 1, 1);
      check(largeYear.hashCode).isA<int>();
    });
  });
}
