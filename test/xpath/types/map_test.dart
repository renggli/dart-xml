import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';

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
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from other', () {
        expect(() => xsMap.cast(123), throwsA(isA<XPathEvaluationException>()));
      });
    });
  });
}
