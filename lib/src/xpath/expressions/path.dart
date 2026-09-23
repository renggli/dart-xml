import 'package:collection/collection.dart';

import '../../xml/extensions/comparison.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'axis.dart';
import 'node.dart';
import 'step.dart';

class PathExpression implements XPathExpression {
  factory(List<XPathExpression> steps) {
    if (steps.isEmpty) {
      throw ArgumentError('PathExpression must have at least one step');
    }
    if (steps.length == 1) {
      return PathExpression._(steps, isOrderPreserved: true);
    }
    final optimizedSteps = <XPathExpression>[steps.first];
    for (var i = 1; i < steps.length; i++) {
      final previous = optimizedSteps.last;
      final current = steps[i];
      if (previous is StepExpression &&
          previous.predicates.isEmpty &&
          previous.axis is DescendantOrSelfAxis &&
          previous.nodeTest is NodeTypeTest &&
          current is StepExpression &&
          current.predicates.isEmpty) {
        switch (current.axis) {
          case ChildAxis():
            optimizedSteps.last = StepExpression(
              const DescendantAxis(),
              nodeTest: current.nodeTest,
            );
          case SelfAxis():
            optimizedSteps.last = StepExpression(
              const DescendantOrSelfAxis(),
              nodeTest: current.nodeTest,
            );
          case DescendantAxis():
          case DescendantOrSelfAxis():
            optimizedSteps.last = current;
          default:
            optimizedSteps.add(current);
        }
      } else {
        optimizedSteps.add(current);
      }
    }
    return PathExpression._(
      optimizedSteps,
      isOrderPreserved: _isOrderPreserved(optimizedSteps),
    );
  }

  const new _(this.steps, {required this.isOrderPreserved});

  final List<XPathExpression> steps;
  final bool isOrderPreserved;

  @override
  XPathSequence call(XPathContext context) {
    final inner = context.copy();
    if (isOrderPreserved) {
      var nodes = <XPathItem>[...steps.first.call(context)];
      for (final step in steps.skip(1)) {
        final innerNodes = <XPathItem>[];
        for (final node in nodes) {
          if (node is XPathNode) {
            inner.item = node;
            innerNodes.addAll(step(inner));
          } else {
            _throwPathOperatorRequiresNodes(node);
          }
        }
        nodes = innerNodes;
      }
      return XPathSequence(nodes);
    } else {
      var nodes = <XPathItem>{...steps.first.call(context)};
      for (final step in steps.skip(1)) {
        final innerNodes = <XPathItem>{};
        for (final node in nodes) {
          if (node is XPathNode) {
            inner.item = node;
            innerNodes.addAll(step(inner));
          } else {
            _throwPathOperatorRequiresNodes(node);
          }
        }
        nodes = innerNodes;
      }
      return XPathSequence(_sortAndDeduplicate(nodes));
    }
  }
}

bool _isOrderPreserved(List<XPathExpression> expressions) {
  if (expressions.length <= 1) {
    return true;
  }
  if (expressions.any((expression) => expression is! StepExpression)) {
    return false;
  }
  final steps = expressions.cast<StepExpression>().toList();
  if (steps
      .skip(1)
      .every((s) => s.axis is SelfAxis || s.axis is AttributeAxis)) {
    return true;
  }
  var i = 0;
  while (i < steps.length) {
    final axis = steps[i].axis;
    if (axis is SelfAxis || axis is AttributeAxis || axis is ChildAxis) {
      i++;
    } else {
      break;
    }
  }
  if (i < steps.length) {
    final axis = steps[i].axis;
    if (axis is DescendantAxis || axis is DescendantOrSelfAxis) i++;
  }
  while (i < steps.length) {
    final axis = steps[i].axis;
    if (axis is SelfAxis || axis is AttributeAxis) {
      i++;
    } else {
      break;
    }
  }
  return i == steps.length;
}

List<XPathItem> _sortAndDeduplicate(Iterable<XPathItem> iter) {
  final nodes = <XmlNode>{};
  final others = <XPathItem>{};
  for (final item in iter) {
    if (item is XPathNode) {
      nodes.add(item.node);
    } else {
      others.add(item);
    }
  }
  final result = <XPathItem>[];
  if (nodes.length <= 50) {
    result.addAll(nodes.sorted(_compareNodePosition).map(XPathNode.new));
  } else {
    final root = nodes.first.root;
    if (nodes.remove(root)) result.add(XPathNode(root));
    for (final node in root.descendants) {
      if (nodes.isEmpty) break;
      if (nodes.remove(node)) result.add(XPathNode(node));
    }
    if (nodes.isNotEmpty) {
      result.addAll(nodes.sorted(_compareNodePosition).map(XPathNode.new));
    }
  }
  result.addAll(others);
  return result;
}

int _compareNodePosition(XmlNode node1, XmlNode node2) {
  final pos = node1.compareDocumentPosition(node2);
  if (pos.isPreceding) return 1;
  if (pos.isFollowing) return -1;
  return 0;
}

Never _throwPathOperatorRequiresNodes(Object object) =>
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0019,
      'Path operator / requires sequence of nodes, but got $object',
    );
