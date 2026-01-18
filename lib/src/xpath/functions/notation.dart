import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION-equal
const opNotationEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'NOTATION-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opNotationEqual,
);

XPathSequence _opNotationEqual(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1 == arg2);
}
