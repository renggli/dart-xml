import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

extension type const XPathNumber(num _) implements num {}

extension XPathNumberExtension on Object {
  XPathNumber toXPathNumber() {
    final self = this;
    if (self is num) {
      return XPathNumber(self);
    } else if (self is bool) {
      return XPathNumber(self ? 1 : 0);
    } else if (self is String) {
      return XPathNumber(num.tryParse(self) ?? double.nan);
    } else if (self is XmlNode) {
      return self.toXPathString().toXPathNumber();
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathNumber();
    }
    XPathEvaluationException.unsupportedCast(self, 'number');
  }
}
