import 'dart:convert';

import '../../../xml.dart';
import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'json-doc',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'json-to-xml',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'xml-to-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathSequenceType(
        xsNode,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
