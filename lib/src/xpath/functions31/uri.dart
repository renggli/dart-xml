import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
XPathSequence fnResolveUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:resolve-uri',
    arguments,
    1,
    2,
  );
  final relative = XPathEvaluationException.extractZeroOrOne(
    'fn:resolve-uri',
    'relative',
    arguments[0],
  )?.toXPathString();
  if (relative == null) return XPathSequence.empty;
  if (arguments.length < 2) {
    // TODO: Use base-uri from static context if available
    return XPathSequence.single(XPathString(relative));
  }
  final base =
      XPathEvaluationException.extractZeroOrOne(
        'fn:resolve-uri',
        'base',
        arguments[1],
      )?.toXPathString() ??
      '';
  try {
    return XPathSequence.single(
      XPathString(Uri.parse(base).resolve(relative).toString()),
    );
  } catch (e) {
    throw XPathEvaluationException('Invalid URI: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
XPathSequence fnEncodeForUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:encode-for-uri',
    arguments,
    1,
  );
  final uriPart =
      XPathEvaluationException.extractZeroOrOne(
        'fn:encode-for-uri',
        'uriPart',
        arguments[0],
      )?.toXPathString() ??
      '';
  return XPathSequence.single(XPathString(Uri.encodeComponent(uriPart)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
XPathSequence fnIriToUri(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:iri-to-uri', arguments, 1);
  final iri =
      XPathEvaluationException.extractZeroOrOne(
        'fn:iri-to-uri',
        'iri',
        arguments[0],
      )?.toXPathString() ??
      '';
  return XPathSequence.single(XPathString(Uri.encodeFull(iri)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
XPathSequence fnEscapeHtmlUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:escape-html-uri',
    arguments,
    1,
  );
  final uri =
      XPathEvaluationException.extractZeroOrOne(
        'fn:escape-html-uri',
        'uri',
        arguments[0],
      )?.toXPathString() ??
      '';
  // Simple implementation using Uri.encodeFull which is similar to what's required
  return XPathSequence.single(XPathString(Uri.encodeFull(uri)));
}
