import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../exceptions/evaluation_exception.dart';

extension type const XPathString(String _value) implements String {
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
    } else if (self is XmlNode) {
      final buffer = StringBuffer();
      _stringForNodeOn(self, buffer);
      return XPathString(buffer.toString());
    } else if (self is Iterable) {
      if (self.isEmpty) return XPathString.empty;
      final list = self.toList();
      if (list.length > 1) {
        throw XPathEvaluationException(
          'A sequence of more than one item cannot be cast to a string',
        );
      }
      return (list.first as Object).toXPathString();
    }
    throw XPathEvaluationException(
      'Unsupported type for string casting: ${self.runtimeType}',
    );
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
