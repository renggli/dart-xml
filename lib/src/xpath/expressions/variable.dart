import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

class VariableExpression implements XPathExpression {
  VariableExpression(this.name);

  final String name;

  @override
  XPathValue call(XPathContext context) =>
      XPathEvaluationException.checkVariable(name, context.getVariable(name));
}
