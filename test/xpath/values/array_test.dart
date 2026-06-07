import 'package:test/test.dart';
import 'package:xml/src/xpath/values/array.dart';

void main() {
  group('XPathArray', () {
    test('works as List', () {
      final array = [1, 2, 3];
      expect(array, isA<XPathArray>());
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array.length, 3);
    });
  });
}
