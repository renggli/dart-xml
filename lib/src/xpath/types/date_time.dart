import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath dateTime type.
const xsDateTime = XPathTypeDefinition(
  'xs:dateTime',
  matches: _matches,
  cast: _cast,
);

bool _matches(Object item) => item is DateTime;

XPathSequence _cast(Object item) => item.toXPathDateTime().toXPathSequence();

extension XPathDateTimeExtension on Object {
  DateTime toXPathDateTime() {
    final self = this;
    if (self is DateTime) {
      return self;
    } else if (self is String) {
      final parsed = DateTime.tryParse(self);
      if (parsed != null) {
        return parsed;
      }
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathDateTime();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'dateTime');
  }
}
