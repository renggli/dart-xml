import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';
import '../types/string.dart';

class StringConcatExpression implements XPathExpression {
  const StringConcatExpression(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathSequence call(XPathContext context) {
    final buffer = StringBuffer();
    for (final expression in expressions) {
      buffer.write(expression(context).toXPathString());
    }
    return XPathSequence.single(buffer.toString());
  }
}
