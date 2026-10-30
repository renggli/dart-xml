import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/expressions/function.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final context = XPathConfiguration().context(XmlElement.tag('root'));
const arg1 = XPathSequence.single(XPathString('First'));
const arg2 = XPathSequence.single(XPathString('Second'));
const result = XPathSequence.single(XPathString('Confirmed'));

XPathSequence function(XPathContext context, List<XPathSequence> args) {
  check(args).deepEquals([arg1, arg2]);
  return result;
}

final xpathFunction = function.toXPathFunction(arity: 2);

void main() {
  group('DynamicFunctionExpression', () {
    test('evaluate existing function', () {
      const expr = FunctionExpression('fun', [
        LiteralExpression(arg1),
        LiteralExpression(arg2),
      ]);
      check(
        expr(
          context.configuration
              .copy(
                functions: {
                  const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                      function.toXPathFunction(arity: 2),
                },
              )
              .context(context.item)
              .copy(variables: context.variables),
        ),
      ).equals(result);
    });
    test('evaluate missing function', () {
      const expr = FunctionExpression('fun', []);
      check(() => expr(context))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Unknown function: fun'));
    });
    test('partial application expects more arguments', () {
      const expr = FunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.configuration
            .copy(
              functions: {
                const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                    function.toXPathFunction(arity: 2),
              },
            )
            .context(context.item)
            .copy(variables: context.variables),
      );
      final functionItem = functionSeq.first as XPathFunctionItem;
      check(() => functionItem(context, []))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Partial function application expects more arguments',
            ),
          );
    });
    test('partial application expects fewer arguments', () {
      const expr = FunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.configuration
            .copy(
              functions: {
                const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                    function.toXPathFunction(arity: 2),
              },
            )
            .context(context.item)
            .copy(variables: context.variables),
      );
      final functionItem = functionSeq.first as XPathFunctionItem;
      check(() => functionItem(context, [arg1, arg2]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Partial function application expects fewer arguments',
            ),
          );
    });
    test('partial application success', () {
      const expr = FunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.configuration
            .copy(
              functions: {
                const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                    function.toXPathFunction(arity: 2),
              },
            )
            .context(context.item)
            .copy(variables: context.variables),
      );
      final functionItem = functionSeq.first as XPathFunctionItem;
      check(functionItem(context, [arg1])).equals(result);
    });
    test('partial application name and arity', () {
      const expr = FunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.configuration
            .copy(
              functions: {
                const XmlName.parts(
                  'fun',
                  namespaceUri: xpathFnNamespace,
                ): function.toXPathFunction(
                  name: const XmlName.parts(
                    'fun',
                    namespaceUri: xpathFnNamespace,
                  ),
                  arity: 2,
                ),
              },
            )
            .context(context.item)
            .copy(variables: context.variables),
      );
      final fn = functionSeq.first as XPathFunctionItem;
      check(fn.name)
          .equals(const XmlName.parts('fun', namespaceUri: xpathFnNamespace));
      check(fn.arity).equals(1);
    });
  });
  group('InlineFunctionExpression', () {
    test('no arguments', () {
      const expr = InlineFunctionExpression(LiteralExpression(result), []);
      final function = expr(context).first as XPathFunctionItem;
      check(function(context, [])).equals(result);
    });
    test('name and arity', () {
      const expr = InlineFunctionExpression(LiteralExpression(result), [
        'a',
        'b',
      ]);
      final fn = expr(context).first as XPathFunctionItem;
      check(fn.name).equals(anonymousFunctionName);
      check(fn.arity).equals(2);
    });
    test('with arguments', () {
      const expr = InlineFunctionExpression(VariableExpression('a'), ['a']);
      final function = expr(context).first as XPathFunctionItem;
      check(function(context, [result])).equals(result);
    });
    test('closure', () {
      const expr = InlineFunctionExpression(FunctionExpression('foo', []), []);
      final closureContext = context.configuration
          .copy(
            functions: {
              const XmlName.parts('foo', namespaceUri: xpathFnNamespace): ((
                XPathContext context,
                List<XPathSequence> args,
              ) => result).toXPathFunction(arity: 0),
            },
          )
          .context(context.item)
          .copy(variables: context.variables);
      final function = expr(closureContext).first as XPathFunctionItem;
      check(function(context, [])).equals(result);
    });
    test('invalid number of arguments', () {
      const expr = InlineFunctionExpression(VariableExpression('a'), ['a']);
      final function = expr(context).first as XPathFunctionItem;
      check(
        () => function(context, []),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(message: 'Expected 1 arguments, but got 0'),
      );
    });
  });
  group('NamedFunctionExpression', () {
    test('evaluate', () {
      const expr = NamedFunctionExpression('foo', 0);
      final function =
          expr(
                context.configuration
                    .copy(
                      functions: {
                        const XmlName.parts(
                          'foo',
                          namespaceUri: xpathFnNamespace,
                        ): ((
                          XPathContext context,
                          List<XPathSequence> args,
                        ) => result).toXPathFunction(arity: 0),
                      },
                    )
                    .context(context.item)
                    .copy(variables: context.variables),
              ).first
              as XPathFunctionItem;
      check(function(context, [])).equals(result);
    });
    test('evaluate with standard functions', () {
      const expr = NamedFunctionExpression('fn:abs', 1);
      final function = expr(context).first as XPathFunctionItem;
      check(
        function(context, [
          XPathSequence.from([-42]),
        ]),
      ).isXPathSequence([42]);
    });
  });
  group('ArrowExpression', () {
    test('evaluate with name', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        'foo',
        const [],
      );
      check(
        expr(
          context.configuration
              .copy(
                functions: {
                  const XmlName.parts('foo', namespaceUri: xpathFnNamespace):
                      ((XPathContext context, List<XPathSequence> args) =>
                              XPathSequence.single(
                                XPathInteger.fromInt(
                                  (args[0].first as XPathInteger).asInt + 1,
                                ),
                              ))
                          .toXPathFunction(arity: 1),
                },
              )
              .context(context.item)
              .copy(variables: context.variables),
        ).first,
      ).equals(XPathInteger.fromInt(2));
    });
    test('evaluate with expression', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        const NamedFunctionExpression('foo', 1),
        const [],
      );
      check(
        expr(
          context.configuration
              .copy(
                functions: {
                  const XmlName.parts('foo', namespaceUri: xpathFnNamespace):
                      ((XPathContext context, List<XPathSequence> args) =>
                              XPathSequence.single(
                                XPathInteger.fromInt(
                                  (args[0].first as XPathInteger).asInt + 1,
                                ),
                              ))
                          .toXPathFunction(arity: 1),
                },
              )
              .context(context.item)
              .copy(variables: context.variables),
        ).first,
      ).equals(XPathInteger.fromInt(2));
    });
    test('evaluate with empty expression', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        const LiteralExpression(XPathSequence.empty),
        const [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a single function item, but got 0 items',
        ),
      );
    });
    test('evaluate with non-function expression', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(123))),
        const [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a function item, but got XPathInteger',
        ),
      );
    });
    test('evaluate with multiple items expression', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        LiteralExpression(XPathSequence([xpathFunction, xpathFunction])),
        const [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a single function item, but got 2 items',
        ),
      );
    });
    test('evaluate with invalid specifier', () {
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        123,
        const [],
      );
      check(() => expr(context))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .equals('Invalid arrow function specifier: 123');
    });
    test('evaluate with Map', () {
      final map = XPathMap({
        const XPathString('key'): const XPathSequence.single(
          XPathString('value'),
        ),
      });
      final expr = ArrowExpression(
        const LiteralExpression(XPathSequence.single(XPathString('key'))),
        LiteralExpression(XPathSequence.single(map)),
        const [],
      );
      check(expr(context)).isXPathSequence(['value']);
    });
    test('evaluate with List', () {
      const array = XPathArray([
        XPathSequence.single(XPathString('first')),
        XPathSequence.single(XPathString('second')),
      ]);
      final expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        const LiteralExpression(XPathSequence.single(array)),
        const [],
      );
      check(expr(context)).isXPathSequence(['first']);
    });
  });

  group('FunctionCallExpression', () {
    test('evaluate with empty sequence', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.empty),
        [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a single function item, but got 0 items',
        ),
      );
    });
    test('evaluate with non-function sequence', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(XPathString('text'))),
        [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a function item, but got XPathString',
        ),
      );
    });
    test('evaluate with multiple items sequence', () {
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence([xpathFunction, xpathFunction])),
        const [],
      );
      check(() => expr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          message: 'Expected a single function item, but got 2 items',
        ),
      );
    });
    test('partial application expects more arguments', () {
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(xpathFunction)),
        const [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunctionItem;
      check(() => resultFunction(context, []))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Partial function application expects more arguments',
            ),
          );
    });
    test('partial application expects fewer arguments', () {
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(xpathFunction)),
        const [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunctionItem;
      check(() => resultFunction(context, [arg1, arg2]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Partial function application expects fewer arguments',
            ),
          );
    });
    test('partial application success', () {
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(xpathFunction)),
        const [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunctionItem;
      check(resultFunction(context, [arg1])).equals(result);
    });
    test('evaluate with Map', () {
      final map = XPathMap({
        const XPathString('key'): const XPathSequence.single(
          XPathString('value'),
        ),
      });
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(map)),
        const [LiteralExpression(XPathSequence.single(XPathString('key')))],
      );
      check(expr(context)).isXPathSequence(['value']);
    });
    test('evaluate with List', () {
      const array = XPathArray([
        XPathSequence.single(XPathString('first')),
        XPathSequence.single(XPathString('second')),
      ]);
      final expr = FunctionCallExpression(
        const LiteralExpression(XPathSequence.single(array)),
        [LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1)))],
      );
      check(expr(context)).isXPathSequence(['first']);
    });
  });

  group('Partial Application', () {
    test('parser support', () {
      expectEvaluate(XmlDocument(), 'math:pow(?, 2)(3)', [9.0]);
      expectEvaluate(XmlDocument(), 'math:pow(2, ?)(3)', [8.0]);
    });
    test('multiple placeholders', () {
      expectEvaluate(XmlDocument(), 'concat(?, "-", ?)(1, 2)', ['1-2']);
    });
    test('fold-left integration', () {
      expectEvaluate(
        XmlDocument(),
        'fold-left(("a", "b", "c"), "", concat(?, ?, "-suffix"))',
        ['a-suffixb-suffixc-suffix'],
      );
    });
  });

  group('ArgumentPlaceholderExpression', () {
    test('evaluate throws StateError', () {
      const expr = ArgumentPlaceholderExpression();
      check(() => expr(context))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .equals('Argument placeholder cannot be evaluated');
    });
  });

  group('Function Resolution & Validation', () {
    final doc = XmlDocument();
    test('unbound prefix throws XPST0081', () {
      check(() => doc.xpathEvaluate('unbound-prefix:unknown-func()'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XPST0081'));
    });
    test('reserved function names rejected in named function reference', () {
      for (final name in [
        'attribute',
        'comment',
        'document-node',
        'element',
        'empty-sequence',
        'function',
        'if',
        'item',
        'map',
        'namespace-node',
        'node',
        'processing-instruction',
        'schema-attribute',
        'schema-element',
        'switch',
        'text',
        'typeswitch',
        'array',
      ]) {
        check(() => doc.xpathEvaluate('$name#1'))
            .throws<XPathParserException>()
            .which(isXPathParserException());
      }
    });
    test('inline function duplicate parameter names throw XQST0039', () {
      check(() => doc.xpathEvaluate(r'function($a, $a) { 42 }'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XQST0039'));
      check(() => doc.xpathEvaluate(r'function($Q{ }a, $a) { 42 }'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XQST0039'));
      check(() => doc.xpathEvaluate(r'function($Q{}a, $Q{   }a) { 42 }'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XQST0039'));
    });
  });
}
