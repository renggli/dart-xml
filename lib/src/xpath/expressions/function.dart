import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/function.dart';
import '../types31/sequence.dart';

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
    final function = XPathEvaluationException.checkFunction(
      name,
      context.getFunction(name),
    );
    return function(context, arguments.map((each) => each(context)).toList());
  }
}
