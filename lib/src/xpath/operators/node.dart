import '../../xml/extensions/comparison.dart';
import '../../xml/nodes/node.dart';
import '../types/node.dart';
import '../values/sequence.dart';

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
  final arg1 = left.map(xsNode.cast).toSet();
  final arg2 = right.map(xsNode.cast).toSet();
  final result = operation(arg1, arg2).toList();
  result.sort(_compareNodePosition);
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodeIs(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  return XPathSequence.single(identical(node1, node2));
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodePrecedes(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  return XPathSequence.single(_compareNodePosition(node1, node2) < 0);
}

/// https://www.w3.org/TR/xpath-31/#id-node-comparisons
XPathSequence opNodeFollows(XPathSequence left, XPathSequence right) {
  final node1 = _singleNodeOrNull(left);
  final node2 = _singleNodeOrNull(right);
  if (node1 == null || node2 == null) return XPathSequence.empty;
  return XPathSequence.single(_compareNodePosition(node1, node2) > 0);
}

XmlNode? _singleNodeOrNull(XPathSequence seq) {
  if (seq.isEmpty) return null;
  return xsNode.cast(seq.single);
}

int _compareNodePosition(XmlNode a, XmlNode b) {
  final pos = a.compareDocumentPosition(b);
  if (pos.isPreceding) return 1;
  if (pos.isFollowing) return -1;
  return 0;
}
