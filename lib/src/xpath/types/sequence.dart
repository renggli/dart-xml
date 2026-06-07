import '../definitions/cardinality.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/sequence.dart';
import 'any.dart';

/// The XPath empty sequence type.
const xsEmptySequence = _XPathEmptySequenceType();

class _XPathEmptySequenceType extends XPathType<XPathSequence<Never>> {
  const _XPathEmptySequenceType();

  @override
  String get name => 'empty-sequence()';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) => value is XPathSequence && value.isEmpty;

  @override
  XPathSequence<Never> cast(Object value) {
    if (matches(value)) return XPathSequence.empty;
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath sequence type.
const xsSequence = XPathSequenceType(type: xsAny);

class XPathSequenceType<T extends Object> extends XPathType<XPathSequence<T>> {
  const XPathSequenceType({
    required this.type,
    this.cardinality = XPathCardinality.zeroOrMore,
  });

  /// The type of the values in the sequence.
  final XPathType<T> type;

  /// The cardinality of the sequence.
  final XPathCardinality cardinality;

  @override
  String get name => '$type$cardinality';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) =>
      value is XPathSequence<T> &&
      value.hasCardinality(cardinality) &&
      (identical(type, xsAny) || value.every(type.matches));

  @override
  XPathSequence<T> cast(Object value) {
    if (value is XPathSequence) {
      if (value.hasCardinality(cardinality)) {
        return XPathSequence.cached(value.map(type.cast));
      }
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    return XPathSequence.single(type.cast(value));
  }
}
