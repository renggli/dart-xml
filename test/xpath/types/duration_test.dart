import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';

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
        // TODO: Update when string parsing is implemented
        expect(
          () => xsDuration.cast('P1Y'),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('from XPathSequence', () {
        const duration = Duration(seconds: 1);
        expect(xsDuration.cast(const XPathSequence.single(duration)), duration);
        expect(
          () => xsDuration.cast(XPathSequence.empty),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from other', () {
        expect(
          () => xsDuration.cast(123),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
}
