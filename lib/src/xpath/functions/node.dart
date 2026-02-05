import '../../xml/extensions/ancestors.dart';

import '../../xml/extensions/parent.dart';
import '../../xml/mixins/has_children.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../generator.dart';
import '../types/node.dart';
import '../types/sequence.dart';

XPathNode _defaultNode(XPathContext context) => context.item.toXPathNode();

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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [XPathNode? arg]) {
  final node = arg;
  if (node is XmlHasName) {
    return XPathSequence.single((node as XmlHasName).qualifiedName);
  }
  return XPathSequence.emptyString;
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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [XPathNode? arg]) {
  final node = arg;
  if (node is XmlHasName) {
    return XPathSequence.single((node as XmlHasName).localName);
  }
  return XPathSequence.emptyString;
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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [XPathNode? arg]) {
  final node = arg;
  if (node is XmlHasName) {
    return XPathSequence.single((node as XmlHasName).namespaceUri ?? '');
  }
  return XPathSequence.emptyString;
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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [XPathNode? arg]) {
  final node = arg;
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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [XPathNode? node]) {
  final arg = node;
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
      defaultValue: _defaultNode,
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [XPathNode? arg]) {
  final node = arg;
  if (node != null) {
    return XPathSequence.single(node.xpathGenerate());
  }
  return XPathSequence.empty;
}
