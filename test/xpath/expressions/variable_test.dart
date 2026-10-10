import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

void main() {
  group('ContextItemExpression', () {
    test('node context item', () {
      final node = XmlElement.tag('root');
      final context = const XPathConfiguration.raw().context(node);
      const expr = ContextItemExpression();
      check(expr(context)).isXPathSequence([node]);
    });
    test('sequence context item', () {
      final seq = XPathSequence([XPathInteger.fromInt(42)]);
      final context = const XPathConfiguration.raw().context()..item = seq;
      const expr = ContextItemExpression();
      check(expr(context)).equals(seq);
    });
    test('undefined context item', () {
      final context = const XPathConfiguration.raw().context();
      const expr = ContextItemExpression();
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.XPDY0002,
          message: 'Context item is undefined',
        ),
      );
    });
  });
  group('VariableExpression', () {
    test('evaluate existing variable', () {
      const value = XPathSequence.single(XPathString('a'));
      final context = const XPathConfiguration.raw()
          .context(XmlElement.tag('root'))
          .copy(variables: const {'var': value});
      const expr = VariableExpression('var');
      check(expr(context)).equals(value);
    });
    test('evaluate missing variable', () {
      final context = const XPathConfiguration.raw().context(
        XmlElement.tag('root'),
      );
      const expr = VariableExpression('var');
      check(() => expr(context))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Unknown variable: var'));
    });
  });
  test('LiteralExpression', () {
    const value = XPathSequence.single(XPathString('a'));
    const expr = LiteralExpression(value);
    final context = const XPathConfiguration.raw().context(
      XmlElement.tag('root'),
    );
    check(expr(context)).equals(value);
  });
}
