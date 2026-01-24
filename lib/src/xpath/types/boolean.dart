import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'node.dart';
import 'number.dart';
import 'sequence.dart';
import 'string.dart';

typedef XPathBoolean = bool;

extension XPathBooleanExtension on Object {
  XPathBoolean toXPathBoolean() {
    final self = this;
    if (self is XPathBoolean) {
      return self;
    } else if (self is XPathNumber) {
      return self != 0 && !self.isNaN;
    } else if (self is XPathString) {
      return self.isNotEmpty;
    } else if (self is XPathNode) {
      return true;
    } else if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) return false;
      final item = iterator.current;
      if (item is XmlNode) return true;
      if (!iterator.moveNext()) return item.toXPathBoolean();
    }
    XPathEvaluationException.unsupportedCast(self, 'boolean');
  }
}
