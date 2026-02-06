import 'dart:typed_data';

import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath string type.
const xsString = XPathTypeDefinition(
  'xs:string',
  matches: _matches,
  cast: _cast,
);

bool _matches(Object item) => item is String;

XPathSequence _cast(Object item) => item.toXPathString().toXPathSequence();

extension XPathStringExtension on Object {
  String toXPathString() {
    final self = this;
    if (self is String) {
      return self;
    } else if (self is bool) {
      return self ? 'true' : 'false';
    } else if (self is num) {
      if (self.isNaN) return 'NaN';
      if (self == double.infinity) return 'INF';
      if (self == double.negativeInfinity) return '-INF';
      if (self == 0.0 || self == -0.0) return '0';
      final string = self.toString();
      return string.endsWith('.0')
          ? string.substring(0, string.length - 2)
          : string;
    } else if (self is Uint8List) {
      // This covers both base64 and hex binary cases if we use Uint8List
      // For now, let's assume it's hex as a default or handle individually if we have types
      return self
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
    } else if (self is XmlNode) {
      final buffer = StringBuffer();
      _stringForNodeOn(self, buffer);
      return buffer.toString();
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return '';
      final item = iterator.current;
      if (!iterator.moveNext()) return item.toXPathString();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'string');
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
