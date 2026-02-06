import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath duration type.
const xsDuration = XPathTypeDefinition(
  'xs:duration',
  matches: _matches,
  cast: _cast,
);

bool _matches(Object item) => item is Duration;

XPathSequence _cast(Object item) => item.toXPathDuration().toXPathSequence();

extension XPathDurationExtension on Object {
  Duration toXPathDuration() {
    final self = this;
    if (self is Duration) {
      return self;
    } else if (self is String) {
      // TODO: Implement duration parsing from string
      throw UnimplementedError('Duration from string "$self"');
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDuration();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'duration');
  }
}
