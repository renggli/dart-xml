import '../exceptions/evaluation_exception.dart';
import 'boolean.dart';
import 'node.dart';
import 'sequence.dart';
import 'string.dart';

typedef XPathNumber = num;

extension XPathNumberExtension on Object {
  XPathNumber toXPathNumber() {
    final self = this;
    if (self is XPathNumber) {
      return self;
    } else if (self is XPathBoolean) {
      return self ? 1 : 0;
    } else if (self is XPathString) {
      return num.tryParse(self) ?? double.nan;
    } else if (self is XPathNode) {
      return self.toXPathString().toXPathNumber();
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathNumber();
    }
    XPathEvaluationException.unsupportedCast(self, 'number');
  }
}
