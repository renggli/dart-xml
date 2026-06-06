import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import 'variable.dart';

class FunctionExpression implements XPathExpression {
  const FunctionExpression(this.name, this.arguments);

  final String name;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final function = context.configuration.getFunctionByString(name);
    final hasPlaceholders = arguments.any(
      (argument) => argument is ArgumentPlaceholderExpression,
    );
    return hasPlaceholders
        ? _applyPartialFunction(context, arguments, function)
        : _invokeFunction(
            function,
            context,
            arguments.map((each) => each(context)).toList(),
          );
  }
}

class InlineFunctionExpression implements XPathExpression {
  const InlineFunctionExpression(this.expression, this.parameters);

  final XPathExpression expression;
  final List<String> parameters;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    _XPathInlineFunction(expression, context, parameters),
  );
}

class NamedFunctionExpression implements XPathExpression {
  const NamedFunctionExpression(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) =>
      XPathSequence.single(context.configuration.getFunctionByString(name));
}

class ArrowExpression implements XPathExpression {
  const ArrowExpression(this.expression, this.specifier, this.arguments);

  final XPathExpression expression;
  final Object specifier;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final inputs = expression(context);
    final argumentSeqs = [inputs, ...arguments.map((expr) => expr(context))];
    final spec = specifier;
    switch (spec) {
      case String():
        final function = context.configuration.getFunctionByString(spec);
        return _invokeFunction(function, context, argumentSeqs);
      case XPathExpression():
        final functionSeq = spec(context);
        if (functionSeq.isEmpty) {
          throw XPathEvaluationException(
            'Expected a single function item, but got an empty sequence',
          );
        } else if (functionSeq.length > 1) {
          throw XPathEvaluationException(
            'Expected a single function item, but got ${functionSeq.length} items',
          );
        }
        final functionItem = functionSeq.first;
        if (!xsFunction.matches(functionItem)) {
          throw XPathEvaluationException(
            'Expected a function item, but got ${functionItem.runtimeType}',
          );
        }
        return _invokeFunction(functionItem, context, argumentSeqs);
      default:
        throw StateError('Invalid arrow function specifier: $specifier');
    }
  }
}

class FunctionCallExpression implements XPathExpression {
  const FunctionCallExpression(this.function, this.arguments);

  final XPathExpression function;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final target = _evaluateFunction(context);
    final hasPlaceholders = arguments.any(
      (argument) => argument is ArgumentPlaceholderExpression,
    );
    if (hasPlaceholders) {
      return _applyPartialFunction(context, arguments, target);
    }
    return target.call(
      context,
      arguments.map((each) => each(context)).toList(),
    );
  }

  XPathFunction _evaluateFunction(XPathContext context) {
    final result = function(context);
    if (result.isEmpty) {
      throw XPathEvaluationException(
        'Expected a single function item, but got an empty sequence',
      );
    } else if (result.length > 1) {
      throw XPathEvaluationException(
        'Expected a single function item, but got ${result.length} items',
      );
    }
    final functionItem = result.first;
    if (!xsFunction.matches(functionItem)) {
      throw XPathEvaluationException(
        'Expected a function item, but got ${functionItem.runtimeType}',
      );
    }
    return xsFunction.cast(functionItem);
  }
}

class ArgumentPlaceholderExpression implements XPathExpression {
  const ArgumentPlaceholderExpression();

  @override
  XPathSequence call(XPathContext context) =>
      throw StateError('Argument placeholder cannot be evaluated');
}

XPathSequence _invokeFunction(
  Object functionItem,
  XPathContext context,
  List<XPathSequence> arguments,
) => xsFunction.cast(functionItem).call(context, arguments);

XPathSequence _applyPartialFunction(
  XPathContext context,
  List<XPathExpression> arguments,
  XPathFunction function,
) {
  final evaluatedArguments = arguments
      .map<XPathExpression>(
        (argument) => argument is ArgumentPlaceholderExpression
            ? argument
            : LiteralExpression(argument(context)),
      )
      .toList();
  final placeholderCount = evaluatedArguments
      .whereType<ArgumentPlaceholderExpression>()
      .length;
  return XPathSequence.single(
    _XPathPartialFunction(evaluatedArguments, function, placeholderCount),
  );
}

class _XPathInlineFunction extends XPathFunction {
  _XPathInlineFunction(this.expression, this.context, this.parameters);

  final XPathExpression expression;
  final XPathContext context;
  final List<String> parameters;

  @override
  XmlName get name => const XmlName.qualified('dynamic-function');

  @override
  int get arity => parameters.length;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != parameters.length) {
      throw XPathEvaluationException(
        'Expected ${parameters.length} arguments, but got ${arguments.length}',
      );
    }
    final localVariables = <String, Object>{
      for (var i = 0; i < parameters.length; i++) parameters[i]: arguments[i],
    };
    return expression(this.context.copy(variables: localVariables));
  }
}

class _XPathPartialFunction extends XPathFunction {
  _XPathPartialFunction(this.evaluatedArguments, this.function, this.arity);

  final List<XPathExpression> evaluatedArguments;
  final XPathFunction function;

  @override
  XmlName get name => function.name;

  @override
  final int arity;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    final combinedArguments = <XPathSequence>[];
    var nestedArgumentIndex = 0;
    for (final argument in evaluatedArguments) {
      if (argument is ArgumentPlaceholderExpression) {
        if (nestedArgumentIndex >= arguments.length) {
          throw XPathEvaluationException(
            'Partial function application expects more arguments',
          );
        }
        combinedArguments.add(arguments[nestedArgumentIndex++]);
      } else {
        combinedArguments.add(argument(context));
      }
    }
    if (nestedArgumentIndex < arguments.length) {
      throw XPathEvaluationException(
        'Partial function application expects fewer arguments',
      );
    }
    return function.call(context, combinedArguments);
  }
}
