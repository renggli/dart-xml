import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
const fnResolveUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'resolve-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'relative',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  final uri = Uri.parse(relative);
  if (uri.isAbsolute) return XPathSequence.single(relative);
  if (base == null) {
    // TODO: Use base URI from static context
    return XPathSequence.single(relative);
  }
  return XPathSequence.single(Uri.parse(base).resolve(relative).toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'doc',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'doc-available',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, String? uri) =>
    XPathSequence.single(false);

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
const fnCollection = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'collection',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnCollection,
);

XPathSequence _fnCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
const fnUriCollection = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'uri-collection',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnUriCollection,
);

XPathSequence _fnUriCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
const fnUnparsedText = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnUnparsedText,
);

XPathSequence _fnUnparsedText(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
const fnUnparsedTextLines = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text-lines',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnUnparsedTextLines,
);

XPathSequence _fnUnparsedTextLines(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text-lines');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
const fnUnparsedTextAvailable = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text-available',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnUnparsedTextAvailable,
);

XPathSequence _fnUnparsedTextAvailable(XPathContext context, String? href) {
  throw UnimplementedError('fn:unparsed-text-available');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
const fnEnvironmentVariable = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'environment-variable',
  requiredArguments: [XPathArgumentDefinition(name: 'name', type: xsString)],
  function: _fnEnvironmentVariable,
);

XPathSequence _fnEnvironmentVariable(XPathContext context, String name) {
  throw UnimplementedError('fn:environment-variable');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
const fnAvailableEnvironmentVariables = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'available-environment-variables',
  function: _fnAvailableEnvironmentVariables,
);

XPathSequence _fnAvailableEnvironmentVariables(XPathContext context) {
  throw UnimplementedError('fn:available-environment-variables');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
const fnEncodeForUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'encode-for-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri-part',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'iri-to-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'iri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'escape-html-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, String? uri) {
  if (uri == null) return XPathSequence.emptyString;
  // TODO: Proper HTML URI escaping
  return XPathSequence.single(Uri.encodeFull(uri));
}
