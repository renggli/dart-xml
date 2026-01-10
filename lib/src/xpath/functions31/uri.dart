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
  final relativeValue = relative.firstOrNull?.toXPathString();
  if (relativeValue == null) return XPathSequence.empty;
  if (base == null) {
    // TODO: Use base-uri from static context if available
    return XPathSequence.single(XPathString(relativeValue));
  }
  final baseValue = base.firstOrNull?.toXPathString() ?? '';
  try {
    return XPathSequence.single(
      XPathString(Uri.parse(baseValue).resolve(relativeValue).toString()),
    );
  } catch (e) {
    throw XPathEvaluationException('Invalid URI: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
XPathSequence fnEncodeForUri(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(Uri.encodeComponent(value)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
XPathSequence fnIriToUri(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(Uri.encodeFull(value)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
XPathSequence fnEscapeHtmlUri(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathString() ?? '';
  // Simple implementation using Uri.encodeFull which is similar to what's required
  return XPathSequence.single(XPathString(Uri.encodeFull(value)));
}
