import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

XPathSequence seq(Object value) => XPathSequence.single(value);

void main() {
  // Helpers.
  final d1Ymd = XPathYearMonthDuration(1); // 1 month
  final d2Ymd = XPathYearMonthDuration(2); // 2 months
  final d1Dtd = XPathDayTimeDuration(const Duration(days: 1));
  final d2Dtd = XPathDayTimeDuration(const Duration(days: 2));
  const d1 = XPathDuration(months: 0, dayTime: Duration(days: 1));
  const d2 = XPathDuration(months: 0, dayTime: Duration(days: 1));
  const d3 = XPathDuration(months: 0, dayTime: Duration(days: 2));

  group('opDurationEqual', () {
    test('equal', () {
      expect(opDurationEqual(seq(d1), seq(d2)), [true]);
    });
    test('not equal', () {
      expect(opDurationEqual(seq(d1), seq(d3)), [false]);
    });
    test('P1Y eq P12M (yearMonth equality)', () {
      final p1y = XPathYearMonthDuration(12);
      final p12m = XPathYearMonthDuration(12);
      expect(opDurationEqual(seq(p1y), seq(p12m)), [true]);
    });
    test('P1Y ne P365D (yearMonth vs dayTime differ)', () {
      final p1y = XPathYearMonthDuration(12);
      final p365d = XPathDayTimeDuration(const Duration(days: 365));
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
        XPathYearMonthDuration(3),
      );
    });
  });

  group('opSubtractYearMonthDurations', () {
    test('subtract', () {
      expect(
        opSubtractYearMonthDurations(seq(d2Ymd), seq(d1Ymd)).first,
        XPathYearMonthDuration(1),
      );
    });
  });

  group('opMultiplyYearMonthDuration', () {
    test('multiply', () {
      expect(
        opMultiplyYearMonthDuration(seq(d1Ymd), seq(2)).first,
        XPathYearMonthDuration(2),
      );
    });
  });

  group('opDivideYearMonthDuration', () {
    test('divide', () {
      expect(
        opDivideYearMonthDuration(seq(d2Ymd), seq(2)).first,
        XPathYearMonthDuration(1),
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
  });

  group('opAddDayTimeDurations', () {
    test('add', () {
      expect(
        opAddDayTimeDurations(seq(d1Dtd), seq(d2Dtd)).first,
        XPathDayTimeDuration(const Duration(days: 3)),
      );
    });
  });

  group('opSubtractDayTimeDurations', () {
    test('subtract', () {
      expect(
        opSubtractDayTimeDurations(seq(d2Dtd), seq(d1Dtd)).first,
        XPathDayTimeDuration(const Duration(days: 1)),
      );
    });
  });

  group('opMultiplyDayTimeDuration', () {
    test('multiply', () {
      expect(
        opMultiplyDayTimeDuration(seq(d1Dtd), seq(2)).first,
        XPathDayTimeDuration(const Duration(days: 2)),
      );
    });
  });

  group('opDivideDayTimeDuration', () {
    test('divide', () {
      expect(
        opDivideDayTimeDuration(seq(d2Dtd), seq(2)).first,
        XPathDayTimeDuration(const Duration(days: 1)),
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
    test('divide by zero throws', () {
      expect(
        () => opDivideDurationByDuration(
          seq(d1Dtd),
          seq(XPathDayTimeDuration(Duration.zero)),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
  });
}
