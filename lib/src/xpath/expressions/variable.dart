import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

class ContextItemExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (item is XPathItem) return XPathSequence.single(item);
    if (item is XPathSequence && item.isNotEmpty) return item;
    throw XPathEvaluationException(
      XPathErrorCode.XPDY0002,
      'Context item is undefined',
    );
  }
}

class VariableExpression implements XPathExpression {
  const new(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) => context.getVariable(name);
}

class LiteralExpression implements XPathExpression {
  const new(this.value);

  final XPathSequence value;

  @override
  XPathSequence call(XPathContext context) => value;
}
