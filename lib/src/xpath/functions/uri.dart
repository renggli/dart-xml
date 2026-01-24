import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

XPathString _defaultResolveUriBase(XPathContext context) => '';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
const fnResolveUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'resolve-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'relative',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'base',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
      defaultValue: _defaultResolveUriBase,
    ),
  ],
  function: _fnResolveUri,
);

XPathSequence _fnResolveUri(
  XPathContext context,
  XPathString? relative, [
  XPathString? base,
]) {
  if (relative == null) return XPathSequence.empty;
  // If base was provided as empty sequence, return empty.
  // Note: If base was omitted, defaultValue was used, so base is not null.
  // Wait, if _defaultResolveUriBase returns '', base is ''.
  // But if passed '()' -> base is null.
  // Spec: If base is empty sequence, return empty.
  if (base == null) return XPathSequence.empty;

  final baseStr = base.toString();
  if (baseStr.isEmpty) {
    // If base is empty string (from default value?), return relative?
    // Current logic: return relative.
    return XPathSequence.single(relative);
  }
  try {
    return XPathSequence.single(
      Uri.parse(baseStr).resolve(relative.toString()).toString(),
    );
  } catch (e) {
    throw XPathEvaluationException('Invalid URI: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
const fnEncodeForUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'encode-for-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uriPart',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnEncodeForUri,
);

XPathSequence _fnEncodeForUri(XPathContext context, XPathString? uriPart) {
  final part = uriPart ?? '';
  return XPathSequence.single(Uri.encodeComponent(part));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
const fnIriToUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'iri-to-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'iri',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnIriToUri,
);

XPathSequence _fnIriToUri(XPathContext context, XPathString? iri) {
  final val = iri ?? '';
  return XPathSequence.single(Uri.encodeFull(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
const fnEscapeHtmlUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'escape-html-uri',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, XPathString? uri) {
  final val = uri ?? '';
  // Simple implementation using Uri.encodeFull which is similar to what's required
  return XPathSequence.single(Uri.encodeFull(val));
}
