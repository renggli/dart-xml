import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/date_time.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:adjust-dateTime-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);

    test('adjusts to UTC', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(dt),
          const XPathSequence.single(Duration()),
        ]),
        isXPathSequence([dt]),
      );
    });

    test('adjusts to implicit (local) timezone', () {
      final result =
          fnAdjustDateTimeToTimezone(context, [XPathSequence.single(dt)]).first
              as DateTime;
      final expectedOffset = DateTime.now().timeZoneOffset;
      expect(result.timeZoneOffset, expectedOffset);
    });

    test('returns empty for empty sequence', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.empty,
          const XPathSequence.single(Duration()),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('adjusts to empty timezone (returns self)', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(dt),
          XPathSequence.empty,
        ]),
        isXPathSequence([dt]),
      );
    });

    test('throws exception for unsupported weird offset', () {
      final now = DateTime.now();
      final localOffset = now.timeZoneOffset;
      var weirdOffset = const Duration(minutes: 42);
      if (localOffset.inMinutes == 42) {
        weirdOffset = const Duration(minutes: 43);
      }
      expect(
        () => fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(now),
          XPathSequence.single(weirdOffset),
        ]),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('fn:adjust-date-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      final dt = DateTime.utc(2020, 1, 1);
      final result =
          fnAdjustDateToTimezone(context, [XPathSequence.single(dt)]).first
              as DateTime;
      final expectedOffset = DateTime.now().timeZoneOffset;
      expect(result.timeZoneOffset, expectedOffset);
    });
  });

  group('fn:adjust-time-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
      final result =
          fnAdjustTimeToTimezone(context, [XPathSequence.single(dt)]).first
              as DateTime;
      final expectedOffset = DateTime.now().timeZoneOffset;
      expect(result.timeZoneOffset, expectedOffset);
    });
  });

  group('fn:format-dateTime', () {
    final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);

    test('formats date time', () {
      expect(
        fnFormatDateTime(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[Y]-[M]-[D]'),
        ]),
        isXPathSequence([dt.toIso8601String()]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatDateTime(context, [
          XPathSequence.empty,
          const XPathSequence.single('[Y]'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:format-date', () {
    test('formats date', () {
      final dt = DateTime.utc(2020, 1, 1);
      expect(
        fnFormatDate(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[Y]'),
        ]),
        isXPathSequence([dt.toIso8601String()]),
      );
    });
  });

  group('fn:format-time', () {
    test('formats time', () {
      final dt = DateTime.utc(1970, 1, 1, 10, 30, 0);
      expect(
        fnFormatTime(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[H]:[m]'),
        ]),
        isXPathSequence([dt.toIso8601String()]),
      );
    });
  });

  group('fn:dateTime', () {
    test('combines date and time', () {
      expect(
        fnDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26)),
          XPathSequence.single(DateTime.utc(0, 1, 1, 12, 30, 45)),
        ]).first,
        DateTime(2023, 10, 26, 12, 30, 45),
      );
    });

    test('returns empty if first argument is empty', () {
      expect(
        fnDateTime(context, [
          XPathSequence.empty,
          XPathSequence.single(DateTime.now()),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns empty if second argument is empty', () {
      expect(
        fnDateTime(context, [
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:year-from-dateTime', () {
    test('returns year', () {
      expect(
        fnYearFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26)),
        ]),
        isXPathSequence([2023]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnYearFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:month-from-dateTime', () {
    test('returns month', () {
      expect(
        fnMonthFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([10]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnMonthFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:day-from-dateTime', () {
    test('returns day', () {
      expect(
        fnDayFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([26]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnDayFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:hours-from-dateTime', () {
    test('returns hours', () {
      expect(
        fnHoursFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([12]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnHoursFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:minutes-from-dateTime', () {
    test('returns minutes', () {
      expect(
        fnMinutesFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([30]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnMinutesFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:seconds-from-dateTime', () {
    test('returns seconds', () {
      expect(
        fnSecondsFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([45.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnSecondsFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:timezone-from-dateTime', () {
    test('returns timezone', () {
      expect(
        fnTimezoneFromDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([Duration.zero]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnTimezoneFromDateTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:year-from-date', () {
    test('returns year', () {
      expect(
        fnYearFromDate(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([2023]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnYearFromDate(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:month-from-date', () {
    test('returns month', () {
      expect(
        fnMonthFromDate(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([10]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnMonthFromDate(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:day-from-date', () {
    test('returns day', () {
      expect(
        fnDayFromDate(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([26]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnDayFromDate(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:timezone-from-date', () {
    test('returns timezone', () {
      expect(
        fnTimezoneFromDate(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([Duration.zero]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnTimezoneFromDate(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:hours-from-time', () {
    test('returns hours', () {
      expect(
        fnHoursFromTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([12]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnHoursFromTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:minutes-from-time', () {
    test('returns minutes', () {
      expect(
        fnMinutesFromTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([30]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnMinutesFromTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:seconds-from-time', () {
    test('returns seconds', () {
      expect(
        fnSecondsFromTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([45.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnSecondsFromTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:timezone-from-time', () {
    test('returns timezone', () {
      expect(
        fnTimezoneFromTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([Duration.zero]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnTimezoneFromTime(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:parse-ietf-date', () {
    test('unimplemented', () {
      expect(
        () => fnParseIetfDate(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
