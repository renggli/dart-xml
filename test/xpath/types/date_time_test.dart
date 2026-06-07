import 'package:test/test.dart';
import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/src/xpath/values/date_time.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsDateTime', () {
    test('name', () {
      expect(xsDateTime.name, 'xs:dateTime');
    });
    group('cast', () {
      test('from DateTime', () {
        final dateTime = DateTime.now();
        final casted = xsDateTime.cast(dateTime);
        expect(casted, isA<XPathDateTime>());
        expect(casted.toDateTime().isAtSameMomentAs(dateTime), isTrue);
      });
      test('from String', () {
        final dateTime = DateTime.parse('2021-01-01T12:34:56.000Z');
        expect(
          xsDateTime.cast('2021-01-01T12:34:56.000Z').toDateTime(),
          dateTime,
        );
      });
      test('from String (invalid format)', () {
        expect(
          () => xsDateTime.cast('2021-01-01'),
          throwsA(isXPathEvaluationException()),
        );
      });
      test('from String (hour 24)', () {
        expect(
          xsDateTime.cast('2021-01-01T24:00:00').toDateTime(),
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

  group('xsYearMonth', () {
    test('name', () {
      expect(xsYearMonth.name, 'xs:gYearMonth');
    });
    test('castToString', () {
      final val = xsYearMonth.cast('1999-05');
      expect(xsYearMonth.castToString(val), '1999-05');
    });
  });

  group('xsYear', () {
    test('name', () {
      expect(xsYear.name, 'xs:gYear');
    });
    test('castToString', () {
      final val = xsYear.cast('1999');
      expect(xsYear.castToString(val), '1999');
    });
  });

  group('xsMonthDay', () {
    test('name', () {
      expect(xsMonthDay.name, 'xs:gMonthDay');
    });
    test('castToString', () {
      final val = xsMonthDay.cast('--05-31');
      expect(xsMonthDay.castToString(val), '--05-31');
    });
  });

  group('xsMonth', () {
    test('name', () {
      expect(xsMonth.name, 'xs:gMonth');
    });
    test('castToString', () {
      final val = xsMonth.cast('--05');
      expect(xsMonth.castToString(val), '--05');
    });
  });

  group('xsDay', () {
    test('name', () {
      expect(xsDay.name, 'xs:gDay');
    });
    test('castToString', () {
      final val = xsDay.cast('---31');
      expect(xsDay.castToString(val), '---31');
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
        () => xsYearMonth.cast(123),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => xsYear.cast(123), throwsA(isXPathEvaluationException()));
      expect(() => xsMonthDay.cast(123), throwsA(isXPathEvaluationException()));
      expect(() => xsMonth.cast(123), throwsA(isXPathEvaluationException()));
      expect(() => xsDay.cast(123), throwsA(isXPathEvaluationException()));
    });
  });
}
