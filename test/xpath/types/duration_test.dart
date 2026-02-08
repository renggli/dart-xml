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
}
