import 'package:test/test.dart';
import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/src/xpath/values/date_time.dart';

void main() {
  group('XPathDateTimeWrapper value tests', () {
    test('comparison and operators', () {
      final dt1 = xsDateTime.cast('2021-01-01T12:00:00Z') as XPathDateTime;
      final dt2 = xsDateTime.cast('2021-01-01T13:00:00Z') as XPathDateTime;
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
