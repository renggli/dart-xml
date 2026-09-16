import 'dart:convert';
import 'dart:typed_data';

import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../xdm/atomic/binary.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-from-string
const fnBase64BinaryFromString = XPathFunctionItem.fn1(
  XmlName.qualified('xs:base64Binary'),
  _fnBase64BinaryFromString,
);

XPathSequence _fnBase64BinaryFromString(
  XPathContext context,
  XPathSequence argSeq,
) {
  final arg = argSeq.atomize().firstOrNull;
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathBase64Binary(base64.decode(arg.stringValue)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-from-string
const fnHexBinaryFromString = XPathFunctionItem.fn1(
  XmlName.qualified('xs:hexBinary'),
  _fnHexBinaryFromString,
);

XPathSequence _fnHexBinaryFromString(
  XPathContext context,
  XPathSequence argSeq,
) {
  final arg = argSeq.atomize().firstOrNull;
  if (arg == null) return XPathSequence.empty;
  final str = arg.stringValue;
  final bytes = Uint8List(str.length ~/ 2);
  for (var i = 0; i < str.length; i += 2) {
    bytes[i ~/ 2] = int.parse(str.substring(i, i + 2), radix: 16);
  }
  return XPathSequence.single(XPathHexBinary(bytes));
}
