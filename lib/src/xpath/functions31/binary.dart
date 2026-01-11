import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:hexBinary-equal',
    arguments,
    2,
  );
  final value1 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-equal',
    'value1',
    arguments[0],
  ).toXPathString();
  final value2 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-equal',
    'value2',
    arguments[1],
  ).toXPathString();
  // Assuming canonical string representation (uppercase)
  return XPathSequence.single(value1 == value2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:hexBinary-less-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-less-than',
    'arg1',
    arguments[0],
  ).toXPathString();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-less-than',
    'arg2',
    arguments[1],
  ).toXPathString();
  return XPathSequence.single(arg1.compareTo(arg2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:hexBinary-greater-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-greater-than',
    'arg1',
    arguments[0],
  ).toXPathString();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:hexBinary-greater-than',
    'arg2',
    arguments[1],
  ).toXPathString();
  return XPathSequence.single(arg1.compareTo(arg2) > 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:base64Binary-equal',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-equal',
    'arg1',
    arguments[0],
  ).toXPathString();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-equal',
    'arg2',
    arguments[1],
  ).toXPathString();
  return XPathSequence.single(arg1 == arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:base64Binary-less-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-less-than',
    'arg1',
    arguments[0],
  ).toXPathString();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-less-than',
    'arg2',
    arguments[1],
  ).toXPathString();
  return XPathSequence.single(arg1.compareTo(arg2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:base64Binary-greater-than',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-greater-than',
    'arg1',
    arguments[0],
  ).toXPathString();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:base64Binary-greater-than',
    'arg2',
    arguments[1],
  ).toXPathString();
  return XPathSequence.single(arg1.compareTo(arg2) > 0);
}
