import '../../xml/nodes/element.dart';
import '../../xml/utils/name.dart';
import '../evaluation/cardinality.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/qname.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

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
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected element, found: $element',
    );
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
  throw XPathEvaluationException(
    XPathErrorCode.FONS0004,
    'No namespace found for prefix: $qnameStr',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const fnQName = XPathFunctionItem.fn2(
  XmlName.qualified('fn:QName'),
  _fnQName,
  parameterTypes: [
    XPathSequenceType(
      itemType: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathSequenceType(
      itemType: xsString,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  returnType: XPathSequenceType(
    itemType: xsQName,
    cardinality: XPathCardinality.exactlyOne,
  ),
);

XPathSequence _fnQName(
  XPathContext context,
  XPathSequence paramURISeq,
  XPathSequence paramQNameSeq,
) {
  if (paramURISeq.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Argument 1 to fn:QName accepts at most one item',
    );
  }
  final paramURIItem = paramURISeq.firstOrNull;
  if (paramURIItem != null &&
      paramURIItem is! XPathString &&
      paramURIItem is! XPathUntypedAtomic) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected xs:string? for argument 1 of fn:QName, but got ${paramURIItem.type.name}',
    );
  }
  final paramURI = paramURIItem?.stringValue;

  if (paramQNameSeq.length != 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Argument 2 to fn:QName must be exactly one item',
    );
  }
  final paramQNameItem = paramQNameSeq.single;
  if (paramQNameItem is! XPathString && paramQNameItem is! XPathUntypedAtomic) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected xs:string for argument 2 of fn:QName, but got ${paramQNameItem.type.name}',
    );
  }
  final paramQName = paramQNameItem.stringValue;

  final colonIndex = paramQName.indexOf(':');
  final String? prefix;
  final String local;

  if (colonIndex != -1) {
    if (paramQName.indexOf(':', colonIndex + 1) != -1) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Invalid lexical QName: "$paramQName"',
      );
    }
    prefix = paramQName.substring(0, colonIndex);
    local = paramQName.substring(colonIndex + 1);
    if (!isValidNCName(prefix) || !isValidNCName(local)) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Invalid lexical QName: "$paramQName"',
      );
    }
    if (paramURI == null || paramURI.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Prefix "$prefix" requires non-empty namespace URI',
      );
    }
    if (prefix == 'xmlns') {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Prefix "xmlns" is not allowed in QName',
      );
    }
    if (prefix == 'xml' && paramURI != 'http://www.w3.org/XML/1998/namespace') {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Prefix "xml" must be bound to http://www.w3.org/XML/1998/namespace',
      );
    }
    if (paramURI == 'http://www.w3.org/XML/1998/namespace' && prefix != 'xml') {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Namespace http://www.w3.org/XML/1998/namespace must have prefix "xml"',
      );
    }
  } else {
    prefix = null;
    local = paramQName;
    if (!isValidNCName(local)) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Invalid lexical QName: "$paramQName"',
      );
    }
    if (paramURI == 'http://www.w3.org/XML/1998/namespace') {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Namespace http://www.w3.org/XML/1998/namespace must have prefix "xml"',
      );
    }
  }

  if (paramURI == 'http://www.w3.org/2000/xmlns/') {
    throw XPathEvaluationException(
      XPathErrorCode.FOCA0002,
      'Namespace http://www.w3.org/2000/xmlns/ is reserved and not allowed in QName',
    );
  }

  final effectiveUri = paramURI;
  final xmlName = prefix != null
      ? XmlName.qualified('$prefix:$local', namespaceUri: effectiveUri)
      : XmlName.parts(local, namespaceUri: effectiveUri);

  return XPathSequence.single(XPathQName(xmlName));
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
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected element, found: $element',
    );
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
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected element, found: $element',
    );
  }
  return XPathSequence(element.namespaces.map((ns) => XPathString(ns.prefix)));
}
