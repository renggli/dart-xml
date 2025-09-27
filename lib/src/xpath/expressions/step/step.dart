import '../../../../xml.dart';
import '../../evaluation/context.dart';
import 'axis.dart';
import 'node_test.dart';
import 'predicate.dart';
import 'utils.dart';

class Step {
  const Step(this.axis, this.nodeTest, this.predicates);

  Step.abbrevAxisStep(this.axis)
    : nodeTest = NodeTypeNodeTest(),
      predicates = const [];

  final Axis axis;
  final NodeTest nodeTest;
  final List<Predicate> predicates;

  /// Apply this step to the given context, returning the resulting nodes in document order.
  List<XmlNode> call(XPathContext context) {
    var result = <XmlNode>[];
    for (final node in axis.find(context.node)) {
      if (nodeTest.matches(node)) {
        result.add(node);
      }
    }
    final ctx = context.copy();
    for (final predicate in predicates) {
      ctx.last = result.length;
      final matched = <XmlNode>[];
      for (var i = 0; i < result.length; i++) {
        ctx.node = result[i];
        ctx.position = i + 1;
        if (predicate.matches(ctx)) {
          matched.add(ctx.node);
        }
      }
      result = matched;
    }
    if (axis is ReverseAxis) {
      result.reverse();
    }
    return result;
  }
}
