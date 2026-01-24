import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

typedef XPathDateTime = DateTime;

extension XPathDateTimeExtension on Object {
  XPathDateTime toXPathDateTime() {
    final self = this;
    if (self is XPathDateTime) {
      return self;
    } else if (self is XPathString) {
      final parsed = DateTime.tryParse(self);
      if (parsed != null) {
        return parsed;
      }
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDateTime();
    }
    XPathEvaluationException.unsupportedCast(self, 'dateTime');
  }
}
