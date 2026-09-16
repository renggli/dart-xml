import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-same-key
XPathSequence opSameKey(XPathSequence left, XPathSequence right) {
  final k1 = left.single.atomize();
  final k2 = right.single.atomize();
  if (k1 is XPathDouble &&
      k1.value.isNaN &&
      k2 is XPathDouble &&
      k2.value.isNaN) {
    return XPathSequence.trueSequence;
  }
  return XPathSequence.single(XPathBoolean(k1 == k2));
}
