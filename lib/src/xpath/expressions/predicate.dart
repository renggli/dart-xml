import 'package:meta/meta.dart';

import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

@immutable
class Predicate {
  const new(this.expression);

  final XPathExpression expression;

  bool matches(XPathContext context) {
    final value = expression(context);
    final item = value.singleOrNull;
    if (item is XPathNumeric) {
      if (item is XPathInteger) {
        return item.value == BigInt.from(context.position);
      }
      return item.toDouble() == context.position.toDouble();
    }
    return value.effectiveBooleanValue;
  }
}

class PredicateExpression implements XPathExpression {
  const new(this.expression, this.predicate);

  final XPathExpression expression;
  final Predicate predicate;

  @override
  XPathSequence call(XPathContext context) {
    final items = expression(context).toList();
    final inner = context.copy();
    inner.last = items.length;
    final matched = <XPathItem>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      inner.item = item;
      inner.position = i + 1;
      if (predicate.matches(inner)) {
        matched.add(item);
      }
    }
    return XPathSequence(matched);
  }
}
