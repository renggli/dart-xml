import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/boolean.dart';

/// Checks if [sequence] is an instance of [sequenceType].
class InstanceofExpression extends XPathExpression {
  InstanceofExpression(this.sequence, this.sequenceType);

  final XPathExpression sequence;
  final XPathType sequenceType;

  @override
  XPathSequence call(XPathContext context) {
    final result = sequence(context);
    return sequenceType.matches(result).toXPathBoolean().toXPathSequence();
  }
}

/// Casts [sequence] to [singleType].
class CastExpression extends XPathExpression {
  CastExpression(this.sequence, this.singleType);

  final XPathExpression sequence;
  final XPathType singleType;

  @override
  XPathSequence call(XPathContext context) {
    final result = sequence(context);
    return _cast(result, singleType);
  }
}

/// Checks if [sequence] is castable to [singleType].
class CastableExpression extends XPathExpression {
  CastableExpression(this.sequence, this.singleType);

  final XPathExpression sequence;
  final XPathType singleType;

  @override
  XPathSequence call(XPathContext context) {
    try {
      final result = sequence(context);
      _cast(result, singleType);
      return true.toXPathBoolean().toXPathSequence();
    } catch (_) {
      return false.toXPathBoolean().toXPathSequence();
    }
  }
}

/// Treats [sequence] as [sequenceType].
class TreatExpression extends XPathExpression {
  TreatExpression(this.sequence, this.sequenceType);

  final XPathExpression sequence;
  final XPathType sequenceType;

  @override
  XPathSequence call(XPathContext context) {
    final result = sequence(context);
    if (sequenceType.matches(result)) {
      return result;
    }
    throw XPathEvaluationException('Expected $sequenceType, but got $result');
  }
}

XPathSequence _cast(XPathSequence sequence, XPathType type) {
  if (type is XPathSequenceType &&
      type.cardinality == XPathArgumentCardinality.zeroOrOne &&
      sequence.isEmpty) {
    return XPathSequence.empty;
  }
  // For other types, or if sequence is not empty, we typically need a single item for 'cast as'
  // But XPath 3.1 allows some sequence casts maybe?
  // Actually, 'cast as' is usually for atomic types.
  final item = sequence.singleOrNull;
  if (item == null) {
    if (type.matches(sequence)) return sequence;
    throw XPathEvaluationException(
      'Expected exactly one item for cast, but got $sequence',
    );
  }
  return type.cast(item);
}
