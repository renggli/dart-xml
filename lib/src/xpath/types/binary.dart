import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath base64Binary type.
const xsBase64Binary = XPathTypeDefinition(
  'xs:base64Binary',
  matches: _matchesBase64,
  cast: _castBase64,
);

/// The XPath hexBinary type.
const xsHexBinary = XPathTypeDefinition(
  'xs:hexBinary',
  matches: _matchesHex,
  cast: _castHex,
);

class XPathBase64Binary extends DelegatingList<int> {
  XPathBase64Binary(Uint8List super.base);
}

class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}

bool _matchesBase64(Object item) => item is XPathBase64Binary;

XPathSequence _castBase64(Object item) =>
    item.toXPathBase64Binary().toXPathSequence();

bool _matchesHex(Object item) => item is XPathHexBinary;

XPathSequence _castHex(Object item) =>
    item.toXPathHexBinary().toXPathSequence();

extension XPathBinaryExtension on Object {
  XPathBase64Binary toXPathBase64Binary() {
    final self = this;
    if (self is XPathBase64Binary) {
      return self;
    } else if (self is List<int>) {
      return XPathBase64Binary(Uint8List.fromList(self));
    } else if (self is String) {
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
    } else if (self is String) {
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
