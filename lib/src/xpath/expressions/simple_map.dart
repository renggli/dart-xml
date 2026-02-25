import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';

class SimpleMapExpression implements XPathExpression {
  const SimpleMapExpression(this.expressions);

  final List<XPathExpression> expressions;

  @override
  XPathSequence call(XPathContext context) {
    var result = expressions.first(context);
    for (var i = 1; i < expressions.length; i++) {
      final expression = expressions[i];
      if (result.isEmpty) {
        continue;
      }
      final inputList = result.toList();
      final outputList = <Object>[];
      final innerContext = context.copy();
      innerContext.last = inputList.length;
      for (var j = 0; j < inputList.length; j++) {
        innerContext.item = inputList[j];
        innerContext.position = j + 1;
        final innerResult = expression(innerContext);
        outputList.addAll(innerResult);
      }
      result = XPathSequence(outputList);
    }
    return result;
  }
}
