import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

const xsBase64Binary = XPathBase64BinaryType();
const xsHexBinary = XPathHexBinaryType();

class XPathBase64Binary extends DelegatingList<int> {
  XPathBase64Binary(Uint8List super.base);
}

class XPathBase64BinaryType extends XPathItemType {
  const XPathBase64BinaryType();

  @override
  bool matches(Object item) => item is XPathBase64Binary;

  @override
  XPathSequence cast(Object item) =>
      item.toXPathBase64Binary().toXPathSequence();
}

class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}

class XPathHexBinaryType extends XPathItemType {
  const XPathHexBinaryType();

  @override
  bool matches(Object item) => item is XPathHexBinary;

  @override
  XPathSequence cast(Object item) => item.toXPathHexBinary().toXPathSequence();
}

extension XPathBinaryExtension on Object {
  XPathBase64Binary toXPathBase64Binary() {
    final self = this;
    if (self is XPathBase64Binary) {
      return self;
    } else if (self is List<int>) {
      return XPathBase64Binary(Uint8List.fromList(self));
    } else if (self is XPathString) {
      return XPathBase64Binary(base64Decode(self));
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathBase64Binary();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'base64Binary');
  }

  XPathHexBinary toXPathHexBinary() {
    final self = this;
    if (self is XPathHexBinary) {
      return self;
    } else if (self is List<int>) {
      return XPathHexBinary(Uint8List.fromList(self));
    } else if (self is XPathString) {
      final bytes = Uint8List(self.length ~/ 2);
      for (var i = 0; i < self.length; i += 2) {
        bytes[i ~/ 2] = int.parse(self.substring(i, i + 2), radix: 16);
      }
      return XPathHexBinary(bytes);
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathHexBinary();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'hexBinary');
  }
}
