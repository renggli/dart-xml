import '../../../xml.dart';

import '../evaluation/context.dart';
import '../evaluation/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
const fnNodeName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'node-name',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnNodeName,
);

XPathSequence _fnNodeName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  if (node is XmlElement) return XPathSequence.single(node.name);
  if (node is XmlAttribute) return XPathSequence.single(node.name);
  if (node is XmlProcessing) return XPathSequence.single(node.target);
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
const fnNilled = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'nilled',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnNilled,
);

XPathSequence _fnNilled(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? context.item.toXPathNode();
  if (node is XmlElement) {
    // TODO: Implement proper nilled check based on xsi:nil attribute
    return XPathSequence.falseSequence;
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
const fnString = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'string',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnString,
);

XPathSequence _fnString(XPathContext context, [Object? arg]) {
  final item = arg ?? context.item;
  return XPathSequence.single(item.toXPathString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
const fnData = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'data',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnData,
);

XPathSequence _fnData(XPathContext context, [Object? arg]) {
  if (arg == null) return XPathSequence.empty;
  final items = arg is XPathSequence ? arg : arg.toXPathSequence();
  return XPathSequence(
    items.expand<Object>((item) {
      if (item is XmlNode) return [item.toXPathString()];
      if (item is Iterable && item is! Map) return item.cast<Object>();
      return [item];
    }),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
const fnBaseUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'base-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnBaseUri,
);

XPathSequence _fnBaseUri(XPathContext context, [XmlNode? arg]) {
  // TODO: Add support for xml:base and tracking source URI
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
const fnDocumentUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'document-uri',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnDocumentUri,
);

XPathSequence _fnDocumentUri(XPathContext context, [XmlNode? arg]) {
  // TODO: Add support for tracking source document URI
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
const fnSerialize = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'serialize',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'params', type: xsAny)],
  function: _fnSerialize,
);

XPathSequence _fnSerialize(
  XPathContext context,
  XPathSequence arg, [
  Object? params,
]) {
  throw UnimplementedError('fn:serialize');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
const fnParseXml = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-xml',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnParseXml,
);

XPathSequence _fnParseXml(XPathContext context, String? arg) {
  throw UnimplementedError('fn:parse-xml');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
const fnParseXmlFragment = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-xml-fragment',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnParseXmlFragment,
);

XPathSequence _fnParseXmlFragment(XPathContext context, String? arg) {
  throw UnimplementedError('fn:parse-xml-fragment');
}
