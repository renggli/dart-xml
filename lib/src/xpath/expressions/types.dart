import '../evaluation/cardinality.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/casting_matrix.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

/// Checks if [expression] is an instance of [type].
class InstanceofExpression implements XPathExpression {
  const new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType type;

  @override
  XPathSequence call(XPathContext context) {
    final value = expression(context);
    final result = type.matchesSequence(value);
    return result ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
}

void _validateCastTargetType(XPathType type) {
  final target = type is XPathSequenceType ? type.itemType : type;
  if (!target.isAtomic ||
      target.name == 'xs:anyAtomicType' ||
      target.name == 'xs:NOTATION') {
    throw XPathEvaluationException(
      XPathErrorCode.XPST0080,
      'Target type cannot be ${target.name}',
    );
  }
}

/// Casts [expression] to [type].
class CastExpression implements XPathExpression {
  const new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType type;

  @override
  XPathSequence call(XPathContext context) {
    _validateCastTargetType(type);
    final raw = expression(context);
    final sequence = raw.atomize().toList();
    if (type is XPathSequenceType) {
      final seqType = type as XPathSequenceType;
      if (sequence.isEmpty) {
        if (seqType.cardinality == XPathCardinality.zeroOrOne) {
          return XPathSequence.empty;
        }
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Cannot cast empty sequence to required type ${seqType.itemType}',
        );
      }
      if (sequence.length != 1) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Cannot cast sequence of length ${sequence.length} to ${type.name}',
        );
      }
      return XPathSequence.single(
        castAtomic(sequence.single, seqType.itemType),
      );
    }
    if (sequence.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot cast sequence of length ${sequence.length} to ${type.name}',
      );
    }
    return XPathSequence.single(castAtomic(sequence.single, type));
  }
}

/// Checks if [expression] is castable to [type].
class CastableExpression implements XPathExpression {
  const new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType type;

  @override
  XPathSequence call(XPathContext context) {
    _validateCastTargetType(type);
    final raw = expression(context);
    final sequence = raw.atomize().toList();
    try {
      if (type is XPathSequenceType) {
        final seqType = type as XPathSequenceType;
        if (sequence.isEmpty) {
          return seqType.cardinality == XPathCardinality.zeroOrOne
              ? XPathSequence.trueSequence
              : XPathSequence.falseSequence;
        }
        if (sequence.length != 1) return XPathSequence.falseSequence;
        castAtomic(sequence.single, seqType.itemType);
        return XPathSequence.trueSequence;
      }
      if (sequence.length != 1) return XPathSequence.falseSequence;
      castAtomic(sequence.single, type);
      return XPathSequence.trueSequence;
    } catch (_) {
      return XPathSequence.falseSequence;
    }
  }
}

/// Treats [expression] as [type].
class TreatExpression implements XPathExpression {
  const new(this.expression, this.type);

  final XPathExpression expression;
  final XPathType type;

  @override
  XPathSequence call(XPathContext context) {
    final result = expression(context);
    if (type.matchesSequence(result)) return result;
    throw XPathEvaluationException(
      XPathErrorCode.XPDY0050,
      'Expected $type, but got $result',
    );
  }
}
