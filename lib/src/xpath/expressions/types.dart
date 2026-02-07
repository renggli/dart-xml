import '../definitions/type.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';

/// Checks if [expression] is an instance of [type].
class InstanceofExpression extends XPathExpression {
  InstanceofExpression(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) =>
      XPathSequence.single(type.matches(expression(context).toAtomicValue()));
}

/// Casts [expression] to [type].
class CastExpression extends XPathExpression {
  CastExpression(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) =>
      xsSequence.cast(type.cast(expression(context).toAtomicValue()));
}

/// Checks if [expression] is castable to [type].
class CastableExpression extends XPathExpression {
  CastableExpression(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    try {
      type.cast(expression(context).toAtomicValue());
      return XPathSequence.trueSequence;
    } catch (_) {
      return XPathSequence.falseSequence;
    }
  }
}

/// Treats [expression] as [type].
class TreatExpression extends XPathExpression {
  TreatExpression(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    final result = expression(context).toAtomicValue();
    if (type.matches(result)) return xsSequence.cast(result);
    throw XPathEvaluationException('Expected $type, but got $result');
  }
}
