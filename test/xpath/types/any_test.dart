import 'package:test/test.dart';
import 'package:xml/src/xpath/types/any.dart';

void main() {
  group('xsAny', () {
    test('name', () {
      expect(xsAny.name, 'item()');
    });
    test('matches', () {
      expect(xsAny.matches(1), isTrue);
      expect(xsAny.matches('abc'), isTrue);
      expect(xsAny.matches(true), isTrue);
      expect(xsAny.matches(Object()), isTrue);
    });
    test('cast', () {
      expect(xsAny.cast(1), 1);
      expect(xsAny.cast('abc'), 'abc');
      final object = Object();
      expect(xsAny.cast(object), same(object));
    });
  });
}
