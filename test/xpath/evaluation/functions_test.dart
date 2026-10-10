import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';

void main() {
  group('functions', () {
    test('functions have unique names', () {
      final names = <XmlName>{};
      for (final definition in standardFunctionDefinitions) {
        check(definition.name).isNotNull();
        check(
          because: 'Function name "${definition.name}" is not unique',
          names.add(definition.name),
        ).isTrue();
      }
    });
    test('functions contains all functions', () {
      for (final definition in standardFunctionDefinitions) {
        final defName = definition.name;
        final name = defName.withNamespaceUri(
          xpathNamespaceUris[defName.prefix],
        );
        check(
          because: 'Function "$name" is missing',
          standardFunctions[name],
        ).equals(definition);
      }
    });
  });
}
