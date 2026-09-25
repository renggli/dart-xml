import 'package:test/test.dart';
import 'package:xml/src/xpath/xdm/atomic/date_time.dart';
import 'package:xml/src/xpath/xdm/types.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathDateTime', () {
    test('properties, toDateTime and formatting', () {
      const dt = XPathDateTime(2021, 1, 2, 3, 4, 5, 6, 7, 0);
      expect(dt.type, equals(xsDateTime));
      expect(dt.year, equals(2021));
      expect(dt.month, equals(1));
      expect(dt.day, equals(2));
      expect(dt.hour, equals(3));
      expect(dt.minute, equals(4));
      expect(dt.second, equals(5));
      expect(dt.millisecond, equals(6));
      expect(dt.microsecond, equals(7));
      expect(dt.timezoneOffsetMinutes, equals(0));
      expect(dt.isUtc, isTrue);
      expect(dt.toString(), equals('2021-01-02T03:04:05.006007Z'));

      final d = dt.toDateTime();
      expect(d.isUtc, isTrue);
      expect(d.year, equals(2021));
    });

    test('effectiveBooleanValue throws', () {
      const dt = XPathDateTime(2021, 1, 1, 0, 0, 0);
      expect(
        () => dt.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });

    test('parsing tryParse valid and invalid', () {
      expect(XPathDateTime.tryParse('2021-01-02T03:04:05Z'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-02T03:04:05+02:00'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-02T03:04:05'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-02T24:00:00'), isNotNull);
      expect(XPathDateTime.tryParse('2021-01-02'), isNull);
      expect(XPathDateTime.tryParse('invalid'), isNull);
    });

    test('comparison, before, after, equality', () {
      final dt1 = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt2 = XPathDateTime.tryParse('2021-01-01T13:00:00Z')!;
      final dt1Equiv = XPathDateTime.tryParse('2021-01-01T14:00:00+02:00')!;

      expect(dt1.isBefore(dt2), isTrue);
      expect(dt2.isAfter(dt1), isTrue);
      expect(dt1.isAtSameMomentAs(dt1Equiv), isTrue);
      expect(dt1 == dt1Equiv, isTrue);
      expect(dt1 == dt2, isFalse);
    });

    test('add, subtract, difference', () {
      final dt = XPathDateTime.tryParse('2021-01-01T00:00:00Z')!;
      final added = dt.add(const Duration(days: 1));
      expect(added.day, equals(2));
      final subtracted = dt.subtract(const Duration(days: 1));
      expect(subtracted.day, equals(31));
      expect(added.difference(dt), equals(const Duration(days: 1)));
    });
  });

  group('XPathDateTimeStamp', () {
    test('parsing requires timezone offset', () {
      expect(
        XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05Z'),
        isNotNull,
      );
      expect(
        XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05+05:00'),
        isNotNull,
      );
      expect(
        XPathDateTime.tryParseDateTimeStamp('2021-01-02T03:04:05'),
        isNull,
      );
    });
  });

  group('XPathDateTime date', () {
    test('properties, parsing and formatting', () {
      const date = XPathDateTime.date(2021, 5, 20, 0);
      expect(date.type, equals(xsDate));
      expect(date.year, equals(2021));
      expect(date.month, equals(5));
      expect(date.day, equals(20));
      expect(date.toString(), equals('2021-05-20Z'));

      expect(XPathDateTime.tryParseDate('2021-05-20'), isNotNull);
      expect(XPathDateTime.tryParseDate('2021-05-20-05:00'), isNotNull);
      expect(XPathDateTime.tryParseDate('2021-02-30'), isNull);
    });
  });

  group('XPathDateTime time', () {
    test('properties, parsing and formatting', () {
      const time = XPathDateTime.time(12, 34, 56, 0, 0, 0);
      expect(time.type, equals(xsTime));
      expect(time.hour, equals(12));
      expect(time.minute, equals(34));
      expect(time.second, equals(56));
      expect(time.toString(), equals('12:34:56Z'));

      expect(XPathDateTime.tryParseTime('12:34:56'), isNotNull);
      expect(XPathDateTime.tryParseTime('24:00:00'), isNotNull);
      expect(XPathDateTime.tryParseTime('24:01:00'), isNull);
    });
  });

  group('XPathDateTime partial temporal types', () {
    test('XPathDateTime yearMonth', () {
      const ym = XPathDateTime.yearMonth(2021, 12, 0);
      expect(ym.type, equals(xsGYearMonth));
      expect(ym.year, equals(2021));
      expect(ym.month, equals(12));
      expect(ym.toString(), equals('2021-12Z'));
      expect(XPathDateTime.tryParseYearMonth('2021-12'), isNotNull);
      expect(XPathDateTime.tryParseYearMonth('2021-13'), isNull);
    });

    test('XPathDateTime year', () {
      const y = XPathDateTime.year(2021, 0);
      expect(y.type, equals(xsGYear));
      expect(y.year, equals(2021));
      expect(y.toString(), equals('2021Z'));
      expect(XPathDateTime.tryParseYear('2021'), isNotNull);
      expect(XPathDateTime.tryParseYear('20'), isNull);
    });

    test('XPathDateTime monthDay', () {
      const md = XPathDateTime.monthDay(12, 25, 0);
      expect(md.type, equals(xsGMonthDay));
      expect(md.month, equals(12));
      expect(md.day, equals(25));
      expect(md.toString(), equals('--12-25Z'));
      expect(XPathDateTime.tryParseMonthDay('--12-25'), isNotNull);
      expect(XPathDateTime.tryParseMonthDay('--12-32'), isNull);
    });

    test('XPathDateTime month', () {
      const m = XPathDateTime.month(5, 0);
      expect(m.type, equals(xsGMonth));
      expect(m.month, equals(5));
      expect(m.toString(), equals('--05Z'));
      expect(XPathDateTime.tryParseMonth('--05'), isNotNull);
      expect(XPathDateTime.tryParseMonth('--13'), isNull);
    });

    test('XPathDateTime day', () {
      const d = XPathDateTime.day(15, 0);
      expect(d.type, equals(xsGDay));
      expect(d.day, equals(15));
      expect(d.toString(), equals('---15Z'));
      expect(XPathDateTime.tryParseDay('---15'), isNotNull);
      expect(XPathDateTime.tryParseDay('---32'), isNull);
    });

    test('toLocal conversion and negative timezone offsets', () {
      final dtUtc = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dtLocal = dtUtc.toLocal();
      expect(dtLocal.timezoneOffsetMinutes, isNotNull);
      // toLocal on same offset returns itself
      expect(
        dtLocal.toLocal().timezoneOffsetMinutes,
        equals(dtLocal.timezoneOffsetMinutes),
      );

      const dtNeg = XPathDateTime.date(2021, 5, 20, -300);
      expect(dtNeg.toString(), equals('2021-05-20-05:00'));

      const timeNeg = XPathDateTime.time(12, 30, 0, 0, 0, -330);
      expect(timeNeg.toString(), equals('12:30:00-05:30'));
    });

    test('hashCode and equality', () {
      final dt1 = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt1Clone = XPathDateTime.tryParse('2021-01-01T12:00:00Z')!;
      final dt2 = XPathDateTime.tryParse('2021-01-01T14:00:00+02:00')!;
      expect(dt1.hashCode, equals(dt1Clone.hashCode));
      expect(dt1 == dt2, isTrue);
    });

    test('calendar validations for days in months', () {
      expect(XPathDateTime.tryParseDate('2021-04-30'), isNotNull);
      expect(XPathDateTime.tryParseDate('2021-04-31'), isNull);
      expect(XPathDateTime.tryParseDate('2020-02-29'), isNotNull);
      expect(XPathDateTime.tryParseDate('2021-02-29'), isNull);
      expect(XPathDateTime.tryParseDate('2021-06-31'), isNull);
      expect(XPathDateTime.tryParseDate('2021-09-31'), isNull);
      expect(XPathDateTime.tryParseDate('2021-11-31'), isNull);
    });
  });
}
