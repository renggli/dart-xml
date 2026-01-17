import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';

class SequenceExpression implements XPathExpression {
  const SequenceExpression(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathSequence call(XPathContext context) =>
      XPathSequence(expressions.expand((expression) => expression(context)));
}
