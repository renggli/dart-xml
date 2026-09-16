import '../../xml/nodes/element.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/qname.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
const fnResolveQName = XPathFunctionItem.fn2(
  XmlName.qualified('fn:resolve-QName'),
  _fnResolveQName,
);

XPathSequence _fnResolveQName(
  XPathContext context,
  XPathSequence qnameSeq,
  XPathSequence elementSeq,
) {
  final qnameItem = qnameSeq.firstOrNull;
  if (qnameItem == null) return XPathSequence.empty;
  final elementNode = elementSeq.first as XPathNode;
  final element = elementNode.node;
  if (element is! XmlElement) {
    throw XPathEvaluationException('Expected element, found: $element');
  }
  final qnameStr = qnameItem is XPathString
      ? qnameItem.value
      : qnameItem.stringValue;
  final name = XmlName.parse(qnameStr);
  if (name.namespaceUri == null) {
    final prefix = name.prefix ?? '';
    final uri = element.namespaces
        .where((ns) => ns.prefix == prefix)
        .firstOrNull
        ?.uri;
    if (uri != null) {
      return XPathSequence.single(XPathQName(name.withNamespaceUri(uri)));
    }
  }
  throw XPathEvaluationException('Invalid qualified name: $qnameStr');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionItem.fn2(XmlName.qualified('fn:QName'), _fnQName);

XPathSequence _fnQName(
  XPathContext context,
  XPathSequence paramURISeq,
  XPathSequence paramQNameSeq,
) {
  final paramURIItem = paramURISeq.firstOrNull;
  final paramURI = paramURIItem != null
      ? (paramURIItem is XPathString
            ? paramURIItem.value
            : paramURIItem.stringValue)
      : null;
  final paramQNameItem = paramQNameSeq.first;
  final paramQName = paramQNameItem is XPathString
      ? paramQNameItem.value
      : paramQNameItem.stringValue;
  return XPathSequence.single(
    XPathQName(XmlName.parse(paramQName, namespaceUri: paramURI)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
const fnPrefixFromQName = XPathFunctionItem.fn1(
  XmlName.qualified('fn:prefix-from-QName'),
  _fnPrefixFromQName,
);

XPathSequence _fnPrefixFromQName(XPathContext context, XPathSequence argSeq) {
  final arg = argSeq.firstOrNull as XPathQName?;
  if (arg == null) return XPathSequence.empty;
  final prefix = arg.value.prefix;
  if (prefix == null || prefix.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(XPathString(prefix));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
const fnLocalNameFromQName = XPathFunctionItem.fn1(
  XmlName.qualified('fn:local-name-from-QName'),
  _fnLocalNameFromQName,
);

XPathSequence _fnLocalNameFromQName(
  XPathContext context,
  XPathSequence argSeq,
) {
  final arg = argSeq.firstOrNull as XPathQName?;
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(XPathString(arg.value.local));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
const fnNamespaceUriFromQName = XPathFunctionItem.fn1(
  XmlName.qualified('fn:namespace-uri-from-QName'),
  _fnNamespaceUriFromQName,
);

XPathSequence _fnNamespaceUriFromQName(
  XPathContext context,
  XPathSequence argSeq,
) {
  final arg = argSeq.firstOrNull as XPathQName?;
  final uri = arg?.value.namespaceUri;
  if (uri == null) return XPathSequence.empty;
  return XPathSequence.single(XPathString(uri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
const fnNamespaceUriForPrefix = XPathFunctionItem.fn2(
  XmlName.qualified('fn:namespace-uri-for-prefix'),
  _fnNamespaceUriForPrefix,
);

XPathSequence _fnNamespaceUriForPrefix(
  XPathContext context,
  XPathSequence prefixSeq,
  XPathSequence elementSeq,
) {
  final elementNode = elementSeq.first as XPathNode;
  final element = elementNode.node;
  if (element is! XmlElement) {
    throw XPathEvaluationException('Expected element, found: $element');
  }
  final prefixItem = prefixSeq.firstOrNull;
  final p = prefixItem != null
      ? (prefixItem is XPathString ? prefixItem.value : prefixItem.stringValue)
      : '';
  final uri = element.namespaces.where((ns) => ns.prefix == p).firstOrNull?.uri;
  if (uri == null || uri.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(XPathString(uri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
const fnInScopePrefixes = XPathFunctionItem.fn1(
  XmlName.qualified('fn:in-scope-prefixes'),
  _fnInScopePrefixes,
);

XPathSequence _fnInScopePrefixes(
  XPathContext context,
  XPathSequence elementSeq,
) {
  final elementNode = elementSeq.first as XPathNode;
  final element = elementNode.node;
  if (element is! XmlElement) {
    throw XPathEvaluationException('Expected element, found: $element');
  }
  return XPathSequence(element.namespaces.map((ns) => XPathString(ns.prefix)));
}
