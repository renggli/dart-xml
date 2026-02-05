import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

const xsDateTime = XPathDateTimeType();

typedef XPathDateTime = DateTime;

class XPathDateTimeType extends XPathItemType {
  const XPathDateTimeType();

  @override
  bool matches(Object item) => item is XPathDateTime;

  @override
  XPathSequence cast(Object item) => item.toXPathDateTime().toXPathSequence();
}

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
