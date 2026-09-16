import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/operators.dart';
import '../xdm/atomic/string.dart';
import '../xdm/sequence.dart';

class BinaryOperatorExpression implements XPathExpression {
  const new(this.operator, this.left, this.right);

  final XPathBinaryOperator operator;
  final XPathExpression left;
  final XPathExpression right;

  @override
  XPathSequence call(XPathContext context) =>
      operator(left(context), right(context));
}

class UnaryOperatorExpression implements XPathExpression {
  const new(this.operator, this.arg);

  final XPathUnaryOperator operator;
  final XPathExpression arg;

  @override
  XPathSequence call(XPathContext context) => operator(arg(context));
}

class StringConcatExpression implements XPathExpression {
  const new(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathSequence call(XPathContext context) {
    final buffer = StringBuffer();
    for (final expression in expressions) {
      for (final item in expression(context).atomize()) {
        buffer.write(item.stringValue);
      }
    }
    return XPathSequence.single(XPathString(buffer.toString()));
  }
}
