import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath map type.
const xsMap = XPathTypeDefinition('map(*)', matches: _matches, cast: _cast);

bool _matches(Object item) => item is Map<Object, Object>;

XPathSequence _cast(Object item) => item.toXPathMap().toXPathSequence();

extension XPathMapExtension on Object {
  Map<Object, Object> toXPathMap() {
    final self = this;
    if (self is Map<Object, Object>) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathMap();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'map');
  }
}
