import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/sequence.dart';

class MapConstructor implements XPathExpression {
  const new(this.entries);

  final List<MapEntry<XPathExpression, XPathExpression>> entries;

  @override
  XPathSequence call(XPathContext context) {
    final map = <XPathAtomic, XPathSequence>{};
    for (final entry in entries) {
      final keySeq = entry.key(context).atomize().toList();
      if (keySeq.length != 1) {
        throw XPathEvaluationException(
          'map:constructor key must be exactly one atomic item [err:XPTY0004]',
        );
      }
      final key = keySeq.single;
      for (final existingKey in map.keys) {
        if (XPathMap.sameKey(existingKey, key)) {
          throw XPathEvaluationException(
            'Duplicate key in map constructor: $key [err:XQDY0137]',
          );
        }
      }
      map[key] = entry.value(context);
    }
    return XPathSequence.single(XPathMap(map));
  }
}

class SquareArrayConstructor implements XPathExpression {
  const new(this.members);

  final List<XPathExpression> members;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    XPathArray(members.map((member) => member(context)).toList()),
  );
}

class CurlyArrayConstructor implements XPathExpression {
  const new(this.expression);

  final XPathExpression expression;

  @override
  XPathSequence call(XPathContext context) {
    final seq = expression(context);
    return XPathSequence.single(
      XPathArray(seq.map(XPathSequence.single).toList()),
    );
  }
}
