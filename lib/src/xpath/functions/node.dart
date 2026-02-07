import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
const fnName = XPathFunctionDefinition(
  name: 'fn:name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
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
  name: 'fn:local-name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
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
  name: 'fn:namespace-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
  if (node is XmlElement) {
    return XPathSequence.single(node.name.namespaceUri ?? '');
  } else if (node is XmlAttribute) {
    return XPathSequence.single(node.name.namespaceUri ?? '');
  }
  return XPathSequence.emptyString;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
const fnId = XPathFunctionDefinition(
  name: 'fn:id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: 'fn:element-with-id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: 'fn:idref',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: 'fn:generate-id',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnGenerateId,
);

XPathSequence _fnGenerateId(XPathContext context, [XmlNode? arg]) {
  throw UnimplementedError('fn:generate-id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
const fnRoot = XPathFunctionDefinition(
  name: 'fn:root',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
  return XPathSequence.single(node.root);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
const fnHasChildren = XPathFunctionDefinition(
  name: 'fn:has-children',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
  return XPathSequence.single(node.children.isNotEmpty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
const fnInnermost = XPathFunctionDefinition(
  name: 'fn:innermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: 'fn:outermost',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: 'fn:path',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
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
      if (preceding != null && preceding.length > 1) {
        final index = preceding.indexOf(current);
        components.add('$name[${index + 1}]');
      } else {
        components.add(name);
      }
    } else if (current is XmlAttribute) {
      components.add('@${current.name.local}');
    }
    current = current.parent;
  }
  return XPathSequence.single(components.reversed.join('/'));
}
