import '../../xml/nodes/node.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
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
  XPathContext context, [
  String? jsonText,
  Map<Object, Object>? options,
]) {
  throw UnimplementedError('fn:parse-json');
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
  throw UnimplementedError('fn:json-doc');
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
  throw UnimplementedError('fn:json-to-xml');
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
  throw UnimplementedError('fn:xml-to-json');
}
