import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/map.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnParseJson,
);

XPathSequence _fnParseJson(
  XPathContext context, [
  XPathString? jsonText,
  XPathMap? options,
]) {
  throw UnimplementedError('fn:parse-json');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
const fnJsonDoc = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'json-doc',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnJsonDoc,
);

XPathSequence _fnJsonDoc(
  XPathContext context, [
  XPathString? href,
  XPathMap? options,
]) {
  throw UnimplementedError('fn:json-doc');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml
const fnJsonToXml = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'json-to-xml',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnJsonToXml,
);

XPathSequence _fnJsonToXml(
  XPathContext context, [
  XPathSequence? jsonText,
  XPathMap? options,
]) {
  throw UnimplementedError('fn:json-to-xml');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json
const fnXmlToJson = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'xml-to-json',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnXmlToJson,
);

XPathSequence _fnXmlToJson(
  XPathContext context, [
  XPathSequence? input,
  XPathMap? options,
]) {
  throw UnimplementedError('fn:xml-to-json');
}
