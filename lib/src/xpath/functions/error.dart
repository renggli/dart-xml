import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
/// https://www.w3.org/TR/xpath-functions-31/#func-error
/// https://www.w3.org/TR/xpath-functions-31/#func-error
const fnError = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'error',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'code',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'description', type: XPathString),
    XPathArgumentDefinition(
      name: 'error-object',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnError,
);

XPathSequence _fnError(
  XPathContext context, [
  XPathSequence? code,
  XPathString? description,
  XPathSequence? errorObject,
]) {
  final buffer = StringBuffer();
  if (code != null) {
    buffer.write(code.toXPathString());
  }
  if (description != null) {
    if (buffer.isNotEmpty) buffer.write(': ');
    buffer.write(description);
  }
  if (errorObject != null && errorObject.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(errorObject);
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
const fnTrace = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'trace',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'label', type: XPathString),
  ],
  function: _fnTrace,
);

XPathSequence _fnTrace(
  XPathContext context,
  XPathSequence value, [
  XPathString? label,
]) {
  context.onTraceCallback?.call(value, label);
  return value;
}
