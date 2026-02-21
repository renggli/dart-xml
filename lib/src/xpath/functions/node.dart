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
import '../exceptions/evaluation_exception.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
const fnName = XPathFunctionDefinition(
  name: 'fn:name',
  aliases: ['name'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
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
  aliases: ['local-name'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
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
  aliases: ['namespace-uri'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
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
  aliases: ['id'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnId,
);

XPathSequence _fnId(XPathContext context, XPathSequence arg, [XmlNode? node]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null) throw XPathEvaluationException('Invalid document');
  return XPathSequence(
    root.descendantElements.where(
      (element) => element.attributes.any(
        (attribute) =>
            _isIdAttribute(attribute) && ids.contains(attribute.value.trim()),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
const fnElementWithId = XPathFunctionDefinition(
  name: 'fn:element-with-id',
  aliases: ['element-with-id'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnElementWithId,
);

XPathSequence _fnElementWithId(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null) throw XPathEvaluationException('Invalid document');
  final seen = <String>{};
  return XPathSequence(
    root.descendantElements.where(
      (element) => element.attributes.where(_isIdAttribute).any((attribute) {
        final value = attribute.value.trim();
        return ids.contains(value) && seen.add(value);
      }),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
const fnIdref = XPathFunctionDefinition(
  name: 'fn:idref',
  aliases: ['idref'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnIdref,
);

XPathSequence _fnIdref(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null) throw XPathEvaluationException('Invalid document');
  return XPathSequence(
    root.descendantElements.expand(
      (element) => element.attributes.where(
        (attribute) =>
            _isIdrefAttribute(attribute) &&
            attribute.value.trim().split(_whitespace).any(ids.contains),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
const fnGenerateId = XPathFunctionDefinition(
  name: 'fn:generate-id',
  aliases: ['generate-id'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnGenerateId,
);

XPathSequence _fnGenerateId(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
  final id = identityHashCode(
    node,
  ).toRadixString(16).toUpperCase().padLeft(8, '0');
  return XPathSequence.single('autoId$id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
const fnRoot = XPathFunctionDefinition(
  name: 'fn:root',
  aliases: ['root'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.empty;
  return XPathSequence.single(node.root);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
const fnHasChildren = XPathFunctionDefinition(
  name: 'fn:has-children',
  aliases: ['has-children'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.falseSequence;
  return XPathSequence.single(node.children.isNotEmpty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
const fnInnermost = XPathFunctionDefinition(
  name: 'fn:innermost',
  aliases: ['innermost'],
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
  aliases: ['outermost'],
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
  aliases: ['path'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
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

final _whitespace = RegExp(r'\s+');

XmlNode _defaultToContextItem(XPathContext context) =>
    xsNode.cast(context.item);

Set<String> _parseIdStrings(XPathSequence arg) => arg
    .map(xsString.cast)
    .expand((each) => each.split(_whitespace))
    .where((each) => each.isNotEmpty)
    .toSet();

bool _isIdAttribute(XmlAttribute attr) =>
    attr.name.local == 'id' || attr.name.qualified == 'xml:id';

bool _isIdrefAttribute(XmlAttribute attr) =>
    attr.name.local == 'idref' ||
    attr.name.local == 'idrefs' ||
    attr.name.qualified == 'xml:idref' ||
    attr.name.qualified == 'xml:idrefs';
