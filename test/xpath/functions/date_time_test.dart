import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/date_time.dart';

import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:adjust-dateTime-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
    // Adjust to UTC (same)
    expect(
      fnAdjustDateTimeToTimezone(context, [
        XPathSequence.single(dt),
        const XPathSequence.single(Duration()),
      ]),
      [dt.toXPathDateTime()],
    );
    // Adjust to Implicit (Local) - verify timezone offset matches local
    final result =
        fnAdjustDateTimeToTimezone(context, [XPathSequence.single(dt)]).first
            as DateTime;
    final expectedOffset = DateTime.now().timeZoneOffset;
    expect(result.timeZoneOffset, expectedOffset);
  });
  test('fn:format-dateTime', () {
    final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);
    expect(
      fnFormatDateTime(context, [
        XPathSequence.single(dt),
        const XPathSequence.single('[Y]-[M]-[D]'),
      ]),
      // Basic implementation returns ISO string
      [dt.toIso8601String()],
    );
  });
  test('fn:year-from-date', () {
    expect(
      fnYearFromDate(context, [XPathSequence.single(DateTime(2023, 10, 26))]),
      [2023],
    );
  });

  test('fn:dateTime', () {
    expect(
      fnDateTime(context, [
        XPathSequence.single(DateTime.utc(2023, 10, 26)),
        XPathSequence.single(DateTime.utc(0, 1, 1, 12, 30, 45)),
      ]).first,
      DateTime(2023, 10, 26, 12, 30, 45),
    );
  });
  test('fn:month-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnMonthFromDateTime(context, [XPathSequence.single(dt1)]), [10]);
  });
  test('fn:day-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnDayFromDateTime(context, [XPathSequence.single(dt1)]), [26]);
  });
  test('fn:hours-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnHoursFromDateTime(context, [XPathSequence.single(dt1)]), [12]);
  });
  test('fn:minutes-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnMinutesFromDateTime(context, [XPathSequence.single(dt1)]), [30]);
  });
  test('fn:seconds-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnSecondsFromDateTime(context, [XPathSequence.single(dt1)]), [45.0]);
  });

  test('fn:timezone-from-dateTime', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnTimezoneFromDateTime(context, [XPathSequence.single(dt1)]), [
      Duration.zero,
    ]);
  });
  test('fn:year-from-date', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnYearFromDate(context, [XPathSequence.single(dt1)]), [2023]);
  });
  test('fn:month-from-date', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnMonthFromDate(context, [XPathSequence.single(dt1)]), [10]);
  });
  test('fn:day-from-date', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnDayFromDate(context, [XPathSequence.single(dt1)]), [26]);
  });
  test('fn:timezone-from-date', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnTimezoneFromDate(context, [XPathSequence.single(dt1)]), [
      Duration.zero,
    ]);
  });
  test('fn:hours-from-time', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnHoursFromTime(context, [XPathSequence.single(dt1)]), [12]);
  });
  test('fn:minutes-from-time', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnMinutesFromTime(context, [XPathSequence.single(dt1)]), [30]);
  });
  test('fn:seconds-from-time', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnSecondsFromTime(context, [XPathSequence.single(dt1)]), [45.0]);
  });
  test('fn:timezone-from-time', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    expect(fnTimezoneFromTime(context, [XPathSequence.single(dt1)]), [
      Duration.zero,
    ]);
  });

  test('fn:dateTime (empty)', () {
    expect(
      fnDateTime(context, [
        XPathSequence.empty,
        XPathSequence.single(DateTime.now()),
      ]),
      isEmpty,
    );
    expect(
      fnDateTime(context, [
        XPathSequence.single(DateTime.now()),
        XPathSequence.empty,
      ]),
      isEmpty,
    );
  });
  test('fn:adjust-dateTime-to-timezone (empty timezone)', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
    expect(
      fnAdjustDateTimeToTimezone(context, [
        XPathSequence.single(dt),
        XPathSequence.empty, // Empty timezone sequence
      ]),
      [dt.toXPathDateTime()],
    );
  });
  test('fn:adjust-date-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1);
    // Implicit - verify timezone offset matches local
    final result =
        fnAdjustDateToTimezone(context, [XPathSequence.single(dt)]).first
            as DateTime;
    final expectedOffset = DateTime.now().timeZoneOffset;
    expect(result.timeZoneOffset, expectedOffset);
  });
  test('fn:adjust-time-to-timezone', () {
    final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
    // Implicit - verify timezone offset matches local
    final result =
        fnAdjustTimeToTimezone(context, [XPathSequence.single(dt)]).first
            as DateTime;
    final expectedOffset = DateTime.now().timeZoneOffset;
    expect(result.timeZoneOffset, expectedOffset);
  });
  test('fn:format-date', () {
    final dt = DateTime.utc(2020, 1, 1);
    expect(
      fnFormatDate(context, [
        XPathSequence.single(dt),
        const XPathSequence.single('[Y]'),
      ]),
      [dt.toIso8601String()],
    );
  });
  test('fn:format-time', () {
    final dt = DateTime.utc(1970, 1, 1, 10, 30, 0);
    expect(
      fnFormatTime(context, [
        XPathSequence.single(dt),
        const XPathSequence.single('[H]:[m]'),
      ]),
      [dt.toIso8601String()],
    );
  });
  test('fn:format-dateTime (empty)', () {
    expect(
      fnFormatDateTime(context, [
        XPathSequence.empty,
        const XPathSequence.single('[Y]'),
      ]),
      isEmpty,
    );
  });
  // Component extraction empty tests
  test('components (empty)', () {
    expect(fnYearFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnMonthFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnDayFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnHoursFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnMinutesFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnSecondsFromDateTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnTimezoneFromDateTime(context, [XPathSequence.empty]), isEmpty);

    expect(fnYearFromDate(context, [XPathSequence.empty]), isEmpty);
    expect(fnMonthFromDate(context, [XPathSequence.empty]), isEmpty);
    expect(fnDayFromDate(context, [XPathSequence.empty]), isEmpty);
    expect(fnTimezoneFromDate(context, [XPathSequence.empty]), isEmpty);

    expect(fnHoursFromTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnMinutesFromTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnSecondsFromTime(context, [XPathSequence.empty]), isEmpty);
    expect(fnTimezoneFromTime(context, [XPathSequence.empty]), isEmpty);
  });

  test('fn:adjust-dateTime-to-timezone (unsupported)', () {
    final now = DateTime.now();
    final localOffset = now.timeZoneOffset;
    // Create a duration that is definitely not matching local or UTC
    // If local is 0, we use 42 mins. If local is 42 mins, we use 43.
    var weirdOffset = const Duration(minutes: 42);
    if (localOffset.inMinutes == 42) {
      weirdOffset = const Duration(minutes: 43);
    }

    expect(
      () => fnAdjustDateTimeToTimezone(context, [
        XPathSequence.single(now),
        XPathSequence.single(weirdOffset),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });

  test('fn:parse-ietf-date', () {
    expect(
      () => fnParseIetfDate(context, []),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
