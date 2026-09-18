import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/item.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';

import '../../utils/matchers.dart';

final configuration = XPathConfiguration();
final document = XmlDocument.parse('<root/>');
final element = document.rootElement;

void main() {
  group('constructor', () {
    test('default', () {
      final context = XPathContext(configuration, XPathNode(element));
      expect(context.item, XPathNode(element));
      expect(context.position, 1);
      expect(context.last, 1);
      expect(context.variables, isEmpty);
      expect(context.parentContext, isNull);
      expect(context.configuration, same(configuration));
      expect(context.currentDateTime, isNotNull);
    });
    test('custom', () {
      final variables = {'var': XPathSequence.fromObject(42)};
      final parentContext = XPathContext(configuration, XPathNode(element));
      final customTime = DateTime(2020, 5, 5);
      final context = XPathContext(
        configuration,
        XPathNode(element),
        position: 17,
        last: 23,
        variables: variables,
        parentContext: parentContext,
        currentDateTime: customTime,
      );
      expect(context.item, XPathNode(element));
      expect(context.position, 17);
      expect(context.last, 23);
      expect(context.variables, same(variables));
      expect(context.parentContext, same(parentContext));
      expect(context.configuration, same(configuration));
      expect(context.currentDateTime, same(customTime));
    });
    test('converts native Dart types via XPathConfiguration', () {
      final config = XPathConfiguration(
        variables: {'x': 123, 'y': 'world', 'flag': true},
      );
      final context = config.context('hello');
      expect(context.item, const XPathString('hello'));
      expect(context.getVariable('x').toValue(), 123);
      expect(context.getVariable('y').toValue(), 'world');
      expect(context.getVariable('flag').toValue(), true);
    });
  });
  group('getVariable', () {
    test('defined in context', () {
      final context = XPathContext(
        configuration,
        XPathNode(element),
        variables: {'var': XPathSequence.fromObject(42)},
      );
      expect(context.getVariable('var').toValue(), equals(42));
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
        XPathNode(element),
        parentContext: XPathContext(
          configuration,
          XPathNode(element),
          variables: {'var': XPathSequence.fromObject(42)},
        ),
      );
      expect(context.getVariable('var').toValue(), equals(42));
      expect(
        () => context.getVariable('undefined'),
        throwsA(
          isXPathEvaluationException(message: 'Unknown variable: undefined'),
        ),
      );
    });
    test('defined in static context', () {
      final configuration = XPathConfiguration(variables: const {'var': 42});
      final context = XPathContext(configuration, XPathNode(element));
      expect(context.getVariable('var').toValue(), equals(42));
      expect(
        () => context.getVariable('undefined'),
        throwsA(
          isXPathEvaluationException(message: 'Unknown variable: undefined'),
        ),
      );
    });
  });
  test('evaluate', () {
    final context = XPathContext(configuration, XPathNode(element));
    expect(context.evaluate('1 + 2'), isXPathSequence([3]));
  });
  group('copy', () {
    final base = XPathContext(
      configuration,
      XPathNode(element),
      position: 17,
      last: 23,
      variables: {'var1': XPathSequence.fromObject(42)},
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
      expect(copy.currentDateTime, same(base.currentDateTime));
    });
    test('with overrides', () {
      final variables = {'var2': XPathSequence.fromObject(43)};
      final copy = base.copy(
        item: XPathNode(document),
        position: 2,
        last: 3,
        variables: variables,
      );
      expect(copy, isNot(same(base)));
      expect(copy.item, XPathNode(document));
      expect(copy.position, 2);
      expect(copy.last, 3);
      expect(copy.variables, same(variables));
      expect(copy.configuration, same(base.configuration));
      expect(copy.currentDateTime, same(base.currentDateTime));
    });
  });
}
