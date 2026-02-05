import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'item.dart';
import 'sequence.dart';

const xsArray = XPathArrayType();

typedef XPathArray = List<XPathItem>;

class XPathArrayType extends XPathItemType {
  const XPathArrayType();

  @override
  bool matches(Object item) => item is XPathArray;

  @override
  XPathSequence cast(Object item) => item.toXPathArray().toXPathSequence();
}

extension XPathArrayExtension on Object {
  XPathArray toXPathArray() {
    final self = this;
    if (self is XPathArray) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathArray();
    }
    XPathEvaluationException.unsupportedCast(self, 'array');
  }
}
