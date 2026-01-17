import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathDateTime(DateTime _) implements DateTime {}

extension XPathDateTimeExtension on Object {
  XPathDateTime toXPathDateTime() {
    final self = this;
    if (self is DateTime) {
      return XPathDateTime(self);
    } else if (self is String) {
      final parsed = DateTime.tryParse(self);
      if (parsed != null) {
        return XPathDateTime(parsed);
      }
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDateTime();
    }
    XPathEvaluationException.unsupportedCast(self, 'dateTime');
  }
}
