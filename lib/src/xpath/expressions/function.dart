import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/function.dart';

class StaticFunctionExpression implements XPathExpression {
  const StaticFunctionExpression(this.function, this.arguments);

  final Object function;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final function = this.function;
    if (function is XPathFunctionDefinition) {
      return function(context, arguments.map((each) => each(context)).toList());
    } else if (function is XPathFunction) {
      return function(context, arguments.map((each) => each(context)).toList());
    } else {
      throw XPathEvaluationException('Unknown function type: $function');
    }
  }
}

class DynamicFunctionExpression implements XPathExpression {
  const DynamicFunctionExpression(this.name, this.arguments);

  final String name;
  final List<XPathExpression> arguments;

  @override
  XPathSequence call(XPathContext context) {
    final function =
        context.getFunction(name) ??
        (throw XPathEvaluationException('Unknown function: $name'));
    if (function is XPathFunctionDefinition) {
      return function(context, arguments.map((each) => each(context)).toList());
    } else if (function is XPathFunction) {
      return function(context, arguments.map((each) => each(context)).toList());
    } else {
      throw XPathEvaluationException('Unknown function type: $function');
    }
  }
}
