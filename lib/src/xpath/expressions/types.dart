import '../definitions/cardinality.dart';
import '../definitions/type.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';
import '../values/sequence.dart';

/// Checks if [expression] is an instance of [type].
class InstanceofExpression extends XPathExpression {
  new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    final value = expression(context);
    final result = type.matches(value);
    return XPathSequence.single(result);
  }
}

/// Casts [expression] to [type].
class CastExpression extends XPathExpression {
  new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    final sequence = expression(context).atomize();
    if (type is XPathSequenceType) {
      final seqType = type as XPathSequenceType;
      final list = <Object>[];
      for (final item in sequence) {
        list.add(seqType.type.cast(item));
      }
      final resultSeq = XPathSequence(list);
      if (!resultSeq.hasCardinality(seqType.cardinality)) {
        throw XPathEvaluationException.unsupportedCast(type, sequence);
      }
      return resultSeq;
    }
    final item = sequence.singleOrNull;
    if (item == null) {
      throw XPathEvaluationException.unsupportedCast(type, sequence);
    }
    return XPathSequence.single(type.cast(item));
  }
}

/// Checks if [expression] is castable to [type].
class CastableExpression extends XPathExpression {
  new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    final sequence = expression(context).atomize();
    try {
      if (type is XPathSequenceType) {
        final seqType = type as XPathSequenceType;
        var count = 0;
        for (final item in sequence) {
          count++;
          seqType.type.cast(item);
        }
        if (count == 0 &&
            (seqType.cardinality == XPathCardinality.exactlyOne ||
                seqType.cardinality == XPathCardinality.oneOrMore)) {
          return XPathSequence.falseSequence;
        }
        if (count > 1 &&
            (seqType.cardinality == XPathCardinality.exactlyOne ||
                seqType.cardinality == XPathCardinality.zeroOrOne)) {
          return XPathSequence.falseSequence;
        }
        return XPathSequence.trueSequence;
      }
      final item = sequence.singleOrNull;
      if (item == null) return XPathSequence.falseSequence;
      type.cast(item);
      return XPathSequence.trueSequence;
    } catch (_) {
      return XPathSequence.falseSequence;
    }
  }
}

/// Treats [expression] as [type].
class TreatExpression extends XPathExpression {
  new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType<Object> type;

  @override
  XPathSequence call(XPathContext context) {
    final result = expression(context);
    if (type.matches(result)) return result;
    throw XPathEvaluationException('Expected $type, but got $result');
  }
}
