import 'sequence.dart';

typedef XPathItem = Object;

extension XPathItemExtension on Object {
  XPathItem toXPathItem() {
    final self = this;
    if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) {
        return XPathSequence.empty;
      }
      final value = iterator.current;
      if (!iterator.moveNext()) {
        return value;
      }
      throw Exception('Sequence has more than one value');
    } else {
      return self;
    }
  }

  XPathItem toAtomicValue() {
    final self = this;
    if (self is XPathSequence) {
      final iterator = self.iterator;
      if (!iterator.moveNext()) {
        return XPathSequence.empty;
      }
      final value = iterator.current;
      if (!iterator.moveNext()) {
        return value;
      }
      throw Exception('Sequence has more than one value');
    } else {
      return self;
    }
  }
}
