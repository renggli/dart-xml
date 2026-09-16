import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

class ContextItemExpression implements XPathExpression {
  const new();

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (item is XmlNode) return XPathSequence.single(XPathNode(item));
    if (item is XPathItem) return XPathSequence.single(item);
    if (item is XPathSequence) return item;
    throw XPathEvaluationException('Context item is undefined [err:XPDY0002]');
  }
}

class VariableExpression implements XPathExpression {
  const new(this.name);

  final String name;

  @override
  XPathSequence call(XPathContext context) {
    final val = context.getVariable(name);
    if (val is XPathSequence) return val;
    if (val is XPathItem) return XPathSequence.single(val);
    if (val is Map) {
      return XPathSequence.single(
        XPathMap({
          for (final e in val.entries)
            (XPathSequence.toItem(e.key as Object)
                as XPathAtomic): e.value is XPathSequence
                ? e.value as XPathSequence
                : XPathSequence.from([e.value]),
        }),
      );
    }
    if (val is List) {
      return XPathSequence.single(
        XPathArray([
          for (final item in val)
            if (item is XPathSequence) item else XPathSequence.from([item]),
        ]),
      );
    }
    try {
      return XPathSequence.from([val]);
    } catch (_) {
      throw XPathEvaluationException(
        'Variable \$$name is not an XPath value: $val',
      );
    }
  }
}

class LiteralExpression implements XPathExpression {
  const new(this.value);

  final XPathSequence value;

  @override
  XPathSequence call(XPathContext context) => value;
}
