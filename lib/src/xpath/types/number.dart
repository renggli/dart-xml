import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'boolean.dart';
import 'node.dart';
import 'sequence.dart';
import 'string.dart';

const xsNumber = XPathNumberType();

typedef XPathNumber = num;

class XPathNumberType extends XPathItemType {
  const XPathNumberType();

  @override
  bool matches(Object item) => item is XPathNumber;

  @override
  XPathSequence cast(Object item) =>
      item.toXPathNumber(strict: true).toXPathSequence();
}

extension XPathNumberExtension on Object {
  XPathNumber toXPathNumber({bool strict = false}) {
    final self = this;
    if (self is XPathNumber) {
      return self;
    } else if (self is XPathBoolean) {
      return self ? 1 : 0;
    } else if (self is XPathString) {
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
    } else if (self is XPathNode) {
      return self.toXPathString().toXPathNumber(strict: strict);
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathNumber(strict: strict);
    }
    throw XPathEvaluationException.unsupportedCast(self, 'number');
  }
}
