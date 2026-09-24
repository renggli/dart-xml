import '../../xml/extensions/comparison.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-union
XPathSequence opUnion(XPathSequence left, XPathSequence right) =>
    _nodeSetOperation(left, right, (a, b) => a.union(b));

/// https://www.w3.org/TR/xpath-functions-31/#func-intersect
XPathSequence opIntersect(XPathSequence left, XPathSequence right) =>
    _nodeSetOperation(left, right, (a, b) => a.intersection(b));

/// https://www.w3.org/TR/xpath-functions-31/#func-except
XPathSequence opExcept(XPathSequence left, XPathSequence right) =>
    _nodeSetOperation(left, right, (a, b) => a.difference(b));

XPathSequence _nodeSetOperation(
  XPathSequence left,
  XPathSequence right,
  Set<XmlNode> Function(Set<XmlNode>, Set<XmlNode>) operation,
) {
  final arg1 = <XmlNode>{};
  for (final item in left) {
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Required item type of operand is node(); got ${item.type}',
      );
    }
    arg1.add(item.node);
  }
  final arg2 = <XmlNode>{};
  for (final item in right) {
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Required item type of operand is node(); got ${item.type}',
      );
    }
    arg2.add(item.node);
  }
  final result = operation(arg1, arg2).toList();
  result.sort(_compareNodePosition);
  return XPathSequence.from(result.map(XPathNode.new));
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodeIs(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  if (identical(node1, node2)) return XPathSequence.trueSequence;
  if (node1 is XmlNamespace && node2 is XmlNamespace) {
    return (node1.parent == node2.parent &&
            node1.prefix == node2.prefix &&
            node1.uri == node2.uri)
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodePrecedes(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  return _compareNodePosition(node1, node2) < 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodeFollows(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  return _compareNodePosition(node1, node2) > 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XmlNode? _singleNodeOrNull(XPathSequence seq) {
  if (seq.isEmpty) return null;
  final item = seq.single;
  if (item is! XPathNode) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Required item type of operand is node(); got ${item.type}',
    );
  }
  return item.node;
}

int _compareNodePosition(XmlNode node1, XmlNode node2) {
  final pos = node1.compareDocumentPosition(node2);
  if (pos.isPreceding) return 1;
  if (pos.isFollowing) return -1;
  return 0;
}
