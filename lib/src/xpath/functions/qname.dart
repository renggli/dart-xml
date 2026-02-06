import '../../../xml.dart';

import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
const fnResolveQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'resolve-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'qname',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'element', type: xsNode),
  ],
  function: _fnResolveQName,
);

XPathSequence _fnResolveQName(
  XPathContext context,
  String? qname,
  XmlNode element,
) {
  if (qname == null) return XPathSequence.empty;
  if (element is! XmlElement) {
    throw XPathEvaluationException('Argument "element" must be an element');
  }
  // TODO: Proper QName resolution
  return XPathSequence.single(qname);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'paramURI',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'paramQName', type: xsString),
  ],
  function: _fnQName,
);

XPathSequence _fnQName(
  XPathContext context,
  String? paramURI,
  String paramQName,
) {
  final uri = paramURI ?? '';
  if (uri.isEmpty) return XPathSequence.single(paramQName);
  return XPathSequence.single('{$uri}$paramQName');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
const fnPrefixFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'prefix-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString, // xs:QName
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnPrefixFromQName,
);

XPathSequence _fnPrefixFromQName(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  final index = arg.indexOf(':');
  if (index == -1) return XPathSequence.empty;
  return XPathSequence.single(arg.substring(0, index));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
const fnLocalNameFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'local-name-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString, // xs:QName
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnLocalNameFromQName,
);

XPathSequence _fnLocalNameFromQName(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  final index = arg.indexOf(':');
  if (index == -1) return XPathSequence.single(arg);
  return XPathSequence.single(arg.substring(index + 1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
const fnNamespaceUriFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsString, // xs:QName
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnNamespaceUriFromQName,
);

XPathSequence _fnNamespaceUriFromQName(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  // TODO: Proper QName handling to extract URI
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
const fnNamespaceUriForPrefix = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri-for-prefix',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'prefix',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'element', type: xsNode),
  ],
  function: _fnNamespaceUriForPrefix,
);

XPathSequence _fnNamespaceUriForPrefix(
  XPathContext context,
  String? prefix,
  XmlNode element,
) {
  if (element is! XmlElement) {
    throw XPathEvaluationException('Argument "element" must be an element');
  }
  // TODO: Proper prefix to URI resolution
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
const fnInScopePrefixes = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'in-scope-prefixes',
  requiredArguments: [XPathArgumentDefinition(name: 'element', type: xsNode)],
  function: _fnInScopePrefixes,
);

XPathSequence _fnInScopePrefixes(XPathContext context, XmlNode element) {
  if (element is! XmlElement) {
    throw XPathEvaluationException('Argument "element" must be an element');
  }
  // TODO: Proper in-scope prefixes resolution
  return XPathSequence.empty;
}
