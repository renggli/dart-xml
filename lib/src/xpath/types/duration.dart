import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

const xsDuration = XPathDurationType();

typedef XPathDuration = Duration;

class XPathDurationType extends XPathItemType {
  const XPathDurationType();

  @override
  bool matches(Object item) => item is XPathDuration;

  @override
  XPathSequence cast(Object item) => item.toXPathDuration().toXPathSequence();
}

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
