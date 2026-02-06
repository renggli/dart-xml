import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/number.dart';
import '../types/sequence.dart';

class RangeExpression implements XPathExpression {
  const RangeExpression(this.startExpression, this.endExpression);

  final XPathExpression startExpression;
  final XPathExpression endExpression;

  @override
  XPathSequence call(XPathContext context) {
    final startSeq = startExpression(context);
    final endSeq = endExpression(context);

    if (startSeq.isEmpty || endSeq.isEmpty) {
      return XPathSequence.empty;
    }

    final start = xsInteger.cast(startSeq.singleOrNull!);
    final end = xsInteger.cast(endSeq.singleOrNull!);

    if (start > end) {
      return XPathSequence.empty;
    }

    return XPathSequence.range(start, end);
  }
}
