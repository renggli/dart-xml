import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
XPathSequence fnResolveQName(
  XPathContext context,
  XPathSequence qname,
  XPathSequence element,
) {
  final qnameOpt = XPathEvaluationException.checkZeroOrOne(
    qname,
  )?.toXPathString();
  if (qnameOpt == null || element.isEmpty) return XPathSequence.empty;
  // TODO: Implement proper QName resolution using element's in-scope namespaces.
  return XPathSequence.single(XmlName.fromString(qnameOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
XPathSequence fnQName(
  XPathContext context,
  XPathSequence paramUri,
  XPathSequence paramQName,
) {
  // final uriOpt = XPathEvaluationException.checkZeroOrOne(
  //   paramUri,
  // )?.toXPathString();
  final qnameVal = XPathEvaluationException.checkExactlyOne(
    paramQName,
  ).toXPathString();

  // TODO: XmlName in PetitXml currently does not store the namespace URI explicitly
  // when detached, so uriOpt is ignored here. This is a limitation.
  return XPathSequence.single(XmlName.fromString(qnameVal));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
XPathSequence fnPrefixFromQName(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg);
  if (valOpt is! XmlName) return XPathSequence.empty;
  return valOpt.prefix == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(valOpt.prefix!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
XPathSequence fnLocalNameFromQName(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg);
  if (valOpt is! XmlName) return XPathSequence.empty;
  return XPathSequence.single(XPathString(valOpt.local));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
XPathSequence fnNamespaceUriFromQName(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg);
  if (valOpt is! XmlName) return XPathSequence.empty;
  return valOpt.namespaceUri == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(valOpt.namespaceUri!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName-equal
XPathSequence opQNameEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkZeroOrOne(arg1);
  final val2 = XPathEvaluationException.checkZeroOrOne(arg2);

  if (val1 == null || val2 == null) return XPathSequence.empty;

  if (val1 is XmlName && val2 is XmlName) {
    return XPathSequence.single(val1 == val2);
  }
  // If arguments are not QNames, strictly speaking it should be an error or specialized handling,
  // but for now assume they are compatible if we reached here.
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
XPathSequence fnNamespaceUriForPrefix(
  XPathContext context,
  XPathSequence prefix,
  XPathSequence element,
) {
  throw UnimplementedError('fn:namespace-uri-for-prefix');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
XPathSequence fnInScopePrefixes(XPathContext context, XPathSequence element) {
  throw UnimplementedError('fn:in-scope-prefixes');
}
