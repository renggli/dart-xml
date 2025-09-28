import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

class Predicate {
  Predicate(this.expression);

  final XPathExpression expression;

  bool matches(XPathContext context) {
    final value = expression(context);
    return value is XPathNumber
        ? context.position == value.number.round()
        : value.boolean;
  }
}
