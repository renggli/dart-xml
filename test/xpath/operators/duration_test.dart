import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/src/xpath/values/duration.dart';
import 'package:xml/src/xpath/values/sequence.dart';

import '../../utils/matchers.dart';

XPathSequence seq(Object value) => XPathSequence.single(value);

void main() {
  // Helpers.
  const d1Ymd = XPathYearMonthDuration(1); // 1 month
  const d2Ymd = XPathYearMonthDuration(2); // 2 months
  const d1Dtd = XPathDayTimeDuration(86400000000);
  const d2Dtd = XPathDayTimeDuration(172800000000);
  const d1 = XPathDuration(months: 0, days: 1);
  const d2 = XPathDuration(months: 0, days: 1);
  const d3 = XPathDuration(months: 0, days: 2);

  group('opDurationEqual', () {
    test('equal', () {
      expect(opDurationEqual(seq(d1), seq(d2)), [true]);
    });
    test('not equal', () {
      expect(opDurationEqual(seq(d1), seq(d3)), [false]);
    });
    test('P1Y eq P12M (yearMonth equality)', () {
      const p1y = XPathYearMonthDuration(12);
      const p12m = XPathYearMonthDuration(12);
      expect(opDurationEqual(seq(p1y), seq(p12m)), [true]);
    });
    test('P1Y ne P365D (yearMonth vs dayTime differ)', () {
      const p1y = XPathYearMonthDuration(12);
      const p365d = XPathDayTimeDuration(31536000000000);
      expect(opDurationEqual(seq(p1y), seq(p365d)), [false]);
    });
  });

  group('opYearMonthDurationLessThan', () {
    test('less than', () {
      expect(opYearMonthDurationLessThan(seq(d1Ymd), seq(d2Ymd)), [true]);
    });
  });

  group('opYearMonthDurationGreaterThan', () {
    test('greater than', () {
      expect(opYearMonthDurationGreaterThan(seq(d2Ymd), seq(d1Ymd)), [true]);
    });
  });

  group('opDayTimeDurationLessThan', () {
    test('less than', () {
      expect(opDayTimeDurationLessThan(seq(d1Dtd), seq(d2Dtd)), [true]);
    });
  });

  group('opDayTimeDurationGreaterThan', () {
    test('greater than', () {
      expect(opDayTimeDurationGreaterThan(seq(d2Dtd), seq(d1Dtd)), [true]);
    });
  });

  group('opAddYearMonthDurations', () {
    test('add', () {
      expect(
        opAddYearMonthDurations(seq(d1Ymd), seq(d2Ymd)).first,
        const XPathYearMonthDuration(3),
      );
    });
  });

  group('opSubtractYearMonthDurations', () {
    test('subtract', () {
      expect(
        opSubtractYearMonthDurations(seq(d2Ymd), seq(d1Ymd)).first,
        const XPathYearMonthDuration(1),
      );
    });
  });

  group('opMultiplyYearMonthDuration', () {
    test('multiply', () {
      expect(
        opMultiplyYearMonthDuration(seq(d1Ymd), seq(2)).first,
        const XPathYearMonthDuration(2),
      );
    });
  });

  group('opDivideYearMonthDuration', () {
    test('divide', () {
      expect(
        opDivideYearMonthDuration(seq(d2Ymd), seq(2)).first,
        const XPathYearMonthDuration(1),
      );
    });
  });

  group('opDivideYearMonthDurationByYearMonthDuration', () {
    test('divide', () {
      expect(
        opDivideYearMonthDurationByYearMonthDuration(seq(d2Ymd), seq(d1Ymd)),
        [2.0],
      );
    });
    test('divide by zero throws', () {
      expect(
        () => opDivideYearMonthDurationByYearMonthDuration(
          seq(d1Ymd),
          seq(const XPathYearMonthDuration(0)),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
  });

  group('opAddDayTimeDurations', () {
    test('add', () {
      expect(
        opAddDayTimeDurations(seq(d1Dtd), seq(d2Dtd)).first,
        const XPathDayTimeDuration(259200000000),
      );
    });
  });

  group('opSubtractDayTimeDurations', () {
    test('subtract', () {
      expect(
        opSubtractDayTimeDurations(seq(d2Dtd), seq(d1Dtd)).first,
        const XPathDayTimeDuration(86400000000),
      );
    });
  });

  group('opMultiplyDayTimeDuration', () {
    test('multiply', () {
      expect(
        opMultiplyDayTimeDuration(seq(d1Dtd), seq(2)).first,
        const XPathDayTimeDuration(172800000000),
      );
    });
  });

  group('opDivideDayTimeDuration', () {
    test('divide', () {
      expect(
        opDivideDayTimeDuration(seq(d2Dtd), seq(2)).first,
        const XPathDayTimeDuration(86400000000),
      );
    });
  });

  group('opDivideDayTimeDurationByDayTimeDuration', () {
    test('divide', () {
      expect(opDivideDayTimeDurationByDayTimeDuration(seq(d2Dtd), seq(d1Dtd)), [
        2.0,
      ]);
    });
  });

  group('opDivideDurationByDuration', () {
    test('divide', () {
      expect(opDivideDurationByDuration(seq(d2Dtd), seq(d1Dtd)), [2.0]);
    });
    test('divide by zero throws', () {
      expect(
        () => opDivideDurationByDuration(
          seq(d1Dtd),
          seq(const XPathDayTimeDuration(0)),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
  });

  group('opAddDurations', () {
    test('add', () {
      final result =
          opAddDurations(
                seq(const XPathDuration(months: 1, days: 1)),
                seq(const XPathDuration(months: 2, days: 3)),
              ).first
              as XPathDuration;
      expect(result.months, 3);
      expect(result.days, 4);
    });
  });

  group('opSubtractDurations', () {
    test('subtract', () {
      final result =
          opSubtractDurations(
                seq(const XPathDuration(months: 3, days: 4)),
                seq(const XPathDuration(months: 1, days: 1)),
              ).first
              as XPathDuration;
      expect(result.months, 2);
      expect(result.days, 3);
    });
  });

  group('opMultiplyDuration', () {
    test('multiply', () {
      final result =
          opMultiplyDuration(
                seq(const XPathDuration(months: 2, days: 1)),
                seq(3),
              ).first
              as XPathDuration;
      expect(result.months, 6);
      expect(result.days, 3);
    });
  });

  group('opDivideDuration', () {
    test('divide', () {
      final result =
          opDivideDuration(
                seq(const XPathDuration(months: 6, days: 3)),
                seq(3),
              ).first
              as XPathDuration;
      expect(result.months, 2);
      expect(result.days, 1);
    });
    test('divide by zero throws', () {
      expect(
        () => opDivideDuration(
          seq(const XPathDuration(months: 1, days: 1)),
          seq(0),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
  });

  group('empty input returns empty', () {
    test('opDurationEqual', () {
      expect(opDurationEqual(XPathSequence.empty, seq(d1)), isEmpty);
      expect(opDurationEqual(seq(d1), XPathSequence.empty), isEmpty);
    });
    test('opAddDurations', () {
      expect(opAddDurations(XPathSequence.empty, seq(d1)), isEmpty);
    });
    test('opSubtractDurations', () {
      expect(opSubtractDurations(XPathSequence.empty, seq(d1)), isEmpty);
    });
    test('opMultiplyDuration', () {
      expect(opMultiplyDuration(XPathSequence.empty, seq(1)), isEmpty);
    });
    test('opDivideDuration', () {
      expect(opDivideDuration(XPathSequence.empty, seq(1)), isEmpty);
    });
  });
}
