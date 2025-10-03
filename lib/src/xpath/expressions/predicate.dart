import 'package:meta/meta.dart';

import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

@immutable
class Predicate {
  const Predicate(this.expression);

  final XPathExpression expression;

  bool matches(XPathContext context) {
    final value = expression(context);
    return value is XPathNumber
        ? context.position == value.number.round()
        : value.boolean;
  }
}

class PredicateExpression implements XPathExpression {
  const PredicateExpression(this.expression, this.predicate);

  final XPathExpression expression;
  final Predicate predicate;

  @override
  XPathValue call(XPathContext context) {
    final nodes = expression(context).nodes;
    final inner = context.copy();
    inner.last = nodes.length;
    final matched = <XmlNode>[];
    for (var i = 0; i < nodes.length; i++) {
      inner.node = nodes[i];
      inner.position = i + 1;
      if (predicate.matches(inner)) {
        matched.add(inner.node);
      }
    }
    return XPathNodeSet(matched);
  }
}
