import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
const fnError = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'error',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'code',
      type: XPathSequenceType(
        xsString, // xs:QName technically
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'description', type: xsString),
    XPathArgumentDefinition(
      name: 'error-object',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnError,
);

XPathSequence _fnError(
  XPathContext context, [
  String? code,
  String? description,
  XPathSequence? errorObject,
]) {
  throw XPathEvaluationException(
    description ?? 'XPath error',
    code: code,
    object: errorObject,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
const fnTrace = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'trace',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'label', type: xsString)],
  function: _fnTrace,
);

XPathSequence _fnTrace(
  XPathContext context,
  XPathSequence value, [
  String? label,
]) {
  // ignore: avoid_print
  print('${label ?? "trace"}: $value');
  return value;
}
