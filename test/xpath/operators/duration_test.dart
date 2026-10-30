import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

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
      check(result.months).equals(3);
      check(result.days).equals(4);
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
      check(result.months).equals(2);
      check(result.days).equals(3);
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
      check(result.months).equals(6);
      check(result.days).equals(3);
    });
    test('multiply by NaN throws', () {
      check(
        () => opMultiplyDuration(
          seq(const XPathDuration(months: 2, days: 1)),
          seq(double.nan),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
    test('multiply by Infinity throws', () {
      check(
        () => opMultiplyDuration(
          seq(const XPathDuration(months: 2, days: 1)),
          seq(double.infinity),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
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
      check(result.months).equals(2);
      check(result.days).equals(1);
    });
    test('divide by fractional divisor', () {
      final d1 = XPathDuration.tryParse('PT3H')!;
      final r1 = opDivideDuration(seq(d1), seq(1.5)).first as XPathDuration;
      check(r1.stringValue).equals('PT2H');

      final r2 = opDivideDuration(seq(d1), seq(0.4)).first as XPathDuration;
      check(r2.stringValue).equals('PT7H30M');
    });
    test('divide by zero throws', () {
      check(
            () => opDivideDuration(
              seq(const XPathDuration(months: 1, days: 1)),
              seq(0),
            ),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Division by zero'));
    });
    test('divide by NaN throws', () {
      check(
        () => opDivideDuration(
          seq(const XPathDuration(months: 6, days: 3)),
          seq(double.nan),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
    test('divide by Infinity returns zero duration', () {
      final result =
          opDivideDuration(
                seq(const XPathDuration(months: 6, days: 3)),
                seq(double.infinity),
              ).first
              as XPathDuration;
      check(result.months).equals(0);
      check(result.days).equals(0);
    });
  });

  group('opDivideDurationByDuration', () {
    test('divide', () {
      check(opDivideDurationByDuration(seq(d2Dtd), seq(d1Dtd)))
          .isXPathSequence([2.0]);
    });
    test('divide by zero throws', () {
      check(
            () => opDivideDurationByDuration(
              seq(d1Dtd),
              seq(const XPathDuration.dayTime(0)),
            ),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Division by zero'));
    });
    test('divide yearMonth by zero throws', () {
      check(
        () => opDivideDurationByDuration(
          seq(const XPathDuration.yearMonth(12)),
          seq(const XPathDuration.yearMonth(0)),
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.FOAR0001,
          message: 'Division by zero',
        ),
      );
    });
    test('divide incompatible duration types throws XPTY0004', () {
      check(
        () => opDivideDurationByDuration(
          seq(const XPathDuration.yearMonth(12)),
          seq(d1Dtd),
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.XPTY0004,
          message: 'Cannot divide xs:yearMonthDuration by xs:dayTimeDuration',
        ),
      );
    });
  });

  group('empty input returns empty', () {
    test('opAddDurations', () {
      check(opAddDurations(XPathSequence.empty, seq(d1))).isEmpty();
    });
    test('opSubtractDurations', () {
      check(opSubtractDurations(XPathSequence.empty, seq(d1))).isEmpty();
    });
    test('opMultiplyDuration', () {
      check(opMultiplyDuration(XPathSequence.empty, seq(1))).isEmpty();
    });
    test('opDivideDuration', () {
      check(opDivideDuration(XPathSequence.empty, seq(1))).isEmpty();
    });
  });
}
