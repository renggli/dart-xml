import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  test('ContextItemExpression', () {
    final node = XmlElement.tag('root');
    final context = const XPathConfiguration.raw().context(node);
    const expr = ContextItemExpression();
    expect(expr(context).first, node);
  });
  group('VariableExpression', () {
    test('evaluate existing variable', () {
      const value = XPathSequence.single('a');
      final context = const XPathConfiguration.raw()
          .context(XmlElement.tag('root'))
          .copy(variables: const {'var': value});
      const expr = VariableExpression('var');
      expect(expr(context), value);
    });
    test('evaluate missing variable', () {
      final context = const XPathConfiguration.raw().context(
        XmlElement.tag('root'),
      );
      const expr = VariableExpression('var');
      expect(
        () => expr(context),
        throwsA(isXPathEvaluationException(message: 'Unknown variable: var')),
      );
    });
  });
  test('LiteralExpression', () {
    const value = XPathSequence.single('a');
    const expr = LiteralExpression(value);
    final context = const XPathConfiguration.raw().context(
      XmlElement.tag('root'),
    );
    expect(expr(context), value);
  });
}
