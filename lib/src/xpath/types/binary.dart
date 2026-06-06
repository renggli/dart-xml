import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath base64Binary type.
const xsBase64Binary = _XPathBase64BinaryType();

class _XPathBase64BinaryType extends XPathType<XPathBase64Binary> {
  const _XPathBase64BinaryType();

  @override
  String get name => 'xs:base64Binary';

  @override
  bool matches(Object value) => value is XPathBase64Binary;

  @override
  XPathBase64Binary cast(Object value) => switch (value) {
    XPathBase64Binary() => value,
    List<int>() => XPathBase64Binary(Uint8List.fromList(value)),
    String() => XPathBase64Binary(base64Decode(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  @override
  String castToString(XPathBase64Binary value) => base64Encode(value);
}

class XPathBase64Binary extends DelegatingList<int> {
  XPathBase64Binary(Uint8List super.base);
}

/// The XPath hexBinary type.
const xsHexBinary = _XPathHexBinaryType();

class _XPathHexBinaryType extends XPathType<XPathHexBinary> {
  const _XPathHexBinaryType();

  @override
  String get name => 'xs:hexBinary';

  @override
  bool matches(Object value) => value is XPathHexBinary;

  @override
  XPathHexBinary cast(Object value) => switch (value) {
    XPathHexBinary() => value,
    List<int>() => XPathHexBinary(Uint8List.fromList(value)),
    String() => _parseHexBinary(value),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathHexBinary _parseHexBinary(String value) {
    if (value.length % 2 != 0) {
      throw XPathEvaluationException(
        'Invalid hexBinary length: ${value.length}',
      );
    }
    final bytes = Uint8List(value.length ~/ 2);
    for (var i = 0; i < value.length; i += 2) {
      final digit1 = int.parse(value[i], radix: 16);
      final digit2 = int.parse(value[i + 1], radix: 16);
      bytes[i ~/ 2] = (digit1 << 4) + digit2;
    }
    return XPathHexBinary(bytes);
  }

  @override
  String castToString(XPathHexBinary value) => value
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}

class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}
