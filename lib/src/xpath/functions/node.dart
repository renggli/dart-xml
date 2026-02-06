import '../../../xml.dart';

import '../evaluation/context.dart';
import '../evaluation/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
const fnName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  if (node is XmlElement) {
    return XPathSequence.single(node.name.toString());
  } else if (node is XmlAttribute) {
    return XPathSequence.single(node.name.toString());
  } else if (node is XmlProcessing) {
    return XPathSequence.single(node.target);
  }
  return XPathSequence.emptyString;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
const fnLocalName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'local-name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  if (node is XmlElement) {
    return XPathSequence.single(node.name.local);
  } else if (node is XmlAttribute) {
    return XPathSequence.single(node.name.local);
  } else if (node is XmlProcessing) {
    return XPathSequence.single(node.target);
  }
  return XPathSequence.emptyString;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
const fnNamespaceUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  if (node is XmlElement) {
    return XPathSequence.single(node.name.namespaceUri ?? '');
  } else if (node is XmlAttribute) {
    return XPathSequence.single(node.name.namespaceUri ?? '');
  }
  return XPathSequence.emptyString;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
const fnId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: xsNode)],
  function: _fnId,
);

XPathSequence _fnId(XPathContext context, XPathSequence arg, [XmlNode? node]) {
  throw UnimplementedError('fn:id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
const fnElementWithId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'element-with-id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: xsNode)],
  function: _fnElementWithId,
);

XPathSequence _fnElementWithId(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  throw UnimplementedError('fn:element-with-id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
const fnIdref = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'idref',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: xsNode)],
  function: _fnIdref,
);

XPathSequence _fnIdref(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  throw UnimplementedError('fn:idref');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
const fnGenerateId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'generate-id',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnGenerateId,
);

XPathSequence _fnGenerateId(XPathContext context, [XmlNode? arg]) {
  throw UnimplementedError('fn:generate-id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
const fnRoot = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'root',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [XmlNode? arg]) {
  var node = arg ?? context.item.toXPathNode();
  while (node.parent != null) {
    node = node.parent!;
  }
  return XPathSequence.single(node);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
const fnHasChildren = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'has-children',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.exactlyOne,
      ),
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [XmlNode? node]) {
  final target = node ?? context.item.toXPathNode();
  return XPathSequence.single(target.children.isNotEmpty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
const fnInnermost = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'innermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnInnermost,
);

XPathSequence _fnInnermost(XPathContext context, XPathSequence nodes) {
  final list = nodes.cast<XmlNode>().toList();
  final result = <XmlNode>[];
  for (final node in list) {
    if (!list.any(
      (other) => node != other && node.descendants.any((desc) => desc == other),
    )) {
      result.add(node);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
const fnOutermost = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'outermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnOutermost,
);

XPathSequence _fnOutermost(XPathContext context, XPathSequence nodes) {
  final list = nodes.cast<XmlNode>().toList();
  final result = <XmlNode>[];
  for (final node in list) {
    if (!list.any(
      (other) => node != other && node.ancestors.any((anc) => anc == other),
    )) {
      result.add(node);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-path
const fnPath = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'path',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  // Basic implementation
  final components = <String>[];
  XmlNode? current = node;
  while (current != null) {
    if (current is XmlDocument) {
      components.add('');
    } else if (current is XmlElement) {
      final name = current.name.local;
      final preceding = current.parent?.children
          .whereType<XmlElement>()
          .where((XmlElement e) => e.name.local == name)
          .toList();
      final index = preceding != null ? preceding.indexOf(current) : 0;
      components.add('$name[${index + 1}]');
    } else if (current is XmlAttribute) {
      components.add('@${current.name.local}');
    }
    current = current.parent;
  }
  return XPathSequence.single(components.reversed.join('/'));
}
