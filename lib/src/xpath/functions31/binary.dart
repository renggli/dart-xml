import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/binary.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareHexBinary('op:hexBinary-equal', arguments) == 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareHexBinary('op:hexBinary-less-than', arguments) < 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareHexBinary('op:hexBinary-greater-than', arguments) > 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareBase64Binary('op:base64Binary-equal', arguments) == 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareBase64Binary('op:base64Binary-less-than', arguments) < 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareBase64Binary('op:base64Binary-greater-than', arguments) > 0,
);
int _compareBinary(List<int> a, List<int> b) {
  final len = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final diff = a[i].compareTo(b[i]);
    if (diff != 0) return diff;
  }
  return a.length.compareTo(b.length);
}

int _compareHexBinary(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractExactlyOne(
    name,
    'value1',
    arguments[0],
  ).toXPathHexBinary();
  final value2 = XPathEvaluationException.extractExactlyOne(
    name,
    'value2',
    arguments[1],
  ).toXPathHexBinary();
  return _compareBinary(value1, value2);
}

int _compareBase64Binary(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractExactlyOne(
    name,
    'value1',
    arguments[0],
  ).toXPathBase64Binary();
  final value2 = XPathEvaluationException.extractExactlyOne(
    name,
    'value2',
    arguments[1],
  ).toXPathBase64Binary();
  return _compareBinary(value1, value2);
}
