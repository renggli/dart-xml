import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/operators.dart';
import '../types/sequence.dart';

class BinaryOperatorExpression implements XPathExpression {
  const BinaryOperatorExpression(this.operator, this.left, this.right);

  final XPathBinaryOperator operator;
  final XPathExpression left;
  final XPathExpression right;

  @override
  XPathSequence call(XPathContext context) =>
      operator(left(context), right(context));
}

class UnaryOperatorExpression implements XPathExpression {
  const UnaryOperatorExpression(this.operator, this.arg);

  final XPathUnaryOperator operator;
  final XPathExpression arg;

  @override
  XPathSequence call(XPathContext context) => operator(arg(context));
}
