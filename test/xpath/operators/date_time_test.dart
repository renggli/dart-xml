import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/date_time.dart';
import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';

XPathSequence seq(Object value) => XPathSequence.single(value);

void main() {
  // Reference values.
  final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
  final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
  final dtd1 = XPathDayTimeDuration(const Duration(days: 1));
  final ymd1 = XPathYearMonthDuration(1); // 1 month
  final date1 = XPathDate(DateTime.utc(2020));
  final time1 = XPathTime(DateTime(1970, 1, 1, 12, 0, 0));

  group('opDateTimeEqual', () {
    test('equal', () {
      expect(opDateTimeEqual(seq(dt1), seq(dt1)), [true]);
    });
    test('not equal', () {
      expect(opDateTimeEqual(seq(dt1), seq(dt2)), [false]);
    });
  });

  group('opDateTimeLessThan', () {
    test('less than', () {
      expect(opDateTimeLessThan(seq(dt1), seq(dt2)), [true]);
    });
    test('not less than', () {
      expect(opDateTimeLessThan(seq(dt2), seq(dt1)), [false]);
    });
  });

  group('opDateTimeGreaterThan', () {
    test('greater than', () {
      expect(opDateTimeGreaterThan(seq(dt2), seq(dt1)), [true]);
    });
  });

  group('opSubtractDateTimes', () {
    test('subtract', () {
      expect(
        opSubtractDateTimes(seq(dt2), seq(dt1)).first,
        XPathDayTimeDuration(const Duration(days: 1)),
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
          seq(XPathDate(DateTime.utc(2020))),
          seq(XPathDate(DateTime.utc(2021))),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opDateGreaterThan', () {
    test('greater than', () {
      expect(
        opDateGreaterThan(
          seq(XPathDate(DateTime.utc(2021))),
          seq(XPathDate(DateTime.utc(2020))),
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
          seq(XPathTime(DateTime(1970, 1, 1, 10, 0, 0))),
          seq(XPathTime(DateTime(1970, 1, 1, 11, 0, 0))),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeGreaterThan', () {
    test('greater than', () {
      expect(
        opTimeGreaterThan(
          seq(XPathTime(DateTime(1970, 1, 1, 11, 0, 0))),
          seq(XPathTime(DateTime(1970, 1, 1, 10, 0, 0))),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opSubtractDates', () {
    test('subtract', () {
      final d1 = XPathDate(DateTime.utc(2021));
      final d2 = XPathDate(DateTime.utc(2020));
      final result = opSubtractDates(seq(d1), seq(d2)).first;
      expect(result, isA<XPathDayTimeDuration>());
    });
  });

  group('opSubtractTimes', () {
    test('subtract', () {
      final t1 = XPathTime(DateTime(1970, 1, 1, 12, 0, 0));
      final t2 = XPathTime(DateTime(1970, 1, 1, 10, 0, 0));
      final result = opSubtractTimes(seq(t1), seq(t2)).first;
      expect(result, isA<XPathDayTimeDuration>());
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
    test('add duration returns XPathDate', () {
      final result = opAddYearMonthDurationToDate(seq(date1), seq(ymd1));
      expect(result.first, isA<XPathDate>());
    });
  });

  group('opAddDayTimeDurationToDate', () {
    test('add duration returns XPathDate', () {
      final result = opAddDayTimeDurationToDate(seq(date1), seq(dtd1));
      expect(result.first, isA<XPathDate>());
    });
  });

  group('opSubtractYearMonthDurationFromDate', () {
    test('subtract duration returns XPathDate', () {
      final result = opSubtractYearMonthDurationFromDate(seq(date1), seq(ymd1));
      expect(result.first, isA<XPathDate>());
    });
  });

  group('opSubtractDayTimeDurationFromDate', () {
    test('subtract duration returns XPathDate', () {
      final result = opSubtractDayTimeDurationFromDate(seq(date1), seq(dtd1));
      expect(result.first, isA<XPathDate>());
    });
  });

  group('opAddDayTimeDurationToTime', () {
    test('add duration returns XPathTime', () {
      final result = opAddDayTimeDurationToTime(seq(time1), seq(dtd1));
      expect(result.first, isA<XPathTime>());
    });
  });

  group('opSubtractDayTimeDurationFromTime', () {
    test('subtract duration returns XPathTime', () {
      final result = opSubtractDayTimeDurationFromTime(seq(time1), seq(dtd1));
      expect(result.first, isA<XPathTime>());
    });
  });
}
