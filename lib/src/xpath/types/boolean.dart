import '../../xml/nodes/node.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';

/// The XPath boolean type.
const xsBoolean = XPathTypeDefinition(
  'xs:boolean',
  matches: _matches,
  cast: _cast,
);

bool _matches(Object item) => item is bool;

XPathSequence _cast(Object item) {
  if (item is bool) return item.toXPathSequence();
  if (item is num) return (item != 0 && !item.isNaN).toXPathSequence();
  if (item is String) {
    if (item == 'true' || item == '1') return true.toXPathSequence();
    if (item == 'false' || item == '0') return false.toXPathSequence();
    return item.isNotEmpty.toXPathSequence();
  }
  if (item is XPathSequence) {
    if (item.isEmpty) return false.toXPathSequence();
    final first = item.first;
    if (first is XmlNode) return true.toXPathSequence();
    return _cast(first);
  }
  return true.toXPathSequence();
}

extension XPathBooleanExtension on Object {
  bool toXPathBoolean({bool strict = false}) {
    final self = this;
    if (self is bool) {
      return self;
    } else if (self is num) {
      return self != 0 && !self.isNaN;
    } else if (self is String) {
      final trimmed = self.trim();
      if (trimmed == 'true' || trimmed == '1') return true;
      if (trimmed == 'false' || trimmed == '0') return false;
      if (strict) {
        throw ArgumentError.value(
          self,
          'item',
          'Cannot cast "$self" to boolean.',
        );
      }
      return self.isNotEmpty;
    } else if (self is XmlNode) {
      return true;
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return false;
      final item = iterator.current;
      if (item is XmlNode) return true;
      if (!iterator.moveNext()) return item.toXPathBoolean(strict: strict);
    }
    throw XPathEvaluationException.unsupportedCast(self, 'boolean');
  }
}
