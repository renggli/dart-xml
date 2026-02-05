import '../types/item.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-same-key
XPathSequence opSameKey(XPathSequence left, XPathSequence right) {
  final k1 = left.toAtomicValue();
  final k2 = right.toAtomicValue();
  // TODO: Handle timezone, etc.
  if (k1 is num && k1.isNaN && k2 is num && k2.isNaN) {
    return XPathSequence.trueSequence;
  }
  return XPathSequence.single(k1 == k2);
}
