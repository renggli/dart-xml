import '../evaluation/context.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
XPathSequence opHexBinaryEqual(
  XPathContext context,
  XPathSequence value1,
  XPathSequence value2,
) {
  final s1 = value1.firstOrNull?.toXPathString();
  final s2 = value2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  // Assuming canonical string representation (uppercase)
  return XPathSequence.single(s1 == s2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
XPathSequence opHexBinaryLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final s1 = arg1.firstOrNull?.toXPathString();
  final s2 = arg2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1.compareTo(s2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
XPathSequence opHexBinaryGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final s1 = arg1.firstOrNull?.toXPathString();
  final s2 = arg2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1.compareTo(s2) > 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
XPathSequence opBase64BinaryEqual(
  XPathContext context,
  XPathSequence value1,
  XPathSequence value2,
) {
  final s1 = value1.firstOrNull?.toXPathString();
  final s2 = value2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1 == s2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
XPathSequence opBase64BinaryLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final s1 = arg1.firstOrNull?.toXPathString();
  final s2 = arg2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1.compareTo(s2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
XPathSequence opBase64BinaryGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final s1 = arg1.firstOrNull?.toXPathString();
  final s2 = arg2.firstOrNull?.toXPathString();
  if (s1 == null || s2 == null) return XPathSequence.empty;
  return XPathSequence.single(s1.compareTo(s2) > 0);
}
