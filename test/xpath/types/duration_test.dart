import 'package:test/test.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsDuration', () {
    test('name', () {
      expect(xsDuration.name, 'xs:duration');
    });
    test('matches', () {
      const duration = Duration(seconds: 1);
      expect(xsDuration.matches(duration), isTrue);
      expect(xsDuration.matches('P1Y'), isFalse);
    });
    group('cast', () {
      test('from Duration', () {
        const duration = Duration(seconds: 1);
        expect(xsDuration.cast(duration), duration);
      });
      test('from String', () {
        expect(xsDuration.cast('P1Y'), const Duration(days: 365));
      });
      test('from XPathSequence', () {
        const duration = Duration(seconds: 1);
        expect(xsDuration.cast(const XPathSequence.single(duration)), duration);
        expect(
          () => xsDuration.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to xs:duration',
            ),
          ),
        );
      });
      test('from negative duration', () {
        expect(xsDuration.cast('-P1D'), const Duration(days: -1));
      });
      test('from invalid duration throws', () {
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
      test('from other', () {
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
  });

  group('xsDayTimeDuration', () {
    test('name', () {
      expect(xsDayTimeDuration.name, 'xs:dayTimeDuration');
    });
    test('matches', () {
      final duration = XPathDayTimeDuration(const Duration(seconds: 1));
      expect(xsDayTimeDuration.matches(duration), isTrue);
      expect(xsDayTimeDuration.matches('P1D'), isFalse);
    });
    group('cast', () {
      test('from XPathDayTimeDuration', () {
        final duration = XPathDayTimeDuration(const Duration(seconds: 1));
        expect(xsDayTimeDuration.cast(duration), duration);
      });
      test('from Duration (preserves as generic without approximation)', () {
        const duration = Duration(days: 35);
        expect(
          xsDayTimeDuration.cast(duration),
          XPathDayTimeDuration(duration),
        );
      });
      test('from XPathYearMonthDuration (discards entirely)', () {
        final duration = XPathYearMonthDuration(const Duration(days: 365));
        expect(
          xsDayTimeDuration.cast(duration),
          XPathDayTimeDuration(Duration.zero),
        );
      });
      test('from String (valid)', () {
        expect(
          xsDayTimeDuration.cast('P1D'),
          XPathDayTimeDuration(const Duration(days: 1)),
        );
        expect(
          xsDayTimeDuration.cast('-P1D'),
          XPathDayTimeDuration(const Duration(days: -1)),
        );
        expect(
          xsDayTimeDuration.cast('PT1H'),
          XPathDayTimeDuration(const Duration(hours: 1)),
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
        final duration = XPathDayTimeDuration(const Duration(seconds: 1));
        expect(
          xsDayTimeDuration.cast(XPathSequence.single(duration)),
          duration,
        );
      });
    });
  });

  group('xsYearMonthDuration', () {
    test('name', () {
      expect(xsYearMonthDuration.name, 'xs:yearMonthDuration');
    });
    test('matches', () {
      final duration = XPathYearMonthDuration(const Duration(days: 365));
      expect(xsYearMonthDuration.matches(duration), isTrue);
      expect(xsYearMonthDuration.matches('P1Y'), isFalse);
    });
    group('cast', () {
      test('from XPathYearMonthDuration', () {
        final duration = XPathYearMonthDuration(const Duration(days: 365));
        expect(xsYearMonthDuration.cast(duration), duration);
      });
      test('from Duration (approximates keeping years/months)', () {
        const duration = Duration(days: 35); // 1 month, 5 days
        expect(
          xsYearMonthDuration.cast(duration),
          XPathYearMonthDuration(const Duration(days: 30)),
        );
      });
      test('from XPathDayTimeDuration (discards entirely)', () {
        final duration = XPathDayTimeDuration(const Duration(days: 1));
        expect(
          xsYearMonthDuration.cast(duration),
          XPathYearMonthDuration(Duration.zero),
        );
      });
      test('from String (valid)', () {
        expect(
          xsYearMonthDuration.cast('P1Y'),
          XPathYearMonthDuration(const Duration(days: 365)),
        );
        expect(
          xsYearMonthDuration.cast('-P1M'),
          XPathYearMonthDuration(const Duration(days: -30)),
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
        final duration = XPathYearMonthDuration(const Duration(days: 365));
        expect(
          xsYearMonthDuration.cast(XPathSequence.single(duration)),
          duration,
        );
      });
    });
  });
}
