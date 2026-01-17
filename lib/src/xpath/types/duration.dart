import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

extension type const XPathDuration(Duration _) implements Duration {}

extension XPathDurationExtension on Object {
  XPathDuration toXPathDuration() {
    final self = this;
    if (self is Duration) {
      return XPathDuration(self);
    } else if (self is String) {
      throw UnimplementedError('Duration from string');
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDuration();
    }
    XPathEvaluationException.unsupportedCast(self, 'duration');
  }
}
