import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/array.dart';
import '../types31/map.dart';
import '../types31/sequence.dart';

class MapConstructor implements XPathExpression {
  const MapConstructor(this.entries);

  final List<MapEntry<XPathExpression, XPathExpression>> entries;

  @override
  XPathSequence call(XPathContext context) {
    final map = <Object, Object>{};
    for (final entry in entries) {
      final keySeq = entry.key(context);
      if (keySeq.length != 1) {
        throw XPathEvaluationException.invalidMapKey(keySeq);
      }
      // Keys are atomic
      final key = keySeq.first;
      final value = entry.value(context);
      // Map keys comparison? Standard says "Same key" logic.
      // For now we assume Dart map handles standard types or we need opSameKey.
      // But we just put it in Map. Dart Map uses checking equality.
      // XPath map keys are atoms.
      map[key] = value;
    }
    return XPathSequence.single(XPathMap(map));
  }
}

class SquareArrayConstructor implements XPathExpression {
  const SquareArrayConstructor(this.members);

  final List<XPathExpression> members;

  @override
  XPathSequence call(XPathContext context) {
    final array = <Object>[];
    for (final memberExpr in members) {
      array.add(memberExpr(context));
    }
    return XPathSequence.single(XPathArray(array));
  }
}

class CurlyArrayConstructor implements XPathExpression {
  const CurlyArrayConstructor(this.expression);

  final XPathExpression expression;

  @override
  XPathSequence call(XPathContext context) {
    final sequence = expression(context);
    // Each item in the sequence becomes a member of the array
    final array = sequence.map(XPathSequence.single).toList();
    return XPathSequence.single(XPathArray(array));
  }
}
