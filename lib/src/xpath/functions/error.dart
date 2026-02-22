import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
const fnError = XPathFunctionDefinition(
  name: XmlName.qualified('fn:error'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'code',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'description', type: xsString),
    XPathArgumentDefinition(
      name: 'error-object',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  final buffer = StringBuffer();
  if (code != null) buffer.write(code);
  if (description != null) {
    if (buffer.isNotEmpty) buffer.write(': ');
    buffer.write(description);
  }
  if (errorObject != null) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(errorObject);
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
const fnTrace = XPathFunctionDefinition(
  name: XmlName.qualified('fn:trace'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  final trace = context.onTraceCallback;
  if (trace != null) trace(value, label);
  return value;
}
