import 'package:meta/meta.dart';

import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart' show XPathExpression;
import '../types/node.dart';
import '../types/sequence.dart';
import 'axis.dart';
import 'node.dart';
import 'predicate.dart';

/// A step in a path expression returning nodes in document order.
@immutable
class StepExpression implements XPathExpression {
  const StepExpression(
    this.axis, {
    this.nodeTest = const NodeTypeTest(),
    this.predicates = const [],
  });

  final Axis axis;
  final NodeTest nodeTest;
  final List<Predicate> predicates;

  @override
  XPathSequence call(XPathContext context) {
    var result = <XmlNode>[];
    for (final node in axis.find(xsNode.cast(context.item))) {
      if (nodeTest.matches(node)) {
        result.add(node);
      }
    }
    if (predicates.isNotEmpty) {
      final isReverseIndexed = axis is ReverseAxis;
      final inner = context.copy();
      for (final predicate in predicates) {
        inner.last = result.length;
        final matched = <XmlNode>[];
        for (var i = 0; i < result.length; i++) {
          final node = inner.item =
              result[isReverseIndexed ? result.length - i - 1 : i];
          inner.position = i + 1;
          if (predicate.matches(inner)) {
            matched.add(node);
          }
        }
        result = matched;
      }
    }
    return XPathSequence(result);
  }
}

class RootNodeExpression implements XPathExpression {
  const RootNodeExpression();

  @override
  XPathSequence call(XPathContext context) =>
      XPathSequence.single(xsNode.cast(context.item).root);
}
