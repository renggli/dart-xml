import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';

void main() {
  group('functions', () {
    test('functions have unique names', () {
      final names = <String>{};
      for (final definition in standardFunctionDefinitions) {
        expect(
          names.add(definition.name),
          isTrue,
          reason: 'Function name "${definition.name}" is not unique',
        );
        for (final alias in definition.aliases) {
          expect(
            names.add(alias),
            isTrue,
            reason:
                'Function alias "$alias" of "${definition.name}" is not unique',
          );
        }
      }
    });
    test('functions contains all functions and their aliases', () {
      for (final definition in standardFunctionDefinitions) {
        expect(
          standardFunctions[definition.name],
          definition.call,
          reason: 'Function "${definition.name}" is missing',
        );
        for (final alias in definition.aliases) {
          expect(
            standardFunctions[alias],
            definition.call,
            reason:
                'Function alias "$alias" of "${definition.name}" is missing',
          );
        }
      }
    });
  });
}
