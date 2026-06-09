import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/expressions/function.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/values/function.dart';
import 'package:xml/src/xpath/values/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final context = XPathConfiguration().context(XmlElement.tag('root'));
const arg1 = XPathSequence.single('First');
const arg2 = XPathSequence.single('Second');
const result = XPathSequence.single('Confirmed');

XPathSequence function(XPathContext context, List<XPathSequence> args) {
  expect(args, [arg1, arg2]);
  return result;
}

void main() {
  group('DynamicFunctionExpression', () {
    test('evaluate existing function', () {
      const expr = FunctionExpression('fun', [
        LiteralExpression(arg1),
        LiteralExpression(arg2),
      ]);
      expect(
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
        result,
      );
    });
    test('evaluate missing function', () {
      const expr = FunctionExpression('fun', []);
      expect(
        () => expr(context),
        throwsA(isXPathEvaluationException(message: 'Unknown function: fun')),
      );
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
      final functionItem = functionSeq.first as XPathFunction;
      expect(
        () => functionItem(context, []),
        throwsA(
          isXPathEvaluationException(
            message: 'Partial function application expects more arguments',
          ),
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
      final functionItem = functionSeq.first as XPathFunction;
      expect(
        () => functionItem(context, [arg1, arg2]),
        throwsA(
          isXPathEvaluationException(
            message: 'Partial function application expects fewer arguments',
          ),
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
      final functionItem = functionSeq.first as XPathFunction;
      expect(functionItem(context, [arg1]), result);
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
      final fn = functionSeq.first as XPathFunction;
      expect(
        fn.name,
        const XmlName.parts('fun', namespaceUri: xpathFnNamespace),
      );
      expect(fn.arity, 1);
    });
  });
  group('InlineFunctionExpression', () {
    test('no arguments', () {
      const expr = InlineFunctionExpression(LiteralExpression(result), []);
      final function = expr(context).first as XPathFunction;
      expect(function(context, []), result);
    });
    test('name and arity', () {
      const expr = InlineFunctionExpression(LiteralExpression(result), [
        'a',
        'b',
      ]);
      final fn = expr(context).first as XPathFunction;
      expect(fn.name, const XmlName.qualified('dynamic-function'));
      expect(fn.arity, 2);
    });
    test('with arguments', () {
      const expr = InlineFunctionExpression(VariableExpression('a'), ['a']);
      final function = expr(context).first as XPathFunction;
      expect(function(context, [result]), result);
    });
    test('closure', () {
      const expr = InlineFunctionExpression(FunctionExpression('foo', []), []);
      final closureContext = context.configuration
          .copy(
            functions: {
              const XmlName.parts(
                'foo',
                namespaceUri: xpathFnNamespace,
              ): ((XPathContext context, List<XPathSequence> args) => result)
                  .toXPathFunction(arity: 0),
            },
          )
          .context(context.item)
          .copy(variables: context.variables);
      final function = expr(closureContext).first as XPathFunction;
      expect(function(context, []), result);
    });
    test('invalid number of arguments', () {
      const expr = InlineFunctionExpression(VariableExpression('a'), ['a']);
      final function = expr(context).first as XPathFunction;
      expect(
        () => function(context, []),
        throwsA(
          isXPathEvaluationException(
            message: 'Expected 1 arguments, but got 0',
          ),
        ),
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
                        ): ((XPathContext context, List<XPathSequence> args) =>
                                result)
                            .toXPathFunction(arity: 0),
                      },
                    )
                    .context(context.item)
                    .copy(variables: context.variables),
              ).first
              as XPathFunction;
      expect(function(context, []), result);
    });
    test('evaluate with standard functions', () {
      const expr = NamedFunctionExpression('fn:abs', 1);
      final function = expr(context).first as XPathFunction;
      expect(
        function(context, [const XPathSequence.single(-42)]),
        isXPathSequence([42]),
      );
    });
  });
  group('ArrowExpression', () {
    test('evaluate with name', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        'foo',
        [],
      );
      expect(
        expr(
          context.configuration
              .copy(
                functions: {
                  const XmlName.parts('foo', namespaceUri: xpathFnNamespace):
                      ((XPathContext context, List<XPathSequence> args) =>
                              XPathSequence.single((args[0].first as int) + 1))
                          .toXPathFunction(arity: 1),
                },
              )
              .context(context.item)
              .copy(variables: context.variables),
        ).first,
        2,
      );
    });
    test('evaluate with expression', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        NamedFunctionExpression('foo', 1),
        [],
      );
      expect(
        expr(
          context.configuration
              .copy(
                functions: {
                  const XmlName.parts('foo', namespaceUri: xpathFnNamespace):
                      ((XPathContext context, List<XPathSequence> args) =>
                              XPathSequence.single((args[0].first as int) + 1))
                          .toXPathFunction(arity: 1),
                },
              )
              .context(context.item)
              .copy(variables: context.variables),
        ).first,
        2,
      );
    });
    test('evaluate with empty expression', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        LiteralExpression(XPathSequence.empty),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message:
                'Expected a single function item, but got an empty sequence',
          ),
        ),
      );
    });
    test('evaluate with non-function expression', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        LiteralExpression(XPathSequence.single(123)),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message: 'Expected a function item, but got int',
          ),
        ),
      );
    });
    test('evaluate with multiple items expression', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        LiteralExpression(XPathSequence([function, function])),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message: 'Expected a single function item, but got 2 items',
          ),
        ),
      );
    });
    test('evaluate with invalid specifier', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        123,
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Invalid arrow function specifier: 123',
          ),
        ),
      );
    });
    test('evaluate with Map', () {
      final map = {'key': 'value'};
      final expr = ArrowExpression(
        const LiteralExpression(XPathSequence.single('key')),
        LiteralExpression(XPathSequence.single(map)),
        [],
      );
      expect(expr(context), isXPathSequence(['value']));
    });
    test('evaluate with List', () {
      final array = ['first', 'second'];
      final expr = ArrowExpression(
        const LiteralExpression(XPathSequence.single(1)),
        LiteralExpression(XPathSequence.single(array)),
        [],
      );
      expect(expr(context), isXPathSequence(['first']));
    });
  });

  group('FunctionCallExpression', () {
    test('evaluate with empty sequence', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.empty),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message:
                'Expected a single function item, but got an empty sequence',
          ),
        ),
      );
    });
    test('evaluate with non-function sequence', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single('text')),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message: 'Expected a function item, but got String',
          ),
        ),
      );
    });
    test('evaluate with multiple items sequence', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence([function, function])),
        [],
      );
      expect(
        () => expr(context),
        throwsA(
          isXPathEvaluationException(
            message: 'Expected a single function item, but got 2 items',
          ),
        ),
      );
    });
    test('partial application expects more arguments', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(function)),
        [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunction;
      expect(
        () => resultFunction(context, []),
        throwsA(
          isXPathEvaluationException(
            message: 'Partial function application expects more arguments',
          ),
        ),
      );
    });
    test('partial application expects fewer arguments', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(function)),
        [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunction;
      expect(
        () => resultFunction(context, [arg1, arg2]),
        throwsA(
          isXPathEvaluationException(
            message: 'Partial function application expects fewer arguments',
          ),
        ),
      );
    });
    test('partial application success', () {
      const expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(function)),
        [ArgumentPlaceholderExpression(), LiteralExpression(arg2)],
      );
      final functionSeq = expr(context);
      final resultFunction = functionSeq.first as XPathFunction;
      expect(resultFunction(context, [arg1]), result);
    });
    test('evaluate with Map', () {
      final map = {'key': 'value'};
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(map)),
        [const LiteralExpression(XPathSequence.single('key'))],
      );
      expect(expr(context), isXPathSequence(['value']));
    });
    test('evaluate with List', () {
      final array = ['first', 'second'];
      final expr = FunctionCallExpression(
        LiteralExpression(XPathSequence.single(array)),
        [const LiteralExpression(XPathSequence.single(1))],
      );
      expect(expr(context), isXPathSequence(['first']));
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
      expect(
        () => expr(context),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Argument placeholder cannot be evaluated',
          ),
        ),
      );
    });
  });
}
