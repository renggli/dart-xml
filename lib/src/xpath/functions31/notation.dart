import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';

import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION-equal
XPathSequence opNotationEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString();
  final val2 = XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 == val2);
}
