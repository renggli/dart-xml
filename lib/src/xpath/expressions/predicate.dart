import 'package:meta/meta.dart';

import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/boolean.dart';
import '../types/sequence.dart';

@immutable
class Predicate {
  const Predicate(this.expression);

  final XPathExpression expression;

  bool matches(XPathContext context) {
    final value = expression(context);
    final item = value.singleOrNull;
    return item is num
        ? context.position == item.round()
        : value.toXPathBoolean();
  }
}

class PredicateExpression implements XPathExpression {
  const PredicateExpression(this.expression, this.predicate);

  final XPathExpression expression;
  final Predicate predicate;

  @override
  XPathSequence call(XPathContext context) {
    final nodes = expression(context).toList();
    final inner = context.copy();
    inner.last = nodes.length;
    final matched = <Object>[];
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node is XmlNode) {
        inner.node = node;
      }
      inner.position = i + 1;
      if (predicate.matches(inner)) {
        matched.add(node);
      }
    }
    return XPathSequence(matched);
  }
}
