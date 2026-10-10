import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/date_time.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:adjust-dateTime-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);

    test('adjusts to UTC', () {
      check(
        fnAdjustDateTimeToTimezone(context, [
          seq(dt),
          seq(const XPathDuration.dayTime(0)),
        ]),
      ).isXPathSequence([XPathDateTime.fromDateTime(dt, 0)]);
    });

    test('adjusts to implicit (local) timezone', () {
      final result =
          fnAdjustDateTimeToTimezone(context, [seq(dt)]).first as XPathDateTime;
      check(result.timezoneOffsetMinutes)
          .equals(DateTime.now().timeZoneOffset.inMinutes);
    });

    test('returns empty for empty sequence', () {
      check(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.empty,
          seq(const XPathDuration.dayTime(0)),
        ]),
      ).isXPathSequence(isEmpty);
    });

    test('adjusts to empty timezone (returns timezone-less)', () {
      check(fnAdjustDateTimeToTimezone(context, [seq(dt), XPathSequence.empty]))
          .isXPathSequence([const XPathDateTime(2020, 1, 1, 10, 0, 0)]);
    });

    test('throws exception for invalid offset', () {
      final now = DateTime.now();
      check(
        () => fnAdjustDateTimeToTimezone(context, [
          seq(now),
          seq(const XPathDuration.dayTime(54000000000)),
        ]),
      ).throws<XPathEvaluationException>();
    });

    test('throws exception for timezone with non-integral minutes', () {
      final now = DateTime.now();
      check(
        () => fnAdjustDateTimeToTimezone(context, [
          seq(now),
          seq(const XPathDuration.dayTime(1000)), // 1 ms
        ]),
      ).throws<XPathEvaluationException>();
    });

    test('returns null for out of bounds year', () {
      check(XPathDateTime.tryParseDate('-25252734927766555-06-07+02:00'))
          .isNull();
    });
  });

  group('fn:adjust-date-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      const dt = XPathDateTime.date(2020, 1, 1, 0);
      final result =
          fnAdjustDateToTimezone(context, [seq(dt)]).first as XPathDateTime;
      check(result.timezoneOffsetMinutes)
          .equals(DateTime.now().timeZoneOffset.inMinutes);
    });
  });

  group('fn:adjust-time-to-timezone', () {
    test('adjusts to implicit (local) timezone', () {
      const dt = XPathDateTime.time(10, 0, 0, 0, 0, 0);
      final result =
          fnAdjustTimeToTimezone(context, [seq(dt)]).first as XPathDateTime;
      check(result.timezoneOffsetMinutes)
          .equals(DateTime.now().timeZoneOffset.inMinutes);
    });
  });

  group('fn:format-dateTime', () {
    final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);

    test('formats date time', () {
      check(fnFormatDateTime(context, [seq(dt), seq('[Y]-[M]-[D]')]))
          .isXPathSequence(['2020-01-01T12:00:00Z']);
    });

    test('returns empty for empty sequence', () {
      check(fnFormatDateTime(context, [XPathSequence.empty, seq('[Y]')]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:format-date', () {
    test('formats date', () {
      const dt = XPathDateTime.date(2020, 1, 1, 0);
      check(fnFormatDate(context, [seq(dt), seq('[Y]')]))
          .isXPathSequence(['2020-01-01Z']);
    });
  });

  group('fn:format-time', () {
    test('formats time', () {
      const dt = XPathDateTime.time(10, 30, 0, 0, 0, 0);
      check(fnFormatTime(context, [seq(dt), seq('[H]:[m]')]))
          .isXPathSequence(['10:30:00Z']);
    });
  });

  group('fn:dateTime', () {
    test('combines date and time', () {
      // Both args are timezone-less.
      check(
        (fnDateTime(context, [
                  seq(const XPathDateTime.date(2023, 10, 26)),
                  seq(const XPathDateTime.time(12, 30, 45)),
                ]).first
                as XPathDateTime)
            .toDateTime(),
      ).equals(DateTime(2023, 10, 26, 12, 30, 45));
    });

    test('returns empty if first argument is empty', () {
      check(
        fnDateTime(context, [
          XPathSequence.empty,
          seq(const XPathDateTime.time(12, 0, 0)),
        ]),
      ).isXPathSequence(isEmpty);
    });

    test('returns empty if second argument is empty', () {
      check(
        fnDateTime(context, [
          seq(const XPathDateTime.date(2023, 1, 1)),
          XPathSequence.empty,
        ]),
      ).isXPathSequence(isEmpty);
    });
  });

  group('fn:year-from-dateTime', () {
    test('returns year', () {
      check(fnYearFromDateTime(context, [seq(DateTime.utc(2023, 10, 26))]))
          .isXPathSequence([2023]);
    });

    test('returns empty for empty sequence', () {
      check(fnYearFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:month-from-dateTime', () {
    test('returns month', () {
      check(
        fnMonthFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([10]);
    });

    test('returns empty for empty sequence', () {
      check(fnMonthFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:day-from-dateTime', () {
    test('returns day', () {
      check(
        fnDayFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([26]);
    });

    test('returns empty for empty sequence', () {
      check(fnDayFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:hours-from-dateTime', () {
    test('returns hours', () {
      check(
        fnHoursFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([12]);
    });

    test('returns empty for empty sequence', () {
      check(fnHoursFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:minutes-from-dateTime', () {
    test('returns minutes', () {
      check(
        fnMinutesFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([30]);
    });

    test('returns empty for empty sequence', () {
      check(fnMinutesFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:seconds-from-dateTime', () {
    test('returns seconds', () {
      check(
        fnSecondsFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([45.0]);
    });

    test('returns empty for empty sequence', () {
      check(fnSecondsFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:timezone-from-dateTime', () {
    test('returns timezone', () {
      check(
        fnTimezoneFromDateTime(context, [
          seq(DateTime.utc(2023, 10, 26, 12, 30, 45)),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(0)]);
    });

    test('returns empty for empty sequence', () {
      check(fnTimezoneFromDateTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:year-from-date', () {
    test('returns year', () {
      check(
        fnYearFromDate(context, [
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
        ]),
      ).isXPathSequence([2023]);
    });

    test('returns empty for empty sequence', () {
      check(fnYearFromDate(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:month-from-date', () {
    test('returns month', () {
      check(
        fnMonthFromDate(context, [
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
        ]),
      ).isXPathSequence([10]);
    });

    test('returns empty for empty sequence', () {
      check(fnMonthFromDate(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:day-from-date', () {
    test('returns day', () {
      check(
        fnDayFromDate(context, [
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
        ]),
      ).isXPathSequence([26]);
    });

    test('returns empty for empty sequence', () {
      check(fnDayFromDate(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:timezone-from-date', () {
    test('returns timezone', () {
      check(
        fnTimezoneFromDate(context, [
          seq(const XPathDateTime.date(2023, 10, 26, 0)),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(0)]);
    });

    test('returns empty for empty sequence', () {
      check(fnTimezoneFromDate(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:hours-from-time', () {
    test('returns hours', () {
      check(
        fnHoursFromTime(context, [
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
        ]),
      ).isXPathSequence([12]);
    });

    test('returns empty for empty sequence', () {
      check(fnHoursFromTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:minutes-from-time', () {
    test('returns minutes', () {
      check(
        fnMinutesFromTime(context, [
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
        ]),
      ).isXPathSequence([30]);
    });

    test('returns empty for empty sequence', () {
      check(fnMinutesFromTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:seconds-from-time', () {
    test('returns seconds', () {
      check(
        fnSecondsFromTime(context, [
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
        ]),
      ).isXPathSequence([45.0]);
    });

    test('returns empty for empty sequence', () {
      check(fnSecondsFromTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:timezone-from-time', () {
    test('returns timezone', () {
      check(
        fnTimezoneFromTime(context, [
          seq(const XPathDateTime.time(12, 30, 45, 0, 0, 0)),
        ]),
      ).isXPathSequence([const XPathDuration.dayTime(0)]);
    });

    test('returns empty for empty sequence', () {
      check(fnTimezoneFromTime(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:parse-ietf-date', () {
    test('returns empty for empty sequence', () {
      final result = fnParseIetfDate(context, [XPathSequence.empty]);
      check(result).isEmpty();
    });

    test('parses RFC 2822 format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wed, 20 Aug 2014 19:36:01 GMT')),
      ]);
      check(result.first.stringValue).equals('2014-08-20T19:36:01Z');
    });

    test('parses RFC 850 format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wednesday, 20-Aug-14 19:36:01 GMT')),
      ]);
      check(result.first.stringValue).equals('1914-08-20T19:36:01Z');
    });

    test('parses asctime format', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Wed Aug 20 19:36:01 2014')),
      ]);
      check(result.first.stringValue).equals('2014-08-20T19:36:01Z');
    });

    test('parses with timezone offset and comment', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(
          XPathString('Wed, 20 Aug 2014 14:36:01 -05:00 (EST)'),
        ),
      ]);
      check(result.first.stringValue).equals('2014-08-20T19:36:01Z');
    });

    test('handles 24:00:00 midnight rollover', () {
      final result = fnParseIetfDate(context, const [
        XPathSequence.single(XPathString('Aug 20 24:00:00 2014')),
      ]);
      check(result.first.stringValue).equals('2014-08-21T00:00:00Z');
    });

    test('throws for invalid input', () {
      check(
        () => fnParseIetfDate(context, const [
          XPathSequence.single(XPathString('invalid-date')),
        ]),
      ).throws<XPathEvaluationException>();
    });
  });

  group('fn:format-dateTime, fn:format-date, fn:format-time', () {
    final dt = XPathDateTime.tryParse('2021-05-20T12:30:00Z')!;
    final d = XPathDateTime.tryParseDate('2021-05-20')!;
    final t = XPathDateTime.tryParseTime('12:30:00')!;

    test('fn:format-dateTime with 2, 3, 4, 5 arguments', () {
      check(fnFormatDateTime(context, [seq(dt), seq('[Y0001]-[M01]-[D01]')]))
          .isXPathSequence(['2021-05-20T12:30:00Z']);
      check(fnFormatDateTime(context, [seq(dt), seq('[Y]'), seq('en')]))
          .isXPathSequence(['2021-05-20T12:30:00Z']);
      check(
        fnFormatDateTime(context, [seq(dt), seq('[Y]'), seq('en'), seq('AD')]),
      ).isXPathSequence(['2021-05-20T12:30:00Z']);
      check(
        fnFormatDateTime(context, [
          seq(dt),
          seq('[Y]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
      ).isXPathSequence(['2021-05-20T12:30:00Z']);
      check(fnFormatDateTime(context, [XPathSequence.empty, seq('[Y]')]))
          .isXPathSequence(isEmpty);
    });

    test('fn:format-date with 2, 3, 4, 5 arguments', () {
      check(fnFormatDate(context, [seq(d), seq('[Y0001]-[M01]-[D01]')]))
          .isXPathSequence(['2021-05-20']);
      check(fnFormatDate(context, [seq(d), seq('[Y]'), seq('en')]))
          .isXPathSequence(['2021-05-20']);
      check(fnFormatDate(context, [seq(d), seq('[Y]'), seq('en'), seq('AD')]))
          .isXPathSequence(['2021-05-20']);
      check(
        fnFormatDate(context, [
          seq(d),
          seq('[Y]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
      ).isXPathSequence(['2021-05-20']);
      check(fnFormatDate(context, [XPathSequence.empty, seq('[Y]')]))
          .isXPathSequence(isEmpty);
    });

    test('fn:format-time with 2, 3, 4, 5 arguments', () {
      check(fnFormatTime(context, [seq(t), seq('[H01]:[m01]:[s01]')]))
          .isXPathSequence(['12:30:00']);
      check(fnFormatTime(context, [seq(t), seq('[H]'), seq('en')]))
          .isXPathSequence(['12:30:00']);
      check(fnFormatTime(context, [seq(t), seq('[H]'), seq('en'), seq('AD')]))
          .isXPathSequence(['12:30:00']);
      check(
        fnFormatTime(context, [
          seq(t),
          seq('[H]'),
          seq('en'),
          seq('AD'),
          seq('US'),
        ]),
      ).isXPathSequence(['12:30:00']);
      check(fnFormatTime(context, [XPathSequence.empty, seq('[H]')]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:dateTime and adjust-to-timezone edge cases', () {
    test('fn:dateTime throws FORG0008 on conflicting timezones', () {
      check(
        () => fnDateTime(context, [
          seq(const XPathDateTime.date(2020, 1, 1, 60)),
          seq(const XPathDateTime.time(10, 0, 0, 0, 0, 120)),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0008),
      );
    });

    test('fn:adjust-date-to-timezone and fn:adjust-time-to-timezone with 2 arguments', () {
      final adjustedDate = fnAdjustDateToTimezone(context, [
        seq(const XPathDateTime.date(2020, 1, 1)),
        seq(const XPathDuration.dayTime(0)),
      ]);
      check(adjustedDate.first.stringValue).equals('2020-01-01Z');

      final adjustedTime = fnAdjustTimeToTimezone(context, [
        seq(const XPathDateTime.time(10, 0, 0)),
        seq(const XPathDuration.dayTime(0)),
      ]);
      check(adjustedTime.first.stringValue).equals('10:00:00Z');
    });
  });

  group('fn:parse-ietf-date edge cases', () {
    test('handles fractional seconds, leap and non-leap February', () {
      final res = fnParseIetfDate(context, [
        seq('Wed, 06 Jun 1994 07:29:35.123 GMT'),
      ]);
      check(res.first.stringValue).contains('.123');

      final nonLeap = fnParseIetfDate(context, [
        seq('Sun, 28 Feb 1993 07:29:35 GMT'),
      ]);
      check(nonLeap.first.stringValue).contains('1993-02-28');

      final leap = fnParseIetfDate(context, [
        seq('Thu, 29 Feb 1996 07:29:35 GMT'),
      ]);
      check(leap.first.stringValue).contains('1996-02-29');
    });

    test('throws FORG0010 on empty or invalid inputs', () {
      void expectIetfError(String dateStr) {
        check(() => fnParseIetfDate(context, [seq(dateStr)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FORG0010),
            );
      }

      expectIetfError('');
      expectIetfError('Wed, 06 Foo 1994 07:29:35 GMT');
      expectIetfError('Wed, 06 Jun 1994 07:29:35 +1500');
      expectIetfError('Wed, 06 Jun 1994 07:29:35 +0000 (BAD)');
      expectIetfError('Wed, 06 Jun 1994 07:29:35 UNK');
      expectIetfError('Wed, 31 Apr 1994 07:29:35 GMT');
      expectIetfError('Wed, 06 Jun 1994 25:00:00 GMT');
    });
  });
}
