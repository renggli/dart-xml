import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
XPathSequence fnResolveQName(
  XPathContext context,
  XPathSequence qname,
  XPathSequence element,
) {
  final qnameValue = qname.firstOrNull?.toXPathString();
  if (qnameValue == null || element.isEmpty) return XPathSequence.empty;
  // TODO: Implement proper QName resolution using element's in-scope namespaces.
  return XPathSequence.single(XmlName.fromString(qnameValue));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
XPathSequence fnQName(
  XPathContext context,
  XPathSequence paramUri,
  XPathSequence paramQName,
) {
  final qname = paramQName.firstOrNull?.toXPathString() ?? '';
  return XPathSequence.single(XmlName.fromString(qname));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
XPathSequence fnPrefixFromQName(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value is! XmlName) return XPathSequence.empty;
  return value.prefix == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(value.prefix!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
XPathSequence fnLocalNameFromQName(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value is! XmlName) return XPathSequence.empty;
  return XPathSequence.single(XPathString(value.local));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
XPathSequence fnNamespaceUriFromQName(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value is! XmlName) return XPathSequence.empty;
  return value.namespaceUri == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(value.namespaceUri!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName-equal
XPathSequence opQNameEqual(
  XPathContext context,
  XPathSequence value1,
  XPathSequence value2,
) {
  throw UnimplementedError('op:QName-equal');
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
