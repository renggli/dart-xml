import 'dart:convert';
import 'dart:typed_data';

import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-from-string
const fnBase64BinaryFromString = XPathFunctionDefinition(
  name: 'xs:base64Binary',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnBase64BinaryFromString,
);

XPathSequence _fnBase64BinaryFromString(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  try {
    return XPathSequence.single(base64.decode(arg));
  } catch (e) {
    throw XPathEvaluationException('Invalid base64 string: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-from-string
const fnHexBinaryFromString = XPathFunctionDefinition(
  name: 'xs:hexBinary',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHexBinaryFromString,
);

XPathSequence _fnHexBinaryFromString(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  try {
    final bytes = Uint8List(arg.length ~/ 2);
    for (var i = 0; i < arg.length; i += 2) {
      bytes[i ~/ 2] = int.parse(arg.substring(i, i + 2), radix: 16);
    }
    return XPathSequence.single(bytes);
  } catch (e) {
    throw XPathEvaluationException('Invalid hex string: $e');
  }
}
