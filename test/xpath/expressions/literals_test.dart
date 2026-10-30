import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument();
  test('integer', () {
    expectEvaluate(xml, '0', [0]);
    expectEvaluate(xml, '12', [12]);
    expectEvaluate(xml, '123', [123]);
  });
  test('decimal', () {
    expectEvaluate(xml, '.0', [0.0]);
    expectEvaluate(xml, '.12', [0.12]);
    expectEvaluate(xml, '.123', [0.123]);
    expectEvaluate(xml, '0.1', [0.1]);
    expectEvaluate(xml, '12.34', [12.34]);
    expectEvaluate(xml, '123.456', [123.456]);
    expectEvaluate(xml, '0.', [0.0]);
    expectEvaluate(xml, '12.', [12.0]);
    expectEvaluate(xml, '123.', [123.0]);
  });
  test('double', () {
    expectEvaluate(xml, '1e2', [1e2]);
    expectEvaluate(xml, '1E2', [1e2]);
    expectEvaluate(xml, '1e+2', [1e+2]);
    expectEvaluate(xml, '1e-2', [1e-2]);
    expectEvaluate(xml, '.1e2', [.1e2]);
    expectEvaluate(xml, '.1E2', [.1e2]);
    expectEvaluate(xml, '.1e+2', [.1e+2]);
    expectEvaluate(xml, '.1e-2', [.1e-2]);
    expectEvaluate(xml, '1.2e3', [1.2e3]);
    expectEvaluate(xml, '1.2E3', [1.2E3]);
    expectEvaluate(xml, '1.2e+3', [1.2e+3]);
    expectEvaluate(xml, '1.2e-3', [1.2e-3]);
    expectEvaluate(xml, '1.e2', [1.0e2]);
    expectEvaluate(xml, '1.E2', [1.0E2]);
    expectEvaluate(xml, '1.e+2', [1.0e+2]);
    expectEvaluate(xml, '1.e-2', [1.0e-2]);
  });
  test('string', () {
    expectEvaluate(xml, '""', ['']);
    expectEvaluate(xml, '"Bar"', ['Bar']);
    expectEvaluate(xml, "''", ['']);
    expectEvaluate(xml, "'Foo'", ['Foo']);
  });
  test('variable', () {
    expectEvaluate(xml, r'$a', ['hello'], variables: {'a': 'hello'});
    expectEvaluate(xml, r'$a', [123], variables: {'a': 123});
    expectEvaluate(xml, r'$a', [false], variables: {'a': false});
    check(() => expectEvaluate(xml, r'$unknown', null))
        .throws<XPathEvaluationException>()
        .which(isXPathEvaluationException());
  });
  test('function', () {
    expectEvaluate(
      xml,
      'custom("hello", 42, true())',
      ['ok'],
      functions: {
        const XmlName.parts(
          'custom',
          namespaceUri: xpathFnNamespace,
        ): ((XPathContext context, List<XPathSequence> arguments) {
          check((context.item as XPathNode).node).identicalTo(xml);
          check(context.position).equals(1);
          check(context.last).equals(1);
          check(arguments[0]).isXPathSequence(['hello']);
          check(arguments[1]).isXPathSequence([42]);
          check(arguments[2]).isXPathSequence([true]);
          return const XPathSequence.single(XPathString('ok'));
        }).toXPathFunction(arity: 3),
      },
    );
    check(() => expectEvaluate(xml, 'unknown()', null))
        .throws<XPathEvaluationException>()
        .which(isXPathEvaluationException());
  });
}
