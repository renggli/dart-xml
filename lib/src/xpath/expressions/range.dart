import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

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

    final start = startSeq.toXPathNumber().toInt();
    final end = endSeq.toXPathNumber().toInt();

    if (start > end) {
      return XPathSequence.empty;
    }

    return XPathSequence.range(start, end);
  }
}
