import 'package:meta/meta.dart';

import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import 'axis.dart';
import 'node_test.dart';
import 'predicate.dart';

@immutable
class Step {
  const Step(
    this.axis, [
    this.nodeTest = const NodeTypeNodeTest(),
    this.predicates = const [],
  ]);

  final Axis axis;
  final NodeTest nodeTest;
  final List<Predicate> predicates;

  /// Apply this step to the given context, returning the resulting nodes in document order.
  List<XmlNode> find(XPathContext context) {
    var result = <XmlNode>[];
    for (final node in axis.find(context.node)) {
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
          inner.node = result[isReverseIndexed ? result.length - i - 1 : i];
          inner.position = i + 1;
          if (predicate.matches(inner)) {
            matched.add(inner.node);
          }
        }
        result = matched;
      }
    }
    return result;
  }
}
