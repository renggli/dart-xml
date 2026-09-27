import 'package:meta/meta.dart';

import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart' show XPathExpression;
import '../exceptions/error_code.dart';
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
    if (item is XPathSequence && item.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.XPDY0002,
        'The context item is absent',
      );
    }
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0019,
        'Step expression requires a node, but got ${item.runtimeType}',
      );
    }
    final isReverseIndexed = axis is ReverseAxis;
    final firstConstantIndex = predicates.isNotEmpty
        ? predicates.first.constantIndex
        : null;

    final findLimit = (!isReverseIndexed && firstConstantIndex != null)
        ? firstConstantIndex
        : null;

    if (findLimit != null && findLimit <= 0) {
      return XPathSequence.empty;
    }

    var result = <XmlNode>[];
    for (final node in axis.find(item.node)) {
      if (nodeTest.matches(node)) {
        result.add(node);
        if (findLimit != null && result.length >= findLimit) {
          break;
        }
      }
    }
    if (result.isEmpty) {
      return XPathSequence.empty;
    }
    if (predicates.isNotEmpty) {
      var current = isReverseIndexed ? result.reversed.toList() : result;
      final inner = context.copy();
      for (final predicate in predicates) {
        if (current.isEmpty) break;
        final constantIndex = predicate.constantIndex;
        if (constantIndex != null) {
          if (constantIndex <= 0 || constantIndex > current.length) {
            current = const [];
            break;
          }
          current = [current[constantIndex - 1]];
          continue;
        }
        inner.last = current.length;
        final matched = <XmlNode>[];
        for (var i = 0; i < current.length; i++) {
          final node = current[i];
          inner.item = XPathNode(node);
          inner.position = i + 1;
          if (predicate.matches(inner)) {
            matched.add(node);
          }
        }
        current = matched;
      }
      result = isReverseIndexed ? current.reversed.toList() : current;
    }
    return result.isEmpty
        ? XPathSequence.empty
        : XPathSequence(result.map(XPathNode.new));
  }
}

class RootNodeExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (item is XPathSequence && item.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.XPDY0002,
        'The context item is absent',
      );
    }
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0019,
        'Root expression requires a node, but got ${item.runtimeType}',
      );
    }
    return XPathSequence.single(XPathNode(item.node.root));
  }
}
