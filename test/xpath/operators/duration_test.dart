import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

void main() {
  group('opDurationEqual', () {
    test('equal', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 1);
      expect(
        opDurationEqual(
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ),
        [true],
      );
    });
    test('not equal', () {
      const d1 = Duration(days: 1);
      const d3 = Duration(days: 2);
      expect(
        opDurationEqual(
          const XPathSequence.single(d1),
          const XPathSequence.single(d3),
        ),
        [false],
      );
    });
  });

  group('opYearMonthDurationLessThan', () {
    test('less than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationLessThan(
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ),
        [true],
      );
    });
  });

  group('opYearMonthDurationGreaterThan', () {
    test('greater than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationGreaterThan(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ),
        [true],
      );
    });
  });

  group('opDayTimeDurationLessThan', () {
    test('less than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationLessThan(
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ),
        [true],
      );
    });
  });

  group('opDayTimeDurationGreaterThan', () {
    test('greater than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationGreaterThan(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ),
        [true],
      );
    });
  });

  group('opAddYearMonthDurations', () {
    test('add', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddYearMonthDurations(
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ).first,
        d1 + d2,
      );
    });
  });

  group('opSubtractYearMonthDurations', () {
    test('subtract', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractYearMonthDurations(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ).first,
        d1,
      );
    });
  });

  group('opMultiplyYearMonthDuration', () {
    test('multiply', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyYearMonthDuration(
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ).first,
        d2,
      );
    });
  });

  group('opDivideYearMonthDuration', () {
    test('divide', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDuration(
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ).first,
        d1,
      );
    });
  });

  group('opDivideYearMonthDurationByYearMonthDuration', () {
    test('divide', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDurationByYearMonthDuration(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ),
        [2.0],
      );
    });
  });

  group('opAddDayTimeDurations', () {
    test('add', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddDayTimeDurations(
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ).first,
        d1 + d2,
      );
    });
  });

  group('opSubtractDayTimeDurations', () {
    test('subtract', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractDayTimeDurations(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ).first,
        d1,
      );
    });
  });

  group('opMultiplyDayTimeDuration', () {
    test('multiply', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyDayTimeDuration(
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ).first,
        d2,
      );
    });
  });

  group('opDivideDayTimeDuration', () {
    test('divide', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDuration(
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ).first,
        d1,
      );
    });
  });

  group('opDivideDayTimeDurationByDayTimeDuration', () {
    test('divide', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDurationByDayTimeDuration(
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ),
        [2.0],
      );
    });
  });

  group('opDivideDurationByDuration', () {
    test('divide by zero throws', () {
      const d1 = Duration(days: 1);
      expect(
        () => opDivideDurationByDuration(
          const XPathSequence.single(d1),
          const XPathSequence.single(Duration.zero),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
  });
}
