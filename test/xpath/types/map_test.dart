import 'package:test/test.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsMap', () {
    test('name', () {
      expect(xsMap.name, 'map(*)');
    });
    test('matches', () {
      expect(xsMap.matches({'a': 1}), isTrue);
      expect(xsMap.matches('foo'), isFalse);
    });
    group('cast', () {
      test('from map', () {
        final map = {'a': 1};
        expect(xsMap.cast(map), same(map));
      });
      test('from sequence', () {
        final map = {'a': 1};
        expect(xsMap.cast(XPathSequence.single(map)), same(map));
        expect(
          () => xsMap.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to map(*)',
            ),
          ),
        );
      });
      test('from other', () {
        expect(
          () => xsMap.cast(123),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to map(*)',
            ),
          ),
        );
      });
    });
  });
}
