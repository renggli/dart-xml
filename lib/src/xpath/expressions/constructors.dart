import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/array.dart';
import '../types/atomic.dart';
import '../types/map.dart';
import '../types/sequence.dart';

class MapConstructor implements XPathExpression {
  const MapConstructor(this.entries);

  final List<MapEntry<XPathExpression, XPathExpression>> entries;

  @override
  XPathSequence call(XPathContext context) {
    final map = <Object, Object>{};
    for (final entry in entries) {
      final key = XPathEvaluationException.extractExactlyOne(
        'map:constructor',
        'key',
        entry.key(context),
      );
      map[key] = entry.value(context).toAtomicValue();
    }
    return XPathSequence.single(XPathMap(map));
  }
}

class SquareArrayConstructor implements XPathExpression {
  const SquareArrayConstructor(this.members);

  final List<XPathExpression> members;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    XPathArray(
      members.map((member) {
        final val = member(context);
        return val.length == 1 ? val.first : val;
      }).toList(),
    ),
  );
}

class CurlyArrayConstructor implements XPathExpression {
  const CurlyArrayConstructor(this.expression);

  final XPathExpression expression;

  @override
  XPathSequence call(XPathContext context) => XPathSequence.single(
    XPathArray(
      expression(context)
          .expand((member) => member is XPathSequence ? member : [member])
          .toList(),
    ),
  );
}
