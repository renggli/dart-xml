import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import 'string.dart';

extension type const XPathNumber(num _value) implements num {}

extension XPathNumberExtension on Object {
  XPathNumber toXPathNumber() {
    final self = this;
    if (self is num) {
      return XPathNumber(self);
    } else if (self is bool) {
      return XPathNumber(self ? 1 : 0);
    } else if (self is String) {
      return XPathNumber(num.tryParse(self) ?? double.nan);
    } else if (self is XmlNode) {
      return self.toXPathString().toXPathNumber();
    } else if (self is Iterable) {
      if (self.isEmpty) return const XPathNumber(double.nan);
      if (self.length > 1) {
        throw XPathEvaluationException(
          'A sequence of more than one item cannot be cast to a number',
        );
      }
      return (self.first as Object).toXPathNumber();
    }
    throw XPathEvaluationException(
      'Unsupported type for number casting: ${self.runtimeType}',
    );
  }
}
