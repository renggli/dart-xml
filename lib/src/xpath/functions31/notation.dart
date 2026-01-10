import '../evaluation/context.dart';
import '../types31/sequence.dart';

import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION-equal
XPathSequence opNotationEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final s1 = arg1.firstOrNull?.toXPathString();
  final s2 = arg2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1 == s2);
}
