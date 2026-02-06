import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';

class MapConstructor implements XPathExpression {
  const MapConstructor(this.entries);

  final List<MapEntry<XPathExpression, XPathExpression>> entries;

  @override
  XPathSequence call(XPathContext context) {
    final map = <Object, Object>{};
    for (final entry in entries) {
      final key = entry.key(context).toAtomicValue();
      if (key is XPathSequence) {
        throw XPathEvaluationException(
          'map:constructor key must be exactly one item, but got $key',
        );
      }
      map[key] = entry.value(context).toAtomicValue();
    }
    return XPathSequence.single(map);
  }
}

class SquareArrayConstructor implements XPathExpression {
  const SquareArrayConstructor(this.members);

  final List<XPathExpression> members;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    members.map((member) => member(context).toAtomicValue()).toList(),
  );
}

class CurlyArrayConstructor implements XPathExpression {
  const CurlyArrayConstructor(this.expression);

  final XPathExpression expression;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    expression(
      context,
    ).expand((member) => member is XPathSequence ? member : [member]).toList(),
  );
}
