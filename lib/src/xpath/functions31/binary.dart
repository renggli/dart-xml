import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(
  XPathContext context,
  XPathSequence value1,
  XPathSequence value2,
) {
  final value1Val = XPathEvaluationException.checkExactlyOne(
    value1,
  ).toXPathString();
  final value2Val = XPathEvaluationException.checkExactlyOne(
    value2,
  ).toXPathString();
  // Assuming canonical string representation (uppercase)
  return XPathSequence.single(value1Val == value2Val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Val = XPathEvaluationException.checkExactlyOne(
    arg1,
  ).toXPathString();
  final arg2Val = XPathEvaluationException.checkExactlyOne(
    arg2,
  ).toXPathString();
  return XPathSequence.single(arg1Val.compareTo(arg2Val) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Val = XPathEvaluationException.checkExactlyOne(
    arg1,
  ).toXPathString();
  final arg2Val = XPathEvaluationException.checkExactlyOne(
    arg2,
  ).toXPathString();
  return XPathSequence.single(arg1Val.compareTo(arg2Val) > 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Val = XPathEvaluationException.checkExactlyOne(
    arg1,
  ).toXPathString();
  final arg2Val = XPathEvaluationException.checkExactlyOne(
    arg2,
  ).toXPathString();
  return XPathSequence.single(arg1Val == arg2Val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Val = XPathEvaluationException.checkExactlyOne(
    arg1,
  ).toXPathString();
  final arg2Val = XPathEvaluationException.checkExactlyOne(
    arg2,
  ).toXPathString();
  return XPathSequence.single(arg1Val.compareTo(arg2Val) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Val = XPathEvaluationException.checkExactlyOne(
    arg1,
  ).toXPathString();
  final arg2Val = XPathEvaluationException.checkExactlyOne(
    arg2,
  ).toXPathString();
  return XPathSequence.single(arg1Val.compareTo(arg2Val) > 0);
}
