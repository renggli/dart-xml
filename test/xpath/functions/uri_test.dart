import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

void main() {
  final emptyContext = XPathContext.empty(XPathSequence.empty);
  final populatedContext = XPathContext.empty(
    XPathSequence.empty,
    environment: {'TEST_VAR': 'hello', 'ANOTHER_VAR': 'world'},
  );

  group('fn:environment-variable', () {
    test('returns empty sequence when variable is missing', () {
      expect(
        fnEnvironmentVariable(emptyContext, [
          const XPathSequence.single('TEST_VAR'),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns variable value when present', () {
      expect(
        fnEnvironmentVariable(populatedContext, [
          const XPathSequence.single('TEST_VAR'),
        ]),
        isXPathSequence(['hello']),
      );
      expect(
        fnEnvironmentVariable(populatedContext, [
          const XPathSequence.single('ANOTHER_VAR'),
        ]),
        isXPathSequence(['world']),
      );
    });
  });

  group('fn:available-environment-variables', () {
    test('returns empty sequence for empty environment', () {
      expect(
        fnAvailableEnvironmentVariables(emptyContext, []),
        isXPathSequence(isEmpty),
      );
    });

    test('returns all available variable names', () {
      final result = fnAvailableEnvironmentVariables(populatedContext, []);
      expect(result.length, equals(2));
      expect(result.toSet(), equals({'TEST_VAR', 'ANOTHER_VAR'}));
    });
  });
}
