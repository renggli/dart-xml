import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import 'filters.dart';

class SequenceExpression implements XPathExpression {
  SequenceExpression(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathValue call(XPathContext context) {
    var nodeSet = context.value;
    final innerContext = context.copy();
    outer:
    for (final expression in expressions) {
      if (nodeSet.value.isEmpty) return XPathNodeSet.empty;
      innerContext.nodeSet = nodeSet;
      final innerNodes = <XmlNode>[];
      var pos = 1;
      for (final node in nodeSet.value) {
        innerContext.node = node;
        innerContext.visitingPosition = pos++;
        final result = expression(innerContext);
        if (result is XPathNodeSet) {
          if (nodeSet.value.length == 1) {
            // Fast path: single node set, we can reuse the result directly.
            // In this way, we also preserve the sorted property.
            nodeSet = result;
            continue outer;
          }
          innerNodes.addAll(result.nodes);
        } else if (result.boolean) {
          innerNodes.add(innerContext.node);
        }
      }
      if (nodeSet.isSorted && expression is NodePredicateExpression) {
        // The result is still sorted and unique.
        nodeSet = XPathNodeSet.fromSortedUniqueNodes(innerNodes);
      } else {
        nodeSet = XPathNodeSet(innerNodes);
      }
    }
    return nodeSet;
  }
}

class PredicateExpression implements XPathExpression {
  PredicateExpression(this.expression);

  final XPathExpression expression;

  @override
  XPathValue call(XPathContext context) =>
      XPathBoolean(_matches(context, expression(context)));

  bool _matches(XPathContext context, XPathValue value) => value is XPathNumber
      ? context.position == value.number.round()
      : value.boolean;
}
