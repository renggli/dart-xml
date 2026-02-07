import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import 'variable.dart';

class StaticFunctionExpression implements XPathExpression {
  const StaticFunctionExpression(this.function, this.arguments);

  final XPathFunction function;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) =>
      function(context, arguments.map((each) => each(context)).toList());
}

class DynamicFunctionExpression implements XPathExpression {
  const DynamicFunctionExpression(this.name, this.arguments);

  final String name;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    if (arguments.any(
      (argument) => argument is ArgumentPlaceholderExpression,
    )) {
      final function = context.getFunction(name);
      final evaluatedArguments = arguments
          .map<XPathExpression>(
            (argument) => argument is ArgumentPlaceholderExpression
                ? argument
                : LiteralExpression(argument(context)),
          )
          .toList();
      return XPathSequence.single((
        XPathContext nestedContext,
        List<XPathSequence> nestedArguments,
      ) {
        final combinedArguments = <XPathSequence>[];
        var nestedArgumentIndex = 0;
        for (final argument in evaluatedArguments) {
          if (argument is ArgumentPlaceholderExpression) {
            if (nestedArgumentIndex >= nestedArguments.length) {
              throw XPathEvaluationException(
                'Partial function application expects more arguments',
              );
            }
            combinedArguments.add(nestedArguments[nestedArgumentIndex++]);
          } else {
            combinedArguments.add(argument(nestedContext));
          }
        }
        if (nestedArgumentIndex < nestedArguments.length) {
          throw XPathEvaluationException(
            'Partial function application expects fewer arguments',
          );
        }
        return function(nestedContext, combinedArguments);
      });
    }
    return context.getFunction(name)(
      context,
      arguments.map((each) => each(context)).toList(),
    );
  }
}

class InlineFunctionExpression implements XPathExpression {
  const InlineFunctionExpression(this.parameters, this.body);

  final List<String> parameters;
  final XPathExpression body;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single((
    XPathContext _,
    List<XPathSequence> arguments,
  ) {
    if (arguments.length != parameters.length) {
      throw XPathEvaluationException(
        'Expected ${parameters.length} arguments, but got ${arguments.length}',
      );
    }
    final localVariables = {...context.variables};
    for (var i = 0; i < parameters.length; i++) {
      localVariables[parameters[i]] = arguments[i];
    }
    return body(context.copy(variables: localVariables));
  });
}

class NamedFunctionExpression implements XPathExpression {
  const NamedFunctionExpression(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) =>
      XPathSequence.single(context.getFunction(name));
}

class ArrowExpression implements XPathExpression {
  const ArrowExpression(this.input, this.specifier, this.arguments);

  final XPathExpression input;
  final Object specifier;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final inputSeq = input(context);
    final argumentSeqs = [inputSeq, ...arguments.map((expr) => expr(context))];
    if (specifier is String) {
      return context.getFunction(specifier as String)(context, argumentSeqs);
    } else if (specifier is XPathExpression) {
      final functionSeq = (specifier as XPathExpression)(context);
      if (functionSeq.length != 1) {
        throw XPathEvaluationException(
          'Expected a single function item, but got ${functionSeq.length} items',
        );
      }
      final function = functionSeq.first;
      if (function is! XPathFunction) {
        throw XPathEvaluationException(
          'Expected a function item, but got ${function.runtimeType}',
        );
      }
      return function(context, argumentSeqs);
    }
    throw StateError('Invalid arrow function specifier: $specifier');
  }
}

class FunctionCallExpression implements XPathExpression {
  const FunctionCallExpression(this.function, this.arguments);

  final XPathExpression function;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    if (arguments.any(
      (argument) => argument is ArgumentPlaceholderExpression,
    )) {
      final evaluatedArguments = arguments
          .map<XPathExpression>(
            (argument) => argument is ArgumentPlaceholderExpression
                ? argument
                : LiteralExpression(argument(context)),
          )
          .toList();
      return XPathSequence.single((
        XPathContext nestedContext,
        List<XPathSequence> nestedArguments,
      ) {
        final combinedArguments = <XPathSequence>[];
        var nestedArgumentIndex = 0;
        for (final argument in evaluatedArguments) {
          if (argument is ArgumentPlaceholderExpression) {
            if (nestedArgumentIndex >= nestedArguments.length) {
              throw XPathEvaluationException(
                'Partial function application expects more arguments',
              );
            }
            combinedArguments.add(nestedArguments[nestedArgumentIndex++]);
          } else {
            combinedArguments.add(argument(nestedContext));
          }
        }
        if (nestedArgumentIndex < nestedArguments.length) {
          throw XPathEvaluationException(
            'Partial function application expects fewer arguments',
          );
        }
        return _call(context, combinedArguments);
      });
    }
    return _call(context, arguments.map((each) => each(context)).toList());
  }

  XPathSequence _call(XPathContext context, List<XPathSequence> arguments) {
    final functionSeq = function(context);
    if (functionSeq.length != 1) {
      throw XPathEvaluationException(
        'Expected a single function item, but got ${functionSeq.length} items',
      );
    }
    final functionItem = functionSeq.first;
    if (functionItem is! XPathFunction) {
      throw XPathEvaluationException(
        'Expected a function item, but got ${functionItem.runtimeType}',
      );
    }
    return functionItem(context, arguments);
  }
}

class ArgumentPlaceholderExpression implements XPathExpression {
  const ArgumentPlaceholderExpression();

  @override
  XPathSequence call(XPathContext context) =>
      throw StateError('Argument placeholder cannot be evaluated');
}
