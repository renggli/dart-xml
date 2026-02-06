import 'dart:convert';

import '../../xml/nodes/node.dart';
import '../definitions/cardinality.dart';
import '../definitions/functions.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/map.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionDefinition(
  name: 'fn:parse-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnParseJson,
);

XPathSequence _fnParseJson(
  XPathContext context,
  String? jsonText, [
  Map<Object, Object>? options,
]) {
  if (jsonText == null) return XPathSequence.empty;
  try {
    final result = json.decode(jsonText);
    if (result == null) return XPathSequence.empty;
    return XPathSequence.single(result as Object);
  } catch (e) {
    throw XPathEvaluationException('Invalid JSON: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
const fnJsonDoc = XPathFunctionDefinition(
  name: 'fn:json-doc',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnJsonDoc,
);

XPathSequence _fnJsonDoc(
  XPathContext context,
  String? href, [
  Map<Object, Object>? options,
]) {
  if (href == null) return XPathSequence.empty;
  // TODO: Implement URI resolution and fetching
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml
const fnJsonToXml = XPathFunctionDefinition(
  name: 'fn:json-to-xml',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnJsonToXml,
);

XPathSequence _fnJsonToXml(
  XPathContext context,
  String? jsonText, [
  Map<Object, Object>? options,
]) {
  if (jsonText == null) return XPathSequence.empty;
  // TODO: Implement JSON to XML conversion
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json
const fnXmlToJson = XPathFunctionDefinition(
  name: 'fn:xml-to-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnXmlToJson,
);

XPathSequence _fnXmlToJson(
  XPathContext context,
  XmlNode? input, [
  Map<Object, Object>? options,
]) {
  if (input == null) return XPathSequence.empty;
  // TODO: Implement XML to JSON conversion
  return XPathSequence.empty;
}
