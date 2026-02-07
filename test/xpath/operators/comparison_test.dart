import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/comparison.dart';

void main() {
  group('comparator', () {
    test('compare numbers', () {
      expect(compare(1, 2), -1);
      expect(compare(2, 2), 0);
      expect(compare(2, 1), 1);
      expect(compare(1.0, 2.0), -1);
      expect(compare(1, 1.0), 0);
    });
    test('compare strings', () {
      expect(compare('a', 'b'), -1);
      expect(compare('b', 'b'), 0);
      expect(compare('b', 'a'), 1);
    });
    test('compare booleans', () {
      expect(compare(false, true), -1);
      expect(compare(true, true), 0);
      expect(compare(false, false), 0);
      expect(compare(true, false), 1);
    });
    test('compare mixed types', () {
      expect(compare(1, '2'), -1); // "1" < "2"
      expect(compare('2', 1), 1); // "2" > "1"
    });
  });
}
