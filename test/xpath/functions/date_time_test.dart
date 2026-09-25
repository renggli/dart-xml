import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/date_time.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:adjust-dateTime-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);

    test('adjusts to UTC', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [
          seq(dt),
          seq(const XPathDuration.dayTime(0)),
        ]),
        isXPathSequence([XPathDateTime.fromDateTime(dt, 0)]),
      );
    });

    test('adjusts to implicit (local) timezone', () {
      final result =
          fnAdjustDateTimeToTimezone(context, [seq(dt)]).first as XPathDateTime;
      expect(
        result.timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.empty,
          seq(const XPathDuration.dayTime(0)),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('adjusts to empty timezone (returns timezone-less)', () {
      expect(
        fnAdjustDateTimeToTimezone(context, [seq(dt), XPathSequence.empty]),
        isXPathSequence([const XPathDateTime(2020, 1, 1, 10, 0, 0)]),
      );
    });

    test('throws exception for invalid offset', () {
      final now = DateTime.now();
      expect(
        () => fnAdjustDateTimeToTimezone(context, [
          seq(now),
          seq(const XPathDuration.dayTime(54000000000)),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws exception for timezone with non-integral minutes', () {
      final now = DateTime.now();
      expect(
        () => fnAdjustDateTimeToTimezone(context, [
          seq(now),
          seq(const XPathDuration.dayTime(1000)), // 1 ms
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('returns null for out of bounds year', () {
      expect(
        XPathDateTime.tryParseDate('-25252734927766555-06-07+02:00'),
        isNull,
      );
    });
  });

  group('fn:adjust-date-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      const dt = XPathDateTime.date(2020, 1, 1, 0);
      final result =
          fnAdjustDateToTimezone(context, [seq(dt)]).first as XPathDateTime;
      expect(
        result.timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
    });
  });

  group('fn:adjust-time-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      const dt = XPathDateTime.time(10, 0, 0, 0, 0, 0);
      final result =
          fnAdjustTimeToTimezone(context, [seq(dt)]).first as XPathDateTime;
      expect(
        result.timezoneOffsetMinutes,
        DateTime.now().timeZoneOffset.inMinutes,
      );
    });
  });

  group('fn:format-dateTime', () {
    final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);

    test('formats date time', () {
      expect(
        fnFormatDateTime(context, [seq(dt), seq('[Y]-[M]-[D]')]),
        isXPathSequence(['2020-01-01T12:00:00Z']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnFormatDateTime(context, [XPathSequence.empty, seq('[Y]')]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:format-date', () {
    test('formats date', () {
      const dt = XPathDateTime.date(2020, 1, 1, 0);
      expect(
        fnFormatDate(context, [seq(dt), seq('[Y]')]),
        isXPathSequence(['2020-01-01Z']),
      );
    });
  });

  group('fn:format-time', () {
    test('formats time', () {
      const dt = XPathDateTime.time(10, 30, 0, 0, 0, 0);
      expect(
        fnFormatTime(context, [seq(dt), seq('[H]:[m]')]),
        isXPathSequence(['10:30:00Z']),
      );
    });
  });

  group('fn:dateTime', () {
    test('combines date and time', () {
      // Both args are timezone-less.
      expect(
        (fnDateTime(context, [
                  seq(const XPathDateTime.date(2023, 10, 26)),
                  seq(const XPathDateTime.time(12, 30, 45)),
                ]).first
                as XPathDateTime)
            .toDateTime(),
        DateTime(2023, 10, 26, 12, 30, 45),
      );
    });

    test('returns empty if first argument is empty', () {
      expect(
        fnDateTime(context, [
          XPathSequence.empty,
          seq(const XPathDateTime.time(12, 0, 0)),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns empty if second argument is empty', () {
      expect(
        fnDateTime(context, [
          seq(const XPathDateTime.date(2023, 1, 1)),
          XPathSequence.empty,
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:year-from-dateTime', () {
    test('returns year', () {
      expect(
        fnYearFromDateTime(context, [seq(DateTime.utc(2023, 10, 26))]),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
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
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
        isXPathSequence([const XPathDuration.dayTime(0)]),
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
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
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
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
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
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
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
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
        ]),
        isXPathSequence([const XPathDuration.dayTime(0)]),
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
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
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
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
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
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
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
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
        ]),
        isXPathSequence([const XPathDuration.dayTime(0)]),
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
    test('returns empty for empty sequence', () {
      final result = fnParseIetfDate(context, [XPathSequence.empty]);
      expect(result, isEmpty);
    });

    test('parses RFC 2822 format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wed, 20 Aug 2014 19:36:01 GMT')),
      ]);
      expect(result.first.stringValue, '2014-08-20T19:36:01Z');
    });

    test('parses RFC 850 format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wednesday, 20-Aug-14 19:36:01 GMT')),
      ]);
      expect(result.first.stringValue, '1914-08-20T19:36:01Z');
    });

    test('parses asctime format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wed Aug 20 19:36:01 2014')),
      ]);
      expect(result.first.stringValue, '2014-08-20T19:36:01Z');
    });

    test('parses with timezone offset and comment', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(
          XPathString('Wed, 20 Aug 2014 14:36:01 -05:00 (EST)'),
        ),
      ]);
      expect(result.first.stringValue, '2014-08-20T19:36:01Z');
    });

    test('handles 24:00:00 midnight rollover', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Aug 20 24:00:00 2014')),
      ]);
      expect(result.first.stringValue, '2014-08-21T00:00:00Z');
    });

    test('throws for invalid input', () {
      expect(
        () => fnParseIetfDate(context, const [
          XPathSequence.single(XPathString('invalid-date')),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('fn:format-dateTime, fn:format-date, fn:format-time', () {
    final dt = XPathDateTime.tryParse('2021-05-20T12:30:00Z')!;
    final d = XPathDateTime.tryParseDate('2021-05-20')!;
    final t = XPathDateTime.tryParseTime('12:30:00')!;

    test('fn:format-dateTime with 2, 3, 4, 5 arguments', () {
      expect(
        fnFormatDateTime(context, [seq(dt), seq('[Y0001]-[M01]-[D01]')]),
        isXPathSequence(['2021-05-20T12:30:00Z']),
      );
      expect(
        fnFormatDateTime(context, [seq(dt), seq('[Y]'), seq('en')]),
        isXPathSequence(['2021-05-20T12:30:00Z']),
      );
      expect(
        fnFormatDateTime(context, [seq(dt), seq('[Y]'), seq('en'), seq('AD')]),
        isXPathSequence(['2021-05-20T12:30:00Z']),
      );
      expect(
        fnFormatDateTime(context, [
          seq(dt),
          seq('[Y]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
        isXPathSequence(['2021-05-20T12:30:00Z']),
      );
      expect(
        fnFormatDateTime(context, [XPathSequence.empty, seq('[Y]')]),
        isXPathSequence(isEmpty),
      );
    });

    test('fn:format-date with 2, 3, 4, 5 arguments', () {
      expect(
        fnFormatDate(context, [seq(d), seq('[Y0001]-[M01]-[D01]')]),
        isXPathSequence(['2021-05-20']),
      );
      expect(
        fnFormatDate(context, [seq(d), seq('[Y]'), seq('en')]),
        isXPathSequence(['2021-05-20']),
      );
      expect(
        fnFormatDate(context, [seq(d), seq('[Y]'), seq('en'), seq('AD')]),
        isXPathSequence(['2021-05-20']),
      );
      expect(
        fnFormatDate(context, [
          seq(d),
          seq('[Y]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
        isXPathSequence(['2021-05-20']),
      );
      expect(
        fnFormatDate(context, [XPathSequence.empty, seq('[Y]')]),
        isXPathSequence(isEmpty),
      );
    });

    test('fn:format-time with 2, 3, 4, 5 arguments', () {
      expect(
        fnFormatTime(context, [seq(t), seq('[H01]:[m01]:[s01]')]),
        isXPathSequence(['12:30:00']),
      );
      expect(
        fnFormatTime(context, [seq(t), seq('[H]'), seq('en')]),
        isXPathSequence(['12:30:00']),
      );
      expect(
        fnFormatTime(context, [seq(t), seq('[H]'), seq('en'), seq('AD')]),
        isXPathSequence(['12:30:00']),
      );
      expect(
        fnFormatTime(context, [
          seq(t),
          seq('[H]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
        isXPathSequence(['12:30:00']),
      );
      expect(
        fnFormatTime(context, [XPathSequence.empty, seq('[H]')]),
        isXPathSequence(isEmpty),
      );
    });
  });
}
