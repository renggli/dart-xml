import 'package:test/test.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';

void main() {
  group('functions', () {
    test('functions have unique names', () {
      final names = <XmlName>{};
      for (final definition in standardFunctionDefinitions) {
        expect(
          names.add(definition.name),
          isTrue,
          reason: 'Function name "${definition.name}" is not unique',
        );
      }
    });
    test('functions contains all functions', () {
      for (final definition in standardFunctionDefinitions) {
        final name = definition.name.withNamespaceUri(
          xpathNamespaceUris[definition.name.prefix],
        );
        expect(
          standardFunctions[name],
          definition.call,
          reason: 'Function "$name" is missing',
        );
      }
    });
  });
}
