import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/functions.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

class StaticFunctionExpression implements XPathExpression {
  StaticFunctionExpression(this.name, this.function, this.arguments);

  final String name; // just for debugging
  final XPathFunction function;
  final List<XPathExpression> arguments;

  @override
  XPathValue call(XPathContext context) => function(context, arguments);
}

class DynamicFunctionExpression implements XPathExpression {
  DynamicFunctionExpression(this.name, this.arguments);

  final String name;
  final List<XPathExpression> arguments;

  @override
  XPathValue call(XPathContext context) {
    final function =
        XPathEvaluationException.checkFunction(name, context.getFunction(name));
    return function(context, arguments.map((each) => each(context)).toList());
  }
}
