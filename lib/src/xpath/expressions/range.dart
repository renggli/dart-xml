import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/sequence.dart';

class RangeExpression implements XPathExpression {
  const new(this.startExpression, this.endExpression);

  final XPathExpression startExpression;
  final XPathExpression endExpression;

  @override
  XPathSequence call(XPathContext context) {
    final startSeq = startExpression(context);
    final endSeq = endExpression(context);
    if (startSeq.isEmpty || endSeq.isEmpty) {
      return XPathSequence.empty;
    }
    final start = _toInteger(startSeq);
    final end = _toInteger(endSeq);
    if (start.value > end.value) {
      return XPathSequence.empty;
    }
    return XPathSequence.range(start, end);
  }

  static XPathInteger _toInteger(XPathSequence seq) {
    final list = seq.atomize().toList();
    if (list.length != 1) {
      throw XPathEvaluationException(
        'Range expression operands must be single integer items [err:XPTY0004]',
      );
    }
    final item = list.single;
    if (item is XPathInteger) return item;
    if (item is XPathUntypedAtomic) {
      final parsed = BigInt.tryParse(item.stringValue.trim());
      if (parsed != null) return XPathInteger(parsed);
      throw XPathEvaluationException(
        'Cannot convert untypedAtomic "${item.stringValue}" to xs:integer [err:FORG0001]',
      );
    }
    throw XPathEvaluationException(
      'Range expression operand must be an integer, got ${item.type} [err:XPTY0004]',
    );
  }
}
