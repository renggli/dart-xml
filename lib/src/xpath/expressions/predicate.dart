import 'package:meta/meta.dart';

import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/number.dart';
import '../types/sequence.dart';

@immutable
class Predicate {
  const Predicate(this.expression);

  final XPathExpression expression;

  bool matches(XPathContext context) {
    final value = expression(context);
    final item = value.singleOrNull;
    return item is num ? xsInteger.cast(item) == context.position : value.ebv;
  }
}

class PredicateExpression implements XPathExpression {
  const PredicateExpression(this.expression, this.predicate);

  final XPathExpression expression;
  final Predicate predicate;

  @override
  XPathSequence call(XPathContext context) {
    final items = expression(context).toList();
    final inner = context.copy();
    inner.last = items.length;
    final matched = <Object>[];
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
