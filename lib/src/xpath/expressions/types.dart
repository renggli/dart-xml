import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/boolean.dart';
import '../types/sequence.dart';

/// Checks if [sequence] is an instance of [sequenceType].
class InstanceofExpression extends XPathExpression {
  InstanceofExpression(this.sequence, this.sequenceType);

  final XPathExpression sequence;
  final XPathSequenceType sequenceType;

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
  final XPathSequenceType singleType;

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
  final XPathSequenceType singleType;

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
  final XPathSequenceType sequenceType;

  @override
  XPathSequence call(XPathContext context) {
    final result = sequence(context);
    if (sequenceType.matches(result)) {
      return result;
    }
    throw XPathEvaluationException('Expected $sequenceType, but got $result');
  }
}

XPathSequence _cast(XPathSequence sequence, XPathSequenceType type) {
  if (type.cardinality == XPathArgumentCardinality.zeroOrOne &&
      sequence.isEmpty) {
    return XPathSequence.empty;
  }
  final item = sequence.singleOrNull;
  if (item == null) {
    throw XPathEvaluationException(
      'Expected exactly one item, but got $sequence',
    );
  }
  return _castItem(item, type.itemType);
}

XPathSequence _castItem(Object item, XPathItemType type) => type.cast(item);
