import 'package:test/test.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';

void main() {
  group('functions', () {
    test('functions have unique names', () {
      final names = <XmlName>{};
      for (final definition in standardFunctionDefinitions) {
        expect(definition.name, isNotNull);
        expect(
          names.add(definition.name),
          isTrue,
          reason: 'Function name "${definition.name}" is not unique',
        );
      }
    });
    test('functions contains all functions', () {
      for (final definition in standardFunctionDefinitions) {
        final defName = definition.name;
        final name = defName.withNamespaceUri(
          xpathNamespaceUris[defName.prefix],
        );
        expect(
          standardFunctions[name],
          definition,
          reason: 'Function "$name" is missing',
        );
      }
    });
  });
}
