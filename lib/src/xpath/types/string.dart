import 'dart:convert';

import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../exceptions/evaluation_exception.dart';
import 'binary.dart';
import 'sequence.dart';

extension type const XPathString(String _) implements String {
  static const empty = XPathString('');
}

extension XPathStringExtension on Object {
  XPathString toXPathString() {
    final self = this;
    if (self is String) {
      return XPathString(self);
    } else if (self is bool) {
      return XPathString(self ? 'true' : 'false');
    } else if (self is num) {
      if (self.isNaN) return const XPathString('NaN');
      if (self == double.infinity) return const XPathString('INF');
      if (self == double.negativeInfinity) return const XPathString('-INF');
      if (self == 0.0 || self == -0.0) return const XPathString('0');
      final string = self.toString();
      return XPathString(
        string.endsWith('.0') ? string.substring(0, string.length - 2) : string,
      );
    } else if (self is XPathHexBinary) {
      return XPathString(
        self
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase(),
      );
    } else if (self is XPathBase64Binary) {
      return XPathString(base64Encode(self));
    } else if (self is XmlNode) {
      final buffer = StringBuffer();
      _stringForNodeOn(self, buffer);
      return XPathString(buffer.toString());
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return XPathString.empty;
      final item = iterator.current;
      if (!iterator.moveNext()) return item.toXPathString();
    }
    XPathEvaluationException.unsupportedCast(self, 'string');
  }
}

void _stringForNodeOn(XmlNode node, StringBuffer buffer) {
  if (node is XmlDocument) {
    for (final child in node.children) {
      if (child is XmlElement) {
        _stringForNodeOn(child, buffer);
      }
    }
  } else if (node is XmlElement) {
    for (final child in node.children) {
      _stringForNodeOn(child, buffer);
    }
  } else if (node is XmlText) {
    buffer.write(node.value);
  } else {
    buffer.write(node.value ?? '');
  }
}
