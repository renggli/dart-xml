import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'item.dart';
import 'sequence.dart';

const xsMap = XPathMapType();

typedef XPathMap = Map<XPathItem, XPathItem>;

class XPathMapType extends XPathItemType {
  const XPathMapType();

  @override
  bool matches(Object item) => item is XPathMap;

  @override
  XPathSequence cast(Object item) => item.toXPathMap().toXPathSequence();
}

extension XPathMapExtension on Object {
  XPathMap toXPathMap() {
    final self = this;
    if (self is XPathMap) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathMap();
    }
    XPathEvaluationException.unsupportedCast(self, 'map');
  }
}
