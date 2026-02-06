import 'dart:typed_data';

import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../definitions/types.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath string type.
const xsString = _XPathStringType();

class _XPathStringType extends XPathType<String> {
  const _XPathStringType();

  @override
  String get name => 'xs:string';

  @override
  bool matches(Object value) => value is String;

  @override
  String cast(Object value) {
    if (value is String) {
      return value;
    } else if (value is bool) {
      return value ? 'true' : 'false';
    } else if (value is num) {
      if (value.isNaN) return 'NaN';
      if (value == double.infinity) return 'INF';
      if (value == double.negativeInfinity) return '-INF';
      if (value == 0.0 || value == -0.0) return '0';
      final string = value.toString();
      return string.endsWith('.0')
          ? string.substring(0, string.length - 2)
          : string;
    } else if (value is Uint8List) {
      return value
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
    } else if (value is XmlNode) {
      final buffer = StringBuffer();
      _stringForNodeOn(value, buffer);
      return buffer.toString();
    } else if (value is XPathSequence) {
      final iterator = value.iterator;
      if (!iterator.moveNext()) return '';
      final item = iterator.current;
      if (!iterator.moveNext()) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
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
