import '../../xml/extensions/comparison.dart';
import '../../xml/nodes/node.dart';
import '../types/node.dart';
import '../types/sequence.dart';

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
  XPathSequence arg1Seq,
  XPathSequence arg2Seq,
  Set<XmlNode> Function(Set<XmlNode>, Set<XmlNode>) operation,
) {
  final arg1 = arg1Seq
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toSet();
  final arg2 = arg2Seq
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toSet();
  final result = operation(arg1, arg2).toList();
  result.sort((a, b) => a.compareNodePosition(b));
  return XPathSequence(result);
}
