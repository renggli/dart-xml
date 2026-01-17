import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION-equal
XPathSequence opNotationEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:NOTATION-equal',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractZeroOrOne(
    'op:NOTATION-equal',
    'arg1',
    arguments[0],
  )?.toXPathString();
  final arg2 = XPathEvaluationException.extractZeroOrOne(
    'op:NOTATION-equal',
    'arg2',
    arguments[1],
  )?.toXPathString();
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1 == arg2);
}
