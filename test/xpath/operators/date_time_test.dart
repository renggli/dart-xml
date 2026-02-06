import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/date_time.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  test('op:dateTime-equal', () {
    final dt1 = DateTime(2023, 1, 1);
    final dt2 = DateTime(2023, 1, 1);
    final dt3 = DateTime(2023, 1, 2);
    expect(
      opDateTimeEqual(XPathSequence.single(dt1), XPathSequence.single(dt2)),
      [true],
    );
    expect(
      opDateTimeEqual(XPathSequence.single(dt1), XPathSequence.single(dt3)),
      [false],
    );
  });

  test('op:dateTime-less-than', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
    expect(
      opDateTimeLessThan(XPathSequence.single(dt1), XPathSequence.single(dt2)),
      [true],
    );
    expect(
      opDateTimeLessThan(XPathSequence.single(dt2), XPathSequence.single(dt1)),
      [false],
    );
  });
  test('op:dateTime-greater-than', () {
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
  test('op:subtract-dateTimes', () {
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
  test('op:add-duration-to-dateTime', () {
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
  test('op:subtract-duration-from-dateTime', () {
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

  test('operators coverage', () {
    // opDateEqual
    expect(
      opDateEqual(
        XPathSequence.single(DateTime(2020)),
        XPathSequence.single(DateTime(2020)),
      ),
      XPathSequence.trueSequence,
    );
    // opDateLessThan
    expect(
      opDateLessThan(
        XPathSequence.single(DateTime(2020)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opDateGreaterThan
    expect(
      opDateGreaterThan(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2020)),
      ),
      XPathSequence.trueSequence,
    );
    // opTimeEqual
    expect(
      opTimeEqual(
        XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
        XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
      ),
      XPathSequence.trueSequence,
    );
    // opTimeLessThan
    expect(
      opTimeLessThan(
        XPathSequence.single(DateTime(2020)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opTimeGreaterThan
    expect(
      opTimeGreaterThan(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2020)),
      ),
      XPathSequence.trueSequence,
    );
    // opSubtractDates
    expect(
      opSubtractDates(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2020)),
      ),
      isNotNull,
    );
    // opSubtractTimes
    expect(
      opSubtractTimes(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2020)),
      ),
      isNotNull,
    );
    // opGYearMonthEqual
    expect(
      opGYearMonthEqual(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opGYearEqual
    expect(
      opGYearEqual(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opGMonthDayEqual
    expect(
      opGMonthDayEqual(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opGMonthEqual
    expect(
      opGMonthEqual(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
    // opGDayEqual
    expect(
      opGDayEqual(
        XPathSequence.single(DateTime(2021)),
        XPathSequence.single(DateTime(2021)),
      ),
      XPathSequence.trueSequence,
    );
  });

  test('subtraction (empty)', () {
    expect(
      opSubtractDateTimes(
        XPathSequence.empty,
        XPathSequence.single(DateTime.now()),
      ),
      isEmpty,
    );
    expect(
      opSubtractDateTimes(
        XPathSequence.single(DateTime.now()),
        XPathSequence.empty,
      ),
      isEmpty,
    );
  });
  test('add duration (empty)', () {
    expect(
      opAddDurationToDateTime(
        XPathSequence.empty,
        const XPathSequence.single(Duration()),
      ),
      isEmpty,
    );
    expect(
      opAddDurationToDateTime(
        XPathSequence.single(DateTime.now()),
        XPathSequence.empty,
      ),
      isEmpty,
    );
  });
  test('subtract duration (empty)', () {
    expect(
      opSubtractDurationFromDateTime(
        XPathSequence.empty,
        const XPathSequence.single(Duration()),
      ),
      isEmpty,
    );
    expect(
      opSubtractDurationFromDateTime(
        XPathSequence.single(DateTime.now()),
        XPathSequence.empty,
      ),
      isEmpty,
    );
  });
}
