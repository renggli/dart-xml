import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

typedef XPathDuration = Duration;

extension XPathDurationExtension on Object {
  XPathDuration toXPathDuration() {
    final self = this;
    if (self is Duration) {
      return self;
    } else if (self is XPathString) {
      throw UnimplementedError('Duration from string');
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDuration();
    }
    XPathEvaluationException.unsupportedCast(self, 'duration');
  }
}
