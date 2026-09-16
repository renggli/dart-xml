import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/types.dart';

void main() {
  group('types', () {
    test('types have unique names and aliases', () {
      final names = <String>{};
      for (final type in basicTypes) {
        expect(
          names.add(type.name),
          isTrue,
          reason: 'Type name "${type.name}" is not unique',
        );
      }
    });
    test('types contains all types and their aliases', () {
      for (final type in basicTypes) {
        expect(
          standardTypes[type.name],
          type,
          reason: 'Type name "${type.name}" is missing',
        );
      }
    });
  });
}
