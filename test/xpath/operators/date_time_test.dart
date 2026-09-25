import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/date_time.dart';
import 'package:xml/xpath.dart';

XPathSequence seq(XPathItem value) => XPathSequence.single(value);

void main() {
  // Reference values.
  final dt1 = XPathDateTime.fromDateTime(
    DateTime.utc(2023, 10, 26, 12, 30, 45),
    0,
  );
  final dt2 = XPathDateTime.fromDateTime(
    DateTime.utc(2023, 10, 27, 12, 30, 45),
    0,
  );
  const dtd1 = XPathDuration.dayTime(86400000000);
  const ymd1 = XPathDuration.yearMonth(1); // 1 month
  const date1 = XPathDateTime.date(2020, 1, 1, 0);
  final time1 = XPathDateTime.time(
    12,
    0,
    0,
    0,
    0,
    DateTime(1970, 1, 1, 12, 0, 0).timeZoneOffset.inMinutes,
  );

  group('opDateTimeEqual', () {
    test('equal', () {
      expect(opDateTimeEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
    test('not equal', () {
      expect(opDateTimeEqual(seq(dt1), seq(dt2)), XPathSequence.falseSequence);
    });
  });

  group('opDateTimeLessThan', () {
    test('less than', () {
      expect(
        opDateTimeLessThan(seq(dt1), seq(dt2)),
        XPathSequence.trueSequence,
      );
    });
    test('not less than', () {
      expect(
        opDateTimeLessThan(seq(dt2), seq(dt1)),
        XPathSequence.falseSequence,
      );
    });
  });

  group('opDateTimeGreaterThan', () {
    test('greater than', () {
      expect(
        opDateTimeGreaterThan(seq(dt2), seq(dt1)),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opSubtractDateTimes', () {
    test('subtract', () {
      expect(
        opSubtractDateTimes(seq(dt2), seq(dt1)).first,
        const XPathDuration.dayTime(86400000000),
      );
    });
    test('empty left', () {
      expect(opSubtractDateTimes(XPathSequence.empty, seq(dt1)), isEmpty);
    });
    test('empty right', () {
      expect(opSubtractDateTimes(seq(dt1), XPathSequence.empty), isEmpty);
    });
  });

  group('opAddDurationToDateTime', () {
    test('add dayTime duration', () {
      expect(opAddDurationToDateTime(seq(dt1), seq(dtd1)).first, dt2);
    });
    test('empty sequence left', () {
      expect(opAddDurationToDateTime(XPathSequence.empty, seq(dtd1)), isEmpty);
    });
    test('empty sequence right', () {
      expect(opAddDurationToDateTime(seq(dt1), XPathSequence.empty), isEmpty);
    });
  });

  group('opSubtractDurationFromDateTime', () {
    test('subtract dayTime duration', () {
      expect(opSubtractDurationFromDateTime(seq(dt2), seq(dtd1)).first, dt1);
    });
    test('empty sequence left', () {
      expect(
        opSubtractDurationFromDateTime(XPathSequence.empty, seq(dtd1)),
        isEmpty,
      );
    });
    test('empty sequence right', () {
      expect(
        opSubtractDurationFromDateTime(seq(dt1), XPathSequence.empty),
        isEmpty,
      );
    });
  });

  group('opDateEqual', () {
    test('equal', () {
      expect(opDateEqual(seq(date1), seq(date1)), XPathSequence.trueSequence);
    });
  });

  group('opDateLessThan', () {
    test('less than', () {
      expect(
        opDateLessThan(
          seq(const XPathDateTime.date(2020, 1, 1, 0)),
          seq(const XPathDateTime.date(2021, 1, 1, 0)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opDateGreaterThan', () {
    test('greater than', () {
      expect(
        opDateGreaterThan(
          seq(const XPathDateTime.date(2021, 1, 1, 0)),
          seq(const XPathDateTime.date(2020, 1, 1, 0)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeEqual', () {
    test('equal', () {
      expect(opTimeEqual(seq(time1), seq(time1)), XPathSequence.trueSequence);
    });
  });

  group('opTimeLessThan', () {
    test('less than', () {
      expect(
        opTimeLessThan(
          seq(
            XPathDateTime.time(
              10,
              0,
              0,
              0,
              0,
              DateTime(1970, 1, 1, 10, 0, 0).timeZoneOffset.inMinutes,
            ),
          ),
          seq(
            XPathDateTime.time(
              11,
              0,
              0,
              0,
              0,
              DateTime(1970, 1, 1, 11, 0, 0).timeZoneOffset.inMinutes,
            ),
          ),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeGreaterThan', () {
    test('greater than', () {
      expect(
        opTimeGreaterThan(
          seq(
            XPathDateTime.time(
              11,
              0,
              0,
              0,
              0,
              DateTime(1970, 1, 1, 11, 0, 0).timeZoneOffset.inMinutes,
            ),
          ),
          seq(
            XPathDateTime.time(
              10,
              0,
              0,
              0,
              0,
              DateTime(1970, 1, 1, 10, 0, 0).timeZoneOffset.inMinutes,
            ),
          ),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opSubtractDates', () {
    test('subtract', () {
      const d1 = XPathDateTime.date(2021, 1, 1, 0);
      const d2 = XPathDateTime.date(2020, 1, 1, 0);
      final result = opSubtractDates(seq(d1), seq(d2)).first;
      expect(result, isA<XPathDuration>());
      expect((result as XPathDuration).type, xsDayTimeDuration);
    });
  });

  group('opSubtractTimes', () {
    test('subtract', () {
      final t1 = XPathDateTime.time(
        12,
        0,
        0,
        0,
        0,
        DateTime(1970, 1, 1, 12, 0, 0).timeZoneOffset.inMinutes,
      );
      final t2 = XPathDateTime.time(
        10,
        0,
        0,
        0,
        0,
        DateTime(1970, 1, 1, 10, 0, 0).timeZoneOffset.inMinutes,
      );
      final result = opSubtractTimes(seq(t1), seq(t2)).first;
      expect(result, isA<XPathDuration>());
      expect((result as XPathDuration).type, xsDayTimeDuration);
    });
  });

  group('opGYearMonthEqual', () {
    test('equal', () {
      expect(opGYearMonthEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
  });

  group('opGYearEqual', () {
    test('equal', () {
      expect(opGYearEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
  });

  group('opGMonthDayEqual', () {
    test('equal', () {
      expect(opGMonthDayEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
  });

  group('opGMonthEqual', () {
    test('equal', () {
      expect(opGMonthEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
  });

  group('opGDayEqual', () {
    test('equal', () {
      expect(opGDayEqual(seq(dt1), seq(dt1)), XPathSequence.trueSequence);
    });
  });

  group('opAddYearMonthDurationToDateTime', () {
    test('add duration', () {
      expect(opAddYearMonthDurationToDateTime(seq(dt1), seq(ymd1)), isNotNull);
    });
  });

  group('opAddDayTimeDurationToDateTime', () {
    test('add duration', () {
      expect(opAddDayTimeDurationToDateTime(seq(dt1), seq(dtd1)).first, dt2);
    });
  });

  group('opSubtractYearMonthDurationFromDateTime', () {
    test('subtract duration', () {
      expect(
        opSubtractYearMonthDurationFromDateTime(seq(dt1), seq(ymd1)),
        isNotNull,
      );
    });
  });

  group('opSubtractDayTimeDurationFromDateTime', () {
    test('subtract duration', () {
      expect(
        opSubtractDayTimeDurationFromDateTime(seq(dt2), seq(dtd1)).first,
        dt1,
      );
    });
  });

  group('opAddYearMonthDurationToDate', () {
    test('add duration returns date', () {
      final result = opAddYearMonthDurationToDate(seq(date1), seq(ymd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsDate);
    });
  });

  group('opAddDayTimeDurationToDate', () {
    test('add duration returns date', () {
      final result = opAddDayTimeDurationToDate(seq(date1), seq(dtd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsDate);
    });
  });

  group('opSubtractYearMonthDurationFromDate', () {
    test('subtract duration returns date', () {
      final result = opSubtractYearMonthDurationFromDate(seq(date1), seq(ymd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsDate);
    });
  });

  group('opSubtractDayTimeDurationFromDate', () {
    test('subtract duration returns date', () {
      final result = opSubtractDayTimeDurationFromDate(seq(date1), seq(dtd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsDate);
    });
  });

  group('opAddDayTimeDurationToTime', () {
    test('add duration returns time', () {
      final result = opAddDayTimeDurationToTime(seq(time1), seq(dtd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsTime);
    });
  });

  group('opSubtractDayTimeDurationFromTime', () {
    test('subtract duration returns time', () {
      final result = opSubtractDayTimeDurationFromTime(seq(time1), seq(dtd1));
      expect(result.first, isA<XPathDateTime>());
      expect((result.first as XPathDateTime).type, xsTime);
    });
  });
}
