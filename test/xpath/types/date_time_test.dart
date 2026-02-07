import 'package:test/test.dart';
import 'package:xml/src/xpath/types/date_time.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsDateTime', () {
    test('name', () {
      expect(xsDateTime.name, 'xs:dateTime');
    });
    test('matches', () {
      expect(xsDateTime.matches(DateTime.now()), isTrue);
      expect(xsDateTime.matches('2021-01-01'), isFalse);
    });
    group('cast', () {
      test('from DateTime', () {
        final dateTime = DateTime.now();
        expect(xsDateTime.cast(dateTime), same(dateTime));
      });
      test('from String', () {
        final dateTime = DateTime.parse('2021-01-01T00:00:00.000');
        expect(xsDateTime.cast('2021-01-01T00:00:00.000'), dateTime);
        expect(
          () => xsDateTime.cast('invalid'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from invalid to xs:dateTime',
            ),
          ),
        );
      });
      test('from XPathSequence', () {
        final dateTime = DateTime.now();
        expect(xsDateTime.cast(XPathSequence.single(dateTime)), dateTime);
        expect(
          () => xsDateTime.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to xs:dateTime',
            ),
          ),
        );
      });
      test('from other', () {
        expect(
          () => xsDateTime.cast(123),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to xs:dateTime',
            ),
          ),
        );
      });
    });
  });
}
