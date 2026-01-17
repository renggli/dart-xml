import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName
XPathSequence fnResolveQName(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:resolve-QName', arguments, 2);
  final qname = XPathEvaluationException.extractZeroOrOne(
    'fn:resolve-QName',
    'qname',
    arguments[0],
  )?.toXPathString();
  final element = arguments[1];
  if (qname == null || element.isEmpty) return XPathSequence.empty;
  // TODO: Implement proper QName resolution using element's in-scope namespaces.
  return XPathSequence.single(XmlName.fromString(qname));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
XPathSequence fnQName(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:QName', arguments, 2);
  // final paramUri = XPathEvaluationException.extractZeroOrOne(
  //   'fn:QName',
  //   'paramUri',
  //   arguments[0],
  // )?.toXPathString();
  final paramQName = XPathEvaluationException.extractExactlyOne(
    'fn:QName',
    'paramQName',
    arguments[1],
  ).toXPathString();
  // TODO: XmlName in PetitXml currently does not store the namespace URI explicitly
  // when detached, so uriOpt is ignored here. This is a limitation.
  return XPathSequence.single(XmlName.fromString(paramQName));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-prefix-from-QName
XPathSequence fnPrefixFromQName(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:prefix-from-QName',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:prefix-from-QName',
    'arg',
    arguments[0],
  );
  if (arg is! XmlName) return XPathSequence.empty;
  return arg.prefix == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(arg.prefix!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name-from-QName
XPathSequence fnLocalNameFromQName(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:local-name-from-QName',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:local-name-from-QName',
    'arg',
    arguments[0],
  );
  if (arg is! XmlName) return XPathSequence.empty;
  return XPathSequence.single(XPathString(arg.local));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-from-QName
XPathSequence fnNamespaceUriFromQName(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:namespace-uri-from-QName',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:namespace-uri-from-QName',
    'arg',
    arguments[0],
  );
  if (arg is! XmlName) return XPathSequence.empty;
  return arg.namespaceUri == null
      ? XPathSequence.empty
      : XPathSequence.single(XPathString(arg.namespaceUri!));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-QName-equal
XPathSequence opQNameEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('op:QName-equal', arguments, 2);
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:QName-equal',
    'arg1',
    arguments[0],
  );
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:QName-equal',
    'arg2',
    arguments[1],
  );
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  if (arg1 is XmlName && arg2 is XmlName) {
    return XPathSequence.single(arg1 == arg2);
  }
  // If arguments are not QNames, strictly speaking it should be an error or specialized handling,
  // but for now assume they are compatible if we reached here.
  return XPathSequence.single(arg1 == arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri-for-prefix
XPathSequence fnNamespaceUriForPrefix(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:namespace-uri-for-prefix');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-in-scope-prefixes
XPathSequence fnInScopePrefixes(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:in-scope-prefixes');
}
