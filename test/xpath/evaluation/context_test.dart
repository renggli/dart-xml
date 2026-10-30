import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final configuration = XPathConfiguration();
final document = XmlDocument.parse('<root/>');
final element = document.rootElement;

void main() {
  group('constructor', () {
    test('default', () {
      final context = XPathContext(configuration, XPathNode(element));
      check(context.item).equals(XPathNode(element));
      check(context.position).equals(1);
      check(context.last).equals(1);
      check(context.variables).isEmpty();
      check(context.parentContext).isNull();
      check(context.configuration).identicalTo(configuration);
      check(context.currentDateTime).isNotNull();
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
      check(context.item).equals(XPathNode(element));
      check(context.position).equals(17);
      check(context.last).equals(23);
      check(context.variables).identicalTo(variables);
      check(context.parentContext).identicalTo(parentContext);
      check(context.configuration).identicalTo(configuration);
      check(context.currentDateTime).identicalTo(customTime);
    });
    test('converts native Dart types via XPathConfiguration', () {
      final config = XPathConfiguration(
        variables: {'x': 123, 'y': 'world', 'flag': true},
      );
      final context = config.context('hello');
      check(context.item).equals(const XPathString('hello'));
      check(context.getVariable('x').toValue()).equals(123);
      check(context.getVariable('y').toValue()).equals('world');
      check(context.getVariable('flag').toValue()).equals(true);
    });
  });
  group('getVariable', () {
    test('defined in context', () {
      final context = XPathContext(
        configuration,
        XPathNode(element),
        variables: {'var': XPathSequence.fromObject(42)},
      );
      check(context.getVariable('var').toValue()).equals(42);
      check(() => context.getVariable('undefined'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Unknown variable: undefined'),
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
      check(context.getVariable('var').toValue()).equals(42);
      check(() => context.getVariable('undefined'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Unknown variable: undefined'),
          );
    });
    test('defined in static context', () {
      final configuration = XPathConfiguration(variables: const {'var': 42});
      final context = XPathContext(configuration, XPathNode(element));
      check(context.getVariable('var').toValue()).equals(42);
      check(() => context.getVariable('undefined'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Unknown variable: undefined'),
          );
    });
  });
  test('evaluate', () {
    final context = XPathContext(configuration, XPathNode(element));
    check(context.evaluate('1 + 2')).isXPathSequence([3]);
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
      check(copy).not((it) => it.identicalTo(base));
      check(copy.item).identicalTo(base.item);
      check(copy.position).identicalTo(base.position);
      check(copy.last).identicalTo(base.last);
      check(copy.variables).identicalTo(base.variables);
      check(copy.parentContext).identicalTo(base.parentContext);
      check(copy.configuration).identicalTo(base.configuration);
      check(copy.currentDateTime).identicalTo(base.currentDateTime);
    });
    test('with overrides', () {
      final variables = {'var2': XPathSequence.fromObject(43)};
      final copy = base.copy(
        item: XPathNode(document),
        position: 2,
        last: 3,
        variables: variables,
      );
      check(copy).not((it) => it.identicalTo(base));
      check(copy.item).equals(XPathNode(document));
      check(copy.position).equals(2);
      check(copy.last).equals(3);
      check(copy.variables).identicalTo(variables);
      check(copy.parentContext).identicalTo(base);
      check(copy.configuration).identicalTo(base.configuration);
      check(copy.currentDateTime).identicalTo(base.currentDateTime);
      check(copy.getVariable('var2')).isXPathSequence([43]);
      check(copy.getVariable('var1')).isXPathSequence([42]);
    });
  });
}
