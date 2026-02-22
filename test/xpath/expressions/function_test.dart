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
}
