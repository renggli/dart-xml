import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/xdm/types.dart';

void main() {
  group('types', () {
    test('types have unique names and aliases', () {
      final names = <String>{};
      for (final type in allStandardTypes) {
        check(
          because: 'Type name "${type.name}" is not unique',
          names.add(type.name),
        ).isTrue();
      }
    });
    test('types contains all types and their aliases', () {
      for (final type in allStandardTypes) {
        check(
          because: 'Type name "${type.name}" is missing',
          standardTypes[type.name],
        ).equals(type);
      }
    });
  });
}
