import 'package:meta/meta.dart';
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
  name: 'fn:resolve-QName',
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
  final parts = qname.split(':');
  var prefix = '';
  var local = parts[0];
  if (parts.length == 2) {
    prefix = parts[0];
    local = parts[1];
  } else if (parts.length > 2) {
    throw XPathEvaluationException('Invalid QName syntax: $qname');
  }
  final uri = _lookupNamespaceUri(element, prefix);
  if (uri == null) {
    throw XPathEvaluationException('Prefix "$prefix" not found');
  }
  return XPathSequence.single(_XPathQName(local, prefix, uri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionDefinition(
  name: 'fn:QName',
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
) {
  final uri = paramURI ?? '';
  final parts = paramQName.split(':');
  var prefix = '';
  var local = parts[0];
  if (parts.length == 2) {
    prefix = parts[0];
    local = parts[1];
  } else if (parts.length > 2) {
    throw XPathEvaluationException('Invalid QName syntax: $paramQName');
  }
  return XPathSequence.single(_XPathQName(local, prefix, uri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
const fnPrefixFromQName = XPathFunctionDefinition(
  name: 'fn:prefix-from-QName',
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
  name: 'fn:local-name-from-QName',
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
  name: 'fn:namespace-uri-from-QName',
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
  if (arg == null) return XPathSequence.empty;
  final uri = arg.namespaceUri;
  if (uri == null) return XPathSequence.empty;
  return XPathSequence.single(uri);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
const fnNamespaceUriForPrefix = XPathFunctionDefinition(
  name: 'fn:namespace-uri-for-prefix',
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
  final uri = _lookupNamespaceUri(element, prefix ?? '');
  if (uri == null || uri.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(uri);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
const fnInScopePrefixes = XPathFunctionDefinition(
  name: 'fn:in-scope-prefixes',
  requiredArguments: [
    XPathArgumentDefinition(name: 'element', type: xsElement),
  ],
  function: _fnInScopePrefixes,
);

XPathSequence _fnInScopePrefixes(XPathContext context, XmlElement element) {
  final prefixes = <String>{};
  var current = element;
  while (true) {
    for (final attribute in current.attributes) {
      if (attribute.name.prefix == 'xmlns') {
        prefixes.add(attribute.name.local);
      } else if (attribute.name.prefix == null &&
          attribute.name.local == 'xmlns') {
        if (attribute.value.isNotEmpty) {
          prefixes.add('');
        }
      }
    }
    if (current.parent is! XmlElement) break;
    current = current.parent as XmlElement;
  }
  prefixes.add('xml');
  return XPathSequence(prefixes.map((p) => p));
}

String? _lookupNamespaceUri(XmlElement element, String prefix) {
  if (prefix == 'xml') return 'http://www.w3.org/XML/1998/namespace';
  var current = element;
  while (true) {
    for (final attribute in current.attributes) {
      if (attribute.name.prefix == 'xmlns' && attribute.name.local == prefix) {
        return attribute.value;
      }
      if (attribute.name.prefix == null &&
          attribute.name.local == 'xmlns' &&
          prefix.isEmpty) {
        return attribute.value;
      }
    }
    if (current.parent is! XmlElement) break;
    current = current.parent as XmlElement;
  }
  return null;
}

class _XPathQName extends XmlName {
  _XPathQName(this.local, this.prefix, this.namespaceUri) : super.internal();

  @override
  final String local;

  @override
  final String? prefix;

  @override
  final String? namespaceUri;

  @override
  String get qualified =>
      prefix == null || prefix!.isEmpty ? local : '$prefix:$local';

  @override
  XmlName copy() => _XPathQName(local, prefix, namespaceUri);
}
