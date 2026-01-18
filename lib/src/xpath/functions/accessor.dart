import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
const fnNodeName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'node-name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNodeName,
);

XPathSequence _fnNodeName(XPathContext context, [Object? node = _missing]) {
  final n = identical(node, _missing)
      ? context.node.toXPathNode()
      : (node as XPathNode?);
  if (n is XmlHasName) {
    return XPathSequence.single((n as XmlHasName).name);
  } else if (n is XmlProcessing) {
    return XPathSequence.single(
      XmlName.fromString((n as XmlProcessing).target),
    );
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
const fnNilled = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'nilled',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNilled,
);

XPathSequence _fnNilled(XPathContext context, [Object? node = _missing]) {
  final n = identical(node, _missing)
      ? context.node.toXPathNode()
      : (node as XPathNode?);
  // PetitXml doesn't have a built-in concept of nilled, returning false
  // for elements.
  if (n is XmlElement) return XPathSequence.falseSequence;
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
const fnString = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'string',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnString,
);

XPathSequence _fnString(XPathContext context, [Object? arg = _missing]) {
  if (identical(arg, _missing)) {
    return XPathSequence.single(context.node.toXPathString());
  }
  if (arg == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single((arg as XPathSequence).toXPathString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
const fnData = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'data',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnData,
);

XPathSequence _fnData(XPathContext context, [Object? arg = _missing]) {
  final a = identical(arg, _missing)
      ? XPathSequence.single(context.node)
      : (arg as XPathSequence? ?? XPathSequence.empty);
  return XPathSequence(a.expand(_atomize));
}

Iterable<Object> _atomize(Object item) {
  if (item is XmlNode) {
    return [item.toXPathString()];
  } else if (item is Iterable<Object>) {
    return item.expand(_atomize);
  } else {
    return [item];
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
const fnBaseUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'base-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnBaseUri,
);

XPathSequence _fnBaseUri(XPathContext context, [Object? node = _missing]) {
  final n = identical(node, _missing)
      ? context.node.toXPathNode()
      : (node as XPathNode?);
  // 1. Look for xml:base on the node or its ancestors

  for (XmlNode? current = n; current != null; current = current.parent) {
    if (current is XmlElement) {
      final xmlBase = current.getAttribute('xml:base');
      if (xmlBase != null) {
        try {
          return XPathSequence.single(
            XPathString(Uri.parse(xmlBase).toString()),
          );
        } catch (_) {
          // If invalid URI, ignore
        }
      }
    }
  }
  // 2. Fallback to static base URI if available (not tracked in PetitXml currently)
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
const fnDocumentUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'document-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathNode,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDocumentUri,
);

XPathSequence _fnDocumentUri(XPathContext context, [Object? node = _missing]) {
  final n = identical(node, _missing)
      ? context.node.toXPathNode()
      : (node as XPathNode?);
  if (n is XmlDocument) {
    // PetitXml does not track the source URI of a document.
    // If it did, we would return it here.
    // For now, return empty sequence as per spec for "no document URI"
  }
  return XPathSequence.empty;
}

const _missing = Object();
