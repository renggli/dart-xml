import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';
import 'variable.dart';

class FunctionExpression implements XPathExpression {
  const new(this.name, this.arguments);

  final String name;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final hasPlaceholders = arguments.any(
      (argument) => argument is ArgumentPlaceholderExpression,
    );
    final function = context.configuration.getFunctionByString(
      name,
      hasPlaceholders ? null : arguments.length,
    );
    return hasPlaceholders
        ? _applyPartialFunction(context, arguments, function)
        : function.call(
            context,
            arguments.map((each) => each(context)).toList(),
          );
  }
}

/// Represents an inline `function($param as T) as R { ... }` expression.
class InlineFunctionExpression implements XPathExpression {
  const new(
    this.expression,
    this.parameters, [
    this.parameterTypes,
    this.returnType,
  ]);

  final XPathExpression expression;
  final List<String> parameters;

  /// Optional declared type for each parameter (`null` = untyped).
  final List<XPathType?>? parameterTypes;

  /// Optional declared return type.
  final XPathType? returnType;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    _XPathInlineFunction(
      expression,
      context,
      parameters,
      parameterTypes,
      returnType,
    ),
  );
}

class NamedFunctionExpression implements XPathExpression {
  const new(this.name, this.arity);

  final String name;
  final int arity;

  @override
  XPathSequence call(XPathContext context) {
    final function = context.configuration.getFunctionByString(name, arity);
    return XPathSequence.single(function);
  }
}

class ArrowExpression implements XPathExpression {
  const new(this.expression, this.specifier, this.arguments);

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
        final function = context.configuration.getFunctionByString(
          spec,
          argumentSeqs.length,
        );
        return function.call(context, argumentSeqs);
      case XPathExpression():
        final functionSeq = spec(context);
        if (functionSeq.length != 1) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Expected a single function item, but got ${functionSeq.length} items',
          );
        }
        final functionItem = functionSeq.first;
        if (functionItem is! XPathFunctionItem) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Expected a function item, but got ${functionItem.runtimeType}',
          );
        }
        return functionItem.call(context, argumentSeqs);
      default:
        throw StateError('Invalid arrow function specifier: $specifier');
    }
  }
}

class FunctionCallExpression implements XPathExpression {
  const new(this.function, this.arguments);

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

  XPathFunctionItem _evaluateFunction(XPathContext context) {
    final result = function(context);
    if (result.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Expected a single function item, but got ${result.length} items',
      );
    }
    final functionItem = result.first;
    if (functionItem is! XPathFunctionItem) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Expected a function item, but got ${functionItem.runtimeType}',
      );
    }
    return functionItem;
  }
}

class ArgumentPlaceholderExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) =>
      throw StateError('Argument placeholder cannot be evaluated');
}

XPathSequence _applyPartialFunction(
  XPathContext context,
  List<XPathExpression> arguments,
  XPathFunctionItem function,
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

class _XPathInlineFunction extends XPathFunctionItem {
  const new(
    this.expression,
    this.context,
    this.parameters,
    this._declaredParamTypes,
    this._declaredReturnType,
  );

  final XPathExpression expression;
  final XPathContext context;
  final List<String> parameters;
  final List<XPathType?>? _declaredParamTypes;
  final XPathType? _declaredReturnType;

  @override
  int get arity => parameters.length;

  /// Exposes declared parameter types for `instance of function(T) as R` matching.
  ///
  /// Each entry is the declared type, or [xsSequence] (`item()*`) for untyped params.
  @override
  List<XPathType>? get parameterTypes {
    final types = _declaredParamTypes;
    if (types == null) return null;
    return [for (final t in types) t ?? xsSequence];
  }

  @override
  XPathType? get returnType => _declaredReturnType;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != parameters.length) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAP0001,
        'Expected ${parameters.length} arguments, but got ${arguments.length}',
      );
    }
    final types = _declaredParamTypes;
    if (types != null) {
      for (var i = 0; i < parameters.length; i++) {
        final expected = types[i];
        if (expected != null && !expected.matchesSequence(arguments[i])) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Argument ${i + 1} does not match declared type $expected',
          );
        }
      }
    }
    final localVariables = <String, XPathSequence>{
      for (var i = 0; i < parameters.length; i++) parameters[i]: arguments[i],
    };
    return expression(this.context.copy(variables: localVariables));
  }
}

class _XPathPartialFunction extends XPathFunctionItem {
  const new(this.evaluatedArguments, this.function, this.arity);

  final List<XPathExpression> evaluatedArguments;
  final XPathFunctionItem function;

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
            XPathErrorCode.FOAP0001,
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
        XPathErrorCode.FOAP0001,
        'Partial function application expects fewer arguments',
      );
    }
    return function.call(context, combinedArguments);
  }
}
