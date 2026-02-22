import 'package:collection/collection.dart';

import '../../xml/extensions/comparison.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import 'axis.dart';
import 'node.dart';
import 'step.dart';

class PathExpression implements XPathExpression {
  factory PathExpression(
    List<XPathExpression> steps, {
    required bool isAbsolute,
  }) {
    if (steps.isEmpty) {
      assert(isAbsolute);
      return const PathExpression._(
        [],
        isAbsolute: true,
        isOrderPreserved: true,
      );
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
      isAbsolute: isAbsolute,
      isOrderPreserved: _isOrderPreserved(optimizedSteps),
    );
  }

  const PathExpression._(
    this.steps, {
    required this.isAbsolute,
    required this.isOrderPreserved,
  });

  final List<XPathExpression> steps;
  final bool isAbsolute;
  final bool isOrderPreserved;

  @override
  XPathSequence call(XPathContext context) {
    final contextNode = xsNode.cast(context.item);
    if (steps.isEmpty) {
      return XPathSequence.single(contextNode.root);
    }
    final inner = context.copy();
    if (isOrderPreserved) {
      var nodes = <Object>[if (isAbsolute) contextNode.root else contextNode];
      for (final step in steps) {
        final innerNodes = <Object>[];
        for (final node in nodes) {
          if (node is XmlNode) {
            inner.item = node;
            innerNodes.addAll(step(inner));
          }
        }
        nodes = innerNodes;
      }
      return XPathSequence(nodes);
    } else {
      var nodes = <Object>{if (isAbsolute) contextNode.root else contextNode};
      for (final step in steps) {
        final innerNodes = <Object>{};
        for (final node in nodes) {
          if (node is XmlNode) {
            inner.item = node;
            innerNodes.addAll(step(inner));
          }
        }
        nodes = innerNodes;
      }
      return XPathSequence(_sortAndDeduplicate(nodes, contextNode.root));
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

List<Object> _sortAndDeduplicate(Iterable<Object> iter, XmlNode root) {
  final nodes = <XmlNode>{};
  final others = <Object>{};
  for (final item in iter) {
    if (item is XmlNode) {
      nodes.add(item);
    } else {
      others.add(item);
    }
  }
  final result = <Object>[];
  if (nodes.length <= 50) {
    result.addAll(nodes.sorted((a, b) => a.compareNodePosition(b)));
  } else {
    if (nodes.remove(root)) result.add(root);
    for (final node in root.descendants) {
      if (nodes.isEmpty) break;
      if (nodes.remove(node)) result.add(node);
    }
    if (nodes.isNotEmpty) {
      result.addAll(nodes.sorted((a, b) => a.compareNodePosition(b)));
    }
  }
  result.addAll(others);
  return result;
}
