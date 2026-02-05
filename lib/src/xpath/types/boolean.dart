import '../../xml/nodes/node.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import 'node.dart';
import 'number.dart';
import 'sequence.dart';
import 'string.dart';

const xsBoolean = XPathBooleanType();

typedef XPathBoolean = bool;

class XPathBooleanType extends XPathItemType {
  const XPathBooleanType();

  @override
  bool matches(Object item) => item is XPathBoolean;

  @override
  XPathSequence cast(Object item) =>
      item.toXPathBoolean(strict: true).toXPathSequence();
}

extension XPathBooleanExtension on Object {
  XPathBoolean toXPathBoolean({bool strict = false}) {
    final self = this;
    if (self is XPathBoolean) {
      return self;
    } else if (self is XPathNumber) {
      return self != 0 && !self.isNaN;
    } else if (self is XPathString) {
      final trimmed = self.trim();
      if (trimmed == 'true' || trimmed == '1') return true;
      if (trimmed == 'false' || trimmed == '0') return false;
      if (strict) {
        throw XPathEvaluationException.unsupportedCast(self, 'boolean');
      }
      return self.isNotEmpty;
    } else if (self is XPathNode) {
      return true;
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return false;
      final item = iterator.current;
      if (item is XmlNode) return true;
      if (!iterator.moveNext()) return item.toXPathBoolean(strict: strict);
    }
    XPathEvaluationException.unsupportedCast(self, 'boolean');
  }
}
