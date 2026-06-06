import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';

import '../../utils/matchers.dart';

final configuration = XPathConfiguration();
final document = XmlDocument.parse('<root/>');
final element = document.rootElement;

void main() {
  group('constructor', () {
    test('default', () {
      final context = XPathContext(configuration, element);
      expect(context.item, same(element));
      expect(context.position, 1);
      expect(context.last, 1);
      expect(context.variables, isEmpty);
      expect(context.parentContext, isNull);
      expect(context.configuration, same(configuration));
    });
    test('custom', () {
      final variables = {'var': 42};
      final parentContext = XPathContext(configuration, element);
      final context = XPathContext(
        configuration,
        element,
        position: 17,
        last: 23,
        variables: variables,
        parentContext: parentContext,
      );
      expect(context.item, same(element));
      expect(context.position, 17);
      expect(context.last, 23);
      expect(context.variables, same(variables));
      expect(context.parentContext, same(parentContext));
      expect(context.configuration, same(configuration));
    });
  });
  group('getVariable', () {
    test('defined in context', () {
      final context = XPathContext(
        configuration,
        element,
        variables: const {'var': 42},
      );
      expect(context.getVariable('var'), same(42));
      expect(
        () => context.getVariable('undefined'),
        throwsA(
          isXPathEvaluationException(message: 'Unknown variable: undefined'),
        ),
      );
    });
    test('defined in parent context', () {
      final context = XPathContext(
        configuration,
        element,
        parentContext: XPathContext(
          configuration,
          element,
          variables: const {'var': 42},
        ),
      );
      expect(context.getVariable('var'), same(42));
      expect(
        () => context.getVariable('undefined'),
        throwsA(
          isXPathEvaluationException(message: 'Unknown variable: undefined'),
        ),
      );
    });
    test('defined in static context', () {
      final configuration = XPathConfiguration(variables: const {'var': 42});
      final context = XPathContext(configuration, element);
      expect(context.getVariable('var'), same(42));
      expect(
        () => context.getVariable('undefined'),
        throwsA(
          isXPathEvaluationException(message: 'Unknown variable: undefined'),
        ),
      );
    });
  });
  test('evaluate', () {
    final context = XPathContext(configuration, element);
    expect(context.evaluate('1 + 2'), isXPathSequence([3]));
  });
  group('copy', () {
    final base = XPathContext(
      configuration,
      element,
      position: 17,
      last: 23,
      variables: const {'var1': 42},
    );
    test('without overrides', () {
      final copy = base.copy();
      expect(copy, isNot(same(base)));
      expect(copy.item, same(base.item));
      expect(copy.position, same(base.position));
      expect(copy.last, same(base.last));
      expect(copy.variables, same(base.variables));
      expect(copy.parentContext, same(base));
      expect(copy.configuration, same(base.configuration));
    });
    test('with overrides', () {
      const variables = {'var2': 43};
      final copy = base.copy(
        item: document,
        position: 2,
        last: 3,
        variables: variables,
      );
      expect(copy, isNot(same(base)));
      expect(copy.item, same(document));
      expect(copy.position, 2);
      expect(copy.last, 3);
      expect(copy.variables, same(variables));
      expect(copy.configuration, same(base.configuration));
    });
  });
}
