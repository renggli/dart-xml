import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

class SequenceExpression implements XPathExpression {
  SequenceExpression(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathValue call(XPathContext context) {
    var nodes = context.value.nodes.toList();
    var innerNodes = <XmlNode>[];
    final innerContext = context.copy();
    for (final expression in expressions) {
      if (nodes.isEmpty) return XPathNodeSet.empty;
      innerContext.last = nodes.length;
      for (var i = 0; i < nodes.length; i++) {
        innerContext.node = nodes[i];
        innerContext.position = i + 1;
        final result = expression(innerContext);
        if (result is XPathNodeSet) {
          innerNodes.addAll(result.nodes);
        } else if (result.boolean) {
          innerNodes.add(innerContext.node);
        }
      }
      nodes = innerNodes;
      innerNodes = <XmlNode>[];
    }
    return XPathNodeSet(nodes);
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
