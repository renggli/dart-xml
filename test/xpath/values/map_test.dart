import 'package:test/test.dart';
import 'package:xml/src/xpath/values/map.dart';

void main() {
  group('XPathMap', () {
    test('works as Map', () {
      final map = {'a': 1, 'b': 2};
      expect(map, isA<XPathMap>());
      expect(map['a'], 1);
      expect(map['b'], 2);
      expect(map.length, 2);
    });
  });
}
