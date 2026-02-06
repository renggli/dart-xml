import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';

class ContextItemExpression implements XPathExpression {
  const ContextItemExpression();

  @override
  XPathSequence call(XPathContext context) => xsSequence.cast(context.item);
}

class VariableExpression implements XPathExpression {
  const VariableExpression(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) =>
      xsSequence.cast(context.getVariable(name));
}

class LiteralExpression implements XPathExpression {
  const LiteralExpression(this.value);

  final XPathSequence value;

  @override
  XPathSequence call(XPathContext context) => value;
}
