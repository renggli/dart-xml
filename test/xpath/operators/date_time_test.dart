import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/date_time.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('opDateTimeEqual', () {
    test('equal', () {
      final dt1 = DateTime(2023, 1, 1);
      final dt2 = DateTime(2023, 1, 1);
      expect(
        opDateTimeEqual(XPathSequence.single(dt1), XPathSequence.single(dt2)),
        [true],
      );
    });
    test('not equal', () {
      final dt1 = DateTime(2023, 1, 1);
      final dt3 = DateTime(2023, 1, 2);
      expect(
        opDateTimeEqual(XPathSequence.single(dt1), XPathSequence.single(dt3)),
        [false],
      );
    });
  });

  group('opDateTimeLessThan', () {
    test('less than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeLessThan(
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ),
        [true],
      );
    });
    test('not less than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeLessThan(
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ),
        [false],
      );
    });
  });

  group('opDateTimeGreaterThan', () {
    test('greater than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeGreaterThan(
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ),
        [true],
      );
    });
  });

  group('opSubtractDateTimes', () {
    test('subtract', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opSubtractDateTimes(
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ).first,
        const Duration(days: 1),
      );
    });
    test('empty left', () {
      expect(
        opSubtractDateTimes(
          XPathSequence.empty,
          XPathSequence.single(DateTime.now()),
        ),
        isEmpty,
      );
    });
    test('empty right', () {
      expect(
        opSubtractDateTimes(
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ),
        isEmpty,
      );
    });
  });

  group('opAddDurationToDateTime', () {
    test('add duration', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opAddDurationToDateTime(
          XPathSequence.single(dt1),
          const XPathSequence.single(dur),
        ).first,
        dt2,
      );
    });
    test('empty sequence left', () {
      expect(
        opAddDurationToDateTime(
          XPathSequence.empty,
          const XPathSequence.single(Duration()),
        ),
        isEmpty,
      );
    });
    test('empty sequence right', () {
      expect(
        opAddDurationToDateTime(
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ),
        isEmpty,
      );
    });
  });

  group('opSubtractDurationFromDateTime', () {
    test('subtract duration', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opSubtractDurationFromDateTime(
          XPathSequence.single(dt2),
          const XPathSequence.single(dur),
        ).first,
        dt1,
      );
    });
    test('empty sequence left', () {
      expect(
        opSubtractDurationFromDateTime(
          XPathSequence.empty,
          const XPathSequence.single(Duration()),
        ),
        isEmpty,
      );
    });
    test('empty sequence right', () {
      expect(
        opSubtractDurationFromDateTime(
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ),
        isEmpty,
      );
    });
  });

  group('opDateEqual', () {
    test('equal', () {
      expect(
        opDateEqual(
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2020)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opDateLessThan', () {
    test('less than', () {
      expect(
        opDateLessThan(
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opDateGreaterThan', () {
    test('greater than', () {
      expect(
        opDateGreaterThan(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeEqual', () {
    test('equal', () {
      expect(
        opTimeEqual(
          XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
          XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeLessThan', () {
    test('less than', () {
      expect(
        opTimeLessThan(
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opTimeGreaterThan', () {
    test('greater than', () {
      expect(
        opTimeGreaterThan(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opSubtractDates', () {
    test('subtract', () {
      expect(
        opSubtractDates(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractTimes', () {
    test('subtract', () {
      expect(
        opSubtractTimes(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ),
        isNotNull,
      );
    });
  });

  group('opGYearMonthEqual', () {
    test('equal', () {
      expect(
        opGYearMonthEqual(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGYearEqual', () {
    test('equal', () {
      expect(
        opGYearEqual(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGMonthDayEqual', () {
    test('equal', () {
      expect(
        opGMonthDayEqual(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGMonthEqual', () {
    test('equal', () {
      expect(
        opGMonthEqual(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGDayEqual', () {
    test('equal', () {
      expect(
        opGDayEqual(
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opAddYearMonthDurationToDateTime', () {
    test('add duration', () {
      expect(
        opAddYearMonthDurationToDateTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opAddDayTimeDurationToDateTime', () {
    test('add duration', () {
      expect(
        opAddDayTimeDurationToDateTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractYearMonthDurationFromDateTime', () {
    test('subtract duration', () {
      expect(
        opSubtractYearMonthDurationFromDateTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractDayTimeDurationFromDateTime', () {
    test('subtract duration', () {
      expect(
        opSubtractDayTimeDurationFromDateTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opAddYearMonthDurationToDate', () {
    test('add duration', () {
      expect(
        opAddYearMonthDurationToDate(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opAddDayTimeDurationToDate', () {
    test('add duration', () {
      expect(
        opAddDayTimeDurationToDate(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractYearMonthDurationFromDate', () {
    test('subtract duration', () {
      expect(
        opSubtractYearMonthDurationFromDate(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractDayTimeDurationFromDate', () {
    test('subtract duration', () {
      expect(
        opSubtractDayTimeDurationFromDate(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opAddDayTimeDurationToTime', () {
    test('add duration', () {
      expect(
        opAddDayTimeDurationToTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });

  group('opSubtractDayTimeDurationFromTime', () {
    test('subtract duration', () {
      expect(
        opSubtractDayTimeDurationFromTime(
          XPathSequence.single(DateTime.utc(2020)),
          const XPathSequence.single(Duration(days: 1)),
        ),
        isNotNull,
      );
    });
  });
}
