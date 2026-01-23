import 'sequence.dart';

extension type const XPathAtomicValue(Object _) implements Object {}

extension XPathAtomicValueExtension on Object {
  XPathAtomicValue toAtomicValue() {
    final self = this;
    if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) {
        const XPathAtomicValue(XPathSequence.empty);
      }
      final value = iterator.current;
      if (!iterator.moveNext()) {
        return XPathAtomicValue(value);
      }
      throw Exception('Sequence has more than one value');
    } else {
      return XPathAtomicValue(self);
    }
  }
}
