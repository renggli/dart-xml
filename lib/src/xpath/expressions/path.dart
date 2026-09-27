import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
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
import 'variable.dart';

class PathExpression implements XPathExpression {
  factory(List<XPathExpression> steps, {bool? isOrderPreserved}) {
    if (steps.isEmpty) {
      throw ArgumentError('PathExpression must have at least one step');
    }
    if (steps.length == 1) {
      return PathExpression._(
        steps,
        isOrderPreserved: isOrderPreserved ?? true,
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
          current.predicates.every((p) => p.isDefinitelyNonPositional)) {
        switch (current.axis) {
          case ChildAxis():
            optimizedSteps.last = StepExpression(
              const DescendantAxis(),
              nodeTest: current.nodeTest,
              predicates: current.predicates,
            );
          case SelfAxis():
            optimizedSteps.last = StepExpression(
              const DescendantOrSelfAxis(),
              nodeTest: current.nodeTest,
              predicates: current.predicates,
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
      isOrderPreserved: isOrderPreserved ?? _isOrderPreserved(optimizedSteps),
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
  var steps = expressions;
  if (steps.first is RootNodeExpression) {
    steps = steps.sublist(1);
  }
  if (steps.isEmpty) {
    return true;
  }
  if (steps.any(
    (expression) =>
        expression is! StepExpression && expression is! ContextItemExpression,
  )) {
    return false;
  }
  if (steps.length <= 1) {
    return true;
  }
  final axes = steps
      .map((e) => e is StepExpression ? e.axis : const SelfAxis())
      .toList();
  if (axes.skip(1).every((a) => a is SelfAxis || a is AttributeAxis)) {
    return true;
  }
  var i = 0;
  while (i < axes.length) {
    final axis = axes[i];
    if (axis is SelfAxis || axis is AttributeAxis || axis is ChildAxis) {
      i++;
    } else {
      break;
    }
  }
  if (i < axes.length) {
    final axis = axes[i];
    if (axis is DescendantAxis || axis is DescendantOrSelfAxis) i++;
  }
  while (i < axes.length) {
    final axis = axes[i];
    if (axis is SelfAxis || axis is AttributeAxis) {
      i++;
    } else {
      break;
    }
  }
  return i == axes.length;
}

List<XPathItem> _sortAndDeduplicate(Iterable<XPathItem> iter) {
  final nodes = <XmlNode>{};
  final others = <XPathItem>{};
  final seenNamespaces = <(XmlNode?, String, String)>{};
  for (final item in iter) {
    if (item is XPathNode) {
      final node = item.node;
      if (node is XmlNamespace) {
        if (seenNamespaces.add((node.parent, node.prefix, node.uri))) {
          nodes.add(node);
        }
      } else {
        nodes.add(node);
      }
    } else {
      others.add(item);
    }
  }
  if (nodes.length <= 1) {
    return [...nodes.map(XPathNode.new), ...others];
  }

  // Tier 1: Same-parent fast-path (O(S) sibling scan without sorting).
  XmlNode? commonParent;
  XmlElement? ownerInNodes;

  final p0 = nodes.first.parent;
  if (p0 != null && nodes.every((n) => identical(n.parent, p0))) {
    commonParent = p0;
  } else {
    for (final node in nodes) {
      if (node is XmlElement) {
        if (nodes.every(
          (n) => identical(n, node) || identical(n.parent, node),
        )) {
          ownerInNodes = node;
          commonParent = node;
          break;
        }
      }
    }
  }

  if (commonParent != null) {
    final sorted = <XmlNode>[];
    if (ownerInNodes != null) {
      sorted.add(ownerInNodes);
    }
    List<XmlNamespace>? nsNodes;
    for (final node in nodes) {
      if (node is XmlNamespace) {
        (nsNodes ??= []).add(node);
      }
    }
    if (nsNodes != null) {
      nsNodes.sort((a, b) => a.prefix.compareTo(b.prefix));
      sorted.addAll(nsNodes);
    }
    if (sorted.length < nodes.length) {
      final attributes = commonParent.attributes;
      for (var i = 0; i < attributes.length; i++) {
        final attr = attributes[i];
        if (nodes.contains(attr)) {
          sorted.add(attr);
          if (sorted.length == nodes.length) break;
        }
      }
    }
    if (sorted.length < nodes.length) {
      final children = commonParent.children;
      for (var i = 0; i < children.length; i++) {
        final child = children[i];
        if (nodes.contains(child)) {
          sorted.add(child);
          if (sorted.length == nodes.length) break;
        }
      }
    }
    if (sorted.length == nodes.length) {
      return [...sorted.map(XPathNode.new), ...others];
    }
  }

  // Tier 2: Hierarchical tree-coordinate sort (O(D * N log N)).
  final parentIndexCache = <XmlNode, Map<XmlNode, int>>{};
  final attrIndexCache = <XmlNode, Map<XmlAttribute, int>>{};
  final nsIndexCache = <XmlNode, Map<(String, String), int>>{};

  int getChildIndex(XmlNode parent, XmlNode child) {
    var map = parentIndexCache[parent];
    if (map == null) {
      map = <XmlNode, int>{};
      final children = parent.children;
      for (var i = 0; i < children.length; i++) {
        map[children[i]] = i;
      }
      parentIndexCache[parent] = map;
    }
    return map[child] ?? -1;
  }

  int getAttrIndex(XmlNode parent, XmlAttribute attr) {
    var map = attrIndexCache[parent];
    if (map == null) {
      map = <XmlAttribute, int>{};
      final attributes = parent.attributes;
      for (var i = 0; i < attributes.length; i++) {
        map[attributes[i]] = i;
      }
      attrIndexCache[parent] = map;
    }
    return map[attr] ?? -1;
  }

  int getNsIndex(XmlNode parent, XmlNamespace ns) {
    var map = nsIndexCache[parent];
    if (map == null) {
      map = <(String, String), int>{};
      final list = parent.namespaces.toList();
      list.sort((a, b) => a.prefix.compareTo(b.prefix));
      for (var i = 0; i < list.length; i++) {
        map[(list[i].prefix, list[i].uri)] = i;
      }
      nsIndexCache[parent] = map;
    }
    return map[(ns.prefix, ns.uri)] ?? -1;
  }

  List<int> getPath(XmlNode node) {
    final segments = <int>[];
    XmlNode? current = node;
    while (current != null) {
      final p = current.parent;
      if (p == null) {
        segments.add(identityHashCode(current));
        break;
      }
      if (current is XmlAttribute) {
        segments.add(getAttrIndex(p, current));
        segments.add(-1);
      } else if (current is XmlNamespace) {
        segments.add(getNsIndex(p, current));
        segments.add(-2);
      } else {
        segments.add(getChildIndex(p, current));
      }
      current = p;
    }
    return segments.reversed.toList(growable: false);
  }

  final nodePaths = <(XmlNode, List<int>)>[];
  for (final node in nodes) {
    nodePaths.add((node, getPath(node)));
  }

  nodePaths.sort((a, b) {
    final p1 = a.$2;
    final p2 = b.$2;
    final len = p1.length < p2.length ? p1.length : p2.length;
    for (var i = 0; i < len; i++) {
      final diff = p1[i].compareTo(p2[i]);
      if (diff != 0) return diff;
    }
    return p1.length.compareTo(p2.length);
  });

  return [...nodePaths.map((e) => XPathNode(e.$1)), ...others];
}

Never _throwPathOperatorRequiresNodes(Object object) =>
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0019,
      'Path operator / requires sequence of nodes, but got $object',
    );
