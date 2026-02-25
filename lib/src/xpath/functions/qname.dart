import '../../xml/nodes/element.dart';

import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/node.dart';
import '../types/qname.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
const fnResolveQName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:resolve-QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'qname',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'element', type: xsElement),
  ],
  function: _fnResolveQName,
);

XPathSequence _fnResolveQName(
  XPathContext context,
  String? qname,
  XmlElement element,
) {
  if (qname == null) return XPathSequence.empty;
  final name = XmlName.parse(qname);
  if (name.namespaceUri == null) {
    final prefix = name.prefix ?? '';
    final uri = element.namespaces
        .where((ns) => ns.prefix == prefix)
        .firstOrNull
        ?.uri;
    if (uri != null) {
      return XPathSequence.single(name.withNamespaceUri(uri));
    }
  }
  throw XPathEvaluationException('Invalid qualified name: $qname');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'paramURI',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'paramQName', type: xsString),
  ],
  function: _fnQName,
);

XPathSequence _fnQName(
  XPathContext context,
  String? paramURI,
  String paramQName,
) => XPathSequence.single(XmlName.parse(paramQName, namespaceUri: paramURI));

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
const fnPrefixFromQName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:prefix-from-QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsQName,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnPrefixFromQName,
);

XPathSequence _fnPrefixFromQName(XPathContext context, XmlName? arg) {
  if (arg == null) return XPathSequence.empty;
  final prefix = arg.prefix;
  if (prefix == null || prefix.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(prefix);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
const fnLocalNameFromQName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:local-name-from-QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsQName,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnLocalNameFromQName,
);

XPathSequence _fnLocalNameFromQName(XPathContext context, XmlName? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.local);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
const fnNamespaceUriFromQName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:namespace-uri-from-QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsQName,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnNamespaceUriFromQName,
);

XPathSequence _fnNamespaceUriFromQName(XPathContext context, XmlName? arg) {
  final uri = arg?.namespaceUri;
  if (uri == null) return XPathSequence.empty;
  return XPathSequence.single(uri);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
const fnNamespaceUriForPrefix = XPathFunctionDefinition(
  name: XmlName.qualified('fn:namespace-uri-for-prefix'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'prefix',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'element', type: xsElement),
  ],
  function: _fnNamespaceUriForPrefix,
);

XPathSequence _fnNamespaceUriForPrefix(
  XPathContext context,
  String? prefix,
  XmlElement element,
) {
  final p = prefix ?? '';
  final uri = element.namespaces.where((ns) => ns.prefix == p).firstOrNull?.uri;
  if (uri == null || uri.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(uri);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
const fnInScopePrefixes = XPathFunctionDefinition(
  name: XmlName.qualified('fn:in-scope-prefixes'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'element', type: xsElement),
  ],
  function: _fnInScopePrefixes,
);

XPathSequence _fnInScopePrefixes(XPathContext context, XmlElement element) =>
    XPathSequence(element.namespaces.map((ns) => ns.prefix));
