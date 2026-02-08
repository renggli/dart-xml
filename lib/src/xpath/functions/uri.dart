import 'dart:core';

import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
const fnResolveUri = XPathFunctionDefinition(
  name: 'fn:resolve-uri',
  aliases: ['resolve-uri'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'relative',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'base', type: xsString)],
  function: _fnResolveUri,
);

XPathSequence _fnResolveUri(
  XPathContext context,
  String? relative, [
  String? base,
]) {
  if (relative == null) return XPathSequence.empty;
  try {
    final uri = Uri.parse(relative);
    if (uri.isAbsolute) return XPathSequence.single(relative);
    if (base == null) {
      // TODO: Use base URI from static context
      return XPathSequence.single(relative);
    }
    return XPathSequence.single(Uri.parse(base).resolve(relative).toString());
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid URI: ${error.message}');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionDefinition(
  name: 'fn:doc',
  aliases: ['doc'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDoc,
);

XPathSequence _fnDoc(XPathContext context, String? uri) {
  if (uri == null) return XPathSequence.empty;
  // TODO: Implement URI resolution and document fetching
  throw XPathEvaluationException('Document not found: $uri');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
const fnDocAvailable = XPathFunctionDefinition(
  name: 'fn:doc-available',
  aliases: ['doc-available'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, String? uri) =>
    const XPathSequence.single(false);

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
const fnCollection = XPathFunctionDefinition(
  name: 'fn:collection',
  aliases: ['collection'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnCollection,
);

XPathSequence _fnCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
const fnUriCollection = XPathFunctionDefinition(
  name: 'fn:uri-collection',
  aliases: ['uri-collection'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUriCollection,
);

XPathSequence _fnUriCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
const fnUnparsedText = XPathFunctionDefinition(
  name: 'fn:unparsed-text',
  aliases: ['unparsed-text'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedText,
);

XPathSequence _fnUnparsedText(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
const fnUnparsedTextLines = XPathFunctionDefinition(
  name: 'fn:unparsed-text-lines',
  aliases: ['unparsed-text-lines'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedTextLines,
);

XPathSequence _fnUnparsedTextLines(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text-lines');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
const fnUnparsedTextAvailable = XPathFunctionDefinition(
  name: 'fn:unparsed-text-available',
  aliases: ['unparsed-text-available'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedTextAvailable,
);

XPathSequence _fnUnparsedTextAvailable(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text-available');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
const fnEnvironmentVariable = XPathFunctionDefinition(
  name: 'fn:environment-variable',
  aliases: ['environment-variable'],
  requiredArguments: [XPathArgumentDefinition(name: 'name', type: xsString)],
  function: _fnEnvironmentVariable,
);

XPathSequence _fnEnvironmentVariable(XPathContext context, String name) {
  throw UnimplementedError('fn:environment-variable');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
const fnAvailableEnvironmentVariables = XPathFunctionDefinition(
  name: 'fn:available-environment-variables',
  aliases: ['available-environment-variables'],
  function: _fnAvailableEnvironmentVariables,
);

XPathSequence _fnAvailableEnvironmentVariables(XPathContext context) {
  throw UnimplementedError('fn:available-environment-variables');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
const fnEncodeForUri = XPathFunctionDefinition(
  name: 'fn:encode-for-uri',
  aliases: ['encode-for-uri'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri-part',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnEncodeForUri,
);

XPathSequence _fnEncodeForUri(XPathContext context, String? uriPart) {
  if (uriPart == null) return XPathSequence.emptyString;
  return XPathSequence.single(Uri.encodeComponent(uriPart));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
const fnIriToUri = XPathFunctionDefinition(
  name: 'fn:iri-to-uri',
  aliases: ['iri-to-uri'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'iri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnIriToUri,
);

XPathSequence _fnIriToUri(XPathContext context, String? iri) {
  if (iri == null) return XPathSequence.emptyString;
  return XPathSequence.single(Uri.encodeFull(iri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
const fnEscapeHtmlUri = XPathFunctionDefinition(
  name: 'fn:escape-html-uri',
  aliases: ['escape-html-uri'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, String? uri) {
  if (uri == null) return XPathSequence.emptyString;
  // TODO: Proper HTML URI escaping
  return XPathSequence.single(Uri.encodeFull(uri));
}
