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
  XPathBase64Binary cast(Object value) {
    if (value is XPathBase64Binary) {
      return value;
    } else if (value is List<int>) {
      return XPathBase64Binary(Uint8List.fromList(value));
    } else if (value is String) {
      return XPathBase64Binary(base64Decode(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
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
  XPathHexBinary cast(Object value) {
    if (value is XPathHexBinary) {
      return value;
    } else if (value is List<int>) {
      return XPathHexBinary(Uint8List.fromList(value));
    } else if (value is String) {
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
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}
