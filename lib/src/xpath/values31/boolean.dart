import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';

extension type const XPathBoolean(bool _value) implements bool {}

extension XPathBooleanExtension on Object {
  XPathBoolean toXPathBoolean() {
    final self = this;
    if (self is bool) {
      return XPathBoolean(self);
    } else if (self is num) {
      return XPathBoolean(self != 0 && !self.isNaN);
    } else if (self is String) {
      return XPathBoolean(self.isNotEmpty);
    } else if (self is XmlNode) {
      return const XPathBoolean(true);
    } else if (self is Iterable) {
      if (self.isEmpty) return const XPathBoolean(false);
      final first = self.first;
      if (first is XmlNode) return const XPathBoolean(true);
      if (self.length > 1) {
        throw XPathEvaluationException(
          'A sequence of more than one item cannot be cast to a boolean',
        );
      }
      return (first as Object).toXPathBoolean();
    }
    throw XPathEvaluationException(
      'Unsupported type for boolean casting: ${self.runtimeType}',
    );
  }
}
