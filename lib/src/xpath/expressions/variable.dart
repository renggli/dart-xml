import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';
import '../values/sequence.dart';

class ContextItemExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) => xsSequence.cast(context.item);
}

class VariableExpression implements XPathExpression {
  const new(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) =>
      xsSequence.cast(context.getVariable(name));
}

class LiteralExpression implements XPathExpression {
  const new(this.value);

  final XPathSequence value;

  @override
  XPathSequence call(XPathContext context) => value;
}
