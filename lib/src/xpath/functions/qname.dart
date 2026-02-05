import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
const fnResolveQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'resolve-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'qname',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'element', type: XPathSequence),
  ],
  function: _fnResolveQName,
);

XPathSequence _fnResolveQName(
  XPathContext context,
  XPathString? qname,
  XPathSequence element,
) {
  if (qname == null || element.isEmpty) return XPathSequence.empty;
  // TODO: Implement proper QName resolution using element's in-scope namespaces.
  return XPathSequence.single(XmlName.fromString(qname));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'paramUri',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'paramQName', type: XPathString),
  ],
  function: _fnQName,
);

// TODO: XmlName in PetitXml currently does not store the namespace URI explicitly
// when detached, so uriOpt is ignored here. This is a limitation.
XPathSequence _fnQName(
  XPathContext context,
  XPathString? paramUri,
  XPathString paramQName,
) => XPathSequence.single(XmlName.fromString(paramQName));

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
const fnPrefixFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'prefix-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnPrefixFromQName,
);

XPathSequence _fnPrefixFromQName(XPathContext context, XPathSequence? arg) {
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  // Assuming arg is an XmlName (passed as sequence single item usually, but wait)
  // Arguments to these are xs:QName.
  // In our mapping, QName is handled via XmlName? Or String?
  // Previous implementation: `if (arg is! XmlName) return empty`.
  // `arg` was extracted as `extractZeroOrOne` -> returns `Object?`.
  // If it's a `QName`, it's represented as `XmlName` in PetitXml?
  // `qname.dart`: "If arguments are not QNames... assume they are compatible".
  // `XPathSequence` might contain `XmlName` directly?
  // Yes `XmlName` is NOT an `XPathNode`. But maybe `XPathValue`?
  // `const Map<String, Object> standardFunctions` doesn't define types.
  // `XPathSequence` items can be `XmlName`?
  // If I check `lib/src/xpath/types/sequence.dart`...
  // Usually QName values are strings or XmlNames.
  final item = arg.first;
  if (item is XmlName) {
    return item.prefix == null
        ? XPathSequence.empty
        : XPathSequence.single(item.prefix!);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
const fnLocalNameFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'local-name-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnLocalNameFromQName,
);

XPathSequence _fnLocalNameFromQName(XPathContext context, XPathSequence? arg) {
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  final item = arg.first;
  if (item is XmlName) {
    return XPathSequence.single(item.local);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
const fnNamespaceUriFromQName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri-from-QName',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNamespaceUriFromQName,
);

XPathSequence _fnNamespaceUriFromQName(
  XPathContext context,
  XPathSequence? arg,
) {
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  final item = arg.first;
  if (item is XmlName) {
    return item.namespaceUri == null
        ? XPathSequence.empty
        : XPathSequence.single(item.namespaceUri!);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
const fnNamespaceUriForPrefix = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'namespace-uri-for-prefix',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'prefix',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'element', type: XPathSequence),
  ],
  function: _fnNamespaceUriForPrefix,
);

XPathSequence _fnNamespaceUriForPrefix(
  XPathContext context,
  XPathString? prefix,
  XPathSequence element,
) => throw UnimplementedError('fn:namespace-uri-for-prefix');

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
const fnInScopePrefixes = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'in-scope-prefixes',
  requiredArguments: [
    XPathArgumentDefinition(name: 'element', type: XPathSequence),
  ],
  function: _fnInScopePrefixes,
);

XPathSequence _fnInScopePrefixes(XPathContext context, XPathSequence element) =>
    throw UnimplementedError('fn:in-scope-prefixes');
