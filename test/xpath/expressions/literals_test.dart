import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
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
    expectEvaluate(
      xml,
      '\$a',
      ['hello'],
      variables: {'a': const XPathSequence.single('hello')},
    );
    expectEvaluate(
      xml,
      '\$a',
      [123],
      variables: {'a': const XPathSequence.single(123)},
    );
    expectEvaluate(
      xml,
      '\$a',
      [false],
      variables: {'a': const XPathSequence.single(false)},
    );
    expect(
      () => expectEvaluate(xml, '\$unknown', anything),
      throwsA(isXPathEvaluationException()),
    );
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
        ): (context, arguments) {
          expect(context.item, same(xml));
          expect(context.position, 1);
          expect(context.last, 1);
          expect(arguments, [
            ['hello'],
            [42],
            [true],
          ]);
          return const XPathSequence.single('ok');
        },
      },
    );
    expect(
      () => expectEvaluate(xml, 'unknown()', anything),
      throwsA(isXPathEvaluationException()),
    );
  });
}
