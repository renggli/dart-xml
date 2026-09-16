import '../exceptions/evaluation_exception.dart';

/// Representation of an XPath untypedAtomic value (xs:untypedAtomic).
class XPathUntypedAtomic implements Comparable<Object> {
  const new(this.value);

  final String value;

  @override
  int compareTo(Object other) {
    if (other is XPathUntypedAtomic) return value.compareTo(other.value);
    if (other is String) return value.compareTo(other);
    throw XPathEvaluationException('Cannot compare $this with $other');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XPathUntypedAtomic && other.value == value) ||
      (other is String && other == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
