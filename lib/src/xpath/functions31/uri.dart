import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
XPathSequence fnResolveUri(
  XPathContext context,
  XPathSequence relative, [
  XPathSequence? base,
]) {
  final relVal = XPathEvaluationException.checkZeroOrOne(
    relative,
  )?.toXPathString();
  if (relVal == null) return XPathSequence.empty;
  if (base == null) {
    // TODO: Use base-uri from static context if available
    return XPathSequence.single(XPathString(relVal));
  }
  final baseVal =
      XPathEvaluationException.checkZeroOrOne(base)?.toXPathString() ?? '';
  try {
    return XPathSequence.single(
      XPathString(Uri.parse(baseVal).resolve(relVal).toString()),
    );
  } catch (e) {
    throw XPathEvaluationException('Invalid URI: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
XPathSequence fnEncodeForUri(XPathContext context, XPathSequence uriPart) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(uriPart)?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(Uri.encodeComponent(valOpt)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
XPathSequence fnIriToUri(XPathContext context, XPathSequence iri) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(iri)?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(Uri.encodeFull(valOpt)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
XPathSequence fnEscapeHtmlUri(XPathContext context, XPathSequence uri) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(uri)?.toXPathString() ?? '';
  // Simple implementation using Uri.encodeFull which is similar to what's required
  return XPathSequence.single(XPathString(Uri.encodeFull(valOpt)));
}
