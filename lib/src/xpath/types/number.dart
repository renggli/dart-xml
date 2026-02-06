import '../../xml/nodes/node.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'string.dart';

/// The XPath numeric type.
const xsNumber = XPathTypeDefinition(
  'xs:numeric',
  matches: _matches,
  cast: _cast,
);

/// Alias for [xsNumber].
const xsNumeric = xsNumber;

bool _matches(Object item) => item is num;

XPathSequence _cast(Object item) =>
    item.toXPathNumber(strict: true).toXPathSequence();

extension XPathNumberExtension on Object {
  num toXPathNumber({bool strict = false}) {
    final self = this;
    if (self is num) {
      return self;
    } else if (self is bool) {
      return self ? 1 : 0;
    } else if (self is String) {
      if (self == 'INF') return double.infinity;
      if (self == '-INF') return double.negativeInfinity;
      final result = num.tryParse(self);
      if (result == null) {
        if (strict) {
          throw XPathEvaluationException.unsupportedCast(self, 'number');
        }
        return double.nan;
      }
      return result;
    } else if (self is XmlNode) {
      return self.toXPathString().toXPathNumber(strict: strict);
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathNumber(strict: strict);
    }
    throw XPathEvaluationException.unsupportedCast(self, 'number');
  }
}
