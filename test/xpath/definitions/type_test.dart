import 'package:test/test.dart';
import 'package:xml/src/xpath/definitions/type.dart';

class _TestType extends XPathType<String> {
  const _TestType();
  @override
  String get name => 'test:type';
  @override
  bool matches(Object value) => value is String;
  @override
  String cast(Object value) => value.toString();
}

void main() {
  group('XPathType', () {
    const type = _TestType();
    test('isAtomic', () {
      expect(type.isAtomic, isTrue);
    });
    test('aliases', () {
      expect(type.aliases, isEmpty);
    });
    test('castToString', () {
      expect(type.castToString('hello'), 'hello');
    });
    test('toString', () {
      expect(type.toString(), 'test:type');
    });
  });
}
