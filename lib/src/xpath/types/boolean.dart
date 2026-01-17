import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathBoolean(bool _) implements bool {}

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
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return const XPathBoolean(false);
      final item = iterator.current;
      if (item is XmlNode) return const XPathBoolean(true);
      if (!iterator.moveNext()) return item.toXPathBoolean();
    }
    XPathEvaluationException.unsupportedCast(self, 'boolean');
  }
}
