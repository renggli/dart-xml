import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
const fnNodeName = XPathFunctionDefinition(
  name: 'fn:node-name',
  aliases: ['node-name'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnNodeName,
);

XPathSequence _fnNodeName(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
  if (node is XmlElement) return XPathSequence.single(node.name);
  if (node is XmlAttribute) return XPathSequence.single(node.name);
  if (node is XmlProcessing) {
    return XPathSequence.single(XmlName.qualified(node.target));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
const fnNilled = XPathFunctionDefinition(
  name: 'fn:nilled',
  aliases: ['nilled'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnNilled,
);

XPathSequence _fnNilled(XPathContext context, [XmlNode? arg]) {
  final node = arg ?? xsNode.cast(context.item);
  if (node is XmlElement) {
    // TODO: Implement proper nilled check based on xsi:nil attribute
    return XPathSequence.falseSequence;
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
const fnString = XPathFunctionDefinition(
  name: 'fn:string',
  aliases: ['string'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsSequence,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnString,
);

XPathSequence _fnString(XPathContext context, [XPathSequence? arg]) {
  if (arg == null) return XPathSequence.single(xsString.cast(context.item));
  if (arg.isEmpty) return XPathSequence.emptyString;
  return XPathSequence.single(xsString.cast(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
const fnData = XPathFunctionDefinition(
  name: 'fn:data',
  aliases: ['data'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnData,
);

XPathSequence _fnData(XPathContext context, [XPathSequence? arg]) {
  if (arg == null) return _fnData(context, xsSequence.cast(context.item));
  return XPathSequence(
    arg.expand<Object>((item) {
      if (item is XmlNode) return [xsString.cast(item)];
      if (item is XPathArray) return item;
      return [item];
    }),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
const fnBaseUri = XPathFunctionDefinition(
  name: 'fn:base-uri',
  aliases: ['base-uri'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnBaseUri,
);

// TODO: Add support for xml:base and tracking source URI
XPathSequence _fnBaseUri(XPathContext context, [XmlNode? arg]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
const fnDocumentUri = XPathFunctionDefinition(
  name: 'fn:document-uri',
  aliases: ['document-uri'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDocumentUri,
);

// TODO: Add support for tracking source document URI
XPathSequence _fnDocumentUri(XPathContext context, [XmlNode? arg]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
const fnSerialize = XPathFunctionDefinition(
  name: 'fn:serialize',
  aliases: ['serialize'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'params',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSerialize,
);

XPathSequence _fnSerialize(
  XPathContext context,
  XPathSequence arg, [
  Object? params,
]) => throw UnimplementedError('fn:serialize');

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
const fnParseXml = XPathFunctionDefinition(
  name: 'fn:parse-xml',
  aliases: ['parse-xml'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnParseXml,
);

XPathSequence _fnParseXml(XPathContext context, String? arg) =>
    throw UnimplementedError('fn:parse-xml');

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
const fnParseXmlFragment = XPathFunctionDefinition(
  name: 'fn:parse-xml-fragment',
  aliases: ['parse-xml-fragment'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnParseXmlFragment,
);

XPathSequence _fnParseXmlFragment(XPathContext context, String? arg) =>
    throw UnimplementedError('fn:parse-xml-fragment');
