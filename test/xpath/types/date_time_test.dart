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
}
