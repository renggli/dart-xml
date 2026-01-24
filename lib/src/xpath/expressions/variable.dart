import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';

class ContextItemExpression implements XPathExpression {
  const ContextItemExpression();

  @override
  XPathSequence call(XPathContext context) => context.item.toXPathSequence();
}

class VariableExpression implements XPathExpression {
  const VariableExpression(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) =>
      XPathEvaluationException.checkVariable(name, context.getVariable(name));
}

class LiteralExpression implements XPathExpression {
  const LiteralExpression(this.value);

  final XPathSequence value;

  @override
  XPathSequence call(XPathContext context) => value;
}
