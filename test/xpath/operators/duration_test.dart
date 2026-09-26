import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

XPathSequence seq(Object value) => XPathSequence.single(switch (value) {
  final XPathItem item => item,
  final double v when !v.isFinite => XPathDouble(v),
  final int v => XPathInteger.fromInt(v),
  final double v => XPathDouble(v),
  _ => throw ArgumentError.value(value),
});

void main() {
  const d1Dtd = XPathDuration.dayTime(86400000000);
  const d2Dtd = XPathDuration.dayTime(172800000000);
  const d1 = XPathDuration(months: 0, days: 1);

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
    test('multiply by NaN throws', () {
      expect(
        () => opMultiplyDuration(
          seq(const XPathDuration(months: 2, days: 1)),
          seq(double.nan),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('multiply by Infinity throws', () {
      expect(
        () => opMultiplyDuration(
          seq(const XPathDuration(months: 2, days: 1)),
          seq(double.infinity),
        ),
        throwsA(isXPathEvaluationException()),
      );
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
    test('divide by NaN throws', () {
      expect(
        () => opDivideDuration(
          seq(const XPathDuration(months: 6, days: 3)),
          seq(double.nan),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('divide by Infinity returns zero duration', () {
      final result =
          opDivideDuration(
                seq(const XPathDuration(months: 6, days: 3)),
                seq(double.infinity),
              ).first
              as XPathDuration;
      expect(result.months, 0);
      expect(result.days, 0);
    });
  });

  group('opDivideDurationByDuration', () {
    test('divide', () {
      expect(
        opDivideDurationByDuration(seq(d2Dtd), seq(d1Dtd)),
        isXPathSequence([2.0]),
      );
    });
    test('divide by zero throws', () {
      expect(
        () => opDivideDurationByDuration(
          seq(d1Dtd),
          seq(const XPathDuration.dayTime(0)),
        ),
        throwsA(isXPathEvaluationException(message: 'Division by zero')),
      );
    });
    test('divide yearMonth by zero throws', () {
      expect(
        () => opDivideDurationByDuration(
          seq(const XPathDuration.yearMonth(12)),
          seq(const XPathDuration.yearMonth(0)),
        ),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.FOAR0001,
            message: 'Division by zero',
          ),
        ),
      );
    });
    test('divide incompatible duration types throws XPTY0004', () {
      expect(
        () => opDivideDurationByDuration(
          seq(const XPathDuration.yearMonth(12)),
          seq(d1Dtd),
        ),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains(
              'Cannot divide xs:yearMonthDuration by xs:dayTimeDuration',
            ),
          ),
        ),
      );
    });
  });

  group('empty input returns empty', () {
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
