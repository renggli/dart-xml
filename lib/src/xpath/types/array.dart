import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath array type.
const xsArray = XPathTypeDefinition('array(*)', matches: _matches, cast: _cast);

bool _matches(Object item) => item is List<Object>;

XPathSequence _cast(Object item) => item.toXPathArray().toXPathSequence();

extension XPathArrayExtension on Object {
  List<Object> toXPathArray() {
    final self = this;
    if (self is List<Object>) {
      return self;
    } else if (self is XPathSequence) {
      final item = self.singleOrNull;
      if (item != null) return item.toXPathArray();
    }
    throw XPathEvaluationException.unsupportedCast(self, 'array');
  }
}
