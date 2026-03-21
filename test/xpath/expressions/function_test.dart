import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/expressions/function.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/types/function.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final context = XPathContext.canonical(XmlElement.tag('root'));
const arg1 = XPathSequence.single('First');
const arg2 = XPathSequence.single('Second');
const result = XPathSequence.single('Confirmed');

XPathSequence function(XPathContext context, List<XPathSequence> args) {
  expect(args, [arg1, arg2]);
  return result;
}

void main() {
  group('StaticFunctionExpression', () {
    test('evaluate', () {
      const expr = StaticFunctionExpression(function, [
        LiteralExpression(arg1),
        LiteralExpression(arg2),
      ]);
      expect(expr(context), result);
    });
  });
  group('DynamicFunctionExpression', () {
    test('evaluate existing function', () {
      const expr = DynamicFunctionExpression('fun', [
        LiteralExpression(arg1),
        LiteralExpression(arg2),
      ]);
      expect(
        expr(
          context.copy(
            functions: {
              const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                  function,
            },
          ),
        ),
        result,
      );
    });
    test('evaluate missing function', () {
      const expr = DynamicFunctionExpression('fun', []);
      expect(
        () => expr(context),
        throwsA(isXPathEvaluationException(message: 'Unknown function: fun')),
      );
    });
    test('partial application expects more arguments', () {
      const expr = DynamicFunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.copy(
          functions: {
            const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                function,
          },
        ),
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
      const expr = DynamicFunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.copy(
          functions: {
            const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                function,
          },
        ),
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
      const expr = DynamicFunctionExpression('fun', [
        ArgumentPlaceholderExpression(),
        LiteralExpression(arg2),
      ]);
      final functionSeq = expr(
        context.copy(
          functions: {
            const XmlName.parts('fun', namespaceUri: xpathFnNamespace):
                function,
          },
        ),
      );
      final functionItem = functionSeq.first as XPathFunction;
      expect(functionItem(context, [arg1]), result);
    });
  });
  group('InlineFunctionExpression', () {
    test('no arguments', () {
      const expr = InlineFunctionExpression([], LiteralExpression(result));
      final function = expr(context).first as XPathFunction;
      expect(function(context, []), result);
    });
    test('with arguments', () {
      const expr = InlineFunctionExpression(['a'], VariableExpression('a'));
      final function = expr(context).first as XPathFunction;
      expect(function(context, [result]), result);
    });
    test('closure', () {
      const expr = InlineFunctionExpression(
        [],
        DynamicFunctionExpression('foo', []),
      );
      final closureContext = context.copy(
        functions: {
          const XmlName.parts(
            'foo',
            namespaceUri: xpathFnNamespace,
          ): (context, args) =>
              result,
        },
      );
      final function = expr(closureContext).first as XPathFunction;
      expect(function(context, []), result);
    });
    test('invalid number of arguments', () {
      const expr = InlineFunctionExpression(['a'], VariableExpression('a'));
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
      const expr = NamedFunctionExpression('foo');
      final function =
          expr(
                context.copy(
                  functions: {
                    const XmlName.parts(
                      'foo',
                      namespaceUri: xpathFnNamespace,
                    ): (context, args) =>
                        result,
                  },
                ),
              ).first
              as XPathFunction;
      expect(function(context, []), result);
    });
    test('evaluate with standard functions', () {
      const expr = NamedFunctionExpression('fn:abs');
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
          context.copy(
            functions: {
              const XmlName.parts(
                'foo',
                namespaceUri: xpathFnNamespace,
              ): (context, args) =>
                  XPathSequence.single((args[0].first as int) + 1),
            },
          ),
        ).first,
        2,
      );
    });
    test('evaluate with expression', () {
      const expr = ArrowExpression(
        LiteralExpression(XPathSequence.single(1)),
        NamedFunctionExpression('foo'),
        [],
      );
      expect(
        expr(
          context.copy(
            functions: {
              const XmlName.parts(
                'foo',
                namespaceUri: xpathFnNamespace,
              ): (context, args) =>
                  XPathSequence.single((args[0].first as int) + 1),
            },
          ),
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
