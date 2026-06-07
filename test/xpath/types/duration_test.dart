import 'package:test/test.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/values/duration.dart';
import 'package:xml/src/xpath/values/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsDuration', () {
    test('name', () {
      expect(xsDuration.name, 'xs:duration');
    });
    test('matches', () {
      // xs:duration matches XPathDuration and its subtypes.
      const d = XPathDuration(months: 1);
      expect(xsDuration.matches(d), isTrue);
      expect(xsDuration.matches(const XPathYearMonthDuration(12)), isTrue);
      expect(xsDuration.matches(const XPathDayTimeDuration(1000000)), isTrue);
      expect(xsDuration.matches('P1Y'), isFalse);
    });
    group('cast', () {
      test('from XPathDuration', () {
        const d = XPathDuration(months: 1, days: 2);
        expect(xsDuration.cast(d), d);
      });
      test('from XPathYearMonthDuration', () {
        const d = XPathYearMonthDuration(12);
        expect(xsDuration.cast(d), d);
      });
      test('from XPathDayTimeDuration', () {
        const d = XPathDayTimeDuration(10800000000);
        expect(xsDuration.cast(d), d);
      });
      test('from String P1Y', () {
        final result = xsDuration.cast('P1Y');
        expect(result.totalMonths, 12);
        expect(result.toDuration(), Duration.zero);
      });
      test('from String P1Y2M3DT10H30M', () {
        final result = xsDuration.cast('P1Y2M3DT10H30M');
        expect(result.totalMonths, 14);
        expect(
          result.toDuration(),
          const Duration(days: 3, hours: 10, minutes: 30),
        );
      });
      test('from String with leading whitespace', () {
        // K-SeqExprCast-640: whitespace should be trimmed.
        final d1 = xsDuration.cast(' P1Y2M3DT10H30M ');
        final d2 = xsDuration.cast('P1Y2M3DT10H30M');
        expect(d1, d2);
      });
      test('from negative duration', () {
        final result = xsDuration.cast('-P1D');
        expect(result.totalMonths, 0);
        expect(result.toDuration(), const Duration(days: -1));
      });
      test('from XPathSequence', () {
        const d = XPathDuration(months: 1);
        expect(xsDuration.cast(const XPathSequence.single(d)), d);
        expect(
          () => xsDuration.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to xs:duration',
            ),
          ),
        );
      });
      test('from invalid string throws', () {
        expect(
          () => xsDuration.cast('abc'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from abc to xs:duration',
            ),
          ),
        );
        expect(
          () => xsDuration.cast('P'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from P to xs:duration',
            ),
          ),
        );
      });
      test('from other throws', () {
        expect(
          () => xsDuration.cast(123),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to xs:duration',
            ),
          ),
        );
      });
    });
    group('castToString', () {
      test('zero', () {
        expect(xsDuration.castToString(const XPathDuration(months: 0)), 'PT0S');
      });
      test('P1Y2M3DT10H30M', () {
        final d = xsDuration.cast('P1Y2M3DT10H30M');
        expect(xsDuration.castToString(d), 'P1Y2M3DT10H30M');
      });
    });
    group('equality', () {
      test('P1Y equals P12M', () {
        // Both have yearMonth=12 months, dayTime=zero.
        expect(xsDuration.cast('P1Y'), xsDuration.cast('P12M'));
      });
      test('P1Y not equal to P365D', () {
        // P1Y: months=12, dayTime=zero. P365D: months=0, dayTime=365 days.
        expect(xsDuration.cast('P1Y'), isNot(xsDuration.cast('P365D')));
      });
    });
  });

  group('xsDayTimeDuration', () {
    test('name', () {
      expect(xsDayTimeDuration.name, 'xs:dayTimeDuration');
    });
    test('matches', () {
      const duration = XPathDayTimeDuration(1000000);
      expect(xsDayTimeDuration.matches(duration), isTrue);
      expect(xsDayTimeDuration.matches('P1D'), isFalse);
    });
    group('cast', () {
      test('from XPathDayTimeDuration', () {
        const duration = XPathDayTimeDuration(1000000);
        expect(xsDayTimeDuration.cast(duration), duration);
      });
      test('from Duration', () {
        const duration = Duration(days: 35);
        expect(
          xsDayTimeDuration.cast(duration),
          XPathDayTimeDuration.fromDuration(duration),
        );
      });
      test('from XPathYearMonthDuration (discards entirely)', () {
        const duration = XPathYearMonthDuration(12);
        expect(xsDayTimeDuration.cast(duration), const XPathDayTimeDuration(0));
      });
      test('from String (valid)', () {
        expect(
          xsDayTimeDuration.cast('P1D'),
          const XPathDayTimeDuration(86400000000),
        );
        expect(
          xsDayTimeDuration.cast('-P1D'),
          const XPathDayTimeDuration(-86400000000),
        );
        expect(
          xsDayTimeDuration.cast('PT1H'),
          const XPathDayTimeDuration(3600000000),
        );
      });
      test('from String (invalid throws)', () {
        expect(
          () => xsDayTimeDuration.cast('P1Y'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDayTimeDuration.cast('P1M'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDayTimeDuration.cast('P1Y1D'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDayTimeDuration.cast('P'),
          throwsA(isXPathEvaluationException()),
        );
      });
      test('from XPathSequence', () {
        const duration = XPathDayTimeDuration(1000000);
        expect(
          xsDayTimeDuration.cast(const XPathSequence.single(duration)),
          duration,
        );
      });
    });
    group('castToString', () {
      test('PT0S', () {
        expect(
          xsDayTimeDuration.castToString(const XPathDayTimeDuration(0)),
          'PT0S',
        );
      });
      test('positive', () {
        expect(
          xsDayTimeDuration.castToString(
            XPathDayTimeDuration.fromDuration(
              const Duration(days: 3, hours: 8, minutes: 2, seconds: 1),
            ),
          ),
          'P3DT8H2M1S',
        );
      });
      test('negative', () {
        expect(
          xsDayTimeDuration.castToString(
            XPathDayTimeDuration.fromDuration(
              const Duration(
                days: -3,
                hours: -8,
                minutes: -2,
                milliseconds: -1030,
              ),
            ),
          ),
          '-P3DT8H2M1.03S',
        );
      });
      test('large positive days', () {
        expect(
          xsDayTimeDuration.castToString(
            XPathDayTimeDuration.fromDuration(
              const Duration(
                days: 45678,
                hours: 8,
                minutes: 2,
                milliseconds: 1030,
              ),
            ),
          ),
          'P45678DT8H2M1.03S',
        );
      });
    });
  });

  group('xsYearMonthDuration', () {
    test('name', () {
      expect(xsYearMonthDuration.name, 'xs:yearMonthDuration');
    });
    test('matches', () {
      const duration = XPathYearMonthDuration(12);
      expect(xsYearMonthDuration.matches(duration), isTrue);
      expect(xsYearMonthDuration.matches('P1Y'), isFalse);
    });
    group('cast', () {
      test('from XPathYearMonthDuration', () {
        const duration = XPathYearMonthDuration(12);
        expect(xsYearMonthDuration.cast(duration), duration);
      });
      test('from XPathDayTimeDuration (discards entirely)', () {
        const duration = XPathDayTimeDuration(86400000000);
        expect(
          xsYearMonthDuration.cast(duration),
          const XPathYearMonthDuration(0),
        );
      });
      test('from String P1Y', () {
        expect(
          xsYearMonthDuration.cast('P1Y'),
          const XPathYearMonthDuration(12),
        );
      });
      test('from String -P1M', () {
        expect(
          xsYearMonthDuration.cast('-P1M'),
          const XPathYearMonthDuration(-1),
        );
      });
      test('from String (invalid throws)', () {
        expect(
          () => xsYearMonthDuration.cast('P1D'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsYearMonthDuration.cast('PT1H'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsYearMonthDuration.cast('P1Y1D'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsYearMonthDuration.cast('P'),
          throwsA(isXPathEvaluationException()),
        );
      });
      test('from XPathSequence', () {
        const duration = XPathYearMonthDuration(12);
        expect(
          xsYearMonthDuration.cast(const XPathSequence.single(duration)),
          duration,
        );
      });
    });
    group('castToString', () {
      test('zero', () {
        expect(
          xsYearMonthDuration.castToString(const XPathYearMonthDuration(0)),
          'P0M',
        );
      });
      test('P1Y', () {
        expect(
          xsYearMonthDuration.castToString(const XPathYearMonthDuration(12)),
          'P1Y',
        );
      });
      test('P1Y3M', () {
        expect(
          xsYearMonthDuration.castToString(const XPathYearMonthDuration(15)),
          'P1Y3M',
        );
      });
      test('-P1M', () {
        expect(
          xsYearMonthDuration.castToString(const XPathYearMonthDuration(-1)),
          '-P1M',
        );
      });
    });
    group('arithmetic', () {
      test('addition', () {
        expect(
          const XPathYearMonthDuration(12) + const XPathYearMonthDuration(3),
          const XPathYearMonthDuration(15),
        );
      });
      test('subtraction', () {
        expect(
          const XPathYearMonthDuration(12) - const XPathYearMonthDuration(3),
          const XPathYearMonthDuration(9),
        );
      });
      test('multiply', () {
        expect(
          const XPathYearMonthDuration(12) * 2,
          const XPathYearMonthDuration(24),
        );
      });
      test('comparison', () {
        expect(
          const XPathYearMonthDuration(12) < const XPathYearMonthDuration(24),
          isTrue,
        );
        expect(
          const XPathYearMonthDuration(24) > const XPathYearMonthDuration(12),
          isTrue,
        );
      });
    });
  });
}
