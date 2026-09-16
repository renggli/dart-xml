import 'package:meta/meta.dart';

import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart' show XPathExpression;
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'axis.dart';
import 'node.dart';
import 'predicate.dart';

/// A step in a path expression returning nodes in document order.
@immutable
class StepExpression implements XPathExpression {
  const new(
    this.axis, {
    this.nodeTest = const NodeTypeTest(),
    this.predicates = const [],
  });

  final Axis axis;
  final NodeTest nodeTest;
  final List<Predicate> predicates;

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        'Step expression requires a node, but got ${item.runtimeType} [err:XPTY0019]',
      );
    }
    var result = <XmlNode>[];
    for (final node in axis.find(item.node)) {
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
          final node = result[isReverseIndexed ? result.length - i - 1 : i];
          inner.item = XPathNode(node);
          inner.position = i + 1;
          if (predicate.matches(inner)) {
            matched.add(node);
          }
        }
        result = isReverseIndexed ? matched.reversed.toList() : matched;
      }
    }
    return XPathSequence(result.map(XPathNode.new));
  }
}

class RootNodeExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) {
    var item = context.item;
    if (item is XmlNode) item = XPathNode(item);
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        'Root expression requires a node, but got ${item.runtimeType} [err:XPTY0019]',
      );
    }
    return XPathSequence.single(XPathNode(item.node.root));
  }
}
