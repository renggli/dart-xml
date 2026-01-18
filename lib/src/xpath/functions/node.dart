import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/comparison.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/mixins/has_children.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../generator.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
const fnName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'name',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [Object? arg = _missing]) {
  final node = identical(arg, _missing)
      ? context.node.toXPathNode()
      : arg as XPathNode?;
  if (node is XmlHasName) {
    return XPathSequence.single((node as XmlHasName).qualifiedName);
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
const fnLocalName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'local-name',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [Object? arg = _missing]) {
  final node = identical(arg, _missing)
      ? context.node.toXPathNode()
      : arg as XPathNode?;
  if (node is XmlHasName) {
    return XPathSequence.single(XPathString((node as XmlHasName).localName));
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
const fnNamespaceUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [Object? arg = _missing]) {
  final node = identical(arg, _missing)
      ? context.node.toXPathNode()
      : arg as XPathNode?;
  if (node is XmlHasName) {
    return XPathSequence.single(
      XPathString((node as XmlHasName).namespaceUri ?? ''),
    );
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
const fnRoot = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'root',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [Object? arg = _missing]) {
  final node = identical(arg, _missing)
      ? context.node.toXPathNode()
      : arg as XPathNode?;
  if (node != null) {
    return XPathSequence.single(node.root);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
const fnHasChildren = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'has-children',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [Object? node = _missing]) {
  final arg = identical(node, _missing)
      ? context.node.toXPathNode()
      : node as XPathNode?;
  if (arg is XmlHasChildren) {
    return XPathSequence.single((arg as XmlHasChildren).children.isNotEmpty);
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
const fnInnermost = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'innermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnInnermost,
);

XPathSequence _fnInnermost(XPathContext context, XPathSequence nodes) {
  final nodeList = nodes
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  return XPathSequence(
    nodeList.where(
      (node) => !nodeList.any(
        (other) => other != node && other.ancestors.contains(node),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
const fnOutermost = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'outermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnOutermost,
);

XPathSequence _fnOutermost(XPathContext context, XPathSequence nodes) {
  final nodeList = nodes
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  return XPathSequence(
    nodeList.where(
      (node) => !nodeList.any(
        (other) => other != node && node.ancestors.contains(other),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-path
const fnPath = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'path',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [Object? arg = _missing]) {
  final node = identical(arg, _missing)
      ? context.node.toXPathNode()
      : arg as XPathNode?;
  if (node != null) {
    return XPathSequence.single(XPathString((node as XmlNode).xpathGenerate()));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-31/#combining_seq
const opUnion = XPathFunctionDefinition(
  namespace: 'op',
  name: 'union',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _opUnion,
);

XPathSequence _opUnion(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => _nodeSetOperation(arg1, arg2, (a, b) => a.union(b));

/// https://www.w3.org/TR/xpath-31/#combining_seq
const opIntersect = XPathFunctionDefinition(
  namespace: 'op',
  name: 'intersect',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _opIntersect,
);

XPathSequence _opIntersect(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => _nodeSetOperation(arg1, arg2, (a, b) => a.intersection(b));

/// https://www.w3.org/TR/xpath-31/#combining_seq
const opExcept = XPathFunctionDefinition(
  namespace: 'op',
  name: 'except',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _opExcept,
);

XPathSequence _opExcept(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => _nodeSetOperation(arg1, arg2, (a, b) => a.difference(b));

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

const _missing = Object();
