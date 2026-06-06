import 'package:test/test.dart';
import 'package:xml/src/xpath/types/date_time.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsDateTime', () {
    test('name', () {
      expect(xsDateTime.name, 'xs:dateTime');
    });
    group('cast', () {
      test('from DateTime', () {
        final dateTime = DateTime.now();
        expect(xsDateTime.cast(dateTime), same(dateTime));
      });
      test('from String', () {
        final dateTime = DateTime.parse('2021-01-01T12:34:56.000Z');
        expect(xsDateTime.cast('2021-01-01T12:34:56.000Z'), dateTime);
      });
      test('from String (invalid format)', () {
        expect(
          () => xsDateTime.cast('2021-01-01'),
          throwsA(isXPathEvaluationException()),
        );
      });
      test('from String (hour 24)', () {
        expect(
          xsDateTime.cast('2021-01-01T24:00:00'),
          DateTime.parse('2021-01-02T00:00:00'),
        );
        expect(
          () => xsDateTime.cast('2021-01-01T24:00:01'),
          throwsA(isXPathEvaluationException()),
        );
      });
    });
  });

  group('xsDateTimeStamp', () {
    test('name', () {
      expect(xsDateTimeStamp.name, 'xs:dateTimeStamp');
    });
    group('cast', () {
      test('from String (with timezone)', () {
        expect(
          xsDateTimeStamp.cast('2021-01-01T12:34:56Z'),
          isA<XPathDateTimeStamp>(),
        );
      });
      test('from String (without timezone) throws', () {
        expect(
          () => xsDateTimeStamp.cast('2021-01-01T12:34:56'),
          throwsA(isXPathEvaluationException()),
        );
      });
    });
  });

  group('xsDate', () {
    test('name', () {
      expect(xsDate.name, 'xs:date');
    });
    group('cast', () {
      test('from String', () {
        final date = xsDate.cast('2021-01-01');
        expect(date, isA<XPathDate>());
        expect(date.year, 2021);
        expect(date.month, 1);
        expect(date.day, 1);
      });
      test('from String (invalid day)', () {
        expect(
          () => xsDate.cast('1970-02-30'),
          throwsA(isXPathEvaluationException()),
        );
      });
    });
    test('castToString', () {
      final date = xsDate.cast('2021-01-01');
      expect(xsDate.castToString(date), '2021-01-01');
    });
  });

  group('xsTime', () {
    test('name', () {
      expect(xsTime.name, 'xs:time');
    });
    group('cast', () {
      test('from String', () {
        final time = xsTime.cast('12:34:56');
        expect(time, isA<XPathTime>());
        expect(time.hour, 12);
        expect(time.minute, 34);
        expect(time.second, 56);
      });
    });
    test('castToString', () {
      final time = xsTime.cast('12:34:56');
      expect(xsTime.castToString(time), '12:34:56');
    });
  });

  group('xsGYearMonth', () {
    test('name', () {
      expect(xsGYearMonth.name, 'xs:gYearMonth');
    });
    test('castToString', () {
      final val = xsGYearMonth.cast('1999-05');
      expect(xsGYearMonth.castToString(val), '1999-05');
    });
  });

  group('xsGYear', () {
    test('name', () {
      expect(xsGYear.name, 'xs:gYear');
    });
    test('castToString', () {
      final val = xsGYear.cast('1999');
      expect(xsGYear.castToString(val), '1999');
    });
  });

  group('xsGMonthDay', () {
    test('name', () {
      expect(xsGMonthDay.name, 'xs:gMonthDay');
    });
    test('castToString', () {
      final val = xsGMonthDay.cast('--05-31');
      expect(xsGMonthDay.castToString(val), '--05-31');
    });
  });

  group('xsGMonth', () {
    test('name', () {
      expect(xsGMonth.name, 'xs:gMonth');
    });
    test('castToString', () {
      final val = xsGMonth.cast('--05');
      expect(xsGMonth.castToString(val), '--05');
    });
  });

  group('xsGDay', () {
    test('name', () {
      expect(xsGDay.name, 'xs:gDay');
    });
    test('castToString', () {
      final val = xsGDay.cast('---31');
      expect(xsGDay.castToString(val), '---31');
    });
  });
  group('XPathDateTimeWrapper properties and operators', () {
    test('matches and cast unsupported', () {
      expect(xsDateTime.matches(123), isFalse);
      expect(() => xsDateTime.cast(123), throwsA(isXPathEvaluationException()));
      expect(
        () => xsDateTimeStamp.cast(123),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => xsDate.cast(123), throwsA(isXPathEvaluationException()));
      expect(() => xsTime.cast(123), throwsA(isXPathEvaluationException()));
      expect(
        () => xsGYearMonth.cast(123),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => xsGYear.cast(123), throwsA(isXPathEvaluationException()));
      expect(
        () => xsGMonthDay.cast(123),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => xsGMonth.cast(123), throwsA(isXPathEvaluationException()));
      expect(() => xsGDay.cast(123), throwsA(isXPathEvaluationException()));
    });
    test('comparison and operators', () {
      final dt1 = xsDateTime.cast('2021-01-01T12:00:00Z');
      final dt2 = xsDateTime.cast('2021-01-01T13:00:00Z');
      expect(dt1.isBefore(dt2), isTrue);
      expect(dt2.isAfter(dt1), isTrue);
      expect(dt1.isAtSameMomentAs(dt1), isTrue);
      expect(dt1.compareTo(dt2), lessThan(0));
      expect(dt1.add(const Duration(hours: 1)), dt2);
      expect(dt2.subtract(const Duration(hours: 1)), dt1);
      expect(dt2.difference(dt1), const Duration(hours: 1));
      expect(dt1 == dt2, isFalse);
      expect(dt1 == dt1, isTrue);
      expect(dt1.hashCode, isNotNull);
      expect(dt1.toString(), isNotNull);
    });
    test('timezone formatting and conversions', () {
      final dtUtc = xsDateTime.cast('2021-01-01T12:00:00Z') as XPathDateTime;
      final dtPlus = XPathDateTime(
        DateTime(2021, 1, 1, 12),
        const Duration(hours: 5, minutes: 30),
      );
      final dtMinus = XPathDateTime(
        DateTime(2021, 1, 1, 12),
        const Duration(hours: -5, minutes: -30),
      );
      expect(xsDateTime.castToString(dtUtc), '2021-01-01T12:00:00Z');
      expect(xsDateTime.castToString(dtPlus), '2021-01-01T12:00:00+05:30');
      expect(xsDateTime.castToString(dtMinus), '2021-01-01T12:00:00-05:30');
      expect(dtUtc.toUtc(), same(dtUtc));
      expect(dtPlus.toUtc(), isA<XPathDateTime>());
      expect(dtPlus.toUtc().timeZoneOffset, const Duration());
      expect(dtUtc.toLocal().timeZoneOffset, DateTime.now().timeZoneOffset);
    });
    test('date properties', () {
      final d = xsDate.cast('2021-01-01Z');
      expect(d.toUtc(), same(d));
      expect(d.toLocal(), isA<XPathDate>());
    });
    test('time properties', () {
      final t = xsTime.cast('12:00:00Z');
      expect(t.toUtc(), same(t));
      expect(t.toLocal(), isA<XPathTime>());
    });
    test('fractional seconds formatting', () {
      final dtFrac = XPathDateTime(
        DateTime(2021, 1, 1, 12, 0, 0, 123, 456),
        const Duration(),
      );
      expect(xsDateTime.castToString(dtFrac), '2021-01-01T12:00:00.123456Z');
    });
  });
}
